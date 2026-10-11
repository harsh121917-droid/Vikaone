import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../../core/services/lock_service.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../home/controllers/main_shell_controller.dart';
import '../../investments/controllers/investments_controller.dart';
import 'help_support_view.dart';
import 'policy_detail_view.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final authCtrl = Get.find<AuthController>();
      final user = authCtrl.user.value;

      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
      final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              await authCtrl.fetchCurrentUser();
            },
            color: const Color(0xFF2563EB),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Top Header ──────────────────────────────────────────
                  _buildTopHeader(context, dark, tp, ts, border),

                  const SizedBox(height: 16),

                  // ── Executive User Identity Card ────────────────────────
                  _UserIdentityCard(user: user, dark: dark),

                  const SizedBox(height: 16),

                  // ── Investment & Portfolio Snapshot Bar ─────────────────
                  _PortfolioSnapshotBar(dark: dark),

                  const SizedBox(height: 22),

                  // ── Section 1: Investments & Assets ─────────────────────
                  _buildSectionHeader('INVESTMENTS & ASSETS', ts),
                  const SizedBox(height: 8),
                  _MenuGroupCard(
                    dark: dark,
                    children: [
                      _MenuItemTile(
                        icon: Icons.apartment_rounded,
                        iconColor: const Color(0xFF2563EB),
                        iconBg: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.1),
                        title: 'Explore Properties',
                        subtitle: 'Fractional Bricks & Full Ownership listings',
                        dark: dark,
                        onTap: () => _navigateToTab(1),
                      ),
                      _MenuItemTile(
                        icon: Icons.business_center_rounded,
                        iconColor: const Color(0xFF8B5CF6),
                        iconBg: const Color(0xFF8B5CF6).withOpacity(dark ? 0.2 : 0.1),
                        title: 'Business Opportunities',
                        subtitle: 'Warehouses, petrol pumps, dairy farms & plants',
                        dark: dark,
                        onTap: () => _navigateToTab(3),
                      ),
                      _MenuItemTile(
                        icon: Icons.layers_rounded,
                        iconColor: const Color(0xFF10B981),
                        iconBg: const Color(0xFF10B981).withOpacity(dark ? 0.2 : 0.1),
                        title: 'My Portfolio & Bricks',
                        subtitle: 'Track units, dividend earnings & yield',
                        dark: dark,
                        onTap: () => _navigateToTab(2),
                      ),
                      _MenuItemTile(
                        icon: Icons.favorite_rounded,
                        iconColor: const Color(0xFFF43F5E),
                        iconBg: const Color(0xFFF43F5E).withOpacity(dark ? 0.2 : 0.1),
                        title: 'Saved & Wishlist',
                        subtitle: 'Bookmarked real estate & deals',
                        dark: dark,
                        isLast: true,
                        onTap: () => Get.toNamed(AppRoutes.wishlist),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Section 2: Wallet & Payments ────────────────────────
                  _buildSectionHeader('WALLET & PAYMENTS', ts),
                  const SizedBox(height: 8),
                  _MenuGroupCard(
                    dark: dark,
                    children: [
                      _MenuItemTile(
                        icon: Icons.account_balance_wallet_rounded,
                        iconColor: const Color(0xFF0284C7),
                        iconBg: const Color(0xFF0284C7).withOpacity(dark ? 0.2 : 0.1),
                        title: 'VikaDrx Wallet',
                        subtitle: 'Deposit, withdraw & available investment funds',
                        dark: dark,
                        onTap: () => Get.toNamed(AppRoutes.wallet),
                      ),
                      _MenuItemTile(
                        icon: Icons.account_balance_rounded,
                        iconColor: const Color(0xFF059669),
                        iconBg: const Color(0xFF059669).withOpacity(dark ? 0.2 : 0.1),
                        title: 'Bank Accounts',
                        subtitle: 'Verified bank accounts for dividend payouts',
                        dark: dark,
                        onTap: () => Get.toNamed(AppRoutes.bankAccounts),
                      ),
                      _MenuItemTile(
                        icon: Icons.receipt_long_rounded,
                        iconColor: const Color(0xFFEA580C),
                        iconBg: const Color(0xFFEA580C).withOpacity(dark ? 0.2 : 0.1),
                        title: 'Transaction History',
                        subtitle: 'All order receipts, deposits & transfers',
                        dark: dark,
                        isLast: true,
                        onTap: () => Get.toNamed(AppRoutes.transactions),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // ── Section 3: Account & Security ───────────────────────
                  _buildSectionHeader('ACCOUNT & SECURITY', ts),
                  const SizedBox(height: 8),
                  _MenuGroupCard(
                    dark: dark,
                    children: [
                      _MenuItemTile(
                        icon: Icons.verified_user_rounded,
                        iconColor: const Color(0xFF4F46E5),
                        iconBg: const Color(0xFF4F46E5).withOpacity(dark ? 0.2 : 0.1),
                        title: 'KYC Verification',
                        subtitle: 'Identity, PAN & investor compliance',
                        badgeText: _getKycBadgeText(user?.kycStatus),
                        badgeColor: _getKycBadgeColor(user?.kycStatus),
                        dark: dark,
                        onTap: () => Get.toNamed(AppRoutes.kyc),
                      ),
                      Obx(() {
                        final hasPin = LockService.to.pinActive.value;
                        return _MenuItemTile(
                          icon: Icons.lock_outline_rounded,
                          iconColor: const Color(0xFF0D9488),
                          iconBg: const Color(0xFF0D9488).withOpacity(dark ? 0.2 : 0.1),
                          title: 'App Lock & Security',
                          subtitle: '4-Digit PIN & Biometric protection',
                          badgeText: hasPin ? 'Active 🔒' : 'Not Set',
                          badgeColor: hasPin ? const Color(0xFF10B981) : const Color(0xFF94A3B8),
                          dark: dark,
                          onTap: () => Get.toNamed(AppRoutes.security),
                        );
                      }),
                      _MenuItemTile(
                        icon: Icons.badge_outlined,
                        iconColor: const Color(0xFF6366F1),
                        iconBg: const Color(0xFF6366F1).withOpacity(dark ? 0.2 : 0.1),
                        title: 'Personal Info & Referral',
                        subtitle: 'User ID, phone, referral link & tier details',
                        dark: dark,
                        isLast: true,
                        onTap: () => _showAccountDetailsModal(context, user, dark),
                      ),
                    ],
                  ),

                  // ── Admin-Only Section (if role == 'admin') ─────────────
                  if ((user?.role ?? '').toLowerCase() == 'admin') ...[
                    const SizedBox(height: 22),
                    _buildSectionHeader('ADMIN PORTAL', const Color(0xFF7C3AED)),
                    const SizedBox(height: 8),
                    _MenuGroupCard(
                      dark: dark,
                      children: [
                        _MenuItemTile(
                          icon: Icons.analytics_rounded,
                          iconColor: const Color(0xFF7C3AED),
                          iconBg: const Color(0xFF7C3AED).withOpacity(dark ? 0.2 : 0.1),
                          title: 'Wishlist Analytics',
                          subtitle: 'Inspect properties saved by investors',
                          badgeText: 'Admin',
                          badgeColor: const Color(0xFF7C3AED),
                          dark: dark,
                          isLast: true,
                          onTap: () => Get.toNamed(AppRoutes.adminWishlist),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 22),

                  // ── Section 4: App Preferences & Support ────────────────
                  _buildSectionHeader('PREFERENCES & SUPPORT', ts),
                  const SizedBox(height: 8),
                  _MenuGroupCard(
                    dark: dark,
                    children: [
                      // Theme Switch Tile
                      _ThemeToggleTile(dark: dark),
                      _MenuItemTile(
                        icon: Icons.support_agent_rounded,
                        iconColor: const Color(0xFF06B6D4),
                        iconBg: const Color(0xFF06B6D4).withOpacity(dark ? 0.2 : 0.1),
                        title: 'Help & Support',
                        subtitle: 'Hotline, WhatsApp, query tickets & FAQs',
                        dark: dark,
                        onTap: () => Get.to(() => const HelpSupportView()),
                      ),
                      _MenuItemTile(
                        icon: Icons.gavel_rounded,
                        iconColor: const Color(0xFF64748B),
                        iconBg: const Color(0xFF64748B).withOpacity(dark ? 0.2 : 0.1),
                        title: 'Legal & Policies',
                        subtitle: 'Investor Agreement, Privacy Policy, Terms & Refund',
                        dark: dark,
                        isLast: true,
                        onTap: () => _showLegalPoliciesModal(context, dark),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // ── Sign Out Action ─────────────────────────────────────
                  _SignOutButton(dark: dark),

                  const SizedBox(height: 24),

                  // ── Brand & Security Footer ─────────────────────────────
                  Center(
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.verified_outlined,
                              size: 13,
                              color: Color(0xFF10B981),
                            ),
                            const SizedBox(width: 5),
                            Text(
                              'VikaDrx Platform • SEBI & RERA Compliant',
                              style: TextStyle(
                                color: ts,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Version 1.0.4 • 256-Bit Bank Grade Encryption',
                          style: TextStyle(
                            color: ts.withOpacity(0.7),
                            fontSize: 10,
                          ),
                        ),
                      ],
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

  // ── Top Header Bar ────────────────────────────────────────────────────────
  Widget _buildTopHeader(BuildContext context, bool dark, Color tp, Color ts, Color border) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'My Profile',
                style: TextStyle(
                  color: tp,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Manage identity, investments & security',
                style: TextStyle(color: ts, fontSize: 12),
              ),
            ],
          ),
        ),
        // Quick Security button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Get.toNamed(AppRoutes.security);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF0E1626) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: ts,
              size: 20,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Quick Theme Toggle button
        GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            ThemeController.to.toggle();
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF0E1626) : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: border),
            ),
            child: Icon(
              dark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
              color: dark ? const Color(0xFF60A5FA) : const Color(0xFFF59E0B),
              size: 19,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  void _navigateToTab(int index) {
    HapticFeedback.selectionClick();
    if (Get.isRegistered<MainShellController>()) {
      Get.find<MainShellController>().changeTab(index);
    }
  }

  String _getKycBadgeText(String? status) {
    final s = (status ?? 'pending').toLowerCase();
    if (s == 'approved' || s == 'verified') return 'Verified ✓';
    if (s == 'in_review' || s == 'submitted') return 'Under Review';
    if (s == 'rejected') return 'Rejected';
    return 'Pending';
  }

  Color _getKycBadgeColor(String? status) {
    final s = (status ?? 'pending').toLowerCase();
    if (s == 'approved' || s == 'verified') return const Color(0xFF10B981);
    if (s == 'in_review' || s == 'submitted') return const Color(0xFFF59E0B);
    if (s == 'rejected') return const Color(0xFFEF4444);
    return const Color(0xFF6366F1);
  }

  // ── Modal: Account & Referral Details ─────────────────────────────────────
  void _showAccountDetailsModal(BuildContext context, dynamic user, bool dark) {
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final refCode = (user?.referralCode != null && user!.referralCode!.isNotEmpty)
        ? user!.referralCode!
        : 'VIKA${user?.id?.toString().substring(0, 6).toUpperCase() ?? "DRX"}';

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
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
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(dark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.badge_rounded, color: Color(0xFF6366F1), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Account & Investor Details',
                  style: TextStyle(
                    color: tp,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _buildDetailRow('Full Name', user?.name ?? '—', tp, ts),
            _buildDetailRow('Email Address', user?.email ?? '—', tp, ts),
            _buildDetailRow('Phone Number', user?.phone ?? '—', tp, ts),
            _buildDetailRow('Investor Role', (user?.role ?? 'User').toUpperCase(), tp, ts),
            _buildDetailRow('Investor ID', user?.id ?? '—', tp, ts),
            const SizedBox(height: 14),
            // Referral Box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF2563EB).withOpacity(dark ? 0.15 : 0.06),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Referral Code',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2563EB),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          refCode,
                          style: TextStyle(
                            color: tp,
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(ClipboardData(text: refCode));
                      HapticFeedback.mediumImpact();
                      Get.back();
                      Get.snackbar(
                        'Copied! 📋',
                        'Referral code copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                        backgroundColor: const Color(0xFF2563EB),
                        colorText: Colors.white,
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
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
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.copy_rounded, size: 14, color: Colors.white),
                          SizedBox(width: 5),
                          Text(
                            'Copy',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12.5,
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
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(String label, String value, Color tp, Color ts) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: ts, fontSize: 13)),
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: tp,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Modal: Legal Policies Sheet ───────────────────────────────────────────
  void _showLegalPoliciesModal(BuildContext context, bool dark) {
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
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
            const SizedBox(height: 18),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(dark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.gavel_rounded, color: Color(0xFF6366F1), size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  'Legal Agreements & Policies',
                  style: TextStyle(
                    color: tp,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _PolicyModalItem(
              icon: Icons.handshake_outlined,
              title: 'Investor Agreement',
              subtitle: 'SPV & Framework terms of investment',
              dark: dark,
              onTap: () {
                Get.back();
                Get.to(() => const PolicyDetailView(
                      slug: 'investor-agreement',
                      defaultTitle: 'Investor Agreement',
                    ));
              },
            ),
            _PolicyModalItem(
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'DPDP Act & data protection guidelines',
              dark: dark,
              onTap: () {
                Get.back();
                Get.to(() => const PolicyDetailView(
                      slug: 'privacy-policy',
                      defaultTitle: 'Privacy Policy',
                    ));
              },
            ),
            _PolicyModalItem(
              icon: Icons.article_outlined,
              title: 'Terms & Conditions',
              subtitle: 'Platform usage & governance terms',
              dark: dark,
              onTap: () {
                Get.back();
                Get.to(() => const PolicyDetailView(
                      slug: 'terms-conditions',
                      defaultTitle: 'Terms & Conditions',
                    ));
              },
            ),
            _PolicyModalItem(
              icon: Icons.assignment_return_outlined,
              title: 'Refund & Cancellation Policy',
              subtitle: 'Escrow cooling-off & capital refund policy',
              dark: dark,
              isLast: true,
              onTap: () {
                Get.back();
                Get.to(() => const PolicyDetailView(
                      slug: 'refund-cancellation',
                      defaultTitle: 'Refund & Cancellation Policy',
                    ));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── EXECUTIVE USER IDENTITY CARD ─────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _UserIdentityCard extends StatelessWidget {
  const _UserIdentityCard({required this.user, required this.dark});
  final dynamic user;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final initial = (user?.name?.isNotEmpty == true ? user!.name[0] : 'U').toUpperCase();
    final name = user?.name ?? 'Valued Investor';
    final email = user?.email ?? '';
    final phone = user?.phone ?? '';
    final role = (user?.role ?? 'INVESTOR').toUpperCase();
    final kyc = (user?.kycStatus ?? 'pending').toLowerCase();
    final isKycVerified = kyc == 'approved' || kyc == 'verified';

    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0E1626) : Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Profile Row
          Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                // Avatar with gradient ring
                Container(
                  width: 62,
                  height: 62,
                  padding: const EdgeInsets.all(2.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF8B5CF6)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: dark ? const Color(0xFF0E1626) : Colors.white,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),

                // Name & Info Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: tp,
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                letterSpacing: -0.3,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              role,
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      if (email.isNotEmpty)
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(color: ts, fontSize: 12),
                        ),
                      if (phone.isNotEmpty) ...[
                        const SizedBox(height: 1),
                        Text(
                          phone,
                          style: TextStyle(color: ts, fontSize: 11.5, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // KYC Status Banner Bar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
            decoration: BoxDecoration(
              color: isKycVerified
                  ? const Color(0xFF10B981).withOpacity(dark ? 0.15 : 0.08)
                  : const Color(0xFF2563EB).withOpacity(dark ? 0.15 : 0.07),
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(21)),
              border: Border(
                top: BorderSide(
                  color: isKycVerified
                      ? const Color(0xFF10B981).withOpacity(0.2)
                      : const Color(0xFF2563EB).withOpacity(0.2),
                ),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  isKycVerified ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                  size: 16,
                  color: isKycVerified ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isKycVerified
                        ? 'KYC Verified • Full Trading & Direct Buy Active'
                        : 'Complete KYC to unlock full property deed ownership',
                    style: TextStyle(
                      color: isKycVerified ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 12,
                  color: isKycVerified ? const Color(0xFF10B981) : const Color(0xFF2563EB),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── PORTFOLIO SNAPSHOT STRIP ────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _PortfolioSnapshotBar extends StatelessWidget {
  const _PortfolioSnapshotBar({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Obx(() {
      final invCtrl = Get.isRegistered<InvestmentsController>()
          ? Get.find<InvestmentsController>()
          : null;
      final totalInvested = invCtrl?.totalInvested ?? 0;
      final totalBricks = invCtrl?.totalBricks ?? 0;
      final propCount = invCtrl?.propertyCount ?? 0;

      final investedStr = totalInvested > 0
          ? (totalInvested >= 10000000
              ? '₹${(totalInvested / 10000000).toStringAsFixed(2)} Cr'
              : (totalInvested >= 100000
                  ? '₹${(totalInvested / 100000).toStringAsFixed(1)} L'
                  : '₹$totalInvested'))
          : '₹0';

      return GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          if (Get.isRegistered<MainShellController>()) {
            Get.find<MainShellController>().changeTab(2);
          }
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0E1626) : Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border, width: 1.1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Cell 1: Total Invested
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'TOTAL INVESTED',
                      style: TextStyle(
                        color: ts,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      investedStr,
                      style: TextStyle(
                        color: tp,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: border),
              const SizedBox(width: 14),

              // Cell 2: Total Bricks
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'BRICKS OWNED',
                      style: TextStyle(
                        color: ts,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$totalBricks Units',
                      style: TextStyle(
                        color: tp,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              Container(width: 1, height: 28, color: border),
              const SizedBox(width: 14),

              // Cell 3: Active Deals
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ACTIVE ASSETS',
                      style: TextStyle(
                        color: ts,
                        fontSize: 9.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '$propCount Deals',
                      style: TextStyle(
                        color: tp,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
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
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── GROUPED MENU CONTAINER ──────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _MenuGroupCard extends StatelessWidget {
  const _MenuGroupCard({required this.dark, required this.children});
  final bool dark;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0E1626) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: border, width: 1.1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: children,
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── MENU ITEM TILE ──────────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _MenuItemTile extends StatelessWidget {
  const _MenuItemTile({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.onTap,
    this.badgeText,
    this.badgeColor,
    this.isLast = false,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final bool dark;
  final VoidCallback onTap;
  final String? badgeText;
  final Color? badgeColor;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(18),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon Squircle
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Icon(icon, color: iconColor, size: 19),
                ),
                const SizedBox(width: 14),

                // Title & Subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: tp,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 1.5),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: ts, fontSize: 11),
                      ),
                    ],
                  ),
                ),

                // Optional Badge
                if (badgeText != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (badgeColor ?? const Color(0xFF2563EB)).withOpacity(dark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeText!,
                      style: TextStyle(
                        color: badgeColor ?? const Color(0xFF2563EB),
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                ],

                // Chevron
                Icon(
                  Icons.chevron_right_rounded,
                  color: ts.withOpacity(0.6),
                  size: 20,
                ),
              ],
            ),
          ),
          if (!isLast)
            Divider(
              height: 1,
              indent: 68,
              endIndent: 16,
              color: border,
            ),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── THEME TOGGLE TILE ───────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _ThemeToggleTile extends StatelessWidget {
  const _ThemeToggleTile({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);

    final iconColor = dark ? const Color(0xFF60A5FA) : const Color(0xFFF59E0B);
    final iconBg = dark
        ? const Color(0xFF60A5FA).withOpacity(0.2)
        : const Color(0xFFF59E0B).withOpacity(0.12);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  dark ? Icons.dark_mode_rounded : Icons.wb_sunny_rounded,
                  color: iconColor,
                  size: 19,
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
                        color: tp,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 1.5),
                    Text(
                      dark ? 'Sleek midnight palette active' : 'Bright daylight palette active',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch.adaptive(
                value: dark,
                activeColor: const Color(0xFF2563EB),
                onChanged: (_) {
                  HapticFeedback.lightImpact();
                  ThemeController.to.toggle();
                },
              ),
            ],
          ),
        ),
        Divider(
          height: 1,
          indent: 68,
          endIndent: 16,
          color: border,
        ),
      ],
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── POLICY MODAL ITEM ───────────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _PolicyModalItem extends StatelessWidget {
  const _PolicyModalItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.onTap,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool dark;
  final VoidCallback onTap;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF2563EB), size: 20),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: tp,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(subtitle, style: TextStyle(color: ts, fontSize: 11.5)),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: ts, size: 20),
              ],
            ),
          ),
          if (!isLast) Divider(color: border, height: 1),
        ],
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════════
// ─── SIGN OUT ACTION BUTTON ──────────────────────────────────────────────────
// ═════════════════════════════════════════════════════════════════════════════
class _SignOutButton extends StatelessWidget {
  const _SignOutButton({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _confirmSignOut(context),
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444).withOpacity(dark ? 0.15 : 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF4444).withOpacity(0.3),
            width: 1.1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.logout_rounded, color: Color(0xFFEF4444), size: 18),
            SizedBox(width: 8),
            Text(
              'Sign Out of Account',
              style: TextStyle(
                color: Color(0xFFEF4444),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmSignOut(BuildContext context) {
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
          'Are you sure you want to sign out of your VikaDrx account on this device?',
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
              Get.back();
              Get.find<AuthController>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}
