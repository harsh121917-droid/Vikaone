import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../properties/views/properties_view.dart';
import '../../investments/views/investments_view.dart';
import '../views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../business/views/business_view.dart';
import '../controllers/main_shell_controller.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: const _AppDrawer(),
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: const [
            HomeView(),
            PropertiesView(),
            InvestmentsView(),
            BusinessView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(
          () => _ModernNavbar(
            selected: controller.tabIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── MODERN NAVBAR ITEMS & DEFINITIONS ───────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

const _navItems = [
  _NavItemData(
    icon: Icons.grid_view_outlined,
    activeIcon: Icons.grid_view_rounded,
    label: 'Home',
  ),
  _NavItemData(
    icon: Icons.explore_outlined,
    activeIcon: Icons.explore_rounded,
    label: 'Explore',
  ),
  _NavItemData(
    icon: Icons.token_outlined,
    activeIcon: Icons.token_rounded,
    label: 'Bricks',
  ),
  _NavItemData(
    icon: Icons.business_center_outlined,
    activeIcon: Icons.business_center_rounded,
    label: 'Business',
  ),
  _NavItemData(
    icon: Icons.person_outline_rounded,
    activeIcon: Icons.person_rounded,
    label: 'Profile',
  ),
];

// ═════════════════════════════════════════════════════════════════════════════
// ─── MODERN FLOATING GLASS NAVBAR (LIGHT & DARK SUPPORT) ─────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _ModernNavbar extends StatelessWidget {
  const _ModernNavbar({required this.selected, required this.onTap});

  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final navBg = dark
        ? const Color(0xFF0B1220).withOpacity(0.92)
        : Colors.white.withOpacity(0.95);
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
          child: Container(
            height: 68,
            padding: const EdgeInsets.symmetric(horizontal: 6),
            decoration: BoxDecoration(
              color: navBg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: border, width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.45 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                  spreadRadius: -2,
                ),
                BoxShadow(
                  color: const Color(0xFF2563EB).withOpacity(dark ? 0.15 : 0.05),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                _navItems.length,
                (i) => Expanded(
                  child: _ModernNavBtn(
                    item: _navItems[i],
                    active: i == selected,
                    dark: dark,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(i);
                    },
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

// ─── Individual Modern Nav Button with Scale & Micro-indicator ────────────────
class _ModernNavBtn extends StatefulWidget {
  const _ModernNavBtn({
    required this.item,
    required this.active,
    required this.dark,
    required this.onTap,
  });

  final _NavItemData item;
  final bool active, dark;
  final VoidCallback onTap;

  @override
  State<_ModernNavBtn> createState() => _ModernNavBtnState();
}

class _ModernNavBtnState extends State<_ModernNavBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    if (widget.active) _ctrl.value = 1.0;
  }

  @override
  void didUpdateWidget(covariant _ModernNavBtn old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _ctrl.forward(from: 0.0);
    } else if (!widget.active && old.active) {
      _ctrl.reverse();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final dark = widget.dark;
    final activeText = dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB);
    final inactiveText = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      behavior: HitTestBehavior.opaque,
      child: AnimatedScale(
        scale: _pressed ? 0.92 : 1.0,
        duration: const Duration(milliseconds: 100),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon Container
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                width: active ? 44 : 36,
                height: 32,
                decoration: BoxDecoration(
                  gradient: active
                      ? const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: active
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(dark ? 0.45 : 0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Icon(
                    active ? widget.item.activeIcon : widget.item.icon,
                    color: active ? Colors.white : inactiveText,
                    size: active ? 19 : 20,
                  ),
                ),
              ),

              const SizedBox(height: 3),

              // Label
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: active ? activeText : inactiveText,
                  fontSize: 10,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  letterSpacing: active ? 0.2 : 0,
                ),
                child: Text(widget.item.label),
              ),

              const SizedBox(height: 2),

              // Micro Indicator Dot
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeOut,
                width: active ? 12 : 0,
                height: 2.5,
                decoration: BoxDecoration(
                  color: active ? activeText : Colors.transparent,
                  borderRadius: BorderRadius.circular(2),
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
// ─── MODERN LUXURY APP DRAWER (BLUE THEME + LIGHT & DARK SUPPORT) ────────────
// ═════════════════════════════════════════════════════════════════════════════
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<MainShellController>();
    final auth = Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
    final wishlist = Get.isRegistered<WishlistController>() ? Get.find<WishlistController>() : null;

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : Colors.white;
      final cardBg = dark ? const Color(0xFF0E1626) : const Color(0xFFF8FAFC);
      final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

      final user = auth?.user.value;
      final userName = user?.name ?? 'Investor';
      final userEmail = user?.email ?? 'Vika Member';
      final isKycVerified = user?.kycStatus == 'approved';

      return Drawer(
        backgroundColor: bg,
        surfaceTintColor: Colors.transparent,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header: Brand Logo & Close Button ──────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 16, 12),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(13),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.35),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home_work_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Vika DRX',
                            style: TextStyle(
                              color: tp,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Real Assets • Institutional Yield',
                            style: TextStyle(
                              color: ts,
                              fontSize: 10.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Close button
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: border),
                        ),
                        child: Icon(
                          Icons.close_rounded,
                          color: ts,
                          size: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── User Identity Card ─────────────────────────────────
              GestureDetector(
                onTap: () {
                  shell.changeTab(4);
                  Get.back();
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.25 : 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.3),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            userName.isNotEmpty ? userName[0].toUpperCase() : 'V',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
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
                              userName,
                              style: TextStyle(
                                color: tp,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              userEmail,
                              style: TextStyle(
                                color: ts,
                                fontSize: 11,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            // KYC Pill
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                              decoration: BoxDecoration(
                                color: isKycVerified
                                    ? const Color(0xFF10B981).withOpacity(0.15)
                                    : const Color(0xFFF59E0B).withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: isKycVerified
                                      ? const Color(0xFF10B981).withOpacity(0.35)
                                      : const Color(0xFFF59E0B).withOpacity(0.35),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    isKycVerified
                                        ? Icons.verified_rounded
                                        : Icons.pending_outlined,
                                    size: 11,
                                    color: isKycVerified
                                        ? const Color(0xFF10B981)
                                        : const Color(0xFFF59E0B),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    isKycVerified ? 'KYC Verified' : 'KYC Pending',
                                    style: TextStyle(
                                      color: isKycVerified
                                          ? const Color(0xFF10B981)
                                          : const Color(0xFFF59E0B),
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: ts,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),

              // ── Theme Switcher Bar ─────────────────────────────────
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          dark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          dark ? 'Dark Mode' : 'Light Mode',
                          style: TextStyle(
                            color: tp,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        ThemeController.to.toggle();
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2563EB).withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Text(
                              dark ? 'Dark' : 'Light',
                              style: TextStyle(
                                color: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.sync_rounded,
                              color: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                              size: 13,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),
              Divider(height: 1, color: border.withOpacity(0.7), indent: 16, endIndent: 16),
              const SizedBox(height: 6),

              // ── Navigation Menu List ───────────────────────────────
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  children: [
                    // Section 1: Navigation
                    _SectionTitle(title: 'MAIN NAVIGATION', color: ts),
                    _DrawerMenuTile(
                      icon: Icons.home_rounded,
                      label: 'Home Dashboard',
                      dark: dark,
                      onTap: () {
                        shell.changeTab(0);
                        Get.back();
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.apartment_rounded,
                      label: 'Explore Properties',
                      dark: dark,
                      onTap: () {
                        shell.changeTab(1);
                        Get.back();
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.pie_chart_outline_rounded,
                      label: 'My Portfolio / Bricks',
                      dark: dark,
                      onTap: () {
                        shell.changeTab(2);
                        Get.back();
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.business_center_rounded,
                      label: 'Business Opportunities',
                      dark: dark,
                      onTap: () {
                        shell.changeTab(3);
                        Get.back();
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.person_outline_rounded,
                      label: 'Profile & Settings',
                      dark: dark,
                      onTap: () {
                        shell.changeTab(4);
                        Get.back();
                      },
                    ),

                    const SizedBox(height: 8),
                    _SectionTitle(title: 'FINANCE & ASSETS', color: ts),
                    _DrawerMenuTile(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Escrow Wallet',
                      dark: dark,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.wallet);
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.favorite_outline_rounded,
                      label: 'Saved Wishlist',
                      dark: dark,
                      badge: wishlist != null && wishlist.properties.isNotEmpty
                          ? '${wishlist.properties.length}'
                          : null,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.wishlist);
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.receipt_long_outlined,
                      label: 'Transaction Ledger',
                      dark: dark,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.transactions);
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.account_balance_outlined,
                      label: 'Linked Bank Accounts',
                      dark: dark,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.bankAccounts);
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.savings_outlined,
                      label: 'Savings Plans',
                      dark: dark,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.myPlans);
                      },
                    ),

                    const SizedBox(height: 8),
                    _SectionTitle(title: 'SECURITY & VERIFICATION', color: ts),
                    _DrawerMenuTile(
                      icon: Icons.verified_user_outlined,
                      label: 'KYC Identity Verification',
                      dark: dark,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.kyc);
                      },
                    ),
                    _DrawerMenuTile(
                      icon: Icons.lock_outline_rounded,
                      label: 'Security & App Passcode',
                      dark: dark,
                      onTap: () {
                        Get.back();
                        Get.toNamed(AppRoutes.security);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Sign Out
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: GestureDetector(
                        onTap: () => _confirmSignOut(context, dark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(dark ? 0.14 : 0.08),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.logout_rounded, color: Colors.red, size: 18),
                              SizedBox(width: 12),
                              Text(
                                'Sign Out',
                                style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // ── Drawer Footer ──────────────────────────────────────
              Container(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: border.withOpacity(0.7),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Vika DRX • v1.0.0',
                          style: TextStyle(
                            color: ts,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Secured by SEBI Registered Trustee',
                          style: TextStyle(
                            color: ts.withOpacity(0.7),
                            fontSize: 9.5,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: const Color(0xFF10B981).withOpacity(0.35),
                        ),
                      ),
                      child: const Text(
                        'LIVE',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.8,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  void _confirmSignOut(BuildContext context, bool dark) {
    HapticFeedback.mediumImpact();
    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? const Color(0xFF0E1626) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Sign Out?',
          style: TextStyle(
            color: dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A),
            fontWeight: FontWeight.w800,
          ),
        ),
        content: Text(
          'Are you sure you want to sign out of your Vika DRX account on this device?',
          style: TextStyle(
            color: dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B),
            fontSize: 13,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back(); // close dialog
              Get.back(); // close drawer
              if (Get.isRegistered<AuthController>()) {
                Get.find<AuthController>().logout();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Sign Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.color});
  final String title;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 16, 6),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

// ─── Modern Drawer Menu Tile ──────────────────────────────────────────────────
class _DrawerMenuTile extends StatefulWidget {
  const _DrawerMenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.dark,
    this.badge,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool dark;
  final String? badge;

  @override
  State<_DrawerMenuTile> createState() => _DrawerMenuTileState();
}

class _DrawerMenuTileState extends State<_DrawerMenuTile> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 100),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _pressed
              ? const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.12)
              : (dark ? Colors.transparent : const Color(0xFFF8FAFC)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _pressed
                ? const Color(0xFF2563EB).withOpacity(0.4)
                : (dark ? Colors.transparent : border.withOpacity(0.6)),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(dark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.25),
                ),
              ),
              child: Icon(
                widget.icon,
                color: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                size: 18,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                widget.label,
                style: TextStyle(
                  color: tp,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (widget.badge != null)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  widget.badge!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            Icon(
              Icons.chevron_right_rounded,
              color: dark ? const Color(0xFF4A5C7A) : const Color(0xFF94A3B8),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
