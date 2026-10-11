import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/modules/transactions/controllers/transaction_controller.dart';
import 'package:real_estate/core/theme/app_colors.dart';
import 'package:real_estate/core/theme/controllers/theme_controller.dart';
import 'package:real_estate/data/models/transaction_model.dart';
import 'package:real_estate/routes/app_routes.dart';

class TransactionHistoryView extends StatelessWidget {
  const TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.isRegistered<TransactionController>()
        ? Get.find<TransactionController>()
        : Get.put(TransactionController());

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF4F7FC);

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _HeroHeader(dark: dark, controller: controller),
              Expanded(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    // Tabs
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Obx(
                        () => _TabRow(
                          selected: controller.activeTab.value,
                          onTap: controller.setTab,
                          dark: dark,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Transaction List
                    Expanded(
                      child: Obx(() {
                        if (controller.isLoading.value) {
                          return const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF2563EB),
                              strokeWidth: 2.5,
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

                        // Group transactions by date
                        final grouped = _groupByDate(controller.filtered);

                        return RefreshIndicator(
                          onRefresh: controller.load,
                          color: Color(0xFF2563EB),
                          child: ListView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            physics: const AlwaysScrollableScrollPhysics(
                              parent: BouncingScrollPhysics(),
                            ),
                            itemCount: grouped.length,
                            itemBuilder: (_, i) {
                              final item = grouped[i];
                              if (item is String) {
                                return _DateHeader(date: item, dark: dark);
                              }
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
            ],
          ),
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

// ─── Hero Header & Summary ────────────────────────────────────────────────────
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
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final btnBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF060B16) : const Color(0xFFF4F7FC),
        border: Border(
          bottom: BorderSide(
            color: dark ? const Color(0xFF141E33) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: btnBg,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: tp,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Transactions',
                      style: TextStyle(
                        color: tp,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Official ledger & settlement logs',
                      style: TextStyle(
                        color: ts,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Refresh Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  controller.load();
                },
                child: Container(
                  width: 42,
                  height: 42,
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
                    Icons.refresh_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),

          // 3-Stat Summary Cards
          Obx(() {
            final s = controller.summary.value;
            if (s == null) return const SizedBox.shrink();

            return Container(
              margin: const EdgeInsets.only(top: 14),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF0E1626) : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: border),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.35 : 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: _SumChip(
                      label: 'Total Spent',
                      value: _fmt(s.totalSpent),
                      icon: Icons.payments_rounded,
                      color: const Color(0xFF2563EB),
                      dark: dark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: border,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  Expanded(
                    child: _SumChip(
                      label: 'Invested',
                      value: _fmt(s.totalInvested),
                      icon: Icons.apartment_rounded,
                      color: const Color(0xFF3B82F6),
                      dark: dark,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 38,
                    color: border,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                  ),
                  Expanded(
                    child: _SumChip(
                      label: 'Saved',
                      value: _fmt(s.totalSaved),
                      icon: Icons.savings_rounded,
                      color: const Color(0xFF10B981),
                      dark: dark,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
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
    required this.dark,
  });

  final String label, value;
  final IconData icon;
  final Color color;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 13),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  color: ts,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: tp,
            fontSize: 14,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

// ─── Filter Tab Row ───────────────────────────────────────────────────────────
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
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    return Container(
      height: 46,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          _TabItem(
            label: 'All',
            index: 0,
            selected: selected,
            onTap: onTap,
            dark: dark,
          ),
          _TabItem(
            label: 'Investment',
            index: 1,
            selected: selected,
            onTap: onTap,
            dark: dark,
          ),
          _TabItem(
            label: 'Savings',
            index: 2,
            selected: selected,
            onTap: onTap,
            dark: dark,
          ),
          _TabItem(
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

class _TabItem extends StatelessWidget {
  const _TabItem({
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
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          decoration: BoxDecoration(
            gradient: active
                ? const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            borderRadius: BorderRadius.circular(10),
            boxShadow: active
                ? [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
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
                    : (dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B)),
                fontSize: 12,
                fontWeight: active ? FontWeight.w900 : FontWeight.w600,
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
  Widget build(BuildContext context) {
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8, left: 4),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3.5),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF131D33) : const Color(0xFFE2E8F0),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              date.toUpperCase(),
              style: TextStyle(
                color: ts,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Transaction Card ─────────────────────────────────────────────────────────
class _TxnCard extends StatefulWidget {
  const _TxnCard({required this.txn, required this.dark});
  final TransactionModel txn;
  final bool dark;

  @override
  State<_TxnCard> createState() => _TxnCardState();
}

class _TxnCardState extends State<_TxnCard> {
  bool _pressed = false;

  Color get _typeColor {
    final t = widget.txn;
    if (t.isBrick) return const Color(0xFF3B82F6);
    if (t.isSaving) return const Color(0xFF10B981);
    if (t.isWallet) {
      if (t.isCredit) return const Color(0xFF10B981);
      return const Color(0xFFF59E0B);
    }
    return const Color(0xFF2563EB);
  }

  IconData get _typeIcon {
    final t = widget.txn;
    if (t.isBrick) return Icons.apartment_rounded;
    if (t.isSaving) return Icons.savings_rounded;
    if (t.isWallet) {
      if (t.isCredit) return Icons.arrow_downward_rounded;
      return Icons.arrow_upward_rounded;
    }
    return Icons.receipt_long_rounded;
  }

  @override
  Widget build(BuildContext context) {
    final txn = widget.txn;
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          _showReceipt(context);
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedScale(
          scale: _pressed ? 0.985 : 1.0,
          duration: const Duration(milliseconds: 100),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.25 : 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                // Icon squircle
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(dark ? 0.18 : 0.1),
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: _typeColor.withOpacity(0.3)),
                  ),
                  child: Icon(_typeIcon, color: _typeColor, size: 22),
                ),
                const SizedBox(width: 13),

                // Center info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        txn.title,
                        style: TextStyle(
                          color: tp,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: dark ? const Color(0xFF131D33) : const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              txn.category,
                              style: TextStyle(
                                color: ts,
                                fontSize: 9.5,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            txn.formattedTime,
                            style: TextStyle(
                              color: ts,
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),

                // Right amount + status
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${txn.isWallet && txn.isCredit ? "+" : ""}${txn.formattedAmount}',
                      style: TextStyle(
                        color: txn.isSuccess
                            ? (txn.isWallet && txn.isCredit
                                ? const Color(0xFF10B981)
                                : (dark ? Colors.white : const Color(0xFF0F172A)))
                            : (txn.isPending
                                ? const Color(0xFFF59E0B)
                                : AppColors.error),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _StatusBadge(status: txn.status),
                  ],
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.chevron_right_rounded,
                  color: ts.withOpacity(0.6),
                  size: 18,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showReceipt(BuildContext context) {
    HapticFeedback.lightImpact();
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);
    final txn = widget.txn;

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          border: dark
              ? const Border(top: BorderSide(color: Color(0xFF1E2D4A)))
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.35),
              blurRadius: 30,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 36),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Handle
              Container(
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),

              // Status Icon Circle
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: _typeColor.withOpacity(dark ? 0.2 : 0.12),
                  shape: BoxShape.circle,
                  border: Border.all(color: _typeColor.withOpacity(0.35)),
                  boxShadow: [
                    BoxShadow(
                      color: _typeColor.withOpacity(0.2),
                      blurRadius: 16,
                    ),
                  ],
                ),
                child: Icon(_typeIcon, color: _typeColor, size: 28),
              ),
              const SizedBox(height: 12),

              // Hero Amount
              Text(
                txn.formattedAmount,
                style: TextStyle(
                  color: tp,
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.6,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                txn.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: ts,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              _StatusBadge(status: txn.status, large: true),
              const SizedBox(height: 22),

              // Receipt Details Card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(18),
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
                        label: 'Bricks Purchased',
                        value: '${txn.bricks}',
                        tp: tp,
                        ts: ts,
                        border: border,
                      ),
                    if (txn.pricePerBrick != null)
                      _ReceiptRow(
                        label: 'Price per Brick',
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
                        label: 'Reference Note',
                        value: txn.note!,
                        tp: tp,
                        ts: ts,
                        border: border,
                      ),
                    if (txn.razorpayPaymentId != null)
                      _ReceiptRow(
                        label: 'Payment Gateway Ref',
                        value: txn.razorpayPaymentId!.length > 18
                            ? '${txn.razorpayPaymentId!.substring(0, 18)}...'
                            : txn.razorpayPaymentId!,
                        tp: tp,
                        ts: ts,
                        border: border,
                        mono: true,
                      ),
                    _ReceiptRow(
                      label: 'Transaction ID',
                      value: txn.id.length > 16
                          ? '${txn.id.substring(0, 16)}...'
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

              // Action Buttons Row
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        Clipboard.setData(ClipboardData(text: txn.id));
                        HapticFeedback.mediumImpact();
                        Get.snackbar(
                          'Copied!',
                          'Transaction ID copied to clipboard',
                          snackPosition: SnackPosition.BOTTOM,
                          backgroundColor: const Color(0xFF0E1626),
                          colorText: Colors.white,
                        );
                      },
                      child: Container(
                        height: 48,
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF131D33) : const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: border),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.copy_rounded, color: tp, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Copy Txn ID',
                              style: TextStyle(
                                color: tp,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  if (txn.razorpayPaymentId != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Clipboard.setData(ClipboardData(text: txn.razorpayPaymentId!));
                          HapticFeedback.mediumImpact();
                          Get.snackbar(
                            'Copied!',
                            'Payment Ref ID copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: const Color(0xFF2563EB),
                            colorText: Colors.white,
                          );
                        },
                        child: Container(
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(14),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.receipt_rounded, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                'Payment ID',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
    );
  }
}

// ─── Receipt Details Row ──────────────────────────────────────────────────────
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
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Row(
          children: [
            Text(
              label,
              style: TextStyle(
                color: ts,
                fontSize: 12.5,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: TextStyle(
                  color: tp,
                  fontSize: mono ? 11.5 : 13,
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
      if (!isLast) Divider(height: 1, color: border.withOpacity(0.7)),
    ],
  );
}

// ─── Modern Status Badge ──────────────────────────────────────────────────────
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, this.large = false});
  final String status;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final isSuccess = status == 'success' || status == 'verified';
    final isPending = status == 'pending';

    final Color color = isSuccess
        ? const Color(0xFF10B981)
        : isPending
            ? const Color(0xFFF59E0B)
            : AppColors.error;

    final String label = isSuccess
        ? '✓ Completed'
        : isPending
            ? '⏳ Processing'
            : '✗ Failed';

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? 12 : 7,
        vertical: large ? 4.5 : 2.5,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.35)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: large ? 12 : 9.5,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

// ─── Modern Empty & Error States ──────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(36),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? const Color(0xFF0E1626) : Colors.white,
                border: Border.all(
                  color: const Color(0xFF2563EB).withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.receipt_long_rounded,
                color: Color(0xFF2563EB),
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Transactions Found',
              style: TextStyle(
                color: tp,
                fontSize: 19,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your investments, deposits, savings, and yields will automatically appear here once processed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ts,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(AppRoutes.properties);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Explore Opportunities',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
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
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 44),
            const SizedBox(height: 12),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: ts, fontSize: 13.5),
            ),
            const SizedBox(height: 18),
            GestureDetector(
              onTap: onRetry,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 26,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.35),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Text(
                  'Retry Ledger Sync',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w900,
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
