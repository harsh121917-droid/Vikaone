import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/data/repositories/gold_repository.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import 'package:real_estate/modules/digi_gold/controllers/digi_gold_controller.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import 'transaction_detail_view.dart';

// Jar target is just a personal savings-goal marker (not financial data),
// kept local — everything else below (balance, rate, history) is real API data.
const double _JAR_TARGET = 10.0; // grams goal

// ─── Main Screen ─────────────────────────────────────────────────────────────
class DigiGoldSavingsView extends StatefulWidget {
  const DigiGoldSavingsView({super.key});
  @override
  State<DigiGoldSavingsView> createState() => _DigiGoldSavingsViewState();
}

class _DigiGoldSavingsViewState extends State<DigiGoldSavingsView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _scale;

  // Auto-save state (UI only — no backend SIP endpoint exists yet)
  final _autoAmounts = [100, 500, 1000, 2000];
  int _selectedAutoAmt = 500;
  bool _autoEnabled = false;
  int _autoFreqIdx = 1; // 0=Daily 1=Weekly 2=Monthly

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _scale = Tween(
      begin: 1.0,
      end: 1.06,
    ).animate(CurvedAnimation(parent: _pulse, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  double get _jarSaved => GoldController.to.totalGrams;
  double get _pct => (_jarSaved / _JAR_TARGET * 100).clamp(0, 100);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: dark
              ? const Color(0xFF0E1626)
              : const Color(0xFF3D2B00),
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          title: const Text(
            'Gold Savings Jar',
            style: TextStyle(
              color: Colors.white,
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
                    color: const Color(0xFFD4A017).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: const Color(0xFFD4A017).withOpacity(0.4),
                    ),
                  ),
                  child: const Text(
                    '24K Gold',
                    style: TextStyle(
                      color: Color(0xFFD4A017),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            children: [
              _JarHero(pct: _pct, saved: _jarSaved, scale: _scale, dark: dark),
              _StatsStrip(saved: _jarSaved, dark: dark),
              _AddGoldCard(dark: dark),
              _AutoSaveCard(
                dark: dark,
                enabled: _autoEnabled,
                amounts: _autoAmounts,
                selectedAmt: _selectedAutoAmt,
                freqIdx: _autoFreqIdx,
                onToggle: (v) => setState(() => _autoEnabled = v),
                onAmt: (a) => setState(() => _selectedAutoAmt = a),
                onFreq: (i) => setState(() => _autoFreqIdx = i),
              ),
              _HistorySection(
                entries: GoldController.to.transactions,
                dark: dark,
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
        bottomNavigationBar: _SaveNowBar(dark: dark),
      );
    });
  }
}

// ─── Jar Hero ─────────────────────────────────────────────────────────────────
class _JarHero extends StatelessWidget {
  const _JarHero({
    required this.pct,
    required this.saved,
    required this.scale,
    required this.dark,
  });
  final double pct;
  final double saved;
  final Animation<double> scale;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF1A1200), Color(0xFF2D1F00)],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3D2B00), Color(0xFF6B4A00)],
              ),
      ),
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left — grams + progress
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Saved So Far',
                  style: TextStyle(color: Colors.white54, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Transform.translate(
                      offset: const Offset(2, 3),
                      child: Text(
                        '${saved.toStringAsFixed(4)}g',
                        style: const TextStyle(
                          color: Color(0x44D4A017),
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -1,
                        ),
                      ),
                    ),
                    Text(
                      '${saved.toStringAsFixed(4)}g',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '₹${(saved * GoldController.to.buyRate).toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),

                // Progress bar
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: SizedBox(
                          height: 10,
                          child: Stack(
                            children: [
                              Container(color: Colors.white.withOpacity(0.12)),
                              TweenAnimationBuilder<double>(
                                tween: Tween(
                                  begin: 0,
                                  end: (pct / 100).clamp(0.0, 1.0),
                                ),
                                duration: const Duration(milliseconds: 1000),
                                curve: Curves.easeOutCubic,
                                builder: (_, v, __) => FractionallySizedBox(
                                  widthFactor: v,
                                  child: Stack(
                                    children: [
                                      Container(
                                        decoration: BoxDecoration(
                                          gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFFD4A017),
                                              Color(0xFFFFD700),
                                            ],
                                          ),
                                          boxShadow: [
                                            BoxShadow(
                                              color: const Color(
                                                0xFFD4A017,
                                              ).withOpacity(0.5),
                                              blurRadius: 6,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Positioned(
                                        top: 2,
                                        left: 4,
                                        right: 4,
                                        height: 4,
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.3,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      '${pct.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        color: Color(0xFFD4A017),
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  'Target: ${_JAR_TARGET}g  ·  ${(_JAR_TARGET - saved).clamp(0, _JAR_TARGET).toStringAsFixed(3)}g to go',
                  style: const TextStyle(color: Colors.white38, fontSize: 11),
                ),
              ],
            ),
          ),

          const SizedBox(width: 16),

          // Right — animated jar image
          AnimatedBuilder(
            animation: scale,
            builder: (_, __) => Transform.scale(
              scale: scale.value,
              child: SizedBox(
                width: 120,
                height: 140,
                child: Image.asset(
                  'assets/images/jar_img.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stats Strip ──────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.saved, required this.dark});
  final double saved;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _SC(
            '${saved.toStringAsFixed(4)}g',
            'Total Saved',
            Icons.savings_outlined,
            const Color(0xFFD4A017),
            dark,
          ),
          _VD(dark),
          _SC(
            '₹${(saved * GoldController.to.buyRate).toStringAsFixed(0)}',
            'Value',
            Icons.currency_rupee_rounded,
            const Color(0xFF2ecc71),
            dark,
          ),
          _VD(dark),
          _SC(
            '${(_JAR_TARGET - saved).clamp(0, _JAR_TARGET).toStringAsFixed(3)}g',
            'Remaining',
            Icons.pending_outlined,
            const Color(0xFF3B82F6),
            dark,
          ),
        ],
      ),
    );
  }
}

class _SC extends StatelessWidget {
  const _SC(this.val, this.lbl, this.icon, this.color, this.dark);
  final String val, lbl;
  final IconData icon;
  final Color color;
  final bool dark;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(height: 6),
        Text(
          val,
          style: TextStyle(
            color: dark ? Colors.white : const Color(0xFF1A2340),
            fontSize: 14,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          lbl,
          style: TextStyle(
            color: dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280),
            fontSize: 10,
          ),
        ),
      ],
    ),
  );
}

class _VD extends StatelessWidget {
  const _VD(this.dark);
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    width: 1,
    height: 40,
    color: dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8),
  );
}

// ─── Add Gold (manual) ────────────────────────────────────────────────────────
class _AddGoldCard extends StatelessWidget {
  const _AddGoldCard({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Add to Jar',
            style: TextStyle(
              color: tp,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Save gold anytime — no minimum',
            style: TextStyle(color: ts, fontSize: 12),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.bottomSheet(
                    const _SaveGoldSheet(mode: 'amount'),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4A017).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Text(
                        'Save by ₹ Amount',
                        style: TextStyle(
                          color: Color(0xFF3D2B00),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: GestureDetector(
                  onTap: () => Get.bottomSheet(
                    const _SaveGoldSheet(mode: 'weight'),
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                  ),
                  child: Container(
                    height: 48,
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFD4A017,
                      ).withOpacity(dark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFD4A017).withOpacity(0.4),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Save by Grams',
                        style: TextStyle(
                          color: Color(0xFFD4A017),
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Auto Save Card ───────────────────────────────────────────────────────────
class _AutoSaveCard extends StatelessWidget {
  const _AutoSaveCard({
    required this.dark,
    required this.enabled,
    required this.amounts,
    required this.selectedAmt,
    required this.freqIdx,
    required this.onToggle,
    required this.onAmt,
    required this.onFreq,
  });
  final bool dark, enabled;
  final List<int> amounts;
  final int selectedAmt, freqIdx;
  final ValueChanged<bool> onToggle;
  final ValueChanged<int> onAmt;
  final ValueChanged<int> onFreq;

  static const _freqs = ['Daily', 'Weekly', 'Monthly'];

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 0),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header + toggle
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFFAB47BC).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFFAB47BC).withOpacity(0.3),
                  ),
                ),
                child: const Icon(
                  Icons.autorenew_rounded,
                  color: Color(0xFFAB47BC),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto Save',
                      style: TextStyle(
                        color: tp,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Text(
                      'Save gold automatically',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                  ],
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (v) {
                  HapticFeedback.lightImpact();
                  onToggle(v);
                },
                activeColor: const Color(0xFFD4A017),
              ),
            ],
          ),

          if (enabled) ...[
            const SizedBox(height: 16),
            Divider(color: border, height: 1),
            const SizedBox(height: 16),

            // Frequency
            Text(
              'Frequency',
              style: TextStyle(
                color: ts,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: List.generate(_freqs.length, (i) {
                final active = i == freqIdx;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 3),
                    child: GestureDetector(
                      onTap: () {
                        HapticFeedback.selectionClick();
                        onFreq(i);
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        padding: const EdgeInsets.symmetric(vertical: 9),
                        decoration: BoxDecoration(
                          gradient: active
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFFD4A017),
                                    Color(0xFFFFD700),
                                  ],
                                )
                              : null,
                          color: active
                              ? null
                              : (dark
                                    ? const Color(0xFF0A0F1E)
                                    : const Color(0xFFF5F0E8)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: active ? Colors.transparent : border,
                          ),
                        ),
                        child: Text(
                          _freqs[i],
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: active ? const Color(0xFF3D2B00) : ts,
                            fontSize: 13,
                            fontWeight: active
                                ? FontWeight.w800
                                : FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Amount
            Text(
              'Amount per ${_freqs[freqIdx]}',
              style: TextStyle(
                color: ts,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.4,
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: amounts.map((a) {
                final active = a == selectedAmt;
                return GestureDetector(
                  onTap: () {
                    HapticFeedback.selectionClick();
                    onAmt(a);
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 9,
                    ),
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(
                              colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                            )
                          : null,
                      color: active
                          ? null
                          : (dark
                                ? const Color(0xFF0A0F1E)
                                : const Color(0xFFF5F0E8)),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: active ? Colors.transparent : border,
                      ),
                    ),
                    child: Text(
                      '₹$a',
                      style: TextStyle(
                        color: active ? const Color(0xFF3D2B00) : ts,
                        fontSize: 13,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),

            // Preview
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withOpacity(dark ? 0.12 : 0.06),
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
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '₹$selectedAmt every ${_freqs[freqIdx]} → ${(selectedAmt / GoldController.to.buyRate).toStringAsFixed(4)}g gold per ${_freqs[freqIdx].toLowerCase()}',
                      style: const TextStyle(
                        color: Color(0xFFD4A017),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            GestureDetector(
              onTap: () {
                WalletController.to.addMoney(selectedAmt.toDouble());
                Get.snackbar(
                  'Opening Razorpay...',
                  'Recurring auto-charge on a schedule isn\'t wired yet — this charges ₹$selectedAmt now.',
                  backgroundColor: const Color(0xFFAB47BC),
                  colorText: Colors.white,
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              child: Container(
                height: 48,
                width: double.infinity,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFAB47BC), Color(0xFFCE93D8)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFAB47BC).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Activate Auto Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── History Section ──────────────────────────────────────────────────────────
class _HistorySection extends StatelessWidget {
  const _HistorySection({required this.entries, required this.dark});
  final List<GoldTxnModel> entries;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Savings History',
                style: TextStyle(
                  color: tp,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Center(
                child: Text(
                  'No purchases yet',
                  style: TextStyle(color: ts, fontSize: 13),
                ),
              ),
            ),
          ...entries.map((e) => _HistoryRow(entry: e, dark: dark)),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.entry, required this.dark});
  final GoldTxnModel entry;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final isBuy = entry.type == 'buy';
    final dateStr = entry.createdAt.toString().substring(0, 16);

    return GestureDetector(
      onTap: () => Get.to(() => TransactionDetailView(txn: entry)),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFD4A017).withOpacity(0.12),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(
                  color: const Color(0xFFD4A017).withOpacity(0.3),
                ),
              ),
              child: Icon(
                isBuy ? Icons.add_rounded : Icons.remove_rounded,
                color: const Color(0xFFD4A017),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isBuy ? 'Gold Purchased' : 'Gold Sold',
                    style: TextStyle(
                      color: tp,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(dateStr, style: TextStyle(color: ts, fontSize: 11)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${isBuy ? '+' : '-'}${entry.grams.toStringAsFixed(3)}g',
                  style: const TextStyle(
                    color: Color(0xFF2ecc71),
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '₹${entry.totalAmt.toStringAsFixed(2)}',
                  style: TextStyle(color: ts, fontSize: 11),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Save Now Bottom Bar ──────────────────────────────────────────────────────
class _SaveNowBar extends StatelessWidget {
  const _SaveNowBar({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: GestureDetector(
        onTap: () => Get.bottomSheet(
          const _SaveGoldSheet(mode: 'amount'),
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
        ),
        child: Container(
          height: 54,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFD4A017).withOpacity(0.5),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(2, 4),
              ),
            ],
          ),
          child: const Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.savings_outlined,
                  color: Color(0xFF3D2B00),
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'Save Gold Now',
                  style: TextStyle(
                    color: Color(0xFF3D2B00),
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Save Gold Sheet (by ₹ or grams) ─────────────────────────────────────────
class _SaveGoldSheet extends StatefulWidget {
  const _SaveGoldSheet({required this.mode}); // 'amount' or 'weight'
  final String mode;
  @override
  State<_SaveGoldSheet> createState() => _SaveGoldSheetState();
}

class _SaveGoldSheetState extends State<_SaveGoldSheet> {
  late bool _byAmt;
  final _ctrl = TextEditingController();
  double _slider = 500;

  static const double _MIN = 100, _MAX = 50000;
  static const double _GST = 3.0;

  @override
  void initState() {
    super.initState();
    _byAmt = widget.mode == 'amount';
    _ctrl.text = _byAmt ? '500' : '0.050';
    _slider = 500;
  }

  double get _total => _byAmt
      ? (double.tryParse(_ctrl.text) ?? 0)
      : (double.tryParse(_ctrl.text) ?? 0) *
            GoldController.to.buyRate *
            (1 + _GST / 100);
  double get _amt => _total / (1 + _GST / 100); // gold value (pre-GST)
  double get _grams => _amt / GoldController.to.buyRate;
  double get _gst => _total - _amt;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final subBg = dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5EE);

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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 32),
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
              const SizedBox(height: 16),

              // Header
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_rounded, color: tp, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Save Gold to Jar',
                    style: TextStyle(
                      color: tp,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '24K  ·  ₹${GoldController.to.buyRate.toStringAsFixed(0)}/g',
                    style: const TextStyle(
                      color: Color(0xFFD4A017),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Toggle
              Container(
                height: 44,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: const Color(0xFFD4A017).withOpacity(0.4),
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    _TogBtn(
                      'By Amount',
                      _byAmt,
                      () => setState(() {
                        _byAmt = true;
                        _ctrl.text = '500';
                        _slider = 500;
                      }),
                    ),
                    _TogBtn(
                      'By Weight',
                      !_byAmt,
                      () => setState(() {
                        _byAmt = false;
                        _ctrl.text = '0.050';
                      }),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),

              // Input
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: subBg,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: border),
                ),
                child: Row(
                  children: [
                    Text(
                      _byAmt ? '₹' : 'g',
                      style: TextStyle(
                        color: ts,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) => setState(() {
                          if (_byAmt)
                            _slider = (double.tryParse(v) ?? 500).clamp(
                              _MIN,
                              _MAX,
                            );
                        }),
                        style: TextStyle(
                          color: tp,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          filled: false,
                          hintText: _byAmt ? '0' : '0.000',
                          hintStyle: TextStyle(
                            color: ts.withOpacity(0.4),
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                          ),
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    if ((_ctrl.text).isNotEmpty)
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

              // Slider
              if (_byAmt) ...[
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFFD4A017),
                    inactiveTrackColor: border,
                    thumbColor: Colors.white,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 10,
                      elevation: 4,
                    ),
                    overlayColor: const Color(0xFFD4A017).withOpacity(0.15),
                    trackHeight: 4,
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
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '₹${_MIN.toInt()}',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                    Text(
                      '₹${(_MAX / 1000).toInt()}K',
                      style: TextStyle(color: ts, fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
              ] else
                const SizedBox(height: 10),

              // Quick chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children:
                    (_byAmt
                            ? [100, 500, 1000, 2000, 5000]
                            : [0.050, 0.100, 0.250, 0.500, 1.000])
                        .map(
                          (v) => GestureDetector(
                            onTap: () => setState(() {
                              _ctrl.text = _byAmt
                                  ? '${v.toInt()}'
                                  : v.toString();
                              if (_byAmt)
                                _slider = (v as double).clamp(_MIN, _MAX);
                            }),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFFD4A017,
                                ).withOpacity(0.08),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFFD4A017,
                                  ).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                _byAmt ? '+₹${v.toInt()}' : '+${v}g',
                                style: const TextStyle(
                                  color: Color(0xFFD4A017),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        )
                        .toList(),
              ),
              const SizedBox(height: 18),

              // You save box
              if (_total > 0) ...[
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: subBg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: border),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 44,
                            height: 48,
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
                                  'You will save',
                                  style: TextStyle(color: ts, fontSize: 12),
                                ),
                                Text(
                                  '${_grams.toStringAsFixed(4)}g',
                                  style: TextStyle(
                                    color: tp,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                Text(
                                  '(24K Gold)',
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
                              color: const Color(0xFF2ecc71).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF2ecc71).withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'Insured\n& Secure',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Color(0xFF2ecc71),
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: border, height: 1),
                      const SizedBox(height: 10),
                      _Row('Gold Value', '₹${_amt.toStringAsFixed(2)}', ts, tp),
                      const SizedBox(height: 6),
                      _Row('GST (3%)', '₹${_gst.toStringAsFixed(2)}', ts, tp),
                      const SizedBox(height: 6),
                      Divider(color: border, height: 1),
                      const SizedBox(height: 8),
                      _Row(
                        'Total Payable',
                        '₹${_total.toStringAsFixed(2)}',
                        tp,
                        tp,
                        bold: true,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Save button
              GestureDetector(
                onTap: _total >= 100 && !_saving
                    ? () async {
                        setState(() => _saving = true);
                        final ok = await WalletController.to.buyGold(
                          amount: _amt,
                        );
                        setState(() => _saving = false);
                        if (ok) Get.back();
                      }
                    : null,
                child: Container(
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: _total >= 100
                        ? const LinearGradient(
                            colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                          )
                        : null,
                    color: _total >= 100
                        ? null
                        : const Color(0xFFD4A017).withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: _total >= 100
                        ? [
                            BoxShadow(
                              color: const Color(0xFFD4A017).withOpacity(0.5),
                              blurRadius: 12,
                              offset: const Offset(0, 5),
                            ),
                          ]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      _saving
                          ? 'Processing...'
                          : _total >= 100
                          ? 'Save Gold — ₹${_total.toStringAsFixed(2)}'
                          : 'Min ₹100',
                      style: TextStyle(
                        color: _total >= 100
                            ? const Color(0xFF3D2B00)
                            : Colors.white38,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
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

  Widget _TogBtn(String label, bool active, VoidCallback onTap) => Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        height: double.infinity,
        decoration: BoxDecoration(
          color: active ? const Color(0xFFD4A017) : Colors.transparent,
          borderRadius: BorderRadius.circular(9),
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

  Widget _Row(String l, String v, Color lc, Color vc, {bool bold = false}) =>
      Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l,
            style: TextStyle(
              color: lc,
              fontSize: 13,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            ),
          ),
          Text(
            v,
            style: TextStyle(
              color: vc,
              fontSize: 13,
              fontWeight: bold ? FontWeight.w900 : FontWeight.w600,
            ),
          ),
        ],
      );
}
