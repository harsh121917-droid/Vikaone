import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/investments_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/grouped_investment.dart';
import '../../../routes/app_routes.dart';

class InvestmentsView extends GetView<InvestmentsController> {
  const InvestmentsView({super.key});

  static String _fmt(int n) {
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹$n';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      return Scaffold(
        backgroundColor: dark
            ? const Color(0xFF060B16)
            : const Color(0xFFECF0FF),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.accent,
                strokeWidth: 2,
              ),
            );
          }
          if (controller.errorMsg.value.isNotEmpty) {
            return _ErrorState(msg: controller.errorMsg.value, dark: dark);
          }
          if (controller.groupedHoldings.isEmpty) {
            return _EmptyState(dark: dark);
          }
          return RefreshIndicator(
            onRefresh: controller.loadInvestments,
            color: AppColors.accent,
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 120),
              children: [
                _TopBar(dark: dark),
                const SizedBox(height: 20),
                _HeroCard(
                  dark: dark,
                  total: _fmt(controller.totalInvested),
                  props: controller.propertyCount,
                  bricks: controller.totalBricks,
                ),
                const SizedBox(height: 32),
                _SectionHeader(
                  dark: dark,
                  count: controller.groupedHoldings.length,
                ),
                const SizedBox(height: 16),
                ...controller.groupedHoldings.asMap().entries.map(
                  (e) =>
                      _HoldingCard(holding: e.value, dark: dark, index: e.key),
                ),
              ],
            ),
          );
        }),
      );
    });
  }
}

// ─── Top Bar ──────────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({required this.dark});
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'My Bricks',
                    style: TextStyle(
                      color: tp,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.8,
                    ),
                  ),
                  Text(
                    'Your property portfolio',
                    style: TextStyle(color: ts, fontSize: 12),
                  ),
                ],
              ),
            ),
            // 3D button using BoxShadow only — no Positioned issues
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accent, AppColors.accentLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.5),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 4,
                    offset: const Offset(3, 5),
                  ),
                ],
              ),
              child: const Icon(
                Icons.grid_view_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.dark, required this.count});
  final bool dark;
  final int count;
  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Holdings',
              style: TextStyle(
                color: tp,
                fontSize: 20,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, AppColors.accentLight],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.45),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '$count Asset${count != 1 ? "s" : ""}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Hero Card ────────────────────────────────────────────────────────────────
class _HeroCard extends StatefulWidget {
  const _HeroCard({
    required this.dark,
    required this.total,
    required this.props,
    required this.bricks,
  });
  final bool dark;
  final String total;
  final int props, bricks;
  @override
  State<_HeroCard> createState() => _HeroCardState();
}

class _HeroCardState extends State<_HeroCard>
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

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 22),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Transform.translate(
          offset: Offset(0, -3 + _c.value * 6),
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
              borderRadius: BorderRadius.circular(26),
              border: Border.all(color: AppColors.accent.withOpacity(0.22)),
              // 3D depth via layered shadows
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.6 : 0.30),
                  blurRadius: 30,
                  offset: const Offset(0, 18),
                  spreadRadius: -4,
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.35 : 0.15),
                  blurRadius: 12,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: AppColors.accent.withOpacity(dark ? 0.18 : 0.10),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Portfolio Value',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.45),
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const Spacer(),
                    _GoldBadge('LIVE'),
                  ],
                ),
                const SizedBox(height: 12),
                // 3D shadow text
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Transform.translate(
                      offset: const Offset(2.5, 3.5),
                      child: Text(
                        widget.total,
                        style: TextStyle(
                          color: AppColors.accent.withOpacity(0.25),
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    Text(
                      widget.total,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  height: 1,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppColors.accent.withOpacity(0.45),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Stat row — simple Containers, no Stack extrusion, no Positioned
                Row(
                  children: [
                    Expanded(
                      child: _HeroStat(
                        label: 'Properties',
                        value: '${widget.props}',
                        icon: Icons.apartment_outlined,
                        color: const Color(0xFF3B82F6),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroStat(
                        label: 'Bricks',
                        value: '${widget.bricks}',
                        icon: Icons.grid_view_rounded,
                        color: const Color(0xFF2ecc71),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _HeroStat(
                        label: 'Returns',
                        value: '+0%',
                        icon: Icons.trending_up_rounded,
                        color: AppColors.accent,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero Stat (flat glass card, no extrusion Positioned) ────────────────────
class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.06),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.35)),
      boxShadow: [
        BoxShadow(
          color: color.withOpacity(0.12),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.45), fontSize: 9),
          textAlign: TextAlign.center,
        ),
      ],
    ),
  );
}

// ─── Gold Badge ───────────────────────────────────────────────────────────────
class _GoldBadge extends StatelessWidget {
  const _GoldBadge(this.label);
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: const Color(0xFFFFD700).withOpacity(0.4),
          blurRadius: 10,
        ),
      ],
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 5,
          height: 5,
          decoration: const BoxDecoration(
            color: Color(0xFF1A2340),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Colors.black,
            fontSize: 9,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ],
    ),
  );
}

// ─── Holding Card ─────────────────────────────────────────────────────────────
class _HoldingCard extends StatefulWidget {
  const _HoldingCard({
    required this.holding,
    required this.dark,
    required this.index,
  });
  final GroupedInvestment holding;
  final bool dark;
  final int index;
  @override
  State<_HoldingCard> createState() => _HoldingCardState();
}

class _HoldingCardState extends State<_HoldingCard>
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
      duration: const Duration(milliseconds: 500),
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
    _tiltY = ((d.localPosition.dx / w) - 0.5) * 0.16;
    _tiltX = -((d.localPosition.dy / 380) - 0.5) * 0.08;
  });
  void _reset() => setState(() {
    _tiltX = 0;
    _tiltY = 0;
  });

  @override
  Widget build(BuildContext context) {
    final h = widget.holding;
    final p = h.property;
    final pct = h.ownershipPercent;
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textS = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final barBg = dark ? const Color(0xFF1A2B45) : const Color(0xFFEEF2FF);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 0, 22, 28),
          child: LayoutBuilder(
            builder: (_, box) => GestureDetector(
              onTapDown: (_) {
                HapticFeedback.lightImpact();
                setState(() => _pressed = true);
              },
              onTapUp: (_) {
                setState(() => _pressed = false);
                _reset();
                if (p != null)
                  Get.toNamed(AppRoutes.propertyDetail, arguments: p.id);
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
                      color: AppColors.accent.withOpacity(dark ? 0.14 : 0.06),
                    ),
                    // Real 3D depth via BoxShadow — no separate Positioned layers needed
                    boxShadow: _pressed
                        ? []
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                dark ? 0.55 : 0.12,
                              ),
                              blurRadius: 28,
                              offset: const Offset(0, 14),
                              spreadRadius: -4,
                            ),
                            BoxShadow(
                              color: Colors.black.withOpacity(
                                dark ? 0.25 : 0.06,
                              ),
                              blurRadius: 8,
                              offset: const Offset(0, 6),
                            ),
                            BoxShadow(
                              color: AppColors.accent.withOpacity(
                                dark ? 0.10 : 0.04,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
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
                      // Image
                      _CardImg(p: p, pct: pct, dark: dark),

                      // Body
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            // 3 stat cells — plain Containers, NO Positioned extrusion
                            Row(
                              children: [
                                Expanded(
                                  child: _StatCell(
                                    label: 'Bricks',
                                    value: '${h.bricks}',
                                    color: AppColors.accent,
                                    dark: dark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _StatCell(
                                    label: 'Invested',
                                    value: h.formattedTotal,
                                    color: const Color(0xFF3B82F6),
                                    dark: dark,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: _StatCell(
                                    label: 'Avg/Brick',
                                    value: '₹${h.avgPricePerBrick}',
                                    color: const Color(0xFF2ecc71),
                                    dark: dark,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            _ProgressBar(pct: pct, barBg: barBg, textS: textS),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Icon(
                                  Icons.schedule_rounded,
                                  size: 11,
                                  color: textS,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${h.latestDate.day}/${h.latestDate.month}/${h.latestDate.year}',
                                  style: TextStyle(color: textS, fontSize: 11),
                                ),
                                const Spacer(),
                                _TxnBadge(count: h.transactionCount),
                              ],
                            ),
                          ],
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

// ─── Stat Cell (no Positioned, just BoxShadow for 3D) ────────────────────────
class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.color,
    required this.dark,
  });
  final String label, value;
  final Color color;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF0A0F1E) : const Color(0xFFF0F4FF);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
        // 3D effect with offset BoxShadow
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(dark ? 0.18 : 0.10),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.30 : 0.06),
            blurRadius: 6,
            offset: const Offset(3, 6),
          ),
          if (!dark)
            BoxShadow(
              color: Colors.white,
              blurRadius: 3,
              offset: const Offset(-1, -1),
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(color: ts, fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ─── Card Image ───────────────────────────────────────────────────────────────
class _CardImg extends StatelessWidget {
  const _CardImg({required this.p, required this.pct, required this.dark});
  final dynamic p;
  final double pct;
  final bool dark;
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
        child: p?.coverImage != null
            ? Image.network(
                p!.coverImage!,
                height: 160,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _ph(),
              )
            : _ph(),
      ),
      // Gradient
      Positioned(
        bottom: 0,
        left: 0,
        right: 0,
        height: 85,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black],
            ),
          ),
        ),
      ),
      // Property info
      Positioned(
        bottom: 12,
        left: 14,
        right: 70,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              p?.title ?? 'Property',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
                shadows: [Shadow(color: Colors.black, blurRadius: 6)],
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: AppColors.accent,
                  size: 11,
                ),
                const SizedBox(width: 2),
                Flexible(
                  child: Text(
                    p?.location.city ?? 'India',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Ownership badge — just BoxShadow for 3D, no nested Positioned
      Positioned(
        top: 12,
        right: 12,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
            ),
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB8860B).withOpacity(0.55),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.30),
                blurRadius: 4,
                offset: const Offset(3, 5),
              ),
            ],
          ),
          child: Text(
            '${pct.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.black,
              fontSize: 10,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    ],
  );

  Widget _ph() => Container(
    height: 160,
    decoration: BoxDecoration(
      gradient: dark
          ? const LinearGradient(colors: [Color(0xFF0E1626), Color(0xFF182238)])
          : const LinearGradient(
              colors: [Color(0xFFD5DCF0), Color(0xFFC5CEEA)],
            ),
      borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
    ),
    child: Center(
      child: Icon(
        Icons.home_work_outlined,
        color: dark ? const Color(0xFF4A5C7A) : const Color(0xFF9BA8C0),
        size: 48,
      ),
    ),
  );
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({
    required this.pct,
    required this.barBg,
    required this.textS,
  });
  final double pct;
  final Color barBg, textS;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Row(
        children: [
          Text(
            'Ownership',
            style: TextStyle(
              color: textS,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          const Spacer(),
          Text(
            '${pct.toStringAsFixed(2)}%',
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 10,
          child: Stack(
            children: [
              Container(color: barBg),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: (pct / 100).clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 900),
                curve: Curves.easeOutCubic,
                builder: (_, v, __) => FractionallySizedBox(
                  widthFactor: v,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.5),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}

// ─── TXN Badge ────────────────────────────────────────────────────────────────
class _TxnBadge extends StatelessWidget {
  const _TxnBadge({required this.count});
  final int count;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [AppColors.accent, AppColors.accentLight],
      ),
      borderRadius: BorderRadius.circular(13),
      boxShadow: [
        BoxShadow(
          color: AppColors.accent.withOpacity(0.45),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
        BoxShadow(
          color: Colors.black.withOpacity(0.22),
          blurRadius: 3,
          offset: const Offset(2, 4),
        ),
      ],
    ),
    child: Text(
      '$count TXN${count > 1 ? "S" : ""}',
      style: const TextStyle(
        color: Colors.white,
        fontSize: 10,
        fontWeight: FontWeight.w800,
      ),
    ),
  );
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.dark});
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    return SafeArea(
      child: Center(
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
                  border: Border.all(color: AppColors.accent.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.25),
                      blurRadius: 20,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.accent,
                  size: 34,
                ),
              ),
              const SizedBox(height: 22),
              Text(
                'No Bricks Yet',
                style: TextStyle(
                  color: tp,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Own fractions of premium properties\nand build real wealth.',
                style: TextStyle(color: ts, fontSize: 13, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              GestureDetector(
                onTap: () => Get.toNamed(AppRoutes.properties),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentLight],
                    ),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                      BoxShadow(
                        color: Colors.black.withOpacity(0.20),
                        blurRadius: 6,
                        offset: const Offset(3, 6),
                      ),
                    ],
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.search_rounded, color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text(
                        'Browse Properties',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
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
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.msg, required this.dark});
  final String msg;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.error.withOpacity(0.1),
                  border: Border.all(color: AppColors.error.withOpacity(0.3)),
                ),
                child: const Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: 28,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                msg,
                textAlign: TextAlign.center,
                style: TextStyle(color: ts, fontSize: 14),
              ),
              const SizedBox(height: 18),
              GestureDetector(
                onTap: () =>
                    Get.find<InvestmentsController>().loadInvestments(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 11,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w700,
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
}
