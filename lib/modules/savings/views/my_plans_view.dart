import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/savings_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/saving_model.dart';

class MyPlansView extends GetView<SavingsController> {
  const MyPlansView({super.key});


  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFECF0FF);
      return Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            _HeroHeader(dark: dark, controller: controller),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(30),
                  ),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: _FilterTabs(
                          selected: controller.activeTab.value,
                          onTap: (i) {
                            HapticFeedback.selectionClick();
                            controller.activeTab.value = i;
                          },
                          dark: dark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2563EB),
                              strokeWidth: 2,
                            ),
                          );
                        }
                        final list = controller.activeTab.value == 0
                            ? controller.plans
                            : controller.activeTab.value == 1
                            ? controller.dailyPlans
                            : controller.monthlyPlans;
                        if (list.isEmpty) {
                          return _EmptyState(onAdd: () => Get.back());
                        }
                        return RefreshIndicator(
                          onRefresh: controller.loadSavings,
                          color: Color(0xFF2563EB),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(22, 0, 22, 100),
                            physics: const BouncingScrollPhysics(),
                            itemCount: list.length,
                            itemBuilder: (ctx, i) => _PlanCard3D(
                              plan: list[i],
                              index: i,
                              dark: dark,
                              onPay: () => _handlePayment(ctx, list[i]),
                              onPause: () => controller.togglePause(list[i]),
                              onDelete: () => _confirmDelete(ctx, list[i].id),
                            ),
                          ),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _handlePayment(BuildContext context, SavingModel plan) {
    if (!plan.firstPaymentDone) {
      controller.initiatePayment(plan.id);
    } else {
      _showCycleSheet(context, plan);
    }
  }

  void _showCycleSheet(BuildContext context, SavingModel plan) {
    final dark = ThemeController.to.isDark.value;
    final sheetBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final amtCtrl = TextEditingController(text: plan.amountPerCycle.toString());

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: dark
              ? const Border(top: BorderSide(color: Color(0xFF1A2B45)))
              : null,
        ),
        padding: EdgeInsets.fromLTRB(
          24,
          16,
          24,
          MediaQuery.of(context).viewInsets.bottom + 32,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Add Savings',
              style: TextStyle(
                color: tp,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${plan.formattedSaved} saved of ${plan.formattedTarget}',
              style: TextStyle(color: ts, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
              decoration: BoxDecoration(
                color: Color(0xFF2563EB).withOpacity(dark ? 0.15 : 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Color(0xFF2563EB).withOpacity(0.25)),
              ),
              child: Row(
                children: const [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: Color(0xFF2563EB),
                    size: 14,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Secured by Razorpay',
                    style: TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: amtCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: tp, fontWeight: FontWeight.w700),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                labelStyle: TextStyle(color: ts),
                prefixIcon: const Icon(
                  Icons.savings_outlined,
                  color: Color(0xFF2563EB),
                ),
                filled: true,
                fillColor: dark
                    ? const Color(0xFF0A0F1E)
                    : const Color(0xFFF0F4FF),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(color: border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF2563EB),
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: () {
                final amt = int.tryParse(amtCtrl.text);
                if (amt == null || amt < 1) {
                  Get.snackbar(
                    'Invalid',
                    'Enter a valid amount',
                    backgroundColor: AppColors.error,
                    colorText: Colors.white,
                  );
                  return;
                }
                Get.back();
                controller.initiateCyclePayment(plan.id, amount: amt);
              },
              child: Container(
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2563EB).withOpacity(0.5),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.lock_outline_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Pay via Razorpay',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _confirmDelete(BuildContext context, String id) {
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    Get.dialog(
      Dialog(
        backgroundColor: bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.1),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: Colors.red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Delete Plan?',
                style: TextStyle(
                  color: tp,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'This will permanently remove your saving plan and all history.',
                textAlign: TextAlign.center,
                style: TextStyle(color: ts, fontSize: 13, height: 1.4),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: dark
                              ? const Color(0xFF1A2B45)
                              : const Color(0xFFF0F4FF),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            'Cancel',
                            style: TextStyle(
                              color: ts,
                              fontWeight: FontWeight.w700,
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
                        controller.deletePlan(id);
                      },
                      child: Container(
                        height: 46,
                        decoration: BoxDecoration(
                          color: Colors.red.withOpacity(dark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.4),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.red,
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
    );
  }
}

// ─── 3D Hero Header ───────────────────────────────────────────────────────────
class _HeroHeader extends StatefulWidget {
  const _HeroHeader({required this.dark, required this.controller});
  final bool dark;
  final SavingsController controller;
  @override
  State<_HeroHeader> createState() => _HeroHeaderState();
}

class _HeroHeaderState extends State<_HeroHeader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(seconds: 4))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  static String _fmt(int n) {
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    return SafeArea(
      bottom: false,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => Container(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 28),
          decoration: BoxDecoration(
            gradient: dark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0A0F1E),
                      Color(0xFF0E1626),
                      Color(0xFF0A0F1E),
                    ],
                  )
                : const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1A2340),
                      Color(0xFF243058),
                      Color(0xFF1A2340),
                    ],
                  ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.6 : 0.25),
                blurRadius: 32,
                offset: const Offset(0, 16),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: Color(0xFF2563EB).withOpacity(dark ? 0.12 : 0.06),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // Animated orbs
              Positioned(
                top: -20 + _c.value * 15,
                right: -10 + _c.value * 10,
                child: Container(
                  width: 130,
                  height: 130,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF2563EB).withOpacity(0.13),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -10 + _c.value * 10,
                left: -20,
                child: Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Color(0xFF3B82F6).withOpacity(0.10),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Back + refresh
                  Row(
                    children: [
                      _HeaderBtn(
                        icon: Icons.arrow_back_rounded,
                        onTap: () => Get.back(),
                      ),
                      const Spacer(),
                      _HeaderBtn(
                        icon: Icons.refresh_rounded,
                        onTap: widget.controller.loadSavings,
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Title
                  const Text(
                    'My Saving Plans',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Track and manage your active plans',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.5),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Summary strip
                  Obx(() {
                    final s = widget.controller.summary.value;
                    if (s == null) return const SizedBox.shrink();
                    return Row(
                      children: [
                        Expanded(
                          child: _SumChip(
                            label: 'Total Saved',
                            value: _fmt(s.totalSaved),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SumChip(
                            label: 'Active Plans',
                            value: '${s.activePlans}',
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SumChip(
                            label: 'Target',
                            value: _fmt(s.totalTarget),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderBtn extends StatelessWidget {
  const _HeaderBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
}

class _SumChip extends StatelessWidget {
  const _SumChip({required this.label, required this.value});
  final String label, value;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: Color(0xFF2563EB).withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 9,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─── Filter Tabs ──────────────────────────────────────────────────────────────
class _FilterTabs extends StatelessWidget {
  const _FilterTabs({
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
      height: 52,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.07),
            blurRadius: 14,
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
        children: ['All', 'Daily', 'Monthly'].asMap().entries.map((e) {
          final active = e.key == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(e.key),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: Color(0xFF2563EB).withOpacity(0.45),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 3,
                            offset: const Offset(2, 4),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : (dark
                                ? const Color(0xFF8A95B0)
                                : const Color(0xFF6B7280)),
                      fontSize: 13,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

// ─── 3D Plan Card ─────────────────────────────────────────────────────────────
class _PlanCard3D extends StatefulWidget {
  const _PlanCard3D({
    required this.plan,
    required this.index,
    required this.dark,
    required this.onPay,
    required this.onPause,
    required this.onDelete,
  });
  final SavingModel plan;
  final int index;
  final bool dark;
  final VoidCallback onPay, onPause, onDelete;
  @override
  State<_PlanCard3D> createState() => _PlanCard3DState();
}

class _PlanCard3DState extends State<_PlanCard3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  double _tiltX = 0, _tiltY = 0;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _fade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 80 * widget.index), () {
      if (mounted) _entry.forward();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  void _onPan(DragUpdateDetails d, double w) => setState(() {
    _tiltY = ((d.localPosition.dx / w) - 0.5) * 0.14;
    _tiltX = -((d.localPosition.dy / 350) - 0.5) * 0.08;
  });
  void _reset() => setState(() {
    _tiltX = 0;
    _tiltY = 0;
  });

  @override
  Widget build(BuildContext context) {
    final plan = widget.plan;
    final dark = widget.dark;
    final isDaily = plan.type == 'daily';
    final accent = isDaily ? Color(0xFF3B82F6) : Color(0xFF2563EB);

    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final barBg = dark ? const Color(0xFF1A2B45) : const Color(0xFFEEF2FF);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: LayoutBuilder(
            builder: (ctx, box) => GestureDetector(
              onTapDown: (_) {
                HapticFeedback.lightImpact();
                setState(() => _pressed = true);
              },
              onTapUp: (_) {
                setState(() => _pressed = false);
                _reset();
              },
              onTapCancel: () {
                setState(() => _pressed = false);
                _reset();
              },
              onPanUpdate: (d) => _onPan(d, box.maxWidth),
              onPanEnd: (_) => _reset(),
              child: Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0008)
                  ..rotateX(_pressed ? 0 : _tiltX)
                  ..rotateY(_pressed ? 0 : _tiltY)
                  ..scale(_pressed ? 0.975 : 1.0),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: accent.withOpacity(dark ? 0.18 : 0.08),
                    ),
                    boxShadow: _pressed
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                dark ? 0.50 : 0.10,
                              ),
                              blurRadius: 24,
                              offset: const Offset(0, 12),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: accent.withOpacity(dark ? 0.10 : 0.05),
                              blurRadius: 18,
                              offset: const Offset(0, 8),
                            ),
                            if (!dark)
                              BoxShadow(
                                color: Colors.white.withOpacity(0.9),
                                blurRadius: 4,
                                offset: const Offset(-2, -2),
                              ),
                          ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Colored top stripe
                      Container(
                        height: 4,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [accent, accent.withOpacity(0.5)],
                          ),
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(22),
                          ),
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 14, 12, 0),
                        child: Row(
                          children: [
                            // 3D icon box
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [accent, accent.withOpacity(0.7)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(13),
                                boxShadow: [
                                  BoxShadow(
                                    color: accent.withOpacity(0.45),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(2, 5),
                                  ),
                                ],
                              ),
                              child: Icon(
                                isDaily
                                    ? Icons.wb_sunny_rounded
                                    : Icons.calendar_month_rounded,
                                color: Colors.white,
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    isDaily ? 'Daily Saver' : 'Monthly Saver',
                                    style: TextStyle(
                                      color: dark
                                          ? const Color(0xFFEDF0FF)
                                          : const Color(0xFF1A2340),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    plan.formattedPerCycle,
                                    style: TextStyle(color: ts, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            _StatusBadge3D(plan: plan),
                            PopupMenuButton<String>(
                              icon: Icon(
                                Icons.more_vert_rounded,
                                color: ts,
                                size: 20,
                              ),
                              color: dark
                                  ? const Color(0xFF0E1626)
                                  : Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              onSelected: (v) {
                                if (v == 'pause') widget.onPause();
                                if (v == 'delete') widget.onDelete();
                              },
                              itemBuilder: (_) => [
                                PopupMenuItem(
                                  value: 'pause',
                                  child: Text(
                                    plan.isActive
                                        ? 'Pause plan'
                                        : 'Resume plan',
                                    style: TextStyle(
                                      color: dark
                                          ? const Color(0xFFEDF0FF)
                                          : const Color(0xFF1A2340),
                                    ),
                                  ),
                                ),
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Progress
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Saved',
                                      style: TextStyle(
                                        color: ts,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      plan.formattedSaved,
                                      style: TextStyle(
                                        color: accent,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      'Target',
                                      style: TextStyle(
                                        color: ts,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      plan.formattedTarget,
                                      style: TextStyle(
                                        color: dark
                                            ? const Color(0xFFEDF0FF)
                                            : const Color(0xFF1A2340),
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            // 3D progress bar
                            ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: SizedBox(
                                height: 10,
                                child: Stack(
                                  children: [
                                    Container(color: barBg),
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(
                                        begin: 0,
                                        end: plan.progressPercent,
                                      ),
                                      duration: const Duration(
                                        milliseconds: 900,
                                      ),
                                      curve: Curves.easeOutCubic,
                                      builder: (_, v, _) =>
                                          FractionallySizedBox(
                                            widthFactor: v,
                                            child: Stack(
                                              children: [
                                                Container(
                                                  decoration: BoxDecoration(
                                                    gradient: LinearGradient(
                                                      colors: [
                                                        accent,
                                                        accent.withOpacity(0.7),
                                                      ],
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: accent
                                                            .withOpacity(0.5),
                                                        blurRadius: 8,
                                                        offset: const Offset(
                                                          0,
                                                          3,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // Shine strip
                                                Positioned(
                                                  top: 2,
                                                  left: 6,
                                                  right: 6,
                                                  height: 3,
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.white
                                                          .withOpacity(0.28),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                            10,
                                                          ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                if (plan.estimatedCyclesToGoal != null &&
                                    !plan.goalReached)
                                  Text(
                                    '~${plan.estimatedCyclesToGoal} ${isDaily ? 'days' : 'months'} left',
                                    style: TextStyle(color: ts, fontSize: 10),
                                  ),
                                if (plan.goalReached)
                                  const Text(
                                    '🎯 Goal reached!',
                                    style: TextStyle(
                                      color: Color(0xFF2ecc71),
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                Text(
                                  '${(plan.progressPercent * 100).toStringAsFixed(1)}%',
                                  style: TextStyle(
                                    color: accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Action button
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                        child: _ActionBtn3D(
                          plan: plan,
                          accent: accent,
                          onTap: widget.onPay,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Status Badge ─────────────────────────────────────────────────────────────
class _StatusBadge3D extends StatelessWidget {
  const _StatusBadge3D({required this.plan});
  final SavingModel plan;
  @override
  Widget build(BuildContext context) {
    late String label;
    late Color color;
    late Color bg;
    if (!plan.isActive) {
      label = 'Paused';
      color = const Color(0xFF8A95B0);
      bg = const Color(0xFF1A2B45).withOpacity(0.5);
    } else if (!plan.firstPaymentDone) {
      label = 'Pending';
      color = const Color(0xFFF39C12);
      bg = const Color(0xFFF39C12).withOpacity(0.12);
    } else if (plan.goalReached) {
      label = '🎯 Done';
      color = const Color(0xFF2ecc71);
      bg = const Color(0xFF2ecc71).withOpacity(0.12);
    } else {
      label = 'Active';
      color = const Color(0xFF2ecc71);
      bg = const Color(0xFF2ecc71).withOpacity(0.12);
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionBtn3D extends StatefulWidget {
  const _ActionBtn3D({
    required this.plan,
    required this.accent,
    required this.onTap,
  });
  final SavingModel plan;
  final Color accent;
  final VoidCallback onTap;
  @override
  State<_ActionBtn3D> createState() => _ActionBtn3DState();
}

class _ActionBtn3DState extends State<_ActionBtn3D>
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
    final plan = widget.plan;

    if (plan.goalReached) {
      return Container(
        height: 46,
        decoration: BoxDecoration(
          color: const Color(0xFF2ecc71).withOpacity(0.1),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF2ecc71).withOpacity(0.35)),
        ),
        child: const Center(
          child: Text(
            '🎯 Goal Reached!',
            style: TextStyle(
              color: Color(0xFF27ae60),
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      );
    }

    if (!plan.firstPaymentDone) {
      return Obx(() {
        final paying = Get.find<SavingsController>().isPaying.value;
        return GestureDetector(
          onTapDown: (_) {
            if (!paying && plan.isActive) _c.forward();
          },
          onTapUp: (_) {
            _c.reverse();
            if (!paying && plan.isActive) widget.onTap();
          },
          onTapCancel: () => _c.reverse(),
          child: ScaleTransition(
            scale: _s,
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                gradient: plan.isActive && !paying
                    ? const LinearGradient(
                        colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      )
                    : null,
                color: plan.isActive && !paying
                    ? null
                    : Color(0xFF2563EB).withOpacity(0.5),
                borderRadius: BorderRadius.circular(14),
                boxShadow: plan.isActive && !paying
                    ? [
                        BoxShadow(
                          color: Color(0xFF2563EB).withOpacity(0.5),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 4,
                          offset: const Offset(2, 5),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: paying
                    ? const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 15,
                            height: 15,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Opening payment...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 15,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Pay ₹${plan.amountPerCycle} — Activate',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        );
      });
    }

    return GestureDetector(
      onTapDown: (_) {
        if (plan.isActive) _c.forward();
      },
      onTapUp: (_) {
        _c.reverse();
        if (plan.isActive) widget.onTap();
      },
      onTapCancel: () => _c.reverse(),
      child: ScaleTransition(
        scale: _s,
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            gradient: plan.isActive
                ? LinearGradient(
                    colors: [widget.accent, widget.accent.withOpacity(0.75)],
                  )
                : null,
            color: plan.isActive
                ? null
                : const Color(0xFF1A2B45).withOpacity(0.5),
            borderRadius: BorderRadius.circular(14),
            boxShadow: plan.isActive
                ? [
                    BoxShadow(
                      color: widget.accent.withOpacity(0.45),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 5),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_rounded,
                color: plan.isActive ? Colors.white : Colors.white38,
                size: 18,
              ),
              const SizedBox(width: 7),
              Text(
                'Add Savings',
                style: TextStyle(
                  color: plan.isActive ? Colors.white : Colors.white38,
                  fontWeight: FontWeight.w800,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;
  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? const Color(0xFF0E1626) : Colors.white,
                border: Border.all(color: Color(0xFF2563EB).withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF2563EB).withOpacity(0.22),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.savings_outlined,
                color: Color(0xFF2563EB),
                size: 36,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Plans Yet',
              style: TextStyle(
                color: tp,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Start a daily or monthly plan\nto grow your sqft ownership.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ts, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 26),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF2563EB).withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Create First Plan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
