import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/core/theme/controllers/theme_controller.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import 'package:real_estate/routes/app_routes.dart';
import 'package:real_estate/data/repositories/wallet_repository.dart';

class WalletView extends StatelessWidget {
  const WalletView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }
    final ctrl = WalletController.to;

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: dark ? const Color(0xFF0E1626) : Colors.white,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0EDE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
            ),
          ),
          title: Text(
            'Vika DRX Wallet',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.bankAccounts),
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withOpacity(0.10),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFD4A017).withOpacity(0.35),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFFD4A017),
                      size: 13,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'Bank',
                      style: TextStyle(
                        color: Color(0xFFD4A017),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: ctrl.isLoading.value
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFD4A017),
                  strokeWidth: 2,
                ),
              )
            : RefreshIndicator(
                onRefresh: ctrl.loadAll,
                color: const Color(0xFFD4A017),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  child: Column(
                    children: [
                      // ── Hero ────────────────────────────────────────────────
                      Container(
                        color: dark ? const Color(0xFF0E1626) : Colors.white,
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Available Balance',
                                      style: TextStyle(color: ts, fontSize: 13),
                                    ),
                                    const SizedBox(height: 8),
                                    Obx(() {
                                      final avail =
                                          ctrl.wallet.value?.availableBalance ??
                                          0;
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          Transform.translate(
                                            offset: const Offset(2, 3),
                                            child: Text(
                                              '₹${avail.toStringAsFixed(2)}',
                                              style: TextStyle(
                                                color: const Color(
                                                  0xFFD4A017,
                                                ).withOpacity(0.22),
                                                fontSize: 34,
                                                fontWeight: FontWeight.w900,
                                                letterSpacing: -1,
                                              ),
                                            ),
                                          ),
                                          Text(
                                            '₹${avail.toStringAsFixed(2)}',
                                            style: const TextStyle(
                                              color: Color(0xFFD4A017),
                                              fontSize: 34,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -1,
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFFD4A017),
                                        Color(0xFFFFD700),
                                      ],
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                    ),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFFD4A017,
                                        ).withOpacity(0.4),
                                        blurRadius: 16,
                                      ),
                                    ],
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_wallet_rounded,
                                    color: Color(0xFF3D2B00),
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),

                            // Locked balance
                            Obx(() {
                              final locked =
                                  ctrl.wallet.value?.lockedBalance ?? 0;
                              if (locked <= 0) return const SizedBox.shrink();
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 9,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFFF39C12,
                                  ).withOpacity(0.10),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: const Color(
                                      0xFFF39C12,
                                    ).withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.lock_clock_outlined,
                                      color: Color(0xFFF39C12),
                                      size: 15,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '₹${locked.toStringAsFixed(2)} locked — releasing within 24h',
                                        style: const TextStyle(
                                          color: Color(0xFFF39C12),
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            // Expiry notice banner (if user has active reward money expiring soon)
                            Obx(() {
                              final w = ctrl.wallet.value;
                              if (w == null || !w.hasExpiringReward) return const SizedBox.shrink();
                              return Container(
                                margin: const EdgeInsets.only(top: 14),
                                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF59E0B).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: const Color(0xFFF59E0B).withOpacity(0.4),
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.timer_outlined, color: Color(0xFFF59E0B), size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        '₹${w.expiringAmount?.toStringAsFixed(0)} reward cash expires in ${w.expiringDaysLeft} days (${w.expiringDescription ?? "Monthly Expiry"}). Deposited funds never expire.',
                                        style: const TextStyle(
                                          color: Color(0xFFF59E0B),
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                            const SizedBox(height: 16),

                            // Stats row: Deposited (never expires) vs Reward cash vs Total Added
                            Obx(() {
                              final w = ctrl.wallet.value;
                              return Row(
                                children: [
                                  _StatChip(
                                    '₹${(w?.balance ?? 0).toStringAsFixed(0)}',
                                    'Deposited (No Expiry)',
                                    const Color(0xFF10B981),
                                    dark,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    '₹${(w?.rewardBalance ?? 0).toStringAsFixed(0)}',
                                    'Reward Cash',
                                    const Color(0xFFF59E0B),
                                    dark,
                                  ),
                                  const SizedBox(width: 8),
                                  _StatChip(
                                    '₹${(w?.totalAdded ?? 0).toStringAsFixed(0)}',
                                    'Total Added',
                                    const Color(0xFF3B82F6),
                                    dark,
                                  ),
                                ],
                              );
                            }),
                            const SizedBox(height: 22),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: _ActionBtn(
                                    icon: Icons.add_rounded,
                                    label: 'Add Money',
                                    gradient: const [
                                      Color(0xFF2ecc71),
                                      Color(0xFF27ae60),
                                    ],
                                    glowColor: const Color(0xFF2ecc71),
                                    onTap: () => Get.bottomSheet(
                                      _AddMoneySheet(dark: dark, ctrl: ctrl),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _ActionBtn(
                                    icon: Icons.arrow_upward_rounded,
                                    label: 'Withdraw',
                                    gradient: const [
                                      Color(0xFF3B82F6),
                                      Color(0xFF60A5FA),
                                    ],
                                    glowColor: const Color(0xFF3B82F6),
                                    onTap: () => Get.bottomSheet(
                                      _WithdrawSheet(dark: dark, ctrl: ctrl),
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                    ),
                                  ),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // ── Transaction history ──────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            Text(
                              'Wallet History',
                              style: TextStyle(
                                color: tp,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),

                      Obx(() {
                        final txns = ctrl.wallet.value?.transactions ?? [];
                        if (txns.isEmpty) {
                          return Padding(
                            padding: const EdgeInsets.all(40),
                            child: Column(
                              children: [
                                Icon(
                                  Icons.receipt_long_outlined,
                                  size: 48,
                                  color: ts.withOpacity(0.4),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  'No transactions yet',
                                  style: TextStyle(color: ts),
                                ),
                              ],
                            ),
                          );
                        }
                        return Column(
                          children: txns
                              .map(
                                (t) => _TxnRow(
                                  txn: t,
                                  dark: dark,
                                  cardBg: cardBg,
                                  border: border,
                                  tp: tp,
                                  ts: ts,
                                ),
                              )
                              .toList(),
                        );
                      }),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
      );
    });
  }
}

// ─── Add Money Sheet ──────────────────────────────────────────────────────────
class _AddMoneySheet extends StatefulWidget {
  const _AddMoneySheet({required this.dark, required this.ctrl});
  final bool dark;
  final WalletController ctrl;
  @override
  State<_AddMoneySheet> createState() => _AddMoneySheetState();
}

class _AddMoneySheetState extends State<_AddMoneySheet> {
  final _ctrl = TextEditingController();
  double _slider = 1000;
  static const double _MIN = 100, _MAX = 100000;
  double get _amount => double.tryParse(_ctrl.text) ?? 0;

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final subBg = dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5F0);

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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
          child: Column(
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
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_rounded, color: tp, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Money to Wallet',
                    style: TextStyle(
                      color: tp,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: subBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _amount >= _MIN
                        ? const Color(0xFF2ecc71).withOpacity(0.5)
                        : border,
                    width: _amount >= _MIN ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        color: ts,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: TextInputType.number,
                        onChanged: (v) => setState(
                          () => _slider = (double.tryParse(v) ?? 0).clamp(
                            _MIN,
                            _MAX,
                          ),
                        ),
                        style: TextStyle(
                          color: tp,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintText: '0',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                            color: ts.withOpacity(0.35),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    if (_ctrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() {
                          _ctrl.clear();
                          _slider = _MIN;
                        }),
                        child: Icon(Icons.cancel_rounded, color: ts, size: 20),
                      ),
                  ],
                ),
              ),
              if (_amount > 0 && _amount < _MIN)
                const Padding(
                  padding: EdgeInsets.only(top: 4),
                  child: Text(
                    'Minimum ₹100',
                    style: TextStyle(color: Color(0xFFe74c3c), fontSize: 12),
                  ),
                ),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFF2ecc71),
                  inactiveTrackColor: border,
                  thumbColor: Colors.white,
                  trackHeight: 4,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 11,
                    elevation: 4,
                  ),
                  overlayColor: const Color(0xFF2ecc71).withOpacity(0.15),
                ),
                child: Slider(
                  value: _slider.clamp(_MIN, _MAX),
                  min: _MIN,
                  max: _MAX,
                  onChanged: (v) => setState(() {
                    _slider = v;
                    _ctrl.text = v.toStringAsFixed(0);
                  }),
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [500, 1000, 2000, 5000, 10000].map((a) {
                  final active = _ctrl.text == '$a';
                  return GestureDetector(
                    onTap: () => setState(() {
                      _ctrl.text = '$a';
                      _slider = a.toDouble();
                    }),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 9,
                      ),
                      decoration: BoxDecoration(
                        gradient: active
                            ? const LinearGradient(
                                colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                              )
                            : null,
                        color: active ? null : subBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? Colors.transparent : border,
                        ),
                      ),
                      child: Text(
                        '+₹$a',
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : const Color(0xFF2ecc71),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(12),
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
                      size: 15,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Secured via Razorpay · UPI, Card, Net Banking',
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
              Obx(
                () => GestureDetector(
                  onTap: _amount >= _MIN && !widget.ctrl.isAdding.value
                      ? () {
                          HapticFeedback.mediumImpact();
                          Get.back();
                          widget.ctrl.addMoney(_amount);
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: _amount >= _MIN
                          ? const LinearGradient(
                              colors: [Color(0xFF2ecc71), Color(0xFF27ae60)],
                            )
                          : null,
                      color: _amount >= _MIN
                          ? null
                          : const Color(0xFF2ecc71).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _amount >= _MIN
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF2ecc71,
                                ).withOpacity(0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: widget.ctrl.isAdding.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.lock_outline_rounded,
                                  color: _amount >= _MIN
                                      ? Colors.white
                                      : Colors.white38,
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _amount >= _MIN
                                      ? 'Add ₹${_amount.toStringAsFixed(0)} Securely'
                                      : 'Min ₹100',
                                  style: TextStyle(
                                    color: _amount >= _MIN
                                        ? Colors.white
                                        : Colors.white38,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
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

// ─── Withdraw Sheet ───────────────────────────────────────────────────────────
class _WithdrawSheet extends StatefulWidget {
  const _WithdrawSheet({required this.dark, required this.ctrl});
  final bool dark;
  final WalletController ctrl;
  @override
  State<_WithdrawSheet> createState() => _WithdrawSheetState();
}

class _WithdrawSheetState extends State<_WithdrawSheet> {
  final _ctrl = TextEditingController();
  double get _amount => double.tryParse(_ctrl.text) ?? 0;
  double get _deposited => widget.ctrl.wallet.value?.balance ?? 0;
  double get _locked => widget.ctrl.wallet.value?.lockedBalance ?? 0;
  double get _withdrawable => (_deposited - _locked).clamp(0.0, double.infinity);
  double get _reward => widget.ctrl.wallet.value?.rewardBalance ?? 0;
  bool get _valid => _amount >= 100 && _amount <= _withdrawable;
  String? _selectedBankId;

  @override
  void initState() {
    super.initState();
    _selectedBankId = widget.ctrl.defaultBank?.id;
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final subBg = dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5F0);

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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
          child: Column(
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
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_rounded, color: tp, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Withdraw to Bank',
                    style: TextStyle(
                      color: tp,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Padding(
                padding: const EdgeInsets.only(left: 34),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Withdrawable: ₹${_withdrawable.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: _withdrawable >= 100
                            ? const Color(0xFF10B981)
                            : ts,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (_reward > 0)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '₹${widget.ctrl.wallet.value!.fmtReward} Reward Cash is for investing only',
                          style: const TextStyle(
                            color: Color(0xFFD4A017),
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              if (_reward > 0)
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD4A017).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFD4A017).withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline_rounded,
                        color: Color(0xFFD4A017),
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Promotional Reward Cash (₹${widget.ctrl.wallet.value!.fmtReward}) cannot be withdrawn to a bank. Only deposited funds can be withdrawn.',
                          style: TextStyle(
                            color: tp,
                            fontSize: 11.5,
                            height: 1.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: subBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _valid
                        ? const Color(0xFF3B82F6).withOpacity(0.5)
                        : border,
                    width: _valid ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      '₹',
                      style: TextStyle(
                        color: ts,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        style: TextStyle(
                          color: tp,
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintText: '0',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                            color: ts.withOpacity(0.35),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    if (_ctrl.text.isNotEmpty)
                      GestureDetector(
                        onTap: () => setState(() => _ctrl.clear()),
                        child: Icon(Icons.cancel_rounded, color: ts, size: 20),
                      ),
                  ],
                ),
              ),
              if (_amount > _withdrawable)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _withdrawable <= 0
                        ? 'No withdrawable deposited funds. Reward cash cannot be withdrawn.'
                        : 'Exceeds withdrawable balance (Max: ₹${_withdrawable.toStringAsFixed(2)})',
                    style: const TextStyle(
                      color: Color(0xFFe74c3c),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              Row(
                children: [25, 50, 75, 100].map((pct) {
                  final amt = _withdrawable * pct / 100;
                  final active = _ctrl.text == amt.toStringAsFixed(0);
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: _withdrawable > 0
                            ? () => setState(
                                  () => _ctrl.text = amt.toStringAsFixed(0),
                                )
                            : null,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 9),
                          decoration: BoxDecoration(
                            gradient: active
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFF3B82F6),
                                      Color(0xFF60A5FA),
                                    ],
                                  )
                                : null,
                            color: active ? null : subBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active ? Colors.transparent : border,
                            ),
                          ),
                          child: Column(
                            children: [
                              Text(
                                pct == 100 ? 'Max' : '$pct%',
                                style: TextStyle(
                                  color: active ? Colors.white : ts,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                '₹${amt.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: active ? Colors.white70 : ts,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(
                'Withdraw to',
                style: TextStyle(
                  color: tp,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Obx(() {
                final banks = widget.ctrl.banks;
                if (banks.isEmpty) {
                  return GestureDetector(
                    onTap: () {
                      Get.back();
                      Get.toNamed(AppRoutes.bankAccounts);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: subBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: border),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.add_rounded,
                            color: Color(0xFFD4A017),
                            size: 22,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Add a bank account first',
                            style: TextStyle(
                              color: const Color(0xFFD4A017),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Column(
                  children: banks.map((b) {
                    final active = _selectedBankId == b.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.selectionClick();
                          setState(() => _selectedBankId = b.id);
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: active
                                ? const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(dark ? 0.12 : 0.06)
                                : subBg,
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(
                              color: active ? const Color(0xFF3B82F6) : border,
                              width: active ? 1.5 : 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_balance_rounded,
                                color: Color(0xFF3B82F6),
                                size: 22,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      b.bankName,
                                      style: TextStyle(
                                        color: tp,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${b.maskedAcc}  ·  ${b.ifsc}',
                                      style: TextStyle(color: ts, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              if (b.isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFFD4A017,
                                    ).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: const Text(
                                    'Default',
                                    style: TextStyle(
                                      color: Color(0xFFD4A017),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Icon(
                                active
                                    ? Icons.check_circle_rounded
                                    : Icons.radio_button_unchecked_rounded,
                                color: active ? const Color(0xFF3B82F6) : ts,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              }),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF39C12).withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFF39C12).withOpacity(0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      color: Color(0xFFF39C12),
                      size: 14,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Amount credited within 24 hours',
                        style: TextStyle(
                          color: Color(0xFFF39C12),
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Obx(
                () => GestureDetector(
                  onTap:
                      _valid &&
                          _selectedBankId != null &&
                          !widget.ctrl.isWithdrawing.value
                      ? () async {
                          HapticFeedback.mediumImpact();
                          final ok = await widget.ctrl.withdraw(
                            _amount,
                            _selectedBankId!,
                          );
                          if (ok) Get.back();
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: _valid && _selectedBankId != null
                          ? const LinearGradient(
                              colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                            )
                          : null,
                      color: _valid
                          ? null
                          : const Color(0xFF3B82F6).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _valid
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withOpacity(0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: widget.ctrl.isWithdrawing.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.arrow_upward_rounded,
                                  color: _valid ? Colors.white : Colors.white38,
                                  size: 18,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _valid
                                      ? 'Withdraw ₹${_amount.toStringAsFixed(0)}'
                                      : (_withdrawable < 100
                                          ? 'Requires ₹100 Deposited Funds'
                                          : 'Enter amount'),
                                  style: TextStyle(
                                    color: _valid
                                        ? Colors.white
                                        : Colors.white38,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
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

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _StatChip extends StatelessWidget {
  const _StatChip(this.val, this.lbl, this.color, this.dark);
  final String val, lbl;
  final Color color;
  final bool dark;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(dark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Text(
            val,
            style: TextStyle(
              color: color,
              fontSize: 13,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            lbl,
            style: TextStyle(color: color.withOpacity(0.7), fontSize: 9),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final List<Color> gradient;
  final Color glowColor;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.mediumImpact();
      onTap();
    },
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: glowColor.withOpacity(0.4),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(height: 3),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TxnRow extends StatelessWidget {
  const _TxnRow({
    required this.txn,
    required this.dark,
    required this.cardBg,
    required this.border,
    required this.tp,
    required this.ts,
  });
  final WalletTxnModel txn;
  final bool dark;
  final Color cardBg, border, tp, ts;

  Color get _iconColor {
    switch (txn.type) {
      case 'add':
      case 'drx_deposit':
      case 'deposit':
        return const Color(0xFF2ecc71);
      case 'brick_buy':
      case 'investment':
        return const Color(0xFFD4A017);
      case 'brick_yield':
        return const Color(0xFF10B981);
      case 'withdraw':
      case 'drx_withdraw':
        return const Color(0xFFe74c3c);
      default:
        return const Color(0xFF8A95B0);
    }
  }

  IconData get _icon {
    switch (txn.type) {
      case 'add':
      case 'drx_deposit':
      case 'deposit':
        return Icons.add_rounded;
      case 'brick_buy':
      case 'investment':
        return Icons.apartment_rounded;
      case 'brick_yield':
        return Icons.trending_up_rounded;
      case 'withdraw':
      case 'drx_withdraw':
        return Icons.arrow_upward_rounded;
      default:
        return Icons.swap_horiz_rounded;
    }
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.fromLTRB(16, 0, 16, 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: border),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
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
            color: _iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _iconColor.withOpacity(0.3)),
          ),
          child: Icon(_icon, color: _iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                txn.note.isNotEmpty ? txn.note : txn.type,
                style: TextStyle(
                  color: tp,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                txn.formattedDate,
                style: TextStyle(color: ts, fontSize: 11),
              ),
            ],
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${txn.isCredit ? '+' : '-'}₹${txn.amount.toStringAsFixed(0)}',
              style: TextStyle(
                color: txn.isCredit
                    ? const Color(0xFF2ecc71)
                    : const Color(0xFFe74c3c),
                fontSize: 14,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
              decoration: BoxDecoration(
                color:
                    (txn.isSuccess
                            ? const Color(0xFF2ecc71)
                            : const Color(0xFFF39C12))
                        .withOpacity(0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                txn.isSuccess ? '✓ Done' : '⏳ Pending',
                style: TextStyle(
                  color: txn.isSuccess
                      ? const Color(0xFF2ecc71)
                      : const Color(0xFFF39C12),
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ],
    ),
  );
}
