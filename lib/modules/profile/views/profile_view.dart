import '../../home/controllers/main_shell_controller.dart';
import '../../investments/controllers/investments_controller.dart';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../../core/services/lock_service.dart';
import '../../../routes/app_routes.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final user = Get.find<AuthController>().user.value;

      return Scaffold(
        backgroundColor: dark
            ? const Color(0xFF060B16)
            : const Color(0xFFF0F4FF),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _HeroSection(user: user, dark: dark),
              _StatsStrip(dark: dark),
              _MenuSection(dark: dark),
              const SizedBox(height: 100),
            ],
          ),
        ),
      );
    });
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── HERO SECTION ─────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _HeroSection extends StatefulWidget {
  const _HeroSection({required this.user, required this.dark});
  final dynamic user;
  final bool dark;
  @override
  State<_HeroSection> createState() => _HeroSectionState();
}

class _HeroSectionState extends State<_HeroSection>
    with TickerProviderStateMixin {
  late final AnimationController _orbCtrl;
  late final AnimationController _pulseCtrl;
  late final Animation<double> _orbAnim;
  late final Animation<double> _pulseAnim;
  late final AnimationController _entryCtrl;
  late final Animation<double> _entryFade;
  late final Animation<Offset> _entrySlide;

  @override
  void initState() {
    super.initState();
    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: true);
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _orbAnim = CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut);
    _pulseAnim = CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut);
    _entryFade = CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOut);
    _entrySlide = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entryCtrl, curve: Curves.easeOutCubic));
    _entryCtrl.forward();
  }

  @override
  void dispose() {
    _orbCtrl.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final initial =
        (widget.user?.name?.isNotEmpty == true ? widget.user!.name[0] : '?')
            .toUpperCase();
    final name = widget.user?.name ?? 'Guest';
    final email = widget.user?.email ?? '';
    final size = MediaQuery.sizeOf(context);

    return FadeTransition(
      opacity: _entryFade,
      child: SlideTransition(
        position: _entrySlide,
        child: Container(
          width: double.infinity,
          height: 230,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // ── Base gradient bg ──
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: dark
                        ? [
                            const Color(0xFF0A0F1E),
                            const Color(0xFF0F1829),
                            const Color(0xFF0A0F1E),
                          ]
                        : [
                            const Color(0xFF1A2340),
                            const Color(0xFF243058),
                            const Color(0xFF1A2340),
                          ],
                  ),
                ),
              ),

              // ── Animated orb 1 ──
              AnimatedBuilder(
                animation: _orbAnim,
                builder: (_, __) => Positioned(
                  top: -40 + _orbAnim.value * 30,
                  right: -30 + _orbAnim.value * 20,
                  child: Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent.withOpacity(dark ? 0.20 : 0.15),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Animated orb 2 ──
              AnimatedBuilder(
                animation: _orbAnim,
                builder: (_, __) => Positioned(
                  bottom: 20 - _orbAnim.value * 15,
                  left: -50 + _orbAnim.value * 20,
                  child: Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          const Color(
                            0xFF3B82F6,
                          ).withOpacity(dark ? 0.15 : 0.10),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // ── Grid lines (3D depth feel) ──
              CustomPaint(
                size: Size(size.width, 320),
                painter: _GridPainter(dark: dark),
              ),

              // ── Glassmorphism card ──
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(32),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(dark ? 0.05 : 0.08),
                          borderRadius: BorderRadius.circular(32),
                          border: Border.all(
                            color: Colors.white.withOpacity(dark ? 0.08 : 0.15),
                            width: 1,
                          ),
                        ),
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'My Profile',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.5),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 2,
                                  ),
                                ),
                                _GoldBadge(
                                  label: (widget.user?.role ?? 'USER')
                                      .toUpperCase(),
                                ),
                              ],
                            ),
                            const Spacer(),

                            // Avatar row
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                _HolographicAvatar(
                                  initial: initial,
                                  pulseAnim: _pulseAnim,
                                  dark: dark,
                                ),
                                const SizedBox(width: 18),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          letterSpacing: -0.4,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        email,
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.5),
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 10),
                                      _StatusPill(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // ── Bottom overlap fade ──
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                height: 60,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        (dark
                            ? const Color(0xFF060B16)
                            : const Color(0xFFF0F4FF)),
                      ],
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

// ─── Grid painter (depth lines) ───────────────────────────────────────────────
class _GridPainter extends CustomPainter {
  const _GridPainter({required this.dark});
  final bool dark;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(dark ? 0.03 : 0.04)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

// ─── Gold Badge ───────────────────────────────────────────────────────────────
class _GoldBadge extends StatelessWidget {
  const _GoldBadge({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [DarkColors.goldDark, DarkColors.goldLight],
      ),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: DarkColors.goldLight.withOpacity(0.5),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: Colors.black,
        fontSize: 9,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.5,
      ),
    ),
  );
}

// ─── Status Pill ─────────────────────────────────────────────────────────────
class _StatusPill extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: const Color(0xFF2ecc71).withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: const Color(0xFF2ecc71).withOpacity(0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 6,
          height: 6,
          decoration: const BoxDecoration(
            color: Color(0xFF2ecc71),
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 5),
        const Text(
          'Active Investor',
          style: TextStyle(
            color: Color(0xFF2ecc71),
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}

// ─── Holographic Avatar ───────────────────────────────────────────────────────
class _HolographicAvatar extends StatelessWidget {
  const _HolographicAvatar({
    required this.initial,
    required this.pulseAnim,
    required this.dark,
  });
  final String initial;
  final Animation<double> pulseAnim;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseAnim,
      builder: (_, __) => SizedBox(
        width: 82,
        height: 82,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse ring
            Container(
              width: 82 + pulseAnim.value * 8,
              height: 82 + pulseAnim.value * 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent.withOpacity(
                    0.15 + pulseAnim.value * 0.1,
                  ),
                  width: 1,
                ),
              ),
            ),
            // Mid ring
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: SweepGradient(
                  colors: [
                    DarkColors.goldDark,
                    AppColors.accent,
                    const Color(0xFF3B82F6),
                    DarkColors.goldLight,
                    DarkColors.goldDark,
                  ],
                  transform: GradientRotation(pulseAnim.value * 0.5),
                ),
              ),
            ),
            // Inner dark ring
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? const Color(0xFF0A0F1E) : const Color(0xFF1A2340),
              ),
            ),
            // Avatar surface with 3D sheen
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  center: const Alignment(-0.5, -0.5),
                  colors: dark
                      ? [const Color(0xFF1A2340), const Color(0xFF0F1420)]
                      : [const Color(0xFF243058), const Color(0xFF1A2340)],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(
                      0.3 + pulseAnim.value * 0.2,
                    ),
                    blurRadius: 16,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  initial,
                  style: TextStyle(
                    color: AppColors.accent,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    shadows: [
                      Shadow(
                        color: AppColors.accent.withOpacity(0.8),
                        blurRadius: 12,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── STATS STRIP ──────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
void _openProperties() {
  HapticFeedback.lightImpact();
  if (Get.isRegistered<MainShellController>()) {
    Get.find<MainShellController>().changeTab(1);
  } else {
    Get.toNamed(AppRoutes.properties);
  }
}

void _openMyBricks() {
  HapticFeedback.lightImpact();
  if (Get.isRegistered<MainShellController>()) {
    Get.find<MainShellController>().changeTab(2);
  } else {
    Get.toNamed(AppRoutes.investments);
  }
}

void _openSavings() {
  HapticFeedback.lightImpact();
  if (Get.isRegistered<MainShellController>()) {
    Get.find<MainShellController>().changeTab(3);
  } else {
    Get.toNamed(AppRoutes.myPlans);
  }
}

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final invCtrl = Get.isRegistered<InvestmentsController>()
          ? Get.find<InvestmentsController>()
          : null;
      final totalInvested = invCtrl?.totalInvested ?? 0;
      final propCount = invCtrl?.propertyCount ?? 0;
      final totalBricks = invCtrl?.totalBricks ?? 0;

      final investedStr = totalInvested > 0
          ? '₹${totalInvested >= 10000000 ? "${(totalInvested / 10000000).toStringAsFixed(1)}Cr" : (totalInvested >= 100000 ? "${(totalInvested / 100000).toStringAsFixed(1)}L" : totalInvested.toString())}'
          : '₹0';

      return Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: dark
                ? const LinearGradient(
                    colors: [Color(0xFF0F1829), Color(0xFF162035)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : const LinearGradient(
                    colors: [Color(0xFF1A2340), Color(0xFF243058)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.accent.withOpacity(dark ? 0.2 : 0.15),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.5 : 0.25),
                blurRadius: 24,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: AppColors.accent.withOpacity(0.08),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatCell(
                  value: investedStr,
                  label: 'Invested',
                  icon: Icons.account_balance_wallet_outlined,
                  onTap: _openMyBricks,
                ),
              ),
              _VertDivider(),
              Expanded(
                child: _StatCell(
                  value: '$propCount',
                  label: 'Properties',
                  icon: Icons.apartment_outlined,
                  onTap: _openProperties,
                ),
              ),
              _VertDivider(),
              Expanded(
                child: _StatCell(
                  value: '$totalBricks',
                  label: 'Bricks',
                  icon: Icons.grid_view_rounded,
                  onTap: _openMyBricks,
                ),
              ),
              _VertDivider(),
              Expanded(
                child: _StatCell(
                  value: '12.8%',
                  label: 'Target Yield',
                  icon: Icons.trending_up_rounded,
                  onTap: _openProperties,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.value,
    required this.label,
    required this.icon,
    this.onTap,
  });
  final String value, label;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cellWidget = Column(
      children: [
        Icon(icon, color: AppColors.accent, size: 16),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.5),
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );

    if (onTap == null) return cellWidget;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: cellWidget,
    );
  }
}

class _VertDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 36,
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Colors.transparent,
          Colors.white.withOpacity(0.12),
          Colors.transparent,
        ],
      ),
    ),
  );
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── MENU SECTION ─────────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _MenuSection extends StatelessWidget {
  const _MenuSection({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Quick action grid (2×2 + 1 extra)
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.grid_view_rounded,
                  label: 'My Bricks',
                  subtitle: 'Portfolio',
                  color: AppColors.accent,
                  dark: dark,
                  onTap: _openMyBricks,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  icon: Icons.verified_user_outlined,
                  label: 'KYC',
                  subtitle: 'Verification',
                  color: const Color(0xFF3B82F6),
                  dark: dark,
                  onTap: () => Get.toNamed(AppRoutes.kyc),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.apartment_outlined,
                  label: 'Properties',
                  subtitle: 'Browse',
                  color: const Color(0xFF2ecc71),
                  dark: dark,
                  onTap: _openProperties,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  icon: Icons.savings_outlined,
                  label: 'Savings',
                  subtitle: 'My Plans',
                  color: const Color(0xFFAB47BC),
                  dark: dark,
                  onTap: _openSavings,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _QuickCard(
                  icon: Icons.account_balance_wallet_rounded,
                  label: 'Wallet',
                  subtitle: 'Add / manage money',
                  color: const Color(0xFF3B82F6),
                  dark: dark,
                  onTap: () => Get.toNamed(AppRoutes.wallet),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickCard(
                  icon: Icons.account_balance_rounded,
                  label: 'Bank Accounts',
                  subtitle: 'Withdraw setup',
                  color: const Color(0xFF2ecc71),
                  dark: dark,
                  onTap: () => Get.toNamed(AppRoutes.bankAccounts),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Transactions — full-width card
          _QuickCard(
            icon: Icons.receipt_long_outlined,
            label: 'Transaction History',
            subtitle: 'View all receipts & payments',
            color: const Color(0xFFFF6B35),
            dark: dark,
            onTap: () => Get.toNamed(AppRoutes.transactions),
            wide: true,
          ),
          const SizedBox(height: 20),

          // Info tiles
          _InfoTile(
            icon: Icons.phone_outlined,
            label: 'Phone',
            value: Get.find<AuthController>().user.value?.phone ?? '—',
            dark: dark,
          ),
          const SizedBox(height: 10),
          _InfoTile(
            icon: Icons.badge_outlined,
            label: 'Account Type',
            value: (Get.find<AuthController>().user.value?.role ?? 'user')
                .toUpperCase(),
            dark: dark,
          ),
          const SizedBox(height: 10),
          // Security — PIN & Biometric
          Obx(() {
            final hasPin = LockService.to.pinActive.value;
            return _InfoTile(
              icon: Icons.security_rounded,
              label: 'Security',
              value: hasPin ? '🔒 PIN Active' : 'Not set',
              dark: dark,
              onTap: () => Get.toNamed('/security'),
            );
          }),
          // Admin-only analytics entry
          if ((Get.find<AuthController>().user.value?.role ?? '') ==
              'admin') ...[
            const SizedBox(height: 10),
            GestureDetector(
              onTap: () => Get.toNamed('/admin/wishlist'),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF0F1829) : Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(
                      0xFF3B82F6,
                    ).withOpacity(dark ? 0.25 : 0.12),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(
                        0xFF3B82F6,
                      ).withOpacity(dark ? 0.15 : 0.08),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                      spreadRadius: -2,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.4 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF3B82F6).withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wishlist Analytics',
                            style: TextStyle(
                              color: dark
                                  ? const Color(0xFFEDF0FF)
                                  : const Color(0xFF1A2340),
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'See who saved what properties',
                            style: TextStyle(
                              color: dark
                                  ? const Color(0xFF8A95B0)
                                  : const Color(0xFF6B7280),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF3B82F6,
                        ).withOpacity(dark ? 0.2 : 0.08),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF3B82F6),
                        size: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),

          // Theme toggle
          _ThemeCard(dark: dark),
          const SizedBox(height: 12),

          // Logout
          _LogoutCard(dark: dark),
        ],
      ),
    );
  }
}

// ─── Quick Card (2×2 grid) ────────────────────────────────────────────────────
class _QuickCard extends StatefulWidget {
  const _QuickCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.dark,
    required this.onTap,
    this.wide = false,
  });
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final bool dark;
  final VoidCallback onTap;
  final bool wide;

  @override
  State<_QuickCard> createState() => _QuickCardState();
}

class _QuickCardState extends State<_QuickCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.94,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0F1829) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final textS = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.lightImpact();
        _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: widget.wide ? 70 : 114,
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: widget.color.withOpacity(dark ? 0.2 : 0.08),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.45 : 0.10),
                blurRadius: 20,
                offset: const Offset(0, 10),
                spreadRadius: -4,
              ),
              BoxShadow(
                color: widget.color.withOpacity(dark ? 0.12 : 0.06),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
              if (!dark)
                BoxShadow(
                  color: Colors.white.withOpacity(0.8),
                  blurRadius: 4,
                  offset: const Offset(-2, -2),
                ),
            ],
          ),
          child: widget.wide
              // Wide layout: icon + text side by side
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color,
                              widget.color.withOpacity(0.7),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: widget.color.withOpacity(0.45),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Icon(widget.icon, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              widget.label,
                              style: TextStyle(
                                color: textP,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              widget.subtitle,
                              style: TextStyle(color: textS, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(dark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: widget.color,
                          size: 13,
                        ),
                      ),
                    ],
                  ),
                )
              : Stack(
                  children: [
                    // Colored corner accent
                    Positioned(
                      top: -18,
                      right: -18,
                      child: Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              widget.color.withOpacity(dark ? 0.2 : 0.12),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  widget.color,
                                  widget.color.withOpacity(0.7),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: widget.color.withOpacity(0.45),
                                  blurRadius: 12,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Icon(
                              widget.icon,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.label,
                                style: TextStyle(
                                  color: textP,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                widget.subtitle,
                                style: TextStyle(color: textS, fontSize: 11),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    // Arrow
                    Positioned(
                      top: 14,
                      right: 14,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: widget.color.withOpacity(dark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          color: widget.color,
                          size: 13,
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

// ─── Info Tile ────────────────────────────────────────────────────────────────
class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.dark,
    this.onTap,
  });
  final IconData icon;
  final String label, value;
  final bool dark;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0F1829) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final textS = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.accent.withOpacity(dark ? 0.1 : 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.4 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -3,
            ),
            if (!dark)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(dark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.accent.withOpacity(0.2)),
              ),
              child: Icon(icon, color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(label, style: TextStyle(color: textS, fontSize: 13)),
            ),
            Text(
              value,
              style: TextStyle(
                color: textP,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              Icon(Icons.chevron_right_rounded, color: textS, size: 18),
            ],
          ],
        ),
      ),
    );
  }
}

// ─── Theme Card ───────────────────────────────────────────────────────────────
class _ThemeCard extends StatelessWidget {
  const _ThemeCard({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0F1829) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final textS = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final iconColor = dark ? const Color(0xFF64B5F6) : const Color(0xFFFF8F00);
    final iconBg = dark ? const Color(0xFF1A2B4A) : const Color(0xFFFFF3CD);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        ThemeController.to.toggle();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: (dark ? const Color(0xFF64B5F6) : const Color(0xFFFF8F00))
                .withOpacity(0.2),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.4 : 0.07),
              blurRadius: 16,
              offset: const Offset(0, 8),
              spreadRadius: -3,
            ),
            if (!dark)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: iconColor.withOpacity(0.3)),
              ),
              child: Icon(
                dark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
                color: iconColor,
                size: 18,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dark ? 'Dark Mode' : 'Light Mode',
                    style: TextStyle(
                      color: textP,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Tap to switch',
                    style: TextStyle(color: textS, fontSize: 11),
                  ),
                ],
              ),
            ),
            // Toggle pill
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOutCubic,
              width: 50,
              height: 28,
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                gradient: dark
                    ? const LinearGradient(
                        colors: [DarkColors.goldDark, DarkColors.goldLight],
                      )
                    : LinearGradient(
                        colors: [Colors.grey.shade300, Colors.grey.shade400],
                      ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: (dark ? AppColors.accent : Colors.grey).withOpacity(
                      0.4,
                    ),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                alignment: dark ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: dark ? Colors.black : Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.25),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    dark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
                    color: dark
                        ? DarkColors.goldLight
                        : const Color(0xFFFF8F00),
                    size: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Logout Card ──────────────────────────────────────────────────────────────
class _LogoutCard extends StatefulWidget {
  const _LogoutCard({required this.dark});
  final bool dark;
  @override
  State<_LogoutCard> createState() => _LogoutCardState();
}

class _LogoutCardState extends State<_LogoutCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 130),
    );
    _scale = Tween(
      begin: 1.0,
      end: 0.96,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        HapticFeedback.mediumImpact();
        _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        Get.find<AuthController>().logout();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFE53E3E).withOpacity(widget.dark ? 0.15 : 0.08),
                const Color(0xFFFC8181).withOpacity(widget.dark ? 0.08 : 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE53E3E).withOpacity(0.35),
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(
                  0xFFE53E3E,
                ).withOpacity(widget.dark ? 0.2 : 0.08),
                blurRadius: 16,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFE53E3E).withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFFE53E3E),
                  size: 16,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'Sign Out',
                style: TextStyle(
                  color: Color(0xFFE53E3E),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
