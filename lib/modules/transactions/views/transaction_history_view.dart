import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/modules/transactions/controllers/transaction_controller.dart';
import 'package:real_estate/core/theme/app_colors.dart';
import 'package:real_estate/core/theme/controllers/theme_controller.dart';
import 'package:real_estate/data/models/transaction_model.dart';

class TransactionHistoryView extends GetView<TransactionController> {
  const TransactionHistoryView({super.key});

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
                color: bg,
                child: Column(
                  children: [
                    const SizedBox(height: 16),
                    // Tabs
                    Obx(
                      () => Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: _TabRow(
                          selected: controller.activeTab.value,
                          onTap: controller.setTab,
                          dark: dark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // List
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: AppColors.accent,
                              strokeWidth: 2,
                            ),
                          );
                        }
                        if (controller.errorMsg.value.isNotEmpty) {
                          return _ErrState(
                            msg: controller.errorMsg.value,
                            dark: dark,
                            onRetry: controller.load,
                          );
                        }
                        if (controller.filtered.isEmpty) {
                          return _EmptyState(dark: dark);
                        }
                        // Group by date
                        final grouped = _groupByDate(controller.filtered);
                        return RefreshIndicator(
                          onRefresh: controller.load,
                          color: AppColors.accent,
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                            physics: const BouncingScrollPhysics(),
                            itemCount: grouped.length,
                            itemBuilder: (_, i) {
                              final item = grouped[i];
                              if (item is String)
                                return _DateHeader(date: item, dark: dark);
                              return _TxnCard(
                                txn: item as TransactionModel,
                                dark: dark,
                              );
                            },
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

  List<dynamic> _groupByDate(List<TransactionModel> txns) {
    final result = <dynamic>[];
    String? lastDate;
    for (final t in txns) {
      final d = t.formattedDate;
      if (d != lastDate) {
        result.add(d);
        lastDate = d;
      }
      result.add(t);
    }
    return result;
  }
}

// ─── Hero Header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.dark, required this.controller});
  final bool dark;
  final TransactionController controller;

  String _fmt(int n) {
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(1)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
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
              color: Colors.black.withOpacity(dark ? 0.55 : 0.22),
              blurRadius: 28,
              offset: const Offset(0, 12),
              spreadRadius: -4,
            ),
            BoxShadow(
              color: AppColors.accent.withOpacity(0.08),
              blurRadius: 20,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _NavBtn(
                  icon: Icons.arrow_back_rounded,
                  onTap: () => Get.back(),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Transactions',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.4,
                  ),
                ),
                const Spacer(),
                _NavBtn(icon: Icons.refresh_rounded, onTap: controller.load),
              ],
            ),
            const SizedBox(height: 20),
            Obx(() {
              final s = controller.summary.value;
              if (s == null) return const SizedBox.shrink();
              return Row(
                children: [
                  Expanded(
                    child: _SumChip(
                      label: 'Total Spent',
                      value: _fmt(s.totalSpent),
                      icon: Icons.payments_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SumChip(
                      label: 'Invested',
                      value: _fmt(s.totalInvested),
                      icon: Icons.account_balance_outlined,
                      color: const Color(0xFF3B82F6),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _SumChip(
                      label: 'Saved',
                      value: _fmt(s.totalSaved),
                      icon: Icons.savings_outlined,
                      color: const Color(0xFF2ecc71),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _SumChip extends StatelessWidget {
  const _SumChip({
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
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.07),
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(height: 5),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9),
        ),
      ],
    ),
  );
}

class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white.withOpacity(0.15)),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    ),
  );
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
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 5),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Row(
        children: [
          _Tab(
            label: 'All',
            index: 0,
            selected: selected,
            onTap: onTap,
            dark: dark,
          ),
          _Tab(
            label: 'Investment',
            index: 1,
            selected: selected,
            onTap: onTap,
            dark: dark,
          ),
          _Tab(
            label: 'Savings',
            index: 2,
            selected: selected,
            onTap: onTap,
            dark: dark,
          ),
          _Tab(
            label: 'Wallet',
            index: 3,
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
    required this.index,
    required this.selected,
    required this.onTap,
    required this.dark,
  });
  final String label;
  final int index, selected;
  final ValueChanged<int> onTap;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final active = index == selected;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap(index);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
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
              label,
              style: TextStyle(
                color: active
                    ? Colors.white
                    : (dark
                          ? const Color(0xFF8A95B0)
                          : const Color(0xFF6B7280)),
                fontSize: 12,
                fontWeight: active ? FontWeight.w800 : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Date Header ──────────────────────────────────────────────────────────────
class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.date, required this.dark});
  final String date;
  final bool dark;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 16, bottom: 8),
    child: Text(
      date,
      style: TextStyle(
        color: dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280),
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    ),
  );
}

// ─── Transaction Card ─────────────────────────────────────────────────────────
class _TxnCard extends StatelessWidget {
  const _TxnCard({required this.txn, required this.dark});
  final TransactionModel txn;
  final bool dark;

  Color get _typeColor => txn.isBrick
      ? const Color(0xFF3B82F6)
      : txn.type == 'daily_saving'
      ? AppColors.accent
      : txn.isWallet
      ? (txn.isCredit ? const Color(0xFF10B981) : const Color(0xFFEF4444))
      : const Color(0xFF2ecc71);

  IconData get _typeIcon => txn.isBrick
      ? Icons.home_work_outlined
      : txn.type == 'daily_saving'
      ? Icons.wb_sunny_rounded
      : txn.isWallet
      ? (txn.isCredit
            ? Icons.account_balance_wallet_rounded
            : Icons.arrow_upward_rounded)
      : Icons.calendar_month_rounded;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return GestureDetector(
      onTap: () => _showReceipt(context),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: dark
                ? const Color(0xFF1A2B45)
                : const Color(0xFFE2E6F0).withOpacity(0.6),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.35 : 0.07),
              blurRadius: 14,
              offset: const Offset(0, 5),
              spreadRadius: -2,
            ),
            if (!dark)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 3,
                offset: const Offset(-1, -1),
              ),
          ],
        ),
        child: Row(
          children: [
            // Icon box
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(dark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: _typeColor.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: _typeColor.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 22),
            ),
            const SizedBox(width: 12),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    txn.title,
                    style: TextStyle(
                      color: tp,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),
                  Text(txn.subtitle, style: TextStyle(color: ts, fontSize: 12)),
                  const SizedBox(height: 4),
                  Text(
                    txn.formattedTime,
                    style: TextStyle(color: ts, fontSize: 10),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),

            // Amount + status
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  txn.formattedAmount,
                  style: TextStyle(
                    color: txn.isSuccess
                        ? (txn.isBrick
                              ? const Color(0xFF3B82F6)
                              : txn.isWallet
                              ? (txn.isCredit
                                    ? const Color(0xFF10B981)
                                    : const Color(0xFFEF4444))
                              : const Color(0xFF2ecc71))
                        : AppColors.error,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
                _StatusBadge(status: txn.status),
                const SizedBox(height: 4),
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.accent,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showReceipt(BuildContext context) {
    HapticFeedback.lightImpact();
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: dark
              ? const Border(top: BorderSide(color: Color(0xFF1A2B45)))
              : null,
        ),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
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

            // Receipt header
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                color: _typeColor.withOpacity(dark ? 0.18 : 0.1),
                shape: BoxShape.circle,
                border: Border.all(color: _typeColor.withOpacity(0.35)),
                boxShadow: [
                  BoxShadow(
                    color: _typeColor.withOpacity(0.25),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Icon(_typeIcon, color: _typeColor, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              txn.formattedAmount,
              style: TextStyle(
                color: tp,
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 4),
            Text(txn.title, style: TextStyle(color: ts, fontSize: 14)),
            const SizedBox(height: 4),
            _StatusBadge(status: txn.status, large: true),
            const SizedBox(height: 24),

            // Receipt rows
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF0A0F1E) : const Color(0xFFF4F7FF),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
              ),
              child: Column(
                children: [
                  _ReceiptRow(
                    label: 'Date',
                    value: txn.formattedDate,
                    tp: tp,
                    ts: ts,
                    border: border,
                  ),
                  _ReceiptRow(
                    label: 'Time',
                    value: txn.formattedTime,
                    tp: tp,
                    ts: ts,
                    border: border,
                  ),
                  _ReceiptRow(
                    label: 'Category',
                    value: txn.category,
                    tp: tp,
                    ts: ts,
                    border: border,
                  ),
                  if (txn.bricks != null)
                    _ReceiptRow(
                      label: 'Bricks',
                      value: '${txn.bricks}',
                      tp: tp,
                      ts: ts,
                      border: border,
                    ),
                  if (txn.pricePerBrick != null)
                    _ReceiptRow(
                      label: 'Price/Brick',
                      value: '₹${txn.pricePerBrick}',
                      tp: tp,
                      ts: ts,
                      border: border,
                    ),
                  if (txn.city != null)
                    _ReceiptRow(
                      label: 'Location',
                      value: txn.city!,
                      tp: tp,
                      ts: ts,
                      border: border,
                    ),
                  if (txn.note != null)
                    _ReceiptRow(
                      label: 'Note',
                      value: txn.note!,
                      tp: tp,
                      ts: ts,
                      border: border,
                    ),
                  if (txn.razorpayPaymentId != null)
                    _ReceiptRow(
                      label: 'Payment ID',
                      value: txn.razorpayPaymentId!.length > 20
                          ? '${txn.razorpayPaymentId!.substring(0, 20)}...'
                          : txn.razorpayPaymentId!,
                      tp: tp,
                      ts: ts,
                      border: border,
                      mono: true,
                    ),
                  _ReceiptRow(
                    label: 'Txn ID',
                    value: txn.id.length > 16
                        ? txn.id.substring(0, 16)
                        : txn.id,
                    tp: tp,
                    ts: ts,
                    border: border,
                    isLast: true,
                    mono: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Copy payment ID button
            if (txn.razorpayPaymentId != null)
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: txn.razorpayPaymentId!),
                  );
                  HapticFeedback.mediumImpact();
                  Get.snackbar(
                    'Copied!',
                    'Payment ID copied to clipboard',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.accent,
                    colorText: Colors.white,
                  );
                },
                child: Container(
                  height: 50,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(dark ? 0.15 : 0.08),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.copy_rounded,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Copy Payment ID',
                        style: TextStyle(
                          color: AppColors.accent,
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
      isScrollControlled: true,
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
    required this.label,
    required this.value,
    required this.tp,
    required this.ts,
    required this.border,
    this.isLast = false,
    this.mono = false,
  });
  final String label, value;
  final Color tp, ts, border;
  final bool isLast, mono;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            Text(label, style: TextStyle(color: ts, fontSize: 13)),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: tp,
                  fontSize: mono ? 11 : 13,
                  fontWeight: FontWeight.w700,
                  fontFamily: mono ? 'monospace' : null,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      if (!isLast) Divider(height: 1, color: border),
    ],
  );
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.large = false});
  final String status;
  final bool large;
  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'success' || status == 'verified';
    final isPending = status == 'pending';
    final color = isSuccess
        ? const Color(0xFF2ecc71)
        : isPending
        ? const Color(0xFFF39C12)
        : AppColors.error;
    final bg = color.withOpacity(0.12);
    final label = isSuccess
        ? '✓ Success'
        : isPending
        ? '⏳ Pending'
        : '✗ Failed';
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 14 : 8,
        vertical: large ? 5 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: large ? 13 : 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Empty / Error ────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.dark});
  final bool dark;
  @override
  Widget build(BuildContext context) {
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
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.15),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                color: AppColors.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No transactions yet',
              style: TextStyle(
                color: tp,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment history\nwill appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ts, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrState extends StatelessWidget {
  const _ErrState({
    required this.msg,
    required this.dark,
    required this.onRetry,
  });
  final String msg;
  final bool dark;
  final VoidCallback onRetry;
  @override
  Widget build(BuildContext context) {
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: AppColors.error, size: 40),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: ts, fontSize: 13),
            ),
            const SizedBox(height: 16),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Text(
                  'Retry',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
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
