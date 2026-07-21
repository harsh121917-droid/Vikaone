import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:real_estate/data/repositories/gold_repository.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class TransactionDetailView extends StatefulWidget {
  const TransactionDetailView({super.key, required this.txn});
  final GoldTxnModel txn;

  @override
  State<TransactionDetailView> createState() => _TransactionDetailViewState();
}

class _TransactionDetailViewState extends State<TransactionDetailView> {
  final _repo = GoldRepository();
  bool _downloading = false;

  Future<void> _downloadInvoice() async {
    setState(() => _downloading = true);
    try {
      final bytes = await _repo.getTransactionInvoice(widget.txn.id);
      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/invoice-${widget.txn.id}.pdf');
      await file.writeAsBytes(bytes);
      await Share.shareXFiles([
        XFile(file.path, mimeType: 'application/pdf'),
      ], text: 'Gold transaction invoice');
    } catch (e) {
      Get.snackbar(
        'Failed',
        'Could not download invoice. Try again.',
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _downloading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.txn;
    final isBuy = t.type == 'buy' || t.type == 'sip_buy';

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
      final accent = isBuy ? const Color(0xFFD4A017) : const Color(0xFF3B82F6);

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
            'Transaction Details',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Hero card ────────────────────────────────────────────────
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: isBuy
                        ? [const Color(0xFF3D2B00), const Color(0xFF6B4A00)]
                        : [const Color(0xFF0F1F3D), const Color(0xFF1E3A6B)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withOpacity(0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isBuy
                                ? Icons.add_rounded
                                : Icons.arrow_downward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBuy ? 'Gold Purchased' : 'Gold Sold',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              Text(
                                _fmtDate(t.createdAt),
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color:
                                (t.status == 'success'
                                        ? const Color(0xFF2ecc71)
                                        : const Color(0xFFF39C12))
                                    .withOpacity(0.18),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            t.status == 'success' ? 'Success' : t.status,
                            style: TextStyle(
                              color: t.status == 'success'
                                  ? const Color(0xFF2ecc71)
                                  : const Color(0xFFF39C12),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Text(
                      '${isBuy ? '+' : '-'}${t.grams.toStringAsFixed(4)}g',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '₹${t.totalAmt.toStringAsFixed(2)} ${isBuy ? 'paid' : 'received'}',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Breakdown ────────────────────────────────────────────────
              Text(
                'Breakdown',
                style: TextStyle(
                  color: tp,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    _row('Transaction ID', t.id, tp, ts, mono: true),
                    _div(border),
                    _row(
                      'Rate per Gram',
                      '₹${t.ratePerGram.toStringAsFixed(2)}',
                      tp,
                      ts,
                    ),
                    _div(border),
                    _row(
                      'Gold Quantity',
                      '${t.grams.toStringAsFixed(4)} g',
                      tp,
                      ts,
                    ),
                    _div(border),
                    _row(
                      'Gold Value',
                      '₹${t.goldValue.toStringAsFixed(2)}',
                      tp,
                      ts,
                    ),
                    _div(border),
                    _row(
                      isBuy ? 'GST (3%)' : 'GST',
                      '₹${t.gstAmt.toStringAsFixed(2)}',
                      tp,
                      ts,
                    ),
                    _div(border),
                    _row(
                      isBuy ? 'Total Paid' : 'Total Received',
                      '₹${t.totalAmt.toStringAsFixed(2)}',
                      accent,
                      ts,
                      bold: true,
                    ),
                    if (t.razorpayPaymentId != null) ...[
                      _div(border),
                      _row(
                        'Payment ID',
                        t.razorpayPaymentId!,
                        tp,
                        ts,
                        mono: true,
                      ),
                    ],
                    if (t.note != null && t.note!.isNotEmpty) ...[
                      _div(border),
                      _row('Note', t.note!, tp, ts),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // ── Invoice button ───────────────────────────────────────────
              GestureDetector(
                onTap: _downloading
                    ? null
                    : () {
                        HapticFeedback.mediumImpact();
                        _downloadInvoice();
                      },
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [accent, accent.withOpacity(0.7)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: accent.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Center(
                    child: _downloading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.download_rounded,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Download Invoice',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      );
    });
  }

  String _fmtDate(DateTime dt) {
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
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}, $h:${dt.minute.toString().padLeft(2, '0')} $ampm';
  }

  Widget _div(Color border) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Divider(color: border, height: 1),
  );

  Widget _row(
    String label,
    String value,
    Color vc,
    Color lc, {
    bool bold = false,
    bool mono = false,
  }) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(label, style: TextStyle(color: lc, fontSize: 13)),
      const SizedBox(width: 12),
      Expanded(
        child: Text(
          value,
          textAlign: TextAlign.right,
          style: TextStyle(
            color: vc,
            fontSize: bold ? 15 : 13,
            fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            fontFamily: mono ? 'monospace' : null,
          ),
        ),
      ),
    ],
  );
}
