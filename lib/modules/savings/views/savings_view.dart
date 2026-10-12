import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/savings_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';

// ─── Opportunity data ─────────────────────────────────────────────────────────
class _Opp {
  final String city, tagline, code;
  final IconData icon;
  final Color color;
  const _Opp({
    required this.city,
    required this.tagline,
    required this.code,
    required this.icon,
    required this.color,
  });
}

const _opps = [
  _Opp(
    city: 'Goa',
    tagline: 'Holiday Homes',
    code: 'GOHI',
    icon: Icons.beach_access_rounded,
    color: Color(0xFFFF6B35),
  ),
  _Opp(
    city: 'Bangalore',
    tagline: 'Prime Land',
    code: 'BPLD',
    icon: Icons.account_balance_rounded,
    color: Color(0xFF3B82F6),
  ),
  _Opp(
    city: 'Mumbai',
    tagline: 'Sky Residences',
    code: 'MSKY',
    icon: Icons.apartment_rounded,
    color: Color(0xFF2ecc71),
  ),
  _Opp(
    city: 'Pune',
    tagline: 'IT Hub Flats',
    code: 'PNIT',
    icon: Icons.business_rounded,
    color: Color(0xFFAB47BC),
  ),
];

// ═════════════════════════════════════════════════════════════════════════════
class SavingsView extends GetView<SavingsController> {
  const SavingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFECF0FF);
      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(
                child: CircularProgressIndicator(
                  color: const Color(0xFF2563EB),
                  strokeWidth: 2,
                ),
              );
            }
            return _Body(dark: dark);
          }),
        ),
      );
    });
  }
}

// ─── Body with manual tab state ───────────────────────────────────────────────
class _Body extends StatefulWidget {
  const _Body({required this.dark});
  final bool dark;
  @override
  State<_Body> createState() => _BodyState();
}

class _BodyState extends State<_Body> with SingleTickerProviderStateMixin {
  int _tab = 0; // 0=daily, 1=monthly
  late final AnimationController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    super.dispose();
  }

  void _switchTab(int i) {
    if (i == _tab) return;
    HapticFeedback.selectionClick();
    _tabCtrl.forward(from: 0);
    setState(() => _tab = i);
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return Column(
      children: [
        // ── Top bar ──────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Save & Invest',
                      style: TextStyle(
                        color: tp,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.6,
                      ),
                    ),
                    Text(
                      'Build wealth one brick at a time',
                      style: TextStyle(color: ts, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // My Plans button
              GestureDetector(
                onTap: () => Get.find<SavingsController>().goToMyPlans(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.45),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 3,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.savings_outlined,
                        color: Colors.white,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'My Plans',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),

        // ── Manual Tab Switcher ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: _TabRow(selected: _tab, onTap: _switchTab, dark: dark),
        ),
        const SizedBox(height: 20),

        // ── Content ───────────────────────────────────────────────────────────
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            transitionBuilder: (child, anim) => FadeTransition(
              opacity: anim,
              child: SlideTransition(
                position: Tween(
                  begin: const Offset(0.06, 0),
                  end: Offset.zero,
                ).animate(anim),
                child: child,
              ),
            ),
            child: _tab == 0
                ? _DailySection(key: const ValueKey('daily'), dark: dark)
                : _MonthlySection(key: const ValueKey('monthly'), dark: dark),
          ),
        ),
      ],
    );
  }
}

// ─── Tab Row ──────────────────────────────────────────────────────────────────
class _TabRow extends StatelessWidget {
  const _TabRow({
    required this.selected,
    required this.onTap,
    required this.dark,
  });
  final int selected;
  final ValueChanged<int> onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

    return Container(
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.4 : 0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          if (!dark)
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 4,
              offset: const Offset(-1, -1),
            ),
        ],
      ),
      child: Row(
        children: [
          _Tab(
            label: 'Daily',
            icon: Icons.wb_sunny_rounded,
            index: 0,
            selected: selected,
            onTap: onTap,
            dark: dark,
          ),
          const SizedBox(width: 4),
          _Tab(
            label: 'Monthly',
            icon: Icons.calendar_month_rounded,
            index: 1,
            selected: selected,
            onTap: onTap,
            dark: dark,
          ),
        ],
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({
    required this.label,
    required this.icon,
    required this.index,
    required this.selected,
    required this.onTap,
    required this.dark,
  });
  final String label;
  final IconData icon;
  final int index;
  final int selected;
  final ValueChanged<int> onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final active = index == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutCubic,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(14),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.45),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 3,
                      offset: const Offset(2, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: active
                    ? Colors.white
                    : (dark
                          ? const Color(0xFF8A95B0)
                          : const Color(0xFF6B7280)),
                size: 16,
              ),
              const SizedBox(width: 7),
              Text(
                label,
                style: TextStyle(
                  color: active
                      ? Colors.white
                      : (dark
                            ? const Color(0xFF8A95B0)
                            : const Color(0xFF6B7280)),
                  fontSize: 14,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── DAILY SECTION ────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _DailySection extends StatefulWidget {
  const _DailySection({super.key, required this.dark});
  final bool dark;
  @override
  State<_DailySection> createState() => _DailySectionState();
}

class _DailySectionState extends State<_DailySection> {
  int _amount = 50;
  int _tenure = 3;
  bool _agreed = false;
  static const _chips = [10, 50, 100, 250];
  static const _tenures = [1, 3, 5, 7];

  int get _projected {
    final principal = _amount * 365 * _tenure;
    return (principal * pow(1 + 0.11, _tenure / 2)).round();
  }


  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SavingsController>();
    final dark = widget.dark;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final th = dark ? const Color(0xFF4A5568) : const Color(0xFFADB5BD);
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Projection card (3D floating) ──────────────────────────────────
          _ProjectionCard(
            tenure: _tenure,
            projected: _projected,
            amount: _amount,
            dark: dark,
          ),
          const SizedBox(height: 20),

          // ── Tenure chips ──────────────────────────────────────────────────
          Text(
            'Select Tenure',
            style: TextStyle(
              color: ts,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _tenures.map((y) {
              final active = y == _tenure;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _tenure = y);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                                colors: [
                                  const Color(0xFF2563EB),
                                  const Color(0xFF3B82F6),
                                ],
                              )
                            : null,
                        color: active ? null : cardBg,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: active ? Colors.transparent : border,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.45),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(2, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    dark ? 0.3 : 0.06,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                  spreadRadius: -2,
                                ),
                                if (!dark)
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.9),
                                    blurRadius: 3,
                                    offset: const Offset(-1, -1),
                                  ),
                              ],
                      ),
                      child: Text(
                        '$y Yr',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active ? Colors.white : ts,
                          fontSize: 13,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 22),

          // ── Amount chips ──────────────────────────────────────────────────
          Text(
            'Daily saving amount',
            style: TextStyle(
              color: ts,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: _chips.map((c) {
              final active = c == _amount;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _amount = c);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                                colors: [
                                  const Color(0xFF2563EB),
                                  const Color(0xFF3B82F6),
                                ],
                              )
                            : null,
                        color: active ? null : cardBg,
                        borderRadius: BorderRadius.circular(13),
                        border: Border.all(
                          color: active ? Colors.transparent : border,
                        ),
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.45),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 3,
                                  offset: const Offset(2, 4),
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(
                                    dark ? 0.3 : 0.06,
                                  ),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                  spreadRadius: -2,
                                ),
                                if (!dark)
                                  BoxShadow(
                                    color: Colors.white.withOpacity(0.9),
                                    blurRadius: 3,
                                    offset: const Offset(-1, -1),
                                  ),
                              ],
                      ),
                      child: Text(
                        '₹$c',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: active ? Colors.white : tp,
                          fontSize: 14,
                          fontWeight: active
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // ── Cashback strip ────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            decoration: BoxDecoration(
              color: const Color(0xFF2563EB).withOpacity(dark ? 0.15 : 0.07),
              borderRadius: BorderRadius.circular(13),
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(dark ? 0.3 : 0.18),
              ),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.celebration_outlined,
                  color: const Color(0xFF2563EB),
                  size: 16,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(color: ts, fontSize: 12),
                      children: const [
                        TextSpan(text: 'Get '),
                        TextSpan(
                          text: '10% cashback',
                          style: TextStyle(
                            color: const Color(0xFF2563EB),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(text: ' on your first auto-debit'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          Text(
            '*Returns are estimates and subject to market risks.',
            style: TextStyle(color: th, fontSize: 10.5, height: 1.4),
          ),
          const SizedBox(height: 16),

          // Agreement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                  activeColor: const Color(0xFF2563EB),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: ts, fontSize: 12, height: 1.4),
                    children: const [
                      TextSpan(text: 'I agree to be legally bound by the '),
                      TextSpan(
                        text: 'Purchase Agreement',
                        style: TextStyle(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _SubmitBtn(
            label: 'Start Daily Plan',
            enabled: _agreed,
            onTap: () async {
              HapticFeedback.mediumImpact();
              final ok = await ctrl.createPlan(
                type: 'daily',
                targetAmount: _projected,
                amountPerCycle: _amount,
              );
              if (ok && context.mounted)
                _showSuccess(context, 'daily', _amount, dark);
            },
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── MONTHLY SECTION ──────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _MonthlySection extends StatefulWidget {
  const _MonthlySection({super.key, required this.dark});
  final bool dark;
  @override
  State<_MonthlySection> createState() => _MonthlySectionState();
}

class _MonthlySectionState extends State<_MonthlySection> {
  int _oppIdx = 0, _sqft = 3, _tenure = 1;
  bool _agreed = false;
  final _pageCtrl = PageController(viewportFraction: 0.82);
  static const _pricePerSqft = 750;

  int get _monthly => _sqft * _pricePerSqft;
  int get _totalSav {
    final principal = _monthly * 12 * _tenure;
    return (principal * pow(1 + 0.11, _tenure / 2)).round();
  }

  int get _totalSqft => _sqft * 12 * _tenure;

  String _fmtNum(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<SavingsController>();
    final dark = widget.dark;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final th = dark ? const Color(0xFF4A5568) : const Color(0xFFADB5BD);
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 0, 22, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── City carousel ─────────────────────────────────────────────────
          Text(
            'Choose Investment City',
            style: TextStyle(
              color: ts,
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 150,
            child: PageView.builder(
              controller: _pageCtrl,
              itemCount: _opps.length,
              onPageChanged: (i) => setState(() => _oppIdx = i),
              itemBuilder: (_, i) {
                final opp = _opps[i];
                final active = i == _oppIdx;
                return AnimatedScale(
                  scale: active ? 1.0 : 0.92,
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: GestureDetector(
                    onTap: () {
                      _pageCtrl.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeOut,
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [opp.color, opp.color.withOpacity(0.6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: active
                            ? Border.all(color: Colors.white.withOpacity(0.25))
                            : null,
                        boxShadow: active
                            ? [
                                BoxShadow(
                                  color: opp.color.withOpacity(0.45),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 6,
                                  offset: const Offset(3, 8),
                                ),
                              ]
                            : [],
                      ),
                      child: Stack(
                        children: [
                          // bg orb
                          Positioned(
                            top: -20,
                            right: -20,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(0.08),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      opp.icon,
                                      color: Colors.white,
                                      size: 22,
                                    ),
                                    const Spacer(),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.18),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Text(
                                        opp.code,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      opp.city,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    Text(
                                      opp.tagline,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.75),
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          // Dots
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(_opps.length, (i) {
                final active = i == _oppIdx;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: active ? const Color(0xFF2563EB) : border,
                    borderRadius: BorderRadius.circular(3),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 22),

          // ── Steppers ──────────────────────────────────────────────────────
          _Stepper(
            label: 'SQFT per month',
            value: _sqft,
            min: 3,
            max: 5,
            dark: dark,
            onMinus: () => setState(() {
              if (_sqft > 3) _sqft--;
            }),
            onPlus: () => setState(() {
              if (_sqft < 5) _sqft++;
            }),
          ),
          const SizedBox(height: 10),
          _Stepper(
            label: 'Tenure (years)',
            value: _tenure,
            min: 1,
            max: 10,
            dark: dark,
            display: '$_tenure Year${_tenure > 1 ? "s" : ""}',
            onMinus: () => setState(() {
              if (_tenure > 1) _tenure--;
            }),
            onPlus: () => setState(() {
              if (_tenure < 10) _tenure++;
            }),
          ),
          const SizedBox(height: 20),

          // ── Summary card ──────────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF2563EB).withOpacity(dark ? 0.18 : 0.08),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.4 : 0.08),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                  spreadRadius: -3,
                ),
                if (!dark)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.9),
                    blurRadius: 4,
                    offset: const Offset(-1, -1),
                  ),
              ],
            ),
            child: Column(
              children: [
                _SumRow(
                  label: 'Total SQFT',
                  value: '$_totalSqft sqft',
                  tp: tp,
                  ts: ts,
                ),
                Divider(height: 20, color: border),
                _SumRow(
                  label: 'Monthly Saving',
                  value: '₹${_fmtNum(_monthly)}',
                  tp: tp,
                  ts: ts,
                ),
                Divider(height: 20, color: border),
                _SumRow(
                  label: 'Total Savings',
                  value: '₹${_fmtNum(_totalSav)}',
                  tp: const Color(0xFF2563EB),
                  ts: ts,
                  big: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // ── IRR bar ───────────────────────────────────────────────────────
          _IrrBar(principal: _monthly * 12 * _tenure, dark: dark),
          const SizedBox(height: 20),

          Text(
            '*Returns are estimates and subject to market risks.',
            style: TextStyle(color: th, fontSize: 10.5, height: 1.4),
          ),
          const SizedBox(height: 16),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 22,
                height: 22,
                child: Checkbox(
                  value: _agreed,
                  onChanged: (v) => setState(() => _agreed = v ?? false),
                  activeColor: const Color(0xFF2563EB),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(color: ts, fontSize: 12, height: 1.4),
                    children: const [
                      TextSpan(text: 'I agree to be legally bound by the '),
                      TextSpan(
                        text: 'Purchase Agreement',
                        style: TextStyle(
                          color: const Color(0xFF2563EB),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          _SubmitBtn(
            label: 'Invest Now',
            enabled: _agreed,
            onTap: () async {
              HapticFeedback.mediumImpact();
              final ok = await ctrl.createPlan(
                type: 'monthly',
                targetAmount: _totalSav,
                amountPerCycle: _monthly,
              );
              if (ok && context.mounted)
                _showSuccess(context, 'monthly', _monthly, dark);
            },
          ),
        ],
      ),
    );
  }
}

// ─── Summary Row ─────────────────────────────────────────────────────────────
class _SumRow extends StatelessWidget {
  const _SumRow({
    required this.label,
    required this.value,
    required this.tp,
    required this.ts,
    this.big = false,
  });
  final String label, value;
  final Color tp, ts;
  final bool big;
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(label, style: TextStyle(color: ts, fontSize: 13)),
      const Spacer(),
      Text(
        value,
        style: TextStyle(
          color: tp,
          fontSize: big ? 17 : 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}

// ─── Projection Card ──────────────────────────────────────────────────────────
class _ProjectionCard extends StatefulWidget {
  const _ProjectionCard({
    required this.tenure,
    required this.projected,
    required this.amount,
    required this.dark,
  });
  final int tenure, projected, amount;
  final bool dark;
  @override
  State<_ProjectionCard> createState() => _ProjectionCardState();
}

class _ProjectionCardState extends State<_ProjectionCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, _) => Transform.translate(
        offset: Offset(0, -3 + _c.value * 5),
        child: Container(
          decoration: BoxDecoration(
            gradient: dark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0E1626),
                      Color(0xFF182238),
                      Color(0xFF0A0F1E),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1C2D50),
                      Color(0xFF253868),
                      Color(0xFF1A2340),
                    ],
                  ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.55 : 0.22),
                blurRadius: 28,
                offset: const Offset(0, 14),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: const Color(0xFF2563EB).withOpacity(dark ? 0.15 : 0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Saving ₹${widget.amount}/day for ${widget.tenure}yr${widget.tenure > 1 ? "s" : ""}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 9,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFFD700).withOpacity(0.4),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Text(
                      'PROJECTED',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 8,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              // 3D shadow amount
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Transform.translate(
                    offset: const Offset(2.5, 3.5),
                    child: Text(
                      '₹${_fmt(widget.projected)}',
                      style: TextStyle(
                        color: const Color(0xFF2563EB).withOpacity(0.22),
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ),
                  Text(
                    '₹${_fmt(widget.projected)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // Mini chart (progress bars as chart)
              SizedBox(
                height: 130,
                width: double.infinity,
                child: _MiniChart(
                  tenure: widget.tenure,
                  projected: widget.projected,
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniChart extends StatelessWidget {
  const _MiniChart({required this.tenure, required this.projected});
  final int tenure, projected;

  String _fmt(int n) {
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  // Compound value at year y
  int _val(int y, int daily) {
    final principal = daily * 365 * y;
    return (principal * pow(1 + 0.11, y / 2)).round();
  }

  @override
  Widget build(BuildContext context) {
    final daily = (projected / (pow(1 + 0.11, tenure / 2) * 365 * tenure))
        .round()
        .clamp(1, 99999);
    final years = [1, 3, 5, 7].where((y) => y <= tenure + 2).toList();
    if (years.isEmpty) years.add(tenure);

    return TweenAnimationBuilder<double>(
      key: ValueKey(tenure),
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, progress, __) => CustomPaint(
        size: const Size(double.infinity, 120),
        painter: _LineChartPainter(
          years: years,
          values: years.map((y) => _val(y, daily)).toList(),
          projected: projected,
          progress: progress,
          fmtFn: _fmt,
        ),
      ),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  const _LineChartPainter({
    required this.years,
    required this.values,
    required this.projected,
    required this.progress,
    required this.fmtFn,
  });
  final List<int> years, values;
  final int projected;
  final double progress;
  final String Function(int) fmtFn;

  static const _accent = Color(0xFFD4A017);

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty) return;
    final maxV = values.last.toDouble();
    if (maxV <= 0) return;

    // Points
    final pts = <Offset>[];
    for (int i = 0; i < values.length; i++) {
      final x = size.width * (i / (values.length - 1).clamp(1, 99));
      final y =
          size.height * 0.75 * (1 - values[i] / maxV) + size.height * 0.10;
      pts.add(Offset(x, y));
    }

    // How many points to draw based on progress
    final drawCount = (pts.length * progress).clamp(1.0, pts.length.toDouble());

    // Fill gradient under line
    final fillPath = Path();
    fillPath.moveTo(pts[0].dx, size.height);
    fillPath.lineTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < drawCount.floor(); i++) {
      final cp = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      fillPath.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
    }
    // Partial last segment
    if (drawCount < pts.length) {
      final frac = drawCount - drawCount.floor();
      final last = drawCount.floor();
      if (last < pts.length) {
        final interp = Offset.lerp(pts[last - 1], pts[last], frac)!;
        fillPath.lineTo(interp.dx, interp.dy);
        fillPath.lineTo(interp.dx, size.height);
      }
    } else {
      fillPath.lineTo(pts.last.dx, size.height);
    }
    fillPath.close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [_accent.withOpacity(0.35), _accent.withOpacity(0.0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );

    // Line
    final linePaint = Paint()
      ..color = _accent
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final linePath = Path();
    linePath.moveTo(pts[0].dx, pts[0].dy);
    for (int i = 1; i < drawCount.floor(); i++) {
      final cp = Offset(
        (pts[i - 1].dx + pts[i].dx) / 2,
        (pts[i - 1].dy + pts[i].dy) / 2,
      );
      linePath.quadraticBezierTo(pts[i - 1].dx, pts[i - 1].dy, cp.dx, cp.dy);
    }
    if (drawCount < pts.length) {
      final frac = drawCount - drawCount.floor();
      final last = drawCount.floor();
      if (last < pts.length) {
        linePath.lineTo(
          Offset.lerp(pts[last - 1], pts[last], frac)!.dx,
          Offset.lerp(pts[last - 1], pts[last], frac)!.dy,
        );
      }
    } else {
      linePath.lineTo(pts.last.dx, pts.last.dy);
    }
    canvas.drawPath(linePath, linePaint);

    // Dots + callouts for each point
    for (int i = 0; i < pts.length && i < drawCount; i++) {
      final pt = pts[i];
      // Outer glow
      canvas.drawCircle(pt, 8, Paint()..color = _accent.withOpacity(0.20));
      // White ring
      canvas.drawCircle(
        pt,
        5,
        Paint()
          ..color = Colors.white
          ..style = PaintingStyle.fill,
      );
      canvas.drawCircle(
        pt,
        5,
        Paint()
          ..color = _accent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );

      // Callout box above the dot
      final label = 'Year ${years[i]}';
      final val = fmtFn(values[i]);

      const boxW = 72.0, boxH = 34.0, boxR = 7.0;
      double bx = pt.dx - boxW / 2;
      bx = bx.clamp(0, size.width - boxW);
      final by = (pt.dy - boxH - 14).clamp(0.0, size.height - boxH);

      // Box shadow
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx + 2, by + 3, boxW, boxH),
          const Radius.circular(boxR),
        ),
        Paint()
          ..color = Colors.black.withOpacity(0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Box fill
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, boxW, boxH),
          const Radius.circular(boxR),
        ),
        Paint()..color = Colors.white.withOpacity(0.14),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(bx, by, boxW, boxH),
          const Radius.circular(boxR),
        ),
        Paint()
          ..color = _accent.withOpacity(0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1,
      );

      // Stem line from box to dot
      canvas.drawLine(
        Offset(pt.dx, by + boxH),
        Offset(pt.dx, pt.dy - 6),
        Paint()
          ..color = _accent.withOpacity(0.5)
          ..strokeWidth = 1,
      );

      // Label text
      _drawText(
        canvas,
        label,
        Offset(bx + boxW / 2, by + 6),
        9,
        Colors.white.withOpacity(0.65),
      );
      // Value text
      _drawText(
        canvas,
        val,
        Offset(bx + boxW / 2, by + 18),
        11,
        Colors.white,
        bold: true,
      );
    }
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset center,
    double size,
    Color color, {
    bool bold = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: size,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(center.dx - tp.width / 2, center.dy));
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter old) =>
      old.progress != progress || old.years != years || old.values != values;
}

// ─── Stepper Row ──────────────────────────────────────────────────────────────
class _Stepper extends StatelessWidget {
  const _Stepper({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.dark,
    required this.onMinus,
    required this.onPlus,
    this.display,
  });
  final String label;
  final int value, min, max;
  final bool dark;
  final VoidCallback onMinus, onPlus;
  final String? display;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final stepBg = dark ? const Color(0xFF1A2B45) : const Color(0xFFF0F4FF);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
            spreadRadius: -2,
          ),
          if (!dark)
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 3,
              offset: const Offset(-1, -1),
            ),
        ],
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: ts,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onMinus();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: stepBg,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
                    blurRadius: 6,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(Icons.remove_rounded, color: ts, size: 16),
            ),
          ),
          SizedBox(
            width: 70,
            child: Text(
              display ?? '$value',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: const Color(0xFF2563EB),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onPlus();
            },
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: const Icon(
                Icons.add_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── IRR Bar ─────────────────────────────────────────────────────────────────
class _IrrBar extends StatefulWidget {
  const _IrrBar({required this.principal, required this.dark});
  final int principal;
  final bool dark;
  @override
  State<_IrrBar> createState() => _IrrBarState();
}

class _IrrBarState extends State<_IrrBar> {
  double _irr = 11;

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final barBg = dark ? const Color(0xFF1A2B45) : const Color(0xFFEEF2FF);
    final fv = (widget.principal * pow(1 + _irr / 100, 3)).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.07),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -3,
          ),
          if (!dark)
            BoxShadow(
              color: Colors.white.withOpacity(0.9),
              blurRadius: 3,
              offset: const Offset(-1, -1),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.calculate_outlined,
                color: const Color(0xFF2563EB),
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                'IRR Calculator',
                style: TextStyle(
                  color: tp,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_irr.toStringAsFixed(0)}% p.a.',
                  style: const TextStyle(
                    color: const Color(0xFF2563EB),
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          // Proper slider — track visible so thumb aligns correctly
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF2563EB),
              inactiveTrackColor: barBg,
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(
                enabledThumbRadius: 11,
                elevation: 6,
              ),
              overlayColor: const Color(0xFF2563EB).withOpacity(0.15),
              trackHeight: 8,
              activeTickMarkColor: Colors.transparent,
              inactiveTickMarkColor: Colors.transparent,
            ),
            child: Slider(
              value: _irr,
              min: 5,
              max: 20,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _irr = v);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('5%', style: TextStyle(color: ts, fontSize: 10)),
              Text('20%', style: TextStyle(color: ts, fontSize: 10)),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Future Value (3yr)',
                style: TextStyle(color: ts, fontSize: 12),
              ),
              Text(
                '₹${_fmt(fv)}',
                style: TextStyle(
                  color: tp,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Submit Button ────────────────────────────────────────────────────────────
class _SubmitBtn extends StatefulWidget {
  const _SubmitBtn({
    required this.label,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final bool enabled;
  final VoidCallback onTap;
  @override
  State<_SubmitBtn> createState() => _SubmitBtnState();
}

class _SubmitBtnState extends State<_SubmitBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _s;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _s = Tween(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.enabled) _c.forward();
      },
      onTapUp: (_) {
        _c.reverse();
        if (widget.enabled) widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: widget.enabled
                ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: widget.enabled ? null : (Colors.grey.withOpacity(0.3)),
            borderRadius: BorderRadius.circular(18),
            boxShadow: widget.enabled
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.22),
                      blurRadius: 5,
                      offset: const Offset(3, 7),
                    ),
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              widget.label,
              style: TextStyle(
                color: widget.enabled ? Colors.white : Colors.white54,
                fontSize: 16,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.3,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Success Dialog ───────────────────────────────────────────────────────────
void _showSuccess(BuildContext context, String type, int amount, bool dark) {
  final bg = dark ? const Color(0xFF0E1626) : Colors.white;
  final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
  final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
  Get.dialog(
    Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.fromLTRB(28, 32, 28, 24),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 40,
                offset: const Offset(0, 20),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2ecc71).withOpacity(0.45),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                type == 'daily'
                    ? 'Daily Plan Created!'
                    : 'Monthly Plan Created!',
                style: TextStyle(
                  color: tp,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '₹$amount ${type == 'daily' ? 'per day' : 'per month'} — activate in My Plans',
                textAlign: TextAlign.center,
                style: TextStyle(color: ts, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: dark
                                ? const Color(0xFF1A2B45)
                                : const Color(0xFFE2E6F0),
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Close',
                            style: TextStyle(
                              color: ts,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Get.back();
                        Get.find<SavingsController>().goToMyPlans();
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Text(
                            'View Plan',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
    barrierDismissible: true,
    barrierColor: Colors.black54,
  );
}
