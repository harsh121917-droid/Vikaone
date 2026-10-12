import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../routes/app_routes.dart';
import '../../savings/controllers/savings_controller.dart';
import '../controllers/home_controller.dart';

class HomeSavingsSection extends StatefulWidget {
  const HomeSavingsSection({
    super.key,
    required this.controller,
    required this.dark,
  });

  final HomeController controller;
  final bool dark;

  @override
  State<HomeSavingsSection> createState() => _HomeSavingsSectionState();
}

class _HomeSavingsSectionState extends State<HomeSavingsSection> {
  bool _isDaily = true;

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final textP = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final textS = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    final savingsCtrl = Get.isRegistered<SavingsController>()
        ? Get.find<SavingsController>()
        : Get.put(SavingsController());

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section Header ──────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.savings_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Property Savings SIP',
                          style: TextStyle(
                            color: textP,
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Container(
                        //   padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        //   decoration: BoxDecoration(
                        //     color: const Color(0xFF10B981).withOpacity(0.12),
                        //     borderRadius: BorderRadius.circular(6),
                        //     border: Border.all(
                        //       color: const Color(0xFF10B981).withOpacity(0.35),
                        //     ),
                        //   ),
                        //   child: const Text(
                        //     'NEW',
                        //     style: TextStyle(
                        //       color: Color(0xFF10B981),
                        //       fontSize: 9.5,
                        //       fontWeight: FontWeight.w800,
                        //     ),
                        //   ),
                        // ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Invest systematically & own fractional bricks',
                      style: TextStyle(
                        color: textS,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Link to My Plans
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.myPlans),
                child: Obx(() {
                  final activeCount = savingsCtrl.plans.where((p) => p.isActive).length;
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(dark ? 0.18 : 0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFF2563EB).withOpacity(dark ? 0.35 : 0.2),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          activeCount > 0 ? '$activeCount Active' : 'My Plans',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.chevron_right_rounded,
                          color: Color(0xFF2563EB),
                          size: 16,
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),

        const SizedBox(height: 14),

        // ── Daily vs Monthly Pill Toggle ────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF0A101D) : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _FrequencyPill(
                    label: 'Daily Micro-SIP',
                    badge: 'From ₹100/day',
                    isSelected: _isDaily,
                    dark: dark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isDaily = true);
                    },
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: _FrequencyPill(
                    label: 'Monthly SIP',
                    badge: 'From ₹1,000/mo',
                    isSelected: !_isDaily,
                    dark: dark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _isDaily = false);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 16),

        // ── Properties Carousel ─────────────────────────────────────────────
        Obx(() {
          final props = widget.controller.featuredProps
              .where((p) => p.allowsBricks && (p.brickPrice ?? 0) > 0)
              .toList();

          if (props.isEmpty) {
            final allProps = widget.controller.featuredProps;
            if (allProps.isNotEmpty) {
              return _PropertyCarousel(
                properties: allProps,
                isDaily: _isDaily,
                dark: dark,
                cardBg: cardBg,
                border: border,
                textP: textP,
                textS: textS,
                onSelect: (prop) => _showPropertySavingsModal(context, prop, _isDaily, dark),
              );
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Center(
                child: Text(
                  'No properties available for savings SIP right now.',
                  style: TextStyle(color: textS, fontSize: 13),
                ),
              ),
            );
          }

          return _PropertyCarousel(
            properties: props,
            isDaily: _isDaily,
            dark: dark,
            cardBg: cardBg,
            border: border,
            textP: textP,
            textS: textS,
            onSelect: (prop) => _showPropertySavingsModal(context, prop, _isDaily, dark),
          );
        }),
      ],
    );
  }

  // ── Bottom Sheet for Setting Up the Savings Plan ─────────────────────────
  void _showPropertySavingsModal(
    BuildContext context,
    PropertyModel property,
    bool initialDaily,
    bool dark,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _PropertySavingsSetupModal(
        property: property,
        initialDaily: initialDaily,
        dark: dark,
      ),
    );
  }
}

// ─── Pill Switcher ────────────────────────────────────────────────────────────
class _FrequencyPill extends StatelessWidget {
  const _FrequencyPill({
    required this.label,
    required this.badge,
    required this.isSelected,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final String badge;
  final bool isSelected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    if (isSelected) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                badge,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        color: Colors.transparent,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: dark ? const Color(0xFF8A95B0) : const Color(0xFF475569),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 1),
            Text(
              badge,
              style: TextStyle(
                color: dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8),
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Carousel of Property Savings Cards ──────────────────────────────────────
class _PropertyCarousel extends StatelessWidget {
  const _PropertyCarousel({
    required this.properties,
    required this.isDaily,
    required this.dark,
    required this.cardBg,
    required this.border,
    required this.textP,
    required this.textS,
    required this.onSelect,
  });

  final List<PropertyModel> properties;
  final bool isDaily;
  final bool dark;
  final Color cardBg;
  final Color border;
  final Color textP;
  final Color textS;
  final ValueChanged<PropertyModel> onSelect;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 380,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: properties.length,
        separatorBuilder: (_, _) => const SizedBox(width: 14),
        itemBuilder: (ctx, i) {
          final prop = properties[i];
          return _PropertySavingsCard(
            property: prop,
            isDaily: isDaily,
            dark: dark,
            cardBg: cardBg,
            border: border,
            textP: textP,
            textS: textS,
            onTap: () => onSelect(prop),
          );
        },
      ),
    );
  }
}

// ─── Single Property Savings Card ─────────────────────────────────────────────
class _PropertySavingsCard extends StatelessWidget {
  const _PropertySavingsCard({
    required this.property,
    required this.isDaily,
    required this.dark,
    required this.cardBg,
    required this.border,
    required this.textP,
    required this.textS,
    required this.onTap,
  });

  final PropertyModel property;
  final bool isDaily;
  final bool dark;
  final Color cardBg;
  final Color border;
  final Color textP;
  final Color textS;
  final VoidCallback onTap;

  String _formatCurrency(int amount) {
    if (amount >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)}Cr';
    }
    if (amount >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(1)}L';
    }
    return '₹${amount.toString().replaceAllMapped(RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"), (m) => "${m[1]},")}';
  }

  @override
  Widget build(BuildContext context) {
    final brickPrice = property.brickPrice ?? 10000;
    const defaultDailyCycle = 250;
    const defaultMonthlyCycle = 2500;
    final cycleAmount = isDaily ? defaultDailyCycle : defaultMonthlyCycle;
    final cyclesToBrick = (brickPrice / cycleAmount).ceil();
    final irrText = property.targetXirr != null && property.targetXirr! > 0
        ? '${property.targetXirr!.toStringAsFixed(1)}% IRR'
        : '${property.effectiveXirr.toStringAsFixed(1)}% Yield';

    final yieldPcnt = property.expectedRentalYield > 0
        ? property.expectedRentalYield
        : 8.4;
    final estMonthlyRental = ((brickPrice * (yieldPcnt / 100)) / 12).round();

    final locationCity = property.location.city;
    final locationState = property.location.state;
    final locationDisplay = (locationCity != null && locationCity.isNotEmpty)
        ? '$locationCity${(locationState != null && locationState.isNotEmpty) ? ", $locationState" : ""}'
        : (property.location.address ?? 'Prime Location');

    return Container(
      width: 280,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail with badging ──
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: SizedBox(
                  height: 135,
                  width: double.infinity,
                  child: property.coverImage != null && property.coverImage!.isNotEmpty
                      ? Image.network(
                          property.coverImage!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => _placeholder(dark),
                        )
                      : _placeholder(dark),
                ),
              ),
              // Scrim gradient
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.55),
                        Colors.transparent,
                        Colors.black.withOpacity(0.35),
                      ],
                    ),
                  ),
                ),
              ),
              // Top badge
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF60A5FA),
                        size: 11,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        property.propertyType ?? 'Commercial',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // IRR badge top right
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.4),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                  child: Text(
                    irrText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              // Location badge bottom left
              Positioned(
                bottom: 8,
                left: 10,
                right: 10,
                child: Row(
                  children: [
                    const Icon(
                      Icons.location_on_rounded,
                      color: Colors.white,
                      size: 12,
                    ),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        locationDisplay,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          shadows: [
                            Shadow(blurRadius: 4, color: Colors.black54),
                          ],
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ── Card Details ──
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  property.title,
                  style: TextStyle(
                    color: textP,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      'Brick Price: ',
                      style: TextStyle(color: textS, fontSize: 11.5),
                    ),
                    Text(
                      _formatCurrency(brickPrice),
                      style: TextStyle(
                        color: textP,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                // ── Micro-SIP Box ──
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2563EB).withOpacity(dark ? 0.12 : 0.06),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2563EB).withOpacity(dark ? 0.3 : 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isDaily ? Icons.today_rounded : Icons.calendar_month_rounded,
                                size: 13,
                                color: const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isDaily ? 'Daily Plan' : 'Monthly Plan',
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            isDaily ? '₹$cycleAmount / day' : '₹$cycleAmount / mo',
                            style: TextStyle(
                              color: textP,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          Icon(
                            Icons.timer_outlined,
                            size: 11,
                            color: textS,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              isDaily
                                  ? '1 Brick in ~$cyclesToBrick days'
                                  : '1 Brick in ~$cyclesToBrick months',
                              style: TextStyle(
                                color: textS,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          const Icon(
                            Icons.trending_up_rounded,
                            size: 11,
                            color: Color(0xFF10B981),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '~₹$estMonthlyRental/mo rent payout on goal',
                            style: const TextStyle(
                              color: Color(0xFF10B981),
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // ── Action Button ──
                GestureDetector(
                  onTap: onTap,
                  child: Container(
                    width: double.infinity,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF2563EB).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            isDaily ? 'Start Daily SIP' : 'Start Monthly SIP',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(bool dark) => Container(
        color: dark ? const Color(0xFF1E2838) : const Color(0xFFE2E8F0),
        child: Center(
          child: Icon(
            Icons.apartment_rounded,
            color: dark ? const Color(0xFF4A5C7A) : const Color(0xFF94A3B8),
            size: 32,
          ),
        ),
      );
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── BOTTOM SHEET: INTERACTIVE SAVINGS PLAN SETUP & PAYMENT ──────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _PropertySavingsSetupModal extends StatefulWidget {
  const _PropertySavingsSetupModal({
    required this.property,
    required this.initialDaily,
    required this.dark,
  });

  final PropertyModel property;
  final bool initialDaily;
  final bool dark;

  @override
  State<_PropertySavingsSetupModal> createState() => _PropertySavingsSetupModalState();
}

class _PropertySavingsSetupModalState extends State<_PropertySavingsSetupModal> {
  late bool _isDaily;
  int _targetBricks = 1;
  late int _amountPerCycle;
  bool _isCustomAmount = false;
  late final TextEditingController _customCtrl;
  bool _isSubmitting = false;

  final List<int> _dailyPresets = [100, 250, 500, 1000];
  final List<int> _monthlyPresets = [1000, 2500, 5000, 10000];

  @override
  void initState() {
    super.initState();
    _isDaily = widget.initialDaily;
    _amountPerCycle = _isDaily ? 250 : 2500;
    _customCtrl = TextEditingController(text: '$_amountPerCycle');
  }

  @override
  void dispose() {
    _customCtrl.dispose();
    super.dispose();
  }

  void _onDailyToggled(bool daily) {
    if (_isDaily == daily) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isDaily = daily;
      _isCustomAmount = false;
      _amountPerCycle = _isDaily ? 250 : 2500;
      _customCtrl.text = '$_amountPerCycle';
    });
  }

  void _onPresetSelected(int amt) {
    HapticFeedback.selectionClick();
    setState(() {
      _isCustomAmount = false;
      _amountPerCycle = amt;
      _customCtrl.text = '$amt';
    });
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
        RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
        (m) => "${m[1]},");

  Future<void> _handleStartPlan({required bool payNow}) async {
    final brickPrice = widget.property.brickPrice ?? 10000;
    final targetAmount = _targetBricks * brickPrice;

    if (_amountPerCycle <= 0) {
      Get.snackbar(
        'Invalid Amount',
        'Please enter a valid contribution amount',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final savingsCtrl = Get.find<SavingsController>();

    final plan = await savingsCtrl.createSavingPlan(
      type: _isDaily ? 'daily' : 'monthly',
      targetAmount: targetAmount,
      amountPerCycle: _amountPerCycle,
      targetPropertyId: widget.property.id,
    );

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    if (plan == null) {
      // Error handled by controller
      return;
    }

    Navigator.of(context).pop();

    if (payNow) {
      // Launch Razorpay for the 1st installment
      savingsCtrl.initiatePayment(plan.id);
    } else {
      Get.snackbar(
        '🎉 Plan Created!',
        'Your ${_isDaily ? "daily" : "monthly"} plan for ${widget.property.title} is active.',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        duration: const Duration(seconds: 4),
        mainButton: TextButton(
          onPressed: () => Get.toNamed(AppRoutes.myPlans),
          child: const Text(
            'View Plans',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final textP = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final textS = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final cardBg = dark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC);
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    final brickPrice = widget.property.brickPrice ?? 10000;
    final targetAmount = _targetBricks * brickPrice;
    final cycles = _amountPerCycle > 0 ? (targetAmount / _amountPerCycle).ceil() : 0;
    final cycleLabel = _isDaily ? 'days' : 'months';
    final presets = _isDaily ? _dailyPresets : _monthlyPresets;

    final locCity = widget.property.location.city;
    final cityText = (locCity != null && locCity.isNotEmpty) ? locCity : 'Prime Location';

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(
            color: dark ? const Color(0xFF2563EB).withOpacity(0.4) : const Color(0xFF2563EB).withOpacity(0.2),
            width: 1.5,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF2B3C56) : const Color(0xFFCBD5E1),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            // Header title & close
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 16, 14),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.savings_rounded,
                      color: Color(0xFF2563EB),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Configure Savings SIP',
                          style: TextStyle(
                            color: textP,
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Flexible micro-investing with zero lock-in penalty',
                          style: TextStyle(
                            color: textS,
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close_rounded, color: textS),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            Divider(height: 1, color: border),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Property Info Strip ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: border),
                    ),
                    child: Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 50,
                            height: 50,
                            child: widget.property.coverImage != null
                                ? Image.network(
                                    widget.property.coverImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: const Color(0xFF2563EB).withOpacity(0.1),
                                      child: const Icon(Icons.apartment_rounded, color: Color(0xFF2563EB)),
                                    ),
                                  )
                                : Container(
                                    color: const Color(0xFF2563EB).withOpacity(0.1),
                                    child: const Icon(Icons.apartment_rounded, color: Color(0xFF2563EB)),
                                  ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.property.title,
                                style: TextStyle(
                                  color: textP,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '₹${_fmt(brickPrice)} per Brick · $cityText',
                                style: TextStyle(
                                  color: textS,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  // ── Plan Type: Daily vs Monthly ──
                  Text(
                    'CONTRIBUTION FREQUENCY',
                    style: TextStyle(
                      color: textS,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: _ModalFrequencyButton(
                          title: 'Daily Micro-SIP',
                          subtitle: 'Small daily transfers',
                          isSelected: _isDaily,
                          dark: dark,
                          onTap: () => _onDailyToggled(true),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _ModalFrequencyButton(
                          title: 'Monthly SIP',
                          subtitle: 'Once a month on payday',
                          isSelected: !_isDaily,
                          dark: dark,
                          onTap: () => _onDailyToggled(false),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // ── Target Bricks Selector ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'SAVINGS TARGET',
                        style: TextStyle(
                          color: textS,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        'Goal: ₹${_fmt(targetAmount)}',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [1, 2, 5, 10].map((b) {
                      final isSel = _targetBricks == b;
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _targetBricks = b);
                          },
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 3),
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? const Color(0xFF2563EB)
                                  : (dark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSel
                                    ? const Color(0xFF2563EB)
                                    : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '$b Brick${b > 1 ? "s" : ""}',
                                  style: TextStyle(
                                    color: isSel ? Colors.white : textP,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  '₹${_fmt(b * brickPrice)}',
                                  style: TextStyle(
                                    color: isSel
                                        ? Colors.white.withOpacity(0.85)
                                        : textS,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 18),

                  // ── Amount Per Cycle Presets ──
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'AMOUNT PER ${_isDaily ? "DAY" : "MONTH"}',
                        style: TextStyle(
                          color: textS,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                      Text(
                        '₹${_fmt(_amountPerCycle)} / ${_isDaily ? "day" : "mo"}',
                        style: const TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ...presets.map((amt) {
                        final isSel = !_isCustomAmount && _amountPerCycle == amt;
                        return ChoiceChip(
                          label: Text('₹${_fmt(amt)}'),
                          selected: isSel,
                          onSelected: (_) => _onPresetSelected(amt),
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: dark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                          labelStyle: TextStyle(
                            color: isSel ? Colors.white : textP,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSel
                                  ? const Color(0xFF2563EB)
                                  : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
                            ),
                          ),
                        );
                      }),
                      ChoiceChip(
                        label: const Text('Custom'),
                        selected: _isCustomAmount,
                        onSelected: (_) {
                          HapticFeedback.selectionClick();
                          setState(() => _isCustomAmount = true);
                        },
                        selectedColor: const Color(0xFF2563EB),
                        backgroundColor: dark ? const Color(0xFF131D31) : const Color(0xFFF1F5F9),
                        labelStyle: TextStyle(
                          color: _isCustomAmount ? Colors.white : textP,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                          side: BorderSide(
                            color: _isCustomAmount
                                ? const Color(0xFF2563EB)
                                : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0)),
                          ),
                        ),
                      ),
                    ],
                  ),

                  if (_isCustomAmount) ...[
                    const SizedBox(height: 10),
                    TextField(
                      controller: _customCtrl,
                      keyboardType: TextInputType.number,
                      style: TextStyle(color: textP, fontWeight: FontWeight.w700),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.currency_rupee_rounded, size: 18, color: Color(0xFF2563EB)),
                        hintText: 'Enter amount per cycle',
                        hintStyle: TextStyle(color: textS),
                        filled: true,
                        fillColor: cardBg,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
                        ),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val.replaceAll(',', '').trim()) ?? 0;
                        setState(() => _amountPerCycle = parsed);
                      },
                    ),
                  ],

                  const SizedBox(height: 16),

                  // ── Projection & Timeline Box ──
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(dark ? 0.12 : 0.05),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: const Color(0xFF2563EB).withOpacity(dark ? 0.3 : 0.18),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.av_timer_rounded, size: 15, color: Color(0xFF2563EB)),
                                const SizedBox(width: 6),
                                Text(
                                  'Estimated Timeline',
                                  style: TextStyle(color: textS, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(
                              '~$cycles $cycleLabel to reach goal',
                              style: TextStyle(color: textP, fontSize: 12.5, fontWeight: FontWeight.w800),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.currency_exchange_rounded, size: 15, color: Color(0xFF10B981)),
                                const SizedBox(width: 6),
                                Text(
                                  'Target Portfolio Value',
                                  style: TextStyle(color: textS, fontSize: 12, fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            Text(
                              '₹${_fmt(targetAmount)}',
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ── Main Action Buttons ──
                  if (_isSubmitting)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: CircularProgressIndicator(
                          color: Color(0xFF2563EB),
                          strokeWidth: 2.5,
                        ),
                      ),
                    )
                  else ...[
                    GestureDetector(
                      onTap: () => _handleStartPlan(payNow: true),
                      child: Container(
                        width: double.infinity,
                        height: 48,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.38),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Start & Pay 1st Cycle · ₹${_fmt(_amountPerCycle)}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _handleStartPlan(payNow: false),
                      child: Container(
                        width: double.infinity,
                        height: 44,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Center(
                          child: Text(
                            'Save Plan (Pay Later)',
                            style: TextStyle(
                              color: textP,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Modal Frequency Button ───────────────────────────────────────────────────
class _ModalFrequencyButton extends StatelessWidget {
  const _ModalFrequencyButton({
    required this.title,
    required this.subtitle,
    required this.isSelected,
    required this.dark,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool isSelected;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final border = isSelected
        ? const Color(0xFF2563EB)
        : (dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0));
    final bg = isSelected
        ? const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.08)
        : (dark ? const Color(0xFF131D31) : const Color(0xFFF8FAFC));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: border, width: isSelected ? 1.5 : 1.0),
        ),
        child: Row(
          children: [
            Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF94A3B8),
                  width: isSelected ? 5.5 : 1.5,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF2563EB)
                          : (dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A)),
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B),
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
