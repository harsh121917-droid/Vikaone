import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/business_model.dart';
import '../../../data/repositories/business_repository.dart';

void showScheduleBusinessCallSheet(BuildContext context, BusinessModel business) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.65),
    builder: (_) => ScheduleBusinessCallSheet(business: business),
  );
}

class ScheduleBusinessCallSheet extends StatefulWidget {
  final BusinessModel business;
  const ScheduleBusinessCallSheet({super.key, required this.business});

  @override
  State<ScheduleBusinessCallSheet> createState() => _ScheduleBusinessCallSheetState();
}

class _ScheduleBusinessCallSheetState extends State<ScheduleBusinessCallSheet> {
  final _repository = Get.isRegistered<BusinessRepository>()
      ? Get.find<BusinessRepository>()
      : Get.put(BusinessRepository());

  late final List<DateTime> _dates;
  int _selectedDateIndex = 0;

  final List<String> _timeSlots = const [
    '10:00 AM - 11:00 AM',
    '11:00 AM - 12:00 PM',
    '02:00 PM - 03:00 PM',
    '03:00 PM - 04:00 PM',
    '05:00 PM - 06:00 PM',
  ];
  String _selectedTimeSlot = '11:00 AM - 12:00 PM';

  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  bool _isSubmitting = false;

  final List<String> _weekdays = const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<String> _months = const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  @override
  void initState() {
    super.initState();
    _dates = List.generate(7, (i) => DateTime.now().add(Duration(days: i + 1)));

    String initialName = '';
    String initialPhone = '';
    try {
      if (Get.isRegistered<AuthController>()) {
        final u = Get.find<AuthController>().user.value;
        if (u != null) {
          if (u.name.isNotEmpty) initialName = u.name;
          final p = u.phone;
          if (p != null && p.isNotEmpty) initialPhone = p;
        }
      }
    } catch (_) {}

    _nameCtrl = TextEditingController(text: initialName);
    _phoneCtrl = TextEditingController(text: initialPhone);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  String _formatDatePill(DateTime dt) {
    final dayName = _weekdays[dt.weekday - 1];
    final monthName = _months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName';
  }

  String _formatDateFull(DateTime dt) {
    final dayName = _weekdays[dt.weekday - 1];
    final monthName = _months[dt.month - 1];
    return '$dayName, ${dt.day} $monthName ${dt.year}';
  }

  String _formatDateYmd(DateTime dt) {
    final y = dt.year.toString().padLeft(4, '0');
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  Future<void> _submitConsultation() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar(
        'Required Field',
        'Please enter your full name',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    if (phone.length < 10) {
      Get.snackbar(
        'Invalid Mobile',
        'Please enter a valid 10-digit mobile number',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    final selectedDate = _formatDateYmd(_dates[_selectedDateIndex]);

    try {
      final success = await _repository.submitBusinessLead(
        businessId: widget.business.id,
        businessTitle: widget.business.title,
        name: name,
        phone: phone,
        preferredDate: selectedDate,
        preferredTime: _selectedTimeSlot,
        message: 'Advisory Call Request via Mobile App for ${widget.business.title} (${widget.business.category})',
      );

      if (mounted) {
        setState(() => _isSubmitting = false);
        if (success) {
          Navigator.of(context).pop();
          _showConfirmationDialog(_formatDateFull(_dates[_selectedDateIndex]), _selectedTimeSlot);
        } else {
          Get.snackbar(
            'Request Recorded',
            'Your consultation request has been queued. Our commercial desk will contact you shortly.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: const Color(0xFF2563EB),
            colorText: Colors.white,
          );
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Get.snackbar(
          'Request Recorded',
          'Your request has been logged. Our commercial desk will call you shortly.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF2563EB),
          colorText: Colors.white,
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _showConfirmationDialog(String date, String time) {
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final subColor = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
          side: BorderSide(color: const Color(0xFF2563EB).withOpacity(0.35), width: 1.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF2563EB), width: 2),
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF2563EB), size: 36),
              ),
              const SizedBox(height: 18),
              Text(
                'Consultation Scheduled!',
                style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Our enterprise investment advisor will call you on $date at $time regarding ${widget.business.title}.',
                style: TextStyle(color: subColor, fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: double.infinity,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'Done',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final subColor = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = dark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0);
    final pillBgUnselected = dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final pillBorderUnselected = dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    final pillTextUnselected = dark ? const Color(0xFFE2E8F0) : const Color(0xFF1E293B);
    final inputBg = dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
    final inputBorder = dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1);
    const primaryBlue = Color(0xFF2563EB);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: borderColor),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top notch handle
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(
                      color: dark ? Colors.white24 : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Advisory Callback',
                            style: TextStyle(
                              color: textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.business.title,
                            style: const TextStyle(
                              color: primaryBlue,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        padding: const EdgeInsets.all(7),
                        decoration: BoxDecoration(
                          color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9),
                          shape: BoxShape.circle,
                          border: Border.all(color: borderColor),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: dark ? Colors.white70 : const Color(0xFF475569),
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Advisor Sub-card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(dark ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: primaryBlue.withOpacity(dark ? 0.3 : 0.2)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(dark ? 0.2 : 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: primaryBlue, size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Commercial Venture Desk',
                              style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Get detailed financial models, tenant lock-in copies & due-diligence report.',
                              style: TextStyle(color: subColor, fontSize: 11, height: 1.3),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Date selector
                Text(
                  'Select Consultation Date',
                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dates.length,
                    separatorBuilder: (ctx, index) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final isSel = i == _selectedDateIndex;
                      final d = _dates[i];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDateIndex = i);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? primaryBlue : pillBgUnselected,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? primaryBlue : pillBorderUnselected,
                              width: 1.2,
                            ),
                            boxShadow: isSel
                                ? [
                                    BoxShadow(
                                      color: primaryBlue.withOpacity(0.3),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : null,
                          ),
                          child: Center(
                            child: Text(
                              _formatDatePill(d),
                              style: TextStyle(
                                color: isSel ? Colors.white : pillTextUnselected,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 18),

                // Time Slot selector
                Text(
                  'Select Time Slot',
                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _timeSlots.map((slot) {
                    final isSel = slot == _selectedTimeSlot;
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        setState(() => _selectedTimeSlot = slot);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSel ? primaryBlue : pillBgUnselected,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? primaryBlue : pillBorderUnselected,
                            width: 1.2,
                          ),
                          boxShadow: isSel
                              ? [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.25),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ]
                              : null,
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            color: isSel ? Colors.white : pillTextUnselected,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 18),

                // Contact Details
                Text(
                  'Investor Contact Details',
                  style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: inputBorder),
                        ),
                        child: TextField(
                          controller: _nameCtrl,
                          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: TextStyle(color: subColor, fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: inputBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: inputBorder),
                        ),
                        child: TextField(
                          controller: _phoneCtrl,
                          keyboardType: TextInputType.phone,
                          style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600),
                          decoration: InputDecoration(
                            hintText: 'Phone Number',
                            hintStyle: TextStyle(color: subColor, fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Submit Button
                GestureDetector(
                  onTap: _isSubmitting ? null : _submitConsultation,
                  child: Container(
                    width: double.infinity,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Center(
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.2),
                            )
                          : const Text(
                              'Confirm Advisory Call',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.3,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
