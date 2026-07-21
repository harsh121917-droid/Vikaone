import 'package:flutter/material.dart';
import 'package:real_estate/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';

// ─── Static data (replace with API) ──────────────────────────────────────────

class BuyGoldView extends StatefulWidget {
  const BuyGoldView({super.key});
  @override
  State<BuyGoldView> createState() => _BuyGoldViewState();
}

class _BuyGoldViewState extends State<BuyGoldView> {
  static const double _GST_PCT = 3.0;
  static const double _MIN_AMT = 100.0;
  static const double _MAX_AMT = 100000.0;
  bool _byAmount = true;
  double _slider = 1000;
  final _ctrl = TextEditingController(text: '1000');

  double get _total => _byAmount
      ? (double.tryParse(_ctrl.text) ?? 0)
      : (double.tryParse(_ctrl.text) ?? 0) *
            GoldController.to.buyRate *
            (1 + _GST_PCT / 100);

  double get _amount => _total / (1 + _GST_PCT / 100); // gold value (pre-GST)

  double get _grams => _amount / GoldController.to.buyRate;

  double get _gst => _total - _amount;
  double get _walletBal =>
      WalletController.to.wallet.value?.availableBalance ?? 0;
  bool get _hasEnoughBalance => _walletBal >= _total;
  bool get _valid => _amount >= 100.0 && _hasEnoughBalance;

  void _setAmt(double amt) => setState(() {
    _byAmount = true;
    _slider = amt.clamp(100.0, 100000.0);
    _ctrl.text = amt.toStringAsFixed(0);
  });

  void _setGrams(double grams) => setState(() {
    _byAmount = false;
    _ctrl.text = grams.toStringAsFixed(3);
  });

  String _fmtUpdated(DateTime? dt) {
    if (dt == null) return 'Rate unavailable';
    final now = DateTime.now();
    final sameDay =
        dt.year == now.year && dt.month == now.month && dt.day == now.day;
    final h = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final ampm = dt.hour < 12 ? 'AM' : 'PM';
    final time = '$h:${dt.minute.toString().padLeft(2, '0')} $ampm';
    return sameDay
        ? 'Updated today, $time'
        : 'Updated ${dt.day}/${dt.month}, $time';
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
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy Gold',
                style: TextStyle(
                  color: tp,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                '24K · 99.99% Pure',
                style: TextStyle(color: ts, fontSize: 11),
              ),
            ],
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
                        Icons.notifications_outlined,
                        color: Color(0xFFD4A017),
                        size: 12,
                      ),
                      SizedBox(width: 4),
                      Text(
                        'Price Alert',
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
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.25 : 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    SizedBox(
                      width: 36,
                      height: 36,
                      child: Image.asset(
                        'assets/images/jar_img.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Gold Rate (24K)',
                          style: TextStyle(color: ts, fontSize: 11),
                        ),
                        Text(
                          '₹${GoldController.to.buyRate.toStringAsFixed(2)}/g',
                          style: TextStyle(
                            color: tp,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${(GoldController.to.rate.value?.change24h ?? 0) >= 0 ? '+' : ''}₹${(GoldController.to.rate.value?.change24h ?? 0).toStringAsFixed(2)} (${(GoldController.to.rate.value?.changePct ?? 0).toStringAsFixed(2)}%) ↑',
                          style: TextStyle(
                            color: Color(0xFF2ecc71),
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          _fmtUpdated(GoldController.to.rate.value?.updatedAt),
                          style: TextStyle(color: ts, fontSize: 10),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // ── How much? ────────────────────────────────────────────────────
              Text(
                'How much gold do you want to buy?',
                style: TextStyle(
                  color: tp,
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 14),

              // Toggle
              Container(
                height: 46,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD4A017).withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _TogBtn(
                      'By Amount',
                      _byAmount,
                      () => setState(() {
                        _byAmount = true;
                        _ctrl.text = _amount > 0
                            ? _amount.toStringAsFixed(0)
                            : '1000';
                        _slider = _amount.clamp(100.0, 100000.0);
                      }),
                    ),
                    _TogBtn(
                      'By Weight',
                      !_byAmount,
                      () => setState(() {
                        _byAmount = false;
                        _ctrl.text = _grams > 0
                            ? _grams.toStringAsFixed(3)
                            : '0.100';
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Input box
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
                        ? const Color(0xFFD4A017).withOpacity(0.5)
                        : border,
                    width: _valid ? 1.5 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Text(
                      _byAmount ? '₹' : '',
                      style: TextStyle(
                        color: ts,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) => setState(() {
                          if (_byAmount)
                            _slider = (double.tryParse(v) ?? 0).clamp(
                              100.0,
                              100000.0,
                            );
                        }),
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
                          hintText: _byAmount ? '0' : '0.000',
                          hintStyle: TextStyle(
                            color: ts.withOpacity(0.35),
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if (!_byAmount)
                      Text(
                        'g',
                        style: TextStyle(
                          color: ts,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    if (_ctrl.text.isNotEmpty && _ctrl.text != '0')
                      GestureDetector(
                        onTap: () => setState(() {
                          _ctrl.clear();
                          _slider = 100.0;
                        }),
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8),
                          child: Icon(
                            Icons.cancel_rounded,
                            color: ts,
                            size: 22,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              if (!_valid && _amount > 0)
                Text(
                  'Minimum purchase is ₹${100.0.toInt()}',
                  style: const TextStyle(
                    color: Color(0xFFe74c3c),
                    fontSize: 12,
                  ),
                ),

              // Slider (amount mode)
              if (_byAmount) ...[
                const SizedBox(height: 4),
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFD4A017),
                    inactiveTrackColor: border,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 11,
                      elevation: 6,
                    ),
                    overlayColor: const Color(0xFFD4A017).withOpacity(0.15),
                    trackHeight: 5,
                  ),
                  child: Slider(
                    value: _slider.clamp(100.0, 100000.0),
                    min: 100.0,
                    max: 10000.0,
                    onChanged: (v) => setState(() {
                      _slider = v;
                      _ctrl.text = v.toStringAsFixed(0);
                    }),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${100.0.toInt()}',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                    Text(
                      '₹${(10000.0 / 1000).toInt()}K',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ] else
                const SizedBox(height: 12),

              // Quick chips — amount or weight suggestions depending on mode
              Row(
                children: (_byAmount ? [500, 1000, 2000, 5000] : [1, 2, 5, 10])
                    .map((a) {
                      final label = _byAmount ? '+₹$a' : '+${a}g';
                      final active = _byAmount
                          ? (_ctrl.text == '$a')
                          : (double.tryParse(_ctrl.text) == a.toDouble());
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 3),
                          child: GestureDetector(
                            onTap: () => _byAmount
                                ? _setAmt(a.toDouble())
                                : _setGrams(a.toDouble()),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                gradient: active
                                    ? const LinearGradient(
                                        colors: [
                                          Color(0xFFD4A017),
                                          Color(0xFFFFD700),
                                        ],
                                      )
                                    : null,
                                color: active ? null : subBg,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: active ? Colors.transparent : border,
                                ),
                              ),
                              child: Text(
                                label,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: active
                                      ? const Color(0xFF3D2B00)
                                      : const Color(0xFFD4A017),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    })
                    .toList(),
              ),
              const SizedBox(height: 20),

              // ── You will get ─────────────────────────────────────────────────
              if (_amount > 0) ...[
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
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 52,
                            height: 58,
                            child: Image.asset(
                              'assets/images/jar_img.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'You will get',
                                  style: TextStyle(color: ts, fontSize: 12),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_grams.toStringAsFixed(4)}g',
                                  style: TextStyle(
                                    color: tp,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '(24K Gold · 99.99% Pure)',
                                  style: TextStyle(color: ts, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ecc71).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF2ecc71).withOpacity(0.3),
                              ),
                            ),
                            child: const Column(
                              children: [
                                Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF2ecc71),
                                  size: 16,
                                ),
                                SizedBox(height: 3),
                                Text(
                                  '100% Safe\n& Secure',
                                  textAlign: TextAlign.center,
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
                      const SizedBox(height: 14),
                      Divider(height: 1, color: border),
                      const SizedBox(height: 12),
                      _CalcRow(
                        'Gold Value',
                        '₹${_amount.toStringAsFixed(2)}',
                        ts,
                        tp,
                        dark: dark,
                      ),
                      const SizedBox(height: 8),
                      _CalcRow(
                        'GST (${_GST_PCT.toInt()}%)',
                        '₹${_gst.toStringAsFixed(2)}',
                        ts,
                        tp,
                        dark: dark,
                      ),
                      const SizedBox(height: 8),
                      Divider(height: 1, color: border),
                      const SizedBox(height: 8),
                      _CalcRow(
                        'Total Amount',
                        '₹${_total.toStringAsFixed(2)}',
                        tp,
                        tp,
                        bold: true,
                        dark: dark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // ── Paying from Wallet ────────────────────────────────────────
                Text(
                  'Paying From',
                  style: TextStyle(
                    color: tp,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: _hasEnoughBalance
                        ? const Color(
                            0xFF2ecc71,
                          ).withOpacity(dark ? 0.10 : 0.06)
                        : const Color(
                            0xFFe74c3c,
                          ).withOpacity(dark ? 0.10 : 0.06),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _hasEnoughBalance
                          ? const Color(0xFF2ecc71).withOpacity(0.35)
                          : const Color(0xFFe74c3c).withOpacity(0.35),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: const Color(0xFF3B82F6).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF3B82F6).withOpacity(0.3),
                          ),
                        ),
                        child: const Icon(
                          Icons.account_balance_wallet_rounded,
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
                              'App Wallet',
                              style: TextStyle(
                                color: tp,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'Available Balance: ₹${_walletBal.toStringAsFixed(2)}',
                              style: TextStyle(color: ts, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _hasEnoughBalance
                            ? Icons.check_circle_rounded
                            : Icons.error_outline_rounded,
                        color: _hasEnoughBalance
                            ? const Color(0xFF2ecc71)
                            : const Color(0xFFe74c3c),
                        size: 22,
                      ),
                    ],
                  ),
                ),
                if (!_hasEnoughBalance) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => Get.toNamed('/wallet'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD4A017).withOpacity(0.10),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: const Color(0xFFD4A017).withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.add_circle_outline_rounded,
                            color: Color(0xFFD4A017),
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Add Money to Wallet',
                            style: TextStyle(
                              color: Color(0xFFD4A017),
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const SizedBox(height: 12),

                // Safety strip
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
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
                        size: 16,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your gold is 100% insured and stored in secure vaults.',
                          style: TextStyle(
                            color: Color(0xFF2ecc71),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ],
          ),
        ),

        // ── Bottom bar ────────────────────────────────────────────────────────
        bottomNavigationBar: Container(
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
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8),
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Total + buy btn
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Payable',
                        style: TextStyle(color: ts, fontSize: 11),
                      ),
                      Text(
                        _valid ? '₹${_total.toStringAsFixed(2)}' : '—',
                        style: TextStyle(
                          color: tp,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      Text(
                        '(Incl. taxes)',
                        style: TextStyle(color: ts, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: _valid && !WalletController.to.isBuying.value
                          ? () async {
                              HapticFeedback.mediumImpact();
                              final ok = await WalletController.to.buyGold(
                                amount: _amount,
                              );
                              if (ok) Get.back();
                            }
                          : (_amount >= 100.0 && !_hasEnoughBalance)
                          ? () {
                              HapticFeedback.mediumImpact();
                              Get.snackbar(
                                'Insufficient Balance',
                                'Wallet has ₹${_walletBal.toStringAsFixed(2)}, need ₹${_total.toStringAsFixed(2)}. Add money first.',
                                backgroundColor: const Color(0xFFe74c3c),
                                colorText: Colors.white,
                                snackPosition: SnackPosition.BOTTOM,
                              );
                            }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        height: 52,
                        decoration: BoxDecoration(
                          gradient: _valid
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFD4A017),
                                    Color(0xFFFFD700),
                                  ],
                                )
                              : null,
                          color: _valid
                              ? null
                              : const Color(0xFFD4A017).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: _valid
                              ? [
                                  BoxShadow(
                                    color: const Color(
                                      0xFFD4A017,
                                    ).withOpacity(0.5),
                                    blurRadius: 14,
                                    offset: const Offset(0, 5),
                                  ),
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(2, 4),
                                  ),
                                ]
                              : null,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.lock_outline_rounded,
                                    color: _valid
                                        ? const Color(0xFF3D2B00)
                                        : Colors.white38,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    WalletController.to.isBuying.value
                                        ? 'Processing...'
                                        : _valid
                                        ? 'Buy Gold Securely'
                                        : (_amount >= 100.0 &&
                                              !_hasEnoughBalance)
                                        ? 'Insufficient Balance'
                                        : 'Min ₹${100.0.toInt()}',
                                    style: TextStyle(
                                      color: _valid
                                          ? const Color(0xFF3D2B00)
                                          : Colors.white38,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Wallet Balance: ₹${_walletBal.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: _valid
                                      ? const Color(
                                          0xFF3D2B00,
                                        ).withOpacity(0.55)
                                      : Colors.white24,
                                  fontSize: 9,
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
                    style: TextStyle(color: Color(0xFF8A95B0), fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _TogBtn(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD4A017) : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            label,
            style: TextStyle(
              color: active ? Colors.black : const Color(0xFF8A95B0),
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    ),
  );
}

class _CalcRow extends StatelessWidget {
  const _CalcRow(
    this.label,
    this.value,
    this.lc,
    this.vc, {
    this.bold = false,
    required this.dark,
  });
  final String label, value;
  final Color lc, vc;
  final bool bold, dark;
  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        label,
        style: TextStyle(
          color: lc,
          fontSize: 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
        ),
      ),
      Text(
        value,
        style: TextStyle(
          color: vc,
          fontSize: bold ? 15 : 13,
          fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    ],
  );
}
