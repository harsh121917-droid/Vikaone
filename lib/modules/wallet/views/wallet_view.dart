import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/wallet_controller.dart';

class WalletView extends StatefulWidget {
  const WalletView({super.key});

  @override
  State<WalletView> createState() => _WalletViewState();
}

class _WalletViewState extends State<WalletView> {
  bool _isBalanceVisible = true;

  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = WalletController.to;

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
      final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          child: Column(
            children: [
              // ── Top Header ──────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Get.back(),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'VikaDrx Wallet',
                            style: TextStyle(
                              color: tp,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Investment reserve & payout hub',
                            style: TextStyle(color: ts, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    // Shortcut to Bank Accounts
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.bankAccounts),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2563EB).withOpacity(0.35),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF2563EB),
                              size: 14,
                            ),
                            SizedBox(width: 5),
                            Text(
                              'Banks',
                              style: TextStyle(
                                color: Color(0xFF2563EB),
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

              // ── Main Scrollable Body ─────────────────────────────────────
              Expanded(
                child: ctrl.isLoading.value
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF2563EB),
                          strokeWidth: 2.5,
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: ctrl.loadAll,
                        color: const Color(0xFF2563EB),
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // ── 1. Virtual Executive Wallet Card ─────────
                              _buildVirtualCard(ctrl, dark),

                              const SizedBox(height: 18),

                              // ── 2. Primary Action Buttons ────────────────
                              _buildActionGrid(context, ctrl, dark),

                              const SizedBox(height: 20),

                              // ── 3. Quick Deposit Presets ─────────────────
                              _buildQuickDepositRow(context, ctrl, dark),

                              const SizedBox(height: 20),

                              // ── 4. Escrow Safeguard Banner ───────────────
                              _buildEscrowSafeguardCard(dark),

                              const SizedBox(height: 22),

                              // ── 5. Recent Activity / Transactions ────────
                              _buildRecentTransactionsSection(ctrl, dark),
                            ],
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Virtual Executive Wallet Card ─────────────────────────────────────────
  Widget _buildVirtualCard(WalletController ctrl, bool dark) {
    final avail = ctrl.wallet.value?.availableBalance ?? 0;
    final locked = ctrl.wallet.value?.lockedBalance ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3A8A), // Deep Navy
            Color(0xFF2563EB), // Royal Blue
            Color(0xFF4F46E5), // Indigo
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Chip icon + Label + Eye icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 32,
                    height: 24,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFBBF24).withOpacity(0.85),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Container(
                        width: 24,
                        height: 16,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black26, width: 1),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'VIKADRX RESERVE WALLET',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  setState(() => _isBalanceVisible = !_isBalanceVisible);
                },
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isBalanceVisible ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Available Balance
          const Text(
            'AVAILABLE BALANCE',
            style: TextStyle(
              color: Colors.white60,
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isBalanceVisible
                ? '₹ ${avail >= 100000 ? '${(avail / 100000).toStringAsFixed(2)} L' : avail.toStringAsFixed(2)}'
                : '₹ ••••••••',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.5,
            ),
          ),

          const SizedBox(height: 14),

          // Bottom Info Row: Locked in Escrow & Payout Tag
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (locked > 0)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.25),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.lock_outline_rounded, color: Color(0xFFFBBF24), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        _isBalanceVisible
                            ? '₹ ${locked.toStringAsFixed(0)} in Deals'
                            : 'In Escrow',
                        style: const TextStyle(
                          color: Color(0xFFFDE68A),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.flash_on_rounded, color: Color(0xFF67E8F9), size: 12),
                      SizedBox(width: 4),
                      Text(
                        '100% Liquid • 0% Fee',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              const Text(
                'Instant IMPS / UPI',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── 4 Action Grid: Add Money, Withdraw, Banks, History ────────────────────
  Widget _buildActionGrid(BuildContext context, WalletController ctrl, bool dark) {
    return Row(
      children: [
        // 1. Add Money Button
        Expanded(
          child: _buildActionCard(
            label: 'Add Funds',
            subtitle: 'Instant UPI',
            icon: Icons.add_rounded,
            iconColor: Colors.white,
            gradientColors: const [Color(0xFF2563EB), Color(0xFF1D4ED8)],
            dark: dark,
            onTap: () => _showAddMoneySheet(context, ctrl, dark),
          ),
        ),
        const SizedBox(width: 10),

        // 2. Withdraw Button
        Expanded(
          child: _buildActionCard(
            label: 'Withdraw',
            subtitle: 'To Bank A/c',
            icon: Icons.arrow_upward_rounded,
            iconColor: Colors.white,
            gradientColors: const [Color(0xFF10B981), Color(0xFF059669)],
            dark: dark,
            onTap: () => _showWithdrawSheet(context, ctrl, dark),
          ),
        ),
        const SizedBox(width: 10),

        // 3. Bank Accounts Button
        Expanded(
          child: _buildActionCard(
            label: 'Banks',
            subtitle: 'Payout A/c',
            icon: Icons.account_balance_rounded,
            iconColor: const Color(0xFF6366F1),
            bgColor: const Color(0xFF6366F1).withOpacity(dark ? 0.18 : 0.08),
            dark: dark,
            onTap: () => Get.toNamed(AppRoutes.bankAccounts),
          ),
        ),
        const SizedBox(width: 10),

        // 4. History Button
        Expanded(
          child: _buildActionCard(
            label: 'Receipts',
            subtitle: 'Statements',
            icon: Icons.receipt_long_rounded,
            iconColor: const Color(0xFFEA580C),
            bgColor: const Color(0xFFEA580C).withOpacity(dark ? 0.18 : 0.08),
            dark: dark,
            onTap: () => Get.toNamed(AppRoutes.transactions),
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required String label,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool dark,
    required VoidCallback onTap,
    List<Color> gradientColors = const [],
    Color? bgColor,
  }) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final isGradient = gradientColors.isNotEmpty;

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      child: Container(
        height: 94,
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        decoration: BoxDecoration(
          color: isGradient ? null : (dark ? const Color(0xFF0E1626) : Colors.white),
          gradient: isGradient ? LinearGradient(colors: gradientColors) : null,
          borderRadius: BorderRadius.circular(16),
          border: isGradient ? null : Border.all(color: border),
          boxShadow: isGradient
              ? [
                  BoxShadow(
                    color: gradientColors.first.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: isGradient ? Colors.white.withOpacity(0.2) : bgColor,
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 16),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isGradient ? Colors.white : tp,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            const SizedBox(height: 1),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isGradient ? Colors.white70 : ts,
                  fontSize: 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickDepositRow(BuildContext context, WalletController ctrl, bool dark) {
    final presets = [1000, 5000, 10000, 25000, 50000];
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'QUICK ADD PRESETS',
          style: TextStyle(
            color: Color(0xFF2563EB),
            fontSize: 10.5,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: presets.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final amt = presets[i];
              return GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  _showAddMoneySheet(context, ctrl, dark, prefill: amt.toDouble());
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: border),
                  ),
                  child: Center(
                    child: Text(
                      '+ ₹${amt >= 1000 ? '${(amt / 1000).toStringAsFixed(0)}k' : amt}',
                      style: TextStyle(
                        color: tp,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // ── Escrow Safeguard Banner ───────────────────────────────────────────────
  Widget _buildEscrowSafeguardCard(bool dark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF10B981).withOpacity(dark ? 0.12 : 0.06),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Color(0xFF10B981),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Segregated Escrow Safeguard',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'All funds are held in an ICICI Bank Escrow Account under SEBI-registered Universal Trusteeship instructions. Zero platform touch.',
                  style: TextStyle(
                    fontSize: 11,
                    height: 1.35,
                    color: Color(0xFF047857),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Recent Activity / Transactions Section ────────────────────────────────
  Widget _buildRecentTransactionsSection(WalletController ctrl, bool dark) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;

    final txns = ctrl.wallet.value?.transactions ?? [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ACTIVITY',
              style: TextStyle(
                color: ts,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.0,
              ),
            ),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.transactions),
              child: const Text(
                'View All →',
                style: TextStyle(
                  color: Color(0xFF2563EB),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        if (txns.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: Column(
              children: [
                Icon(Icons.receipt_long_outlined, size: 38, color: ts.withOpacity(0.5)),
                const SizedBox(height: 10),
                Text(
                  'No transactions recorded yet',
                  style: TextStyle(color: tp, fontWeight: FontWeight.w700, fontSize: 13.5),
                ),
                const SizedBox(height: 3),
                Text(
                  'Deposit funds to start investing in verified deals.',
                  style: TextStyle(color: ts, fontSize: 11),
                ),
              ],
            ),
          )
        else
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: border),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: txns.take(5).length,
              separatorBuilder: (_, _) => Divider(height: 1, indent: 64, endIndent: 16, color: border),
              itemBuilder: (context, i) {
                final t = txns[i];
                final isCredit = t.isCredit;
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  leading: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: isCredit
                          ? const Color(0xFF10B981).withOpacity(dark ? 0.2 : 0.1)
                          : const Color(0xFFEF4444).withOpacity(dark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(
                      isCredit ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                      color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      size: 18,
                    ),
                  ),
                  title: Text(
                    t.note.isNotEmpty ? t.note : (isCredit ? 'Money Added' : 'Withdrawal'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: tp,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    t.formattedDate,
                    style: TextStyle(color: ts, fontSize: 11),
                  ),
                  trailing: Text(
                    '${isCredit ? "+" : "-"} ₹${t.amount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444),
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  // ── Bottom Sheet: Add Money ───────────────────────────────────────────────
  void _showAddMoneySheet(BuildContext context, WalletController ctrl, bool dark, {double? prefill}) {
    final txtCtrl = TextEditingController(text: prefill != null ? prefill.toStringAsFixed(0) : '');
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setSheetState) {
          final amt = double.tryParse(txtCtrl.text.trim()) ?? 0;
          final isValid = amt >= 100 && amt <= 1000000;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.add_card_rounded, color: Color(0xFF2563EB), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Add Money to Wallet',
                      style: TextStyle(
                        color: tp,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Amount Input Box
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: txtCtrl,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          style: TextStyle(
                            color: tp,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Enter amount (min ₹100)',
                            hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setSheetState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Quick selector buttons
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [500, 1000, 5000, 10000, 25000].map((v) {
                    return GestureDetector(
                      onTap: () {
                        txtCtrl.text = v.toString();
                        setSheetState(() {});
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB).withOpacity(dark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                        ),
                        child: Text(
                          '+ ₹${v >= 1000 ? '${(v / 1000).toStringAsFixed(0)}k' : v}',
                          style: const TextStyle(
                            color: Color(0xFF2563EB),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),

                // Pay Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (isValid && !ctrl.isAdding.value)
                        ? () {
                            Get.back();
                            ctrl.addMoney(amt);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2563EB),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: ctrl.isAdding.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Proceed to Pay ₹${amt > 0 ? amt.toStringAsFixed(0) : ""}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }

  // ── Bottom Sheet: Withdraw Money ──────────────────────────────────────────
  void _showWithdrawSheet(BuildContext context, WalletController ctrl, bool dark) {
    final avail = ctrl.wallet.value?.availableBalance ?? 0;
    final txtCtrl = TextEditingController();
    String? selectedBankId = ctrl.defaultBank?.id;

    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Get.bottomSheet(
      StatefulBuilder(
        builder: (ctx, setSheetState) {
          final amt = double.tryParse(txtCtrl.text.trim()) ?? 0;
          final isValid = amt >= 100 && amt <= avail && selectedBankId != null;

          return Container(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
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
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF10B981).withOpacity(dark ? 0.2 : 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.arrow_upward_rounded, color: Color(0xFF10B981), size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Withdraw to Bank',
                      style: TextStyle(
                        color: tp,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Available for withdrawal: ₹${avail.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Color(0xFF10B981), fontWeight: FontWeight.w600),
                ),

                const SizedBox(height: 16),

                // Amount Input
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                  ),
                  child: Row(
                    children: [
                      const Text(
                        '₹',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: txtCtrl,
                          keyboardType: TextInputType.number,
                          autofocus: true,
                          style: TextStyle(
                            color: tp,
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                          ),
                          decoration: const InputDecoration(
                            hintText: 'Withdraw amount',
                            hintStyle: TextStyle(fontSize: 15, color: Colors.grey),
                            border: InputBorder.none,
                          ),
                          onChanged: (_) => setSheetState(() {}),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 14),

                // Bank Selection
                if (ctrl.banks.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(dark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Color(0xFFEF4444), size: 20),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'No bank account linked yet.',
                            style: TextStyle(color: Color(0xFFEF4444), fontSize: 12),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Get.back();
                            Get.toNamed(AppRoutes.addBankAccount);
                          },
                          child: const Text('Add Bank', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  )
                else ...[
                  const Text(
                    'DESTINATION ACCOUNT',
                    style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: Colors.grey),
                  ),
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: border),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedBankId,
                        isExpanded: true,
                        dropdownColor: bg,
                        items: ctrl.banks.map((b) {
                          return DropdownMenuItem<String>(
                            value: b.id,
                            child: Row(
                              children: [
                                const Icon(Icons.account_balance_rounded, size: 16, color: Color(0xFF2563EB)),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${b.bankName} (•••• ${b.accountNumber.length > 4 ? b.accountNumber.substring(b.accountNumber.length - 4) : b.accountNumber})',
                                    style: TextStyle(color: tp, fontSize: 13, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                if (b.isDefault)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF10B981).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'PRIMARY',
                                      style: TextStyle(color: Color(0xFF10B981), fontSize: 9, fontWeight: FontWeight.w800),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (val) {
                          setSheetState(() => selectedBankId = val);
                        },
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Withdraw Button
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: (isValid && !ctrl.isWithdrawing.value)
                        ? () async {
                            Get.back();
                            await ctrl.withdraw(amt, selectedBankId!);
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                    child: ctrl.isWithdrawing.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : Text(
                            'Transfer ₹${amt > 0 ? amt.toStringAsFixed(0) : ""} to Bank',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                  ),
                ),
              ],
            ),
            ),
          );
        },
      ),
      isScrollControlled: true,
    );
  }
}
