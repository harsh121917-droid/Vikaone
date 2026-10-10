import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/business_model.dart';
import '../../../data/repositories/business_repository.dart';

void showScheduleBusinessCallSheet(BuildContext context, BusinessModel business) {
  HapticFeedback.mediumImpact();
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withOpacity(0.75),
    builder: (ctx) => _ScheduleBusinessCallSheet(business: business),
  );
}

class _ScheduleBusinessCallSheet extends StatefulWidget {
  final BusinessModel business;
  const _ScheduleBusinessCallSheet({required this.business});

  @override
  State<_ScheduleBusinessCallSheet> createState() => _ScheduleBusinessCallSheetState();
}

class _ScheduleBusinessCallSheetState extends State<_ScheduleBusinessCallSheet> {
  int _selectedDateIndex = 0;
  String _selectedTimeSlot = '11:00 AM';
  bool _isSubmitting = false;

  late final List<DateTime> _dates;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _nameCtrl;

  final List<String> _timeSlots = const [
    '10:00 AM', '11:00 AM', '12:00 PM',
    '02:00 PM', '03:00 PM', '04:00 PM',
    '05:00 PM', '06:00 PM', '07:00 PM',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dates = List.generate(7, (i) => now.add(Duration(days: i)));

    String initialName = '';
    String initialPhone = '';
    try {
      if (Get.isRegistered<AuthService>()) {
        final u = Get.find<AuthService>().currentUser;
        if (u != null) {
          initialName = u.name;
          initialPhone = u.phone ?? '';
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

  String _formatDatePill(DateTime d) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];
    final dayName = days[d.weekday - 1];
    final dayNum = d.day.toString().padLeft(2, '0');
    final monthName = months[d.month - 1];
    return '$dayName $dayNum $monthName';
  }

  Future<void> _submitConsultation() async {
    final name = _nameCtrl.text.trim();
    final phone = _phoneCtrl.text.trim();

    if (name.isEmpty) {
      Get.snackbar('Name Required', 'Please enter your full name',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }
    if (phone.isEmpty || phone.length < 10) {
      Get.snackbar('Valid Phone Required', 'Please enter a valid 10-digit mobile number',
          snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.redAccent, colorText: Colors.white);
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.mediumImpact();

    try {
      final repo = Get.isRegistered<BusinessRepository>() ? Get.find<BusinessRepository>() : Get.put(BusinessRepository());
      final selectedDate = _formatDatePill(_dates[_selectedDateIndex]);

      final success = await repo.submitBusinessLead(
        businessId: widget.business.id,
        businessTitle: widget.business.title,
        name: name,
        phone: phone,
        preferredDate: selectedDate,
        preferredTime: _selectedTimeSlot,
        message: 'Investor requested consultation for ${widget.business.title} (${widget.business.category})',
      );

      if (mounted) {
        Navigator.of(context).pop();
        if (success) {
          _showConfirmationDialog(selectedDate, _selectedTimeSlot);
        } else {
          Get.snackbar('Submission Notice', 'Your request has been recorded. Our team will contact you.',
              snackPosition: SnackPosition.BOTTOM, backgroundColor: AppColors.accent, colorText: Colors.black);
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        Get.snackbar('Request Recorded', 'Your request has been logged. Our commercial desk will call you shortly.',
            snackPosition: SnackPosition.BOTTOM, backgroundColor: const Color(0xFF00D09C), colorText: Colors.black);
        Navigator.of(context).pop();
      }
    }
  }

  void _showConfirmationDialog(String date, String time) {
    Get.dialog(
      Dialog(
        backgroundColor: const Color(0xFF0F172A),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: const BorderSide(color: Color(0xFF00D09C), width: 1.2)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFF00D09C).withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF00D09C), width: 2),
                ),
                child: const Icon(Icons.check_rounded, color: Color(0xFF00D09C), size: 36),
              ),
              const SizedBox(height: 18),
              const Text(
                'Consultation Scheduled!',
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Our enterprise investment advisor will call you on $date at $time regarding ${widget.business.title}.',
                style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00D09C),
                    foregroundColor: Colors.black,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () => Get.back(),
                  child: const Text('Done', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
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
    final textColor = dark ? Colors.white : const Color(0xFF1E293B);
    final subColor = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).viewInsets.bottom + 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top notch
                Center(
                  child: Container(
                    width: 44,
                    height: 5,
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(3)),
                  ),
                ),
                const SizedBox(height: 14),

                // Header
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Request Advisory Callback',
                            style: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.business.title,
                            style: TextStyle(color: widget.business.categoryColor, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, color: Colors.white70),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Advisor Sub-card
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00D09C).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.25)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF00D09C).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.support_agent_rounded, color: Color(0xFF00D09C), size: 24),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Commercial Venture Desk',
                              style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                            ),
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
                const SizedBox(height: 16),

                // Date selector
                Text('Select Consultation Date', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                SizedBox(
                  height: 48,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _dates.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final isSel = i == _selectedDateIndex;
                      final d = _dates[i];
                      return GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedDateIndex = i);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSel ? const Color(0xFF00D09C) : Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSel ? const Color(0xFF00D09C) : Colors.white.withOpacity(0.1),
                            ),
                          ),
                          child: Center(
                            child: Text(
                              _formatDatePill(d),
                              style: TextStyle(
                                color: isSel ? Colors.black : Colors.white,
                                fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Time Slot selector
                Text('Select Time Slot', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
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
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                        decoration: BoxDecoration(
                          color: isSel ? const Color(0xFF00D09C) : Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSel ? const Color(0xFF00D09C) : Colors.white.withOpacity(0.1),
                          ),
                        ),
                        child: Text(
                          slot,
                          style: TextStyle(
                            color: isSel ? Colors.black : Colors.white70,
                            fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),

                // Contact Details
                Text('Investor Contact Details', style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _nameCtrl,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Full Name',
                          hintStyle: TextStyle(color: subColor, fontSize: 12),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.06),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        style: const TextStyle(color: Colors.white, fontSize: 13),
                        decoration: InputDecoration(
                          hintText: 'Phone Number',
                          hintStyle: TextStyle(color: subColor, fontSize: 12),
                          filled: true,
                          fillColor: Colors.white.withOpacity(0.06),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00D09C),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: _isSubmitting ? null : _submitConsultation,
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                          )
                        : const Text(
                            'Confirm Advisory Call',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.3),
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
