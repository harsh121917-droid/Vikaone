import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/data/repositories/coin_repository.dart';
import 'package:real_estate/modules/digi_gold/controllers/digi_gold_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class CoinRedeemView extends StatefulWidget {
  const CoinRedeemView({super.key, required this.coin});
  final CoinModel coin;

  @override
  State<CoinRedeemView> createState() => _CoinRedeemViewState();
}

class _CoinRedeemViewState extends State<CoinRedeemView> {
  final _repo = CoinRepository();
  final _addrCtrl = TextEditingController();
  final _pinCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  bool _submitting = false;

  double get _gramsNeeded => widget.coin.totalValue / widget.coin.ratePerGram;
  bool get _hasEnough => GoldController.to.totalGrams >= _gramsNeeded;
  bool get _valid =>
      _addrCtrl.text.trim().length > 8 &&
      _pinCtrl.text.trim().length == 6 &&
      _phoneCtrl.text.trim().length == 10 &&
      _hasEnough;

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await _repo.redeemCoin(
        coinId: widget.coin.id,
        addressLine: _addrCtrl.text.trim(),
        pincode: _pinCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
      );
      await GoldController.to.loadAll();
      Get.back();
      Get.snackbar(
        'Order Placed! 🪙',
        '${widget.coin.name} will be shipped to your address',
        backgroundColor: const Color(0xFFD4A017),
        colorText: Colors.black,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Failed',
        e is Exception ? e.toString() : 'Could not place order',
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coin = widget.coin;
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
            'Redeem Coin',
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
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      coin.name,
                      style: const TextStyle(
                        color: Color(0xFF3D2B00),
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${coin.grams.toStringAsFixed(0)}g · Making charge ${coin.makingChargePct.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Color(0xFF3D2B00),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Column(
                  children: [
                    _row(
                      'Rate per Gram',
                      '₹${coin.ratePerGram.toStringAsFixed(2)}',
                      tp,
                      ts,
                    ),
                    _div(border),
                    _row(
                      'Gold Value',
                      '₹${coin.value.toStringAsFixed(2)}',
                      tp,
                      ts,
                    ),
                    _div(border),
                    _row(
                      'Making Charge',
                      '₹${coin.makingCharge.toStringAsFixed(2)}',
                      tp,
                      ts,
                    ),
                    _div(border),
                    _row(
                      'Total (deducted as gold)',
                      '${_gramsNeeded.toStringAsFixed(4)}g',
                      const Color(0xFFD4A017),
                      ts,
                      bold: true,
                    ),
                    _div(border),
                    _row(
                      'Your Gold Balance',
                      '${GoldController.to.totalGrams.toStringAsFixed(4)}g',
                      _hasEnough
                          ? const Color(0xFF2ecc71)
                          : const Color(0xFFe74c3c),
                      ts,
                    ),
                  ],
                ),
              ),
              if (!_hasEnough)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Not enough gold to redeem this coin. Buy more gold first.',
                    style: const TextStyle(
                      color: Color(0xFFe74c3c),
                      fontSize: 12,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              Text(
                'Shipping Address',
                style: TextStyle(
                  color: tp,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              _field(
                'Full Address',
                _addrCtrl,
                tp,
                ts,
                border,
                dark,
                hint: 'House no, street, city, state',
              ),
              _field(
                'Pincode',
                _pinCtrl,
                tp,
                ts,
                border,
                dark,
                hint: '6-digit pincode',
                type: TextInputType.number,
              ),
              _field(
                'Phone Number',
                _phoneCtrl,
                tp,
                ts,
                border,
                dark,
                hint: '10-digit mobile',
                type: TextInputType.phone,
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _valid && !_submitting
                    ? () {
                        HapticFeedback.mediumImpact();
                        _submit();
                      }
                    : null,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: _valid
                        ? const LinearGradient(
                            colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                          )
                        : null,
                    color: _valid
                        ? null
                        : const Color(0xFFD4A017).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: _submitting
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _valid ? 'Redeem Coin' : 'Fill all fields',
                            style: TextStyle(
                              color: _valid
                                  ? const Color(0xFF3D2B00)
                                  : Colors.white38,
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                            ),
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

  Widget _div(Color border) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Divider(color: border, height: 1),
  );

  Widget _row(String l, String v, Color vc, Color lc, {bool bold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(l, style: TextStyle(color: lc, fontSize: 13)),
          Text(
            v,
            style: TextStyle(
              color: vc,
              fontSize: bold ? 15 : 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      );

  Widget _field(
    String label,
    TextEditingController ctrl,
    Color tp,
    Color ts,
    Color border,
    bool dark, {
    String hint = '',
    TextInputType? type,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ts,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: ctrl,
            keyboardType: type,
            onChanged: (_) => setState(() {}),
            style: TextStyle(
              color: tp,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: ts.withOpacity(0.5), fontSize: 13),
              filled: true,
              fillColor: dark
                  ? const Color(0xFF0A0F1E)
                  : const Color(0xFFF8F5F0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFD4A017),
                  width: 1.5,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
