import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import 'package:real_estate/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import '../../../modules/auth/controllers/auth_controller.dart';

// ─── Static gold data (replace with API later) ───────────────────────────────
class GoldData {
  static double get ratePerGram => GoldController.to.buyRate;
  static double get change24h => GoldController.to.rate.value?.change24h ?? 0;
  static double get changePct24h =>
      GoldController.to.rate.value?.changePct ?? 0;
  static double get userGrams => GoldController.to.totalGrams;
  static const double jarTargetGrams = 10.0; // user-configurable in future
  static double get jarSavedGrams => GoldController.to.totalGrams;
  static const double pureness = 24;
  static double get totalValue =>
      GoldController.to.balance.value?.currentValue ?? 0;
  static double get jarPct =>
      (GoldController.to.totalGrams / jarTargetGrams * 100).clamp(0, 100);
}

class DigiGoldView extends StatefulWidget {
  const DigiGoldView({super.key});
  @override
  State<DigiGoldView> createState() => _DigiGoldViewState();
}

class _DigiGoldViewState extends State<DigiGoldView>
    with TickerProviderStateMixin {
  late final AnimationController _jarPulse;
  late final AnimationController _shimmer;
  late final AnimationController _rateFlash;
  late final Animation<double> _jarScale;
  late final Animation<double> _shimmerAnim;
  late final Animation<double> _flashAnim;

  @override
  void initState() {
    super.initState();
    _jarPulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _shimmer = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
    _rateFlash = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    )..repeat(reverse: true);
    _jarScale = Tween(
      begin: 1.0,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _jarPulse, curve: Curves.easeInOut));
    _shimmerAnim = Tween(begin: -1.0, end: 2.0).animate(_shimmer);
    _flashAnim = Tween(begin: 0.6, end: 1.0).animate(_rateFlash);
  }

  @override
  void dispose() {
    _jarPulse.dispose();
    _shimmer.dispose();
    _rateFlash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);

      return Scaffold(
        backgroundColor: bg,
        body: RefreshIndicator(
          onRefresh: () async {
            await Future.delayed(const Duration(seconds: 1));
            setState(() {});
          },
          color: const Color(0xFFD4A017),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            child: Column(
              children: [
                _HeroSection(
                  dark: dark,
                  jarScale: _jarScale,
                  shimmerAnim: _shimmerAnim,
                ),
                _RateStrip(dark: dark, flashAnim: _flashAnim),
                _QuickActions(dark: dark),
                // Savings Jar — tap to open full savings screen
                _SavingsJarPreview(dark: dark),
                _SecurityBadge(dark: dark),
                _RecentTransactions(dark: dark),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────
class _HeroSection extends StatelessWidget {
  const _HeroSection({
    required this.dark,
    required this.jarScale,
    required this.shimmerAnim,
  });
  final bool dark;
  final Animation<double> jarScale;
  final Animation<double> shimmerAnim;

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning';
    if (h < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1A1200),
                  Color(0xFF2D1F00),
                  Color(0xFF0A0800),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF3D2B00),
                  Color(0xFF6B4A00),
                  Color(0xFF3D2B00),
                ],
              ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // ── Top bar ────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _greeting,
                          style: TextStyle(
                            color: const Color(0xFFD4A017).withOpacity(0.8),
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Obx(() {
                          final user = Get.find<AuthController>().user.value;
                          return Text(
                            user?.name.split(' ')[0] ?? 'User',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.12)),
                    ),
                    child: const Icon(
                      Icons.notifications_outlined,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A017).withOpacity(0.4),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person_outline_rounded,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),

            // ── Banner with balance overlay ────────────────────────────────────
            SizedBox(
              height: 240,
              child: Stack(
                children: [
                  // Banner image — full width
                  Positioned.fill(
                    child: Image.asset(
                      'assets/images/digi_banner.png',
                      fit: BoxFit.cover,
                      alignment: Alignment.centerRight,
                    ),
                  ),

                  // Gradient overlay so left text is readable
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: dark
                              ? [
                                  const Color(0xFF1A1200),
                                  const Color(0xFF2D1F00).withOpacity(0.85),
                                  Colors.transparent,
                                ]
                              : [
                                  const Color(0xFF3D2B00),
                                  const Color(0xFF5C4000).withOpacity(0.75),
                                  Colors.transparent,
                                ],
                          stops: const [0.0, 0.45, 1.0],
                        ),
                      ),
                    ),
                  ),

                  // Balance text overlaid on left
                  Positioned(
                    left: 22,
                    top: 0,
                    bottom: 0,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'Total Gold Balance',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 5),
                            Icon(
                              Icons.visibility_outlined,
                              color: Colors.white.withOpacity(0.4),
                              size: 13,
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        // 3D shadow text
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Transform.translate(
                              offset: const Offset(2, 3),
                              child: Obx(
                                () => Text(
                                  '${GoldController.to.totalGrams.toStringAsFixed(4)}g',
                                  style: const TextStyle(
                                    color: Color(0x44D4A017),
                                    fontSize: 36,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                            ),
                            Obx(
                              () => Text(
                                '${GoldController.to.totalGrams.toStringAsFixed(4)}g',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '₹${(GoldController.to.balance.value?.currentValue ?? 0).toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 10),
                        // Change badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 9,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2ecc71).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF2ecc71).withOpacity(0.4),
                            ),
                          ),
                          child: Obx(
                            () => Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.trending_up_rounded,
                                  color: Color(0xFF2ecc71),
                                  size: 13,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '+₹${(GoldController.to.rate.value?.change24h ?? 0)} (${(GoldController.to.rate.value?.changePct ?? 0)}%)',
                                  style: TextStyle(
                                    color: Color(0xFF2ecc71),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '24K',
                                  style: const TextStyle(
                                    color: Colors.white38,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Buy Gold CTA
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.mediumImpact();
                            Get.toNamed(AppRoutes.buyGold);
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 11,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFD4A017,
                                  ).withOpacity(0.55),
                                  blurRadius: 14,
                                  offset: const Offset(0, 5),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 4,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.add_rounded,
                                  color: Colors.black,
                                  size: 16,
                                ),
                                SizedBox(width: 5),
                                Text(
                                  'Buy Gold',
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
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

  void _showBuySheet() => Get.bottomSheet(
    const _BuyGoldSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

// ─── Gold Jar Painter ─────────────────────────────────────────────────────────
class _GoldJarPainter extends CustomPainter {
  const _GoldJarPainter({required this.fillPct});
  final double fillPct;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;

    // Jar body path
    final jar = Path()
      ..moveTo(w * 0.18, h * 0.20)
      ..quadraticBezierTo(w * 0.08, h * 0.22, w * 0.06, h * 0.35)
      ..lineTo(w * 0.04, h * 0.88)
      ..quadraticBezierTo(w * 0.04, h * 0.98, w * 0.14, h * 0.98)
      ..lineTo(w * 0.86, h * 0.98)
      ..quadraticBezierTo(w * 0.96, h * 0.98, w * 0.96, h * 0.88)
      ..lineTo(w * 0.94, h * 0.35)
      ..quadraticBezierTo(w * 0.92, h * 0.22, w * 0.82, h * 0.20)
      ..close();

    // Glass jar bg
    canvas.drawPath(jar, Paint()..color = Colors.white.withOpacity(0.10));

    // Gold fill (bottom up)
    final fillH = h * 0.78 * fillPct;
    final fillTop = h * 0.98 - fillH;
    final fillRect = Rect.fromLTRB(w * 0.05, fillTop, w * 0.95, h * 0.98);
    canvas.save();
    canvas.clipPath(jar);
    canvas.drawRect(
      fillRect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFFFD700),
            const Color(0xFFD4A017),
            const Color(0xFFB8860B),
          ],
        ).createShader(fillRect),
    );
    // Gold shine wave
    final wavePath = Path()
      ..moveTo(w * 0.05, fillTop + 6)
      ..quadraticBezierTo(w * 0.3, fillTop - 4, w * 0.5, fillTop + 3)
      ..quadraticBezierTo(w * 0.7, fillTop + 10, w * 0.95, fillTop + 4)
      ..lineTo(w * 0.95, fillTop)
      ..quadraticBezierTo(w * 0.7, fillTop + 6, w * 0.5, fillTop - 1)
      ..quadraticBezierTo(w * 0.3, fillTop - 8, w * 0.05, fillTop + 2)
      ..close();
    canvas.drawPath(wavePath, Paint()..color = Colors.white.withOpacity(0.22));
    canvas.restore();

    // Jar outline
    canvas.drawPath(
      jar,
      Paint()
        ..color = const Color(0xFFFFD700).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Glass shine
    final shinePath = Path()
      ..moveTo(w * 0.18, h * 0.25)
      ..quadraticBezierTo(w * 0.13, h * 0.40, w * 0.10, h * 0.60)
      ..lineTo(w * 0.16, h * 0.60)
      ..quadraticBezierTo(w * 0.18, h * 0.42, w * 0.23, h * 0.26)
      ..close();
    canvas.drawPath(shinePath, Paint()..color = Colors.white.withOpacity(0.20));

    // Lid
    final lid = RRect.fromRectAndRadius(
      Rect.fromLTWH(w * 0.15, h * 0.10, w * 0.70, h * 0.12),
      const Radius.circular(8),
    );
    canvas.drawRRect(
      lid,
      Paint()
        ..shader = const LinearGradient(
          colors: [Color(0xFFFFD700), Color(0xFFD4A017)],
        ).createShader(Rect.fromLTWH(w * 0.15, h * 0.10, w * 0.70, h * 0.12)),
    );
    canvas.drawRRect(
      lid,
      Paint()
        ..color = const Color(0xFFB8860B).withOpacity(0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // DIGI GOLD text on lid
    final tp = TextPainter(
      text: const TextSpan(
        text: 'DIGI GOLD',
        style: TextStyle(
          color: Color(0xFF3D2B00),
          fontSize: 9,
          fontWeight: FontWeight.w900,
          letterSpacing: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, Offset(w / 2 - tp.width / 2, h * 0.13));

    // % badge
    final badgeRect = Rect.fromLTWH(w * 0.68, fillTop - 20, w * 0.28, 22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(badgeRect, const Radius.circular(10)),
      Paint()..color = const Color(0xFFFFD700),
    );
    final pctTp = TextPainter(
      text: TextSpan(
        text:
            '${((GoldController.to.totalGrams / 10.0) * 100).clamp(0, 100).toStringAsFixed(0)}%',
        style: const TextStyle(
          color: Color(0xFF3D2B00),
          fontSize: 10,
          fontWeight: FontWeight.w900,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    pctTp.paint(
      canvas,
      Offset(
        badgeRect.left + badgeRect.width / 2 - pctTp.width / 2,
        badgeRect.top + badgeRect.height / 2 - pctTp.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant _GoldJarPainter old) => old.fillPct != fillPct;
}

// ─── Rate Strip ───────────────────────────────────────────────────────────────
class _RateStrip extends StatelessWidget {
  const _RateStrip({required this.dark, required this.flashAnim});
  final bool dark;
  final Animation<double> flashAnim;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Gold icon
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD4A017).withOpacity(0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: const Center(
              child: Text(
                'Au',
                style: TextStyle(
                  color: Color(0xFF3D2B00),
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gold Rate (24K)',
                  style: TextStyle(
                    color: dark
                        ? const Color(0xFF8A95B0)
                        : const Color(0xFF6B7280),
                    fontSize: 11,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${GoldController.to.buyRate.toStringAsFixed(2)}/g',
                  style: TextStyle(
                    color: dark ? Colors.white : const Color(0xFF1A2340),
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AnimatedBuilder(
                animation: flashAnim,
                builder: (_, __) => Opacity(
                  opacity: flashAnim.value,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2ecc71).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '+₹96.00 (1.23%) ↑',
                      style: TextStyle(
                        color: Color(0xFF2ecc71),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                'Updated today, 09:30 AM',
                style: TextStyle(
                  color: dark
                      ? const Color(0xFF4A5568)
                      : const Color(0xFFADB5BD),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Quick Actions ────────────────────────────────────────────────────────────
class _QuickActions extends StatelessWidget {
  const _QuickActions({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: tp,
              fontSize: 16,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _QA(
                icon: Icons.add_circle_outline_rounded,
                label: 'Buy Gold',
                color: const Color(0xFFD4A017),
                onTap: () => Get.toNamed(AppRoutes.buyGold),
              ),
              _QA(
                icon: Icons.sell_outlined,
                label: 'Sell Gold',
                color: const Color(0xFF3B82F6),
                onTap: () => Get.toNamed(AppRoutes.sellGold),
              ),
              _QA(
                icon: Icons.card_giftcard_rounded,
                label: 'Gift Gold',
                color: const Color(0xFF2ecc71),
                onTap: () => Get.snackbar(
                  'Coming Soon',
                  'Gift Gold feature launching soon!',
                  backgroundColor: const Color(0xFF2ecc71),
                  colorText: Colors.white,
                ),
              ),
              _QA(
                icon: Icons.autorenew_rounded,
                label: 'My Gold',
                color: const Color(0xFF2ecc71),
                onTap: () => Get.toNamed(AppRoutes.myGold),
              ),
              _QA(
                icon: Icons.autorenew_rounded,
                label: 'Auto Save',
                color: const Color(0xFFAB47BC),
                isNew: true,
                onTap: () => Get.snackbar(
                  'Coming Soon',
                  'Auto Save feature launching soon!',
                  backgroundColor: const Color(0xFFAB47BC),
                  colorText: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QA extends StatefulWidget {
  const _QA({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
    this.isNew = false,
  });
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  final bool isNew;
  @override
  State<_QA> createState() => _QAState();
}

class _QAState extends State<_QA> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        setState(() => _pressed = true);
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.93 : 1.0,
        duration: const Duration(milliseconds: 120),
        child: SizedBox(
          width: 72,
          child: Column(
            children: [
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: widget.color.withOpacity(dark ? 0.15 : 0.10),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: widget.color.withOpacity(0.3)),
                      boxShadow: [
                        BoxShadow(
                          color: widget.color.withOpacity(0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(widget.icon, color: widget.color, size: 26),
                  ),
                  if (widget.isNew)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4A017),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'New',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 7),
              Text(
                widget.label,
                style: TextStyle(
                  color: dark
                      ? const Color(0xFF8A95B0)
                      : const Color(0xFF6B7280),
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Savings Jar Preview (nav to full screen) ───────────────────────────────
class _SavingsJarPreview extends StatelessWidget {
  const _SavingsJarPreview({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final grams = GoldController.to.totalGrams;
    final pct = (grams / 10.0 * 100).clamp(0.0, 100.0);
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.digiGoldSavings),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 20, 16, 0),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: dark
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF1A1200), Color(0xFF2D1F00)],
                )
              : const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF3D2B00), Color(0xFF5C4100)],
                ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD4A017).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Your Savings Jar',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Obx(
                    () => Text(
                      '${GoldController.to.totalGrams.toStringAsFixed(4)}g / 10.0g',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: SizedBox(
                      height: 8,
                      child: Stack(
                        children: [
                          Container(color: Colors.white.withOpacity(0.12)),
                          FractionallySizedBox(
                            widthFactor: (pct / 100).clamp(0.0, 1.0),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFD4A017),
                                        Color(0xFFFFD700),
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFD4A017,
                                        ).withOpacity(0.5),
                                        blurRadius: 6,
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 1,
                                  left: 4,
                                  right: 4,
                                  height: 3,
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${pct.toStringAsFixed(0)}%  ·  Tap to manage your jar',
                    style: const TextStyle(color: Colors.white38, fontSize: 11),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4A017).withOpacity(0.5),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.savings_outlined,
                          color: Color(0xFFD4A017),
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Save Gold',
                          style: TextStyle(
                            color: Color(0xFFD4A017),
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            SizedBox(
              width: 100,
              height: 120,
              child: Image.asset(
                'assets/images/jar_img.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Security Badge ───────────────────────────────────────────────────────────
class _SecurityBadge extends StatelessWidget {
  const _SecurityBadge({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
    return GestureDetector(
      onTap: () {},
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF2ecc71).withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF2ecc71).withOpacity(0.3),
                ),
              ),
              child: const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF2ecc71),
                size: 22,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '100% Safe & Secure',
                    style: TextStyle(
                      color: Color(0xFF2ecc71),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Your gold is stored in insured & secured vaults.',
                    style: TextStyle(
                      color: dark
                          ? const Color(0xFF8A95B0)
                          : const Color(0xFF6B7280),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: dark ? const Color(0xFF8A95B0) : const Color(0xFFADB5BD),
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recent Transactions ──────────────────────────────────────────────────────
class _RecentTransactions extends StatelessWidget {
  const _RecentTransactions({required this.dark});
  final bool dark;

  // transactions loaded from GoldController

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: TextStyle(
                  color: tp,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                'View All',
                style: TextStyle(
                  color: const Color(0xFFD4A017),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...GoldController.to.transactions.take(3).map((t) {
            final sign = t.isBuy ? '+' : '-';
            final grams = '${sign}${t.grams.toStringAsFixed(3)}g';
            final amt = '\u20b9${t.totalAmt.toStringAsFixed(2)}';
            return _TxnRow(
              item: _TxnItem(
                type: t.isBuy ? 'buy' : 'sell',
                label: t.isBuy ? 'Gold Purchased' : 'Gold Sold',
                sub: t.createdAt.toString().substring(0, 16),
                grams: grams,
                amt: amt,
              ),
              dark: dark,
            );
          }),
        ],
      ),
    );
  }
}

class _TxnItem {
  final String type, label, sub, grams, amt;
  const _TxnItem({
    required this.type,
    required this.label,
    required this.sub,
    required this.grams,
    required this.amt,
  });
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({required this.item, required this.dark});
  final _TxnItem item;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final isBuy = item.type == 'buy';
    final gramColor = isBuy ? const Color(0xFF2ecc71) : const Color(0xFFe74c3c);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: const Color(0xFFD4A017).withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFD4A017).withOpacity(0.3),
              ),
            ),
            child: Center(
              child: Text(
                'Au',
                style: TextStyle(
                  color: const Color(0xFFD4A017),
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    color: tp,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(item.sub, style: TextStyle(color: ts, fontSize: 11)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                item.grams,
                style: TextStyle(
                  color: gramColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(item.amt, style: TextStyle(color: ts, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Buy Gold Bottom Sheet ────────────────────────────────────────────────────
class _BuyGoldSheet extends StatefulWidget {
  const _BuyGoldSheet({this.initialTab = 'amount'});
  final String initialTab;
  @override
  State<_BuyGoldSheet> createState() => _BuyGoldSheetState();
}

class _BuyGoldSheetState extends State<_BuyGoldSheet> {
  late bool _byAmount;
  double _sliderVal = 1000;
  final _ctrl = TextEditingController();
  static const double _minAmt = 100;
  static const double _maxAmt = 100000;
  static const double _gstPct = 3.0; // 3% GST — no making charges shown

  @override
  void initState() {
    super.initState();
    _byAmount = widget.initialTab == 'amount';
    _ctrl.text = _byAmount ? '1000' : '0.100';
    _sliderVal = 1000;
  }

  double get _amount {
    if (_byAmount) return double.tryParse(_ctrl.text) ?? 0;
    return (double.tryParse(_ctrl.text) ?? 0) * GoldController.to.buyRate;
  }

  double get _grams {
    if (!_byAmount) return double.tryParse(_ctrl.text) ?? 0;
    final amt = double.tryParse(_ctrl.text) ?? 0;
    return amt / GoldController.to.buyRate;
  }

  double get _gst => _amount * _gstPct / 100;
  double get _total => _amount + _gst;
  double get _netGrams => _grams; // grams calculated on pre-GST amount

  void _setAmount(double amt) {
    setState(() {
      _byAmount = true;
      _sliderVal = amt.clamp(_minAmt, _maxAmt);
      _ctrl.text = amt.toStringAsFixed(0);
    });
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final subBg = dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5EE);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
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
              const SizedBox(height: 14),

              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_rounded, color: tp, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Buy Gold',
                    style: TextStyle(
                      color: tp,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFFD4A017).withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.notifications_outlined,
                          color: Color(0xFFD4A017),
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Price Alert',
                          style: TextStyle(
                            color: Color(0xFFD4A017),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Current rate strip
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: subBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    // jar thumbnail
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Image.asset(
                        'assets/images/jar_img.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Gold Rate (24K)',
                          style: TextStyle(color: ts, fontSize: 11),
                        ),
                        Text(
                          '₹${GoldController.to.buyRate.toStringAsFixed(2)}/g',
                          style: TextStyle(
                            color: tp,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text(
                          '+₹96.00 (1.33%) ↑',
                          style: TextStyle(
                            color: Color(0xFF2ecc71),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Updated today, 09:30 AM',
                          style: TextStyle(color: ts, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Text(
                'How much gold do you want to buy?',
                style: TextStyle(
                  color: tp,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              // By Amount / By Weight toggle
              Container(
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD4A017).withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _ToggleBtn(
                      'By Amount',
                      _byAmount,
                      () => setState(() {
                        _byAmount = true;
                        _ctrl.text = '1000';
                        _sliderVal = 1000;
                      }),
                    ),
                    _ToggleBtn(
                      'By Weight',
                      !_byAmount,
                      () => setState(() {
                        _byAmount = false;
                        _ctrl.text = '0.100';
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Amount input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: subBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Text(
                      _byAmount ? '₹' : 'g',
                      style: TextStyle(
                        color: ts,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) {
                          final val = double.tryParse(v) ?? 0;
                          setState(() {
                            if (_byAmount)
                              _sliderVal = val.clamp(_minAmt, _maxAmt);
                          });
                        },
                        style: TextStyle(
                          color: tp,
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintText: _byAmount ? '0' : '0.000',
                          hintStyle: TextStyle(
                            color: ts.withOpacity(0.4),
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (_ctrl.text.isNotEmpty && _ctrl.text != '0')
                      GestureDetector(
                        onTap: () => setState(() {
                          _ctrl.clear();
                          _sliderVal = _minAmt;
                        }),
                        child: Icon(Icons.cancel_rounded, color: ts, size: 20),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Slider (only for ₹ mode)
              if (_byAmount) ...[
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFD4A017),
                    inactiveTrackColor: border,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 11,
                      elevation: 4,
                    ),
                    overlayColor: const Color(0xFFD4A017).withOpacity(0.15),
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: _sliderVal.clamp(_minAmt, _maxAmt),
                    min: _minAmt,
                    max: _maxAmt,
                    onChanged: (v) {
                      setState(() {
                        _sliderVal = v;
                        _ctrl.text = v.toStringAsFixed(0);
                      });
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${_minAmt.toInt()}',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                    Text(
                      '₹${(_maxAmt / 1000).toInt()}K',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
              ],

              // Quick amount chips
              Row(
                children: [500, 1000, 2000, 5000]
                    .map(
                      (a) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () => _setAmount(a.toDouble()),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: (_byAmount && _ctrl.text == '$a')
                                    ? const Color(0xFFD4A017)
                                    : const Color(0xFFD4A017).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4A017,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                '+₹$a',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: (_byAmount && _ctrl.text == '$a')
                                      ? Colors.black
                                      : const Color(0xFFD4A017),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 20),

              // You will get box
              if (_amount > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: subBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 50,
                            height: 55,
                            child: Image.asset(
                              'assets/images/jar_img.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You will get',
                                  style: TextStyle(color: ts, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_netGrams.toStringAsFixed(4)}g',
                                  style: TextStyle(
                                    color: tp,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '(24K Gold)',
                                  style: TextStyle(color: ts, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          // Safe badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ecc71).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF2ecc71).withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2ecc71),
                                  size: 12,
                                ),
                                SizedBox(width: 4),
                                Text(
                                  '100% Safe\n& Secure',
                                  style: TextStyle(
                                    color: Color(0xFF2ecc71),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Divider(color: border, height: 1),
                      const SizedBox(height: 12),
                      // Breakdown — NO making charges, only GST 3%
                      _CalcRow(
                        'GST (${_gstPct.toInt()}%)',
                        '₹${_gst.toStringAsFixed(2)}',
                        ts,
                        tp,
                      ),
                      const SizedBox(height: 8),
                      Divider(color: border, height: 1),
                      const SizedBox(height: 8),
                      _CalcRow(
                        'Total Amount',
                        '₹${_total.toStringAsFixed(2)}',
                        tp,
                        tp,
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],

              // Payment method
              if (_amount > 0) ...[
                Text(
                  'Select Payment Method',
                  style: TextStyle(
                    color: tp,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                _PayMethod(
                  icon: Icons.account_balance_rounded,
                  label: 'UPI',
                  sub: 'Pay using any UPI app',
                  dark: dark,
                  border: border,
                  tp: tp,
                  ts: ts,
                ),
                const SizedBox(height: 8),
                _PayMethod(
                  icon: Icons.credit_card_rounded,
                  label: 'Debit / Credit Card',
                  sub: 'Visa, Mastercard, Rupay',
                  dark: dark,
                  border: border,
                  tp: tp,
                  ts: ts,
                ),
                const SizedBox(height: 8),
                _PayMethod(
                  icon: Icons.account_balance_outlined,
                  label: 'Net Banking',
                  sub: 'All major banks supported',
                  dark: dark,
                  border: border,
                  tp: tp,
                  ts: ts,
                ),
                const SizedBox(height: 16),
              ],

              // Safety note
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF2ecc71).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF2ecc71).withOpacity(0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF2ecc71),
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Your gold is 100% insured and stored in secure vaults.',
                        style: TextStyle(
                          color: Color(0xFF2ecc71),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Footer — total + buy button
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Payable',
                        style: TextStyle(color: ts, fontSize: 11),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _amount > 0 ? '₹${_total.toStringAsFixed(2)}' : '₹0.00',
                        style: TextStyle(
                          color: tp,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '(Inclusive of all taxes)',
                        style: TextStyle(color: ts, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _amount >= 100
                          ? () {
                              Get.back();
                              Get.snackbar(
                                'Order Placed! 🥇',
                                'Buying ${_netGrams.toStringAsFixed(4)}g gold for ₹${_total.toStringAsFixed(2)} (incl. 3% GST)',
                                backgroundColor: const Color(0xFFD4A017),
                                colorText: Colors.black,
                                snackPosition: SnackPosition.BOTTOM,
                                duration: const Duration(seconds: 3),
                              );
                            }
                          : null,
                      child: Container(
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _amount >= 100
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFD4A017),
                                    Color(0xFFFFD700),
                                  ],
                                )
                              : null,
                          color: _amount >= 100
                              ? null
                              : const Color(0xFFD4A017).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _amount >= 100
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD4A017,
                                    ).withOpacity(0.5),
                                    blurRadius: 12,
                                    offset: const Offset(0, 5),
                                  ),
                                ]
                              : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _amount >= 100 ? 'Buy Gold Securely' : 'Min ₹100',
                              style: TextStyle(
                                color: _amount >= 100
                                    ? const Color(0xFF3D2B00)
                                    : Colors.white38,
                                fontSize: 14,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'powered by ',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF3D2B00,
                                    ).withOpacity(0.6),
                                    fontSize: 10,
                                  ),
                                ),
                                Text(
                                  'Razorpay',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFF3D2B00,
                                    ).withOpacity(0.8),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget _ToggleBtn(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD4A017) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : const Color(0xFF8A95B0),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}

class _CalcRow extends StatelessWidget {
  const _CalcRow(this.label, this.value, this.lc, this.vc, {this.bold = false});
  final String label, value;
  final Color lc, vc;
  final bool bold;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: lc,
          fontSize: 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: vc,
          fontSize: 13,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    ],
  );
}

class _PayMethod extends StatefulWidget {
  const _PayMethod({
    required this.icon,
    required this.label,
    required this.sub,
    required this.dark,
    required this.border,
    required this.tp,
    required this.ts,
  });
  final IconData icon;
  final String label, sub;
  final bool dark;
  final Color border, tp, ts;
  @override
  State<_PayMethod> createState() => _PayMethodState();
}

class _PayMethodState extends State<_PayMethod> {
  bool _selected = false;
  @override
  Widget build(BuildContext context) {
    final bg = widget.dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5EE);
    return GestureDetector(
      onTap: () => setState(() => _selected = !_selected),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _selected ? const Color(0xFFD4A017).withOpacity(0.08) : bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _selected ? const Color(0xFFD4A017) : widget.border,
            width: _selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: _selected ? const Color(0xFFD4A017) : widget.ts,
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.label,
                    style: TextStyle(
                      color: widget.tp,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    widget.sub,
                    style: TextStyle(color: widget.ts, fontSize: 11),
                  ),
                ],
              ),
            ),
            if (_selected)
              const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFFD4A017),
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

// ─── Sell Gold Bottom Sheet ───────────────────────────────────────────────────
class _SellGoldSheet extends StatefulWidget {
  const _SellGoldSheet();
  @override
  State<_SellGoldSheet> createState() => _SellGoldSheetState();
}

class _SellGoldSheetState extends State<_SellGoldSheet> {
  final _ctrl = TextEditingController();
  double get _grams => double.tryParse(_ctrl.text) ?? 0;
  double get _amount => _grams * GoldController.to.buyRate;

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Sell Gold',
                style: TextStyle(
                  color: tp,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'Balance: ${GoldController.to.totalGrams}g',
                style: TextStyle(color: ts, fontSize: 13),
              ),
            ],
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _ctrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              suffixText: 'g',
              hintText: '0.000',
              hintStyle: TextStyle(color: ts),
              filled: true,
              fillColor: dark
                  ? const Color(0xFF0A0F1E)
                  : const Color(0xFFF5F5F5),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFF3B82F6),
                  width: 1.5,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (_grams > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'You receive',
                    style: TextStyle(color: ts, fontSize: 13),
                  ),
                  Text(
                    '₹${_amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      color: Color(0xFF3B82F6),
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: _grams > 0 && _grams <= GoldController.to.totalGrams
                ? () {
                    Get.back();
                    Get.snackbar(
                      'Sold! 💰',
                      'Sold ${_grams}g for ₹${_amount.toStringAsFixed(2)}',
                      backgroundColor: const Color(0xFF3B82F6),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  }
                : null,
            child: Container(
              height: 54,
              decoration: BoxDecoration(
                gradient: _grams > 0
                    ? const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                      )
                    : null,
                color: _grams > 0
                    ? null
                    : const Color(0xFF3B82F6).withOpacity(0.3),
                borderRadius: BorderRadius.circular(16),
                boxShadow: _grams > 0
                    ? [
                        BoxShadow(
                          color: const Color(0xFF3B82F6).withOpacity(0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Center(
                child: Text(
                  _grams > 0
                      ? 'Sell ${_grams}g — Get ₹${_amount.toStringAsFixed(2)}'
                      : 'Enter Grams',
                  style: TextStyle(
                    color: _grams > 0 ? Colors.white : Colors.white38,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
