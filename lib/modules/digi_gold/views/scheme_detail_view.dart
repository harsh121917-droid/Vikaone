import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/data/repositories/scheme_repository.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class SchemeDetailView extends StatefulWidget {
  const SchemeDetailView({super.key, required this.enrollmentId});
  final String enrollmentId;

  @override
  State<SchemeDetailView> createState() => _SchemeDetailViewState();
}

class _SchemeDetailViewState extends State<SchemeDetailView> {
  final _repo = SchemeRepository();
  SchemeEnrollmentModel? _e;
  bool _loading = true;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final e = await _repo.getEnrollmentDetail(widget.enrollmentId);
      if (mounted)
        setState(() {
          _e = e;
          _loading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  DateTime get _endDate {
    final e = _e!;
    return DateTime(
      e.startedAt.year,
      e.startedAt.month + e.durationMonths,
      e.startedAt.day,
    );
  }

  Future<void> _payNext({required double shortfall}) async {
    setState(() => _paying = true);
    try {
      if (shortfall > 0) {
        // Not enough wallet balance — top up via real Razorpay checkout first,
        // then complete the installment once the payment succeeds.
        await WalletController.to.addMoney(shortfall);
        // addMoney() opens Razorpay and returns immediately (async callback
        // handles success) — give it a moment then check balance before
        // attempting the installment automatically.
        await Future.delayed(const Duration(seconds: 2));
        await WalletController.to.loadWallet();
        final bal = WalletController.to.wallet.value?.availableBalance ?? 0;
        if (bal < (_e!.monthlyAmount)) {
          Get.snackbar(
            'Complete Payment',
            'Finish adding money in the Razorpay window, then tap "Pay Installment" again.',
            backgroundColor: const Color(0xFF3B82F6),
            colorText: Colors.white,
            snackPosition: SnackPosition.BOTTOM,
          );
          return;
        }
      }
      await _repo.payNextInstallment(_e!.id);
      await WalletController.to.loadWallet();
      await _load();
      Get.snackbar(
        'Installment Paid! 🥇',
        'Gold credited to your account.',
        backgroundColor: const Color(0xFFD4A017),
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        e.toString().replaceFirst('Exception: ', ''),
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          backgroundColor: cardBg,
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
            _e?.schemeName ?? 'Scheme Details',
            style: TextStyle(
              color: tp,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: _loading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFFD4A017)),
              )
            : _e == null
            ? Center(
                child: Text(
                  'Could not load scheme',
                  style: TextStyle(color: ts),
                ),
              )
            : SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                child: _buildBody(dark, cardBg, tp, ts, border),
              ),
      );
    });
  }

  Widget _buildBody(bool dark, Color cardBg, Color tp, Color ts, Color border) {
    final e = _e!;
    final statusColor = e.status == 'completed'
        ? const Color(0xFF2ecc71)
        : e.status == 'cancelled'
        ? const Color(0xFFe74c3c)
        : const Color(0xFFD4A017);
    final bal = WalletController.to.wallet.value?.availableBalance ?? 0;
    final shortfall = (e.monthlyAmount - bal).clamp(0, double.infinity);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Hero ─────────────────────────────────────────────────────────
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF3D2B00), Color(0xFF6B4A00)],
            ),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      e.schemeName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      e.status.toUpperCase(),
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${e.durationMonths}+${e.bonusMonths} · ₹${e.monthlyAmount.toStringAsFixed(0)}/month',
                style: const TextStyle(color: Colors.white60, fontSize: 12),
              ),
              const SizedBox(height: 18),
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox(
                  height: 8,
                  child: Stack(
                    children: [
                      Container(color: Colors.white.withOpacity(0.15)),
                      FractionallySizedBox(
                        widthFactor: (e.progressPct / 100).clamp(0.0, 1.0),
                        child: Container(color: const Color(0xFFD4A017)),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${e.installmentsPaid}/${e.durationMonths} installments paid',
                style: const TextStyle(color: Colors.white54, fontSize: 11),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ── Start / End / Gold summary ──────────────────────────────────
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: border),
          ),
          child: Row(
            children: [
              Expanded(
                child: _StatCol('Start Date', _fmtDate(e.startedAt), tp, ts),
              ),
              _VDiv(border),
              Expanded(
                child: _StatCol(
                  e.status == 'completed' ? 'Completed' : 'End Date',
                  e.completedAt != null
                      ? _fmtDate(e.completedAt!)
                      : _fmtDate(_endDate),
                  tp,
                  ts,
                ),
              ),
              _VDiv(border),
              Expanded(
                child: _StatCol(
                  'Total Gold',
                  '${e.totalGoldGrams.toStringAsFixed(4)}g',
                  const Color(0xFFD4A017),
                  ts,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        if (e.status == 'active') ...[
          if (shortfall > 0)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF3B82F6),
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Wallet short by ₹${shortfall.toStringAsFixed(0)} — Razorpay will open to top up before paying.',
                      style: const TextStyle(
                        color: Color(0xFF3B82F6),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          GestureDetector(
            onTap: _paying
                ? null
                : () => _payNext(shortfall: shortfall.toDouble()),
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: _paying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        shortfall > 0
                            ? 'Add ₹${shortfall.toStringAsFixed(0)} & Pay Installment #${e.installmentsPaid + 1}'
                            : 'Pay Installment #${e.installmentsPaid + 1} — ₹${e.monthlyAmount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Color(0xFF3D2B00),
                          fontSize: 13,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // ── EMI history ──────────────────────────────────────────────────
        Text(
          'Installment History',
          style: TextStyle(
            color: tp,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        ...e.payments.map((p) => _PaymentRow(p: p, dark: dark)),
      ],
    );
  }

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }
}

class _StatCol extends StatelessWidget {
  const _StatCol(this.label, this.value, this.vc, this.lc);
  final String label, value;
  final Color vc, lc;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: lc, fontSize: 10)),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(color: vc, fontSize: 13, fontWeight: FontWeight.w800),
      ),
    ],
  );
}

class _VDiv extends StatelessWidget {
  const _VDiv(this.border);
  final Color border;
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 36, color: border);
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.p, required this.dark});
  final SchemePaymentModel p;
  final bool dark;

  String _fmtDate(DateTime d) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final h = d.hour % 12 == 0 ? 12 : d.hour % 12;
    final ampm = d.hour < 12 ? 'AM' : 'PM';
    return '${d.day} ${months[d.month - 1]} ${d.year}, $h:${d.minute.toString().padLeft(2, '0')} $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final accent = p.isBonus
        ? const Color(0xFF2ecc71)
        : const Color(0xFFD4A017);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: p.isBonus ? accent.withOpacity(0.4) : border,
          width: p.isBonus ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: accent.withOpacity(0.12),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              p.isBonus
                  ? Icons.card_giftcard_rounded
                  : Icons.check_circle_outline_rounded,
              color: accent,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  p.isBonus
                      ? 'Bonus (Maturity)'
                      : 'Installment #${p.installmentNo}',
                  style: TextStyle(
                    color: tp,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _fmtDate(p.paidAt),
                  style: TextStyle(color: ts, fontSize: 11),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+${p.grams.toStringAsFixed(4)}g',
                style: TextStyle(
                  color: accent,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                p.isBonus ? 'Free' : '₹${p.amount.toStringAsFixed(0)}',
                style: TextStyle(color: ts, fontSize: 11),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
