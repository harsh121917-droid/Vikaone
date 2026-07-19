import 'dart:math';
import 'package:flutter/material.dart';
import 'package:real_estate/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:real_estate/data/repositories/gold_repository.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';

// ─── Static data ─────────────────────────────────────────────────────────────

class SellGoldView extends StatefulWidget {
  const SellGoldView({super.key});
  @override
  State<SellGoldView> createState() => _SellGoldViewState();
}

class _SellGoldViewState extends State<SellGoldView> {
  bool _byGrams = true; // Grams / Rupees toggle
  double _grams = 1.0;
  final _ctrl = TextEditingController(text: '1.000');

  // Percentage quick picks
  final _pctPicks = [0.25, 0.50, 0.75, 1.0];

  double get _sellRate =>
      GoldController.to.sellRate > 0 ? GoldController.to.sellRate : 7256.0;
  double get _gramsDisp =>
      _byGrams ? _grams : (_byGrams ? _grams : _grams / _sellRate);
  double get _available => GoldController.to.balance.value?.availableGrams ?? 0;
  bool get _valid => _gramsDisp > 0 && _gramsDisp <= _available;

  void _setGrams(double g) {
    setState(() {
      _byGrams = true;
      _grams = g;
      _ctrl.text = g.toStringAsFixed(3);
    });
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
      final subBg = dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5EE);

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
            'Sell Gold',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          actions: [
            Center(
              child: Padding(
                padding: const EdgeInsets.only(right: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF3B82F6).withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFF3B82F6).withOpacity(0.3),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up_rounded,
                        color: Color(0xFF3B82F6),
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Sell Price',
                        style: TextStyle(
                          color: Color(0xFF3B82F6),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Live rate strip ──────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    const Text(
                      'Live 24K Rate',
                      style: TextStyle(color: Color(0xFF8A95B0), fontSize: 11),
                    ),
                    const Spacer(),
                    Text(
                      '₹${GoldController.to.sellRate.toStringAsFixed(2)}/g',
                      style: const TextStyle(
                        color: Color(0xFFD4A017),
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(
                      Icons.info_outline_rounded,
                      color: Color(0xFF8A95B0),
                      size: 14,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Balance card ─────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text(
                                'Available Gold Balance',
                                style: TextStyle(
                                  color: Color(0xFF8A95B0),
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 5),
                              const Icon(
                                Icons.visibility_outlined,
                                color: Color(0xFF8A95B0),
                                size: 14,
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          // 3D text
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Transform.translate(
                                offset: const Offset(2, 2.5),
                                child: Text(
                                  '${(GoldController.to.balance.value?.availableGrams ?? 0)}g',
                                  style: TextStyle(
                                    color: const Color(
                                      0xFFD4A017,
                                    ).withOpacity(0.25),
                                    fontSize: 34,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -1,
                                  ),
                                ),
                              ),
                              Text(
                                '${(GoldController.to.balance.value?.availableGrams ?? 0)}g',
                                style: TextStyle(
                                  color: tp,
                                  fontSize: 34,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Current Value  ₹${(GoldController.to.balance.value?.currentValue ?? 0).toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Color(0xFF8A95B0),
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 9,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ecc71).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFF2ecc71).withOpacity(0.3),
                              ),
                            ),
                            child: Obx(() {
                              final gl = GoldController.to.balance.value;
                              return Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.trending_up_rounded,
                                    color: Color(0xFF2ecc71),
                                    size: 13,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '+₹${(gl?.gainLoss.abs() ?? 0).toStringAsFixed(2)} (${(gl?.gainLossPct.abs() ?? 0).toStringAsFixed(2)}%)',
                                    style: const TextStyle(
                                      color: Color(0xFF2ecc71),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              );
                            }),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'since last purchase',
                            style: TextStyle(color: ts, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 100,
                      height: 110,
                      child: Image.asset(
                        'assets/images/jar_img.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── Amount input ─────────────────────────────────────────────────
              Text(
                'Enter Gold to Sell',
                style: TextStyle(
                  color: ts,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 10),

              // Grams / Rupees toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  _Toggle(
                    'Grams',
                    _byGrams,
                    () => setState(() {
                      _byGrams = true;
                      _ctrl.text = _grams.toStringAsFixed(3);
                    }),
                  ),
                  const SizedBox(width: 8),
                  _Toggle(
                    'Rupees',
                    !_byGrams,
                    () => setState(() {
                      _byGrams = false;
                      _ctrl.text = (_grams * GoldController.to.sellRate)
                          .toStringAsFixed(0);
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 10),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: subBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) =>
                            setState(() => _grams = double.tryParse(v) ?? 0),
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
                          hintText: '0.000',
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                          hintStyle: TextStyle(
                            color: ts.withOpacity(0.4),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                    Text(
                      _byGrams ? 'g' : '₹',
                      style: TextStyle(
                        color: ts,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (_byGrams) ...[
                      const SizedBox(width: 8),
                      Text(
                        '+${((GoldController.to.balance.value?.availableGrams ?? 0) * 1000).toStringAsFixed(0)} mg',
                        style: const TextStyle(
                          color: Color(0xFF8A95B0),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 12),

              // Slider
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: const Color(0xFFD4A017),
                  inactiveTrackColor: border,
                  thumbColor: Colors.white,
                  thumbShape: const RoundSliderThumbShape(
                    enabledThumbRadius: 11,
                    elevation: 4,
                  ),
                  overlayColor: const Color(0xFFD4A017).withOpacity(0.15),
                  trackHeight: 4,
                ),
                child: Slider(
                  value: _grams.clamp(
                    0,
                    (GoldController.to.balance.value?.availableGrams ?? 0),
                  ),
                  min: 0,
                  max: (GoldController.to.balance.value?.availableGrams ?? 0),
                  onChanged: (v) {
                    setState(() {
                      _grams = v;
                      _ctrl.text = v.toStringAsFixed(3);
                    });
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('0g', style: TextStyle(color: ts, fontSize: 11)),
                  Text(
                    '${(GoldController.to.balance.value?.availableGrams ?? 0)}g',
                    style: TextStyle(color: ts, fontSize: 11),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // % quick picks
              Row(
                children: _pctPicks.map((pct) {
                  final g =
                      (GoldController.to.balance.value?.availableGrams ?? 0) *
                      pct;
                  final isMax = pct == 1.0;
                  final active =
                      ((_grams /
                                  (GoldController
                                          .to
                                          .balance
                                          .value
                                          ?.availableGrams ??
                                      0)) -
                              pct)
                          .abs() <
                      0.001;
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: GestureDetector(
                        onTap: () => _setGrams(g),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            gradient: active || isMax
                                ? const LinearGradient(
                                    colors: [
                                      Color(0xFFD4A017),
                                      Color(0xFFFFD700),
                                    ],
                                  )
                                : null,
                            color: active || isMax ? null : subBg,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: active || isMax
                                  ? Colors.transparent
                                  : border,
                            ),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                isMax ? 'Max' : '${(pct * 100).toInt()}%',
                                style: TextStyle(
                                  color: active || isMax
                                      ? const Color(0xFF3D2B00)
                                      : ts,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${g.toStringAsFixed(3)}g',
                                style: TextStyle(
                                  color: (active || isMax)
                                      ? const Color(0xFF3D2B00).withOpacity(0.7)
                                      : ts,
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
              const SizedBox(height: 20),

              // ── You will receive ─────────────────────────────────────────────
              if (_gramsDisp > 0) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'You will receive',
                            style: TextStyle(color: ts, fontSize: 13),
                          ),
                          const SizedBox(width: 6),
                          const Icon(
                            Icons.info_outline_rounded,
                            color: Color(0xFF8A95B0),
                            size: 14,
                          ),
                          const Spacer(),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ecc71).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF2ecc71).withOpacity(0.3),
                              ),
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2ecc71),
                                  size: 11,
                                ),
                                SizedBox(width: 3),
                                Text(
                                  '100% Secure\nBest Price Guarantee',
                                  style: TextStyle(
                                    color: Color(0xFF2ecc71),
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      // Big receive amount
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Transform.translate(
                            offset: const Offset(2, 3),
                            child: Text(
                              '₹${(_gramsDisp * GoldController.to.sellRate).toStringAsFixed(2)}',
                              style: TextStyle(
                                color: const Color(0xFF3B82F6).withOpacity(0.2),
                                fontSize: 30,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          Text(
                            '₹${(_gramsDisp * GoldController.to.sellRate).toStringAsFixed(2)}',
                            style: TextStyle(
                              color: tp,
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${_gramsDisp.toStringAsFixed(3)}g × ₹${GoldController.to.sellRate.toStringAsFixed(2)} (Sell Price)',
                        style: TextStyle(color: ts, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Payout to ──────────────────────────────────────────────────
                Text(
                  'Payout to',
                  style: TextStyle(
                    color: tp,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_rounded,
                          color: Color(0xFF3B82F6),
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'HDFC Bank',
                              style: TextStyle(
                                color: tp,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'A/c No. ●●●● ●●●● 1234',
                              style: TextStyle(color: ts, fontSize: 11),
                            ),
                            Text(
                              'IFSC: HDFC0001234',
                              style: TextStyle(color: ts, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ecc71).withOpacity(0.10),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color(0xFF2ecc71).withOpacity(0.3),
                          ),
                        ),
                        child: const Text(
                          'Preferred',
                          style: TextStyle(
                            color: Color(0xFF2ecc71),
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: ts,
                        size: 20,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: Color(0xFF8A95B0),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Amount will be credited in 1-2 working hours',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
              ],
            ],
          ),
        ),

        // ── Bottom bar ────────────────────────────────────────────────────────
        bottomNavigationBar: _valid
            ? Container(
                padding: EdgeInsets.fromLTRB(
                  16,
                  12,
                  16,
                  MediaQuery.paddingOf(context).bottom + 12,
                ),
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF0E1626) : Colors.white,
                  border: Border(
                    top: BorderSide(
                      color: dark
                          ? const Color(0xFF1A2B45)
                          : const Color(0xFFE8DFC8),
                    ),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        Get.back();
                        Get.snackbar(
                          'Sell Order Placed! 💰',
                          'Selling ${_gramsDisp.toStringAsFixed(3)}g → ₹${(_gramsDisp * GoldController.to.sellRate).toStringAsFixed(2)} to your bank',
                          backgroundColor: const Color(0xFF3B82F6),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                          duration: const Duration(seconds: 3),
                        );
                      },
                      child: Container(
                        height: 54,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF3B82F6), Color(0xFF60A5FA)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF3B82F6).withOpacity(0.45),
                              blurRadius: 14,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.lock_outline_rounded,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Text(
                                'Review Sell Order',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.shield_outlined,
                          size: 12,
                          color: Color(0xFF8A95B0),
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Safe. Secure. Trusted by 1M+ users.',
                          style: TextStyle(
                            color: Color(0xFF8A95B0),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : null,
      );
    });
  }

  Widget _Toggle(String label, bool active, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
          decoration: BoxDecoration(
            color: active ? const Color(0xFFD4A017) : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active
                  ? const Color(0xFFD4A017)
                  : const Color(0xFF8A95B0).withOpacity(0.4),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : const Color(0xFF8A95B0),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      );
}
