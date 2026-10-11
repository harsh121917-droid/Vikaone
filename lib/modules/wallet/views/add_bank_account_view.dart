import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../controllers/wallet_controller.dart';

class AddBankAccountView extends StatefulWidget {
  const AddBankAccountView({super.key});

  @override
  State<AddBankAccountView> createState() => _AddBankAccountViewState();
}

class _AddBankAccountViewState extends State<AddBankAccountView> {
  final _holderCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _confirmAccCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  String _accType = 'savings';
  bool _saving = false;

  bool get _valid {
    final h = _holderCtrl.text.trim();
    final b = _bankCtrl.text.trim();
    final a = _accCtrl.text.trim();
    final ca = _confirmAccCtrl.text.trim();
    final i = _ifscCtrl.text.trim();

    return h.length >= 3 &&
        b.length >= 3 &&
        a.length >= 8 &&
        a == ca &&
        i.length == 11;
  }

  @override
  Widget build(BuildContext context) {
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
                            'Add Bank Account',
                            style: TextStyle(
                              color: tp,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Enter bank details for verified payouts',
                            style: TextStyle(color: ts, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // ── Form Scrollable Area ─────────────────────────────────────
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Verification note
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(dark ? 0.12 : 0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.verified_user_outlined,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'Account holder name must match the name registered on your PAN card. Instant penny-drop verification will be initiated.',
                                style: TextStyle(
                                  color: dark ? const Color(0xFFA7F3D0) : const Color(0xFF065F46),
                                  fontSize: 11.5,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 18),

                      // Form Container
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: border, width: 1.1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(dark ? 0.3 : 0.03),
                              blurRadius: 14,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 1. Account Holder Name
                            _buildField(
                              label: 'ACCOUNT HOLDER NAME',
                              controller: _holderCtrl,
                              hint: 'e.g. Rahul Sharma',
                              icon: Icons.person_outline_rounded,
                              tp: tp,
                              ts: ts,
                              border: border,
                              dark: dark,
                            ),
                            const SizedBox(height: 16),

                            // 2. Bank Name
                            _buildField(
                              label: 'BANK NAME',
                              controller: _bankCtrl,
                              hint: 'e.g. HDFC Bank, ICICI Bank',
                              icon: Icons.account_balance_outlined,
                              tp: tp,
                              ts: ts,
                              border: border,
                              dark: dark,
                            ),
                            const SizedBox(height: 16),

                            // 3. Account Number
                            _buildField(
                              label: 'ACCOUNT NUMBER',
                              controller: _accCtrl,
                              hint: 'Enter account number',
                              icon: Icons.numbers_rounded,
                              keyboardType: TextInputType.number,
                              tp: tp,
                              ts: ts,
                              border: border,
                              dark: dark,
                            ),
                            const SizedBox(height: 16),

                            // 4. Confirm Account Number
                            _buildField(
                              label: 'CONFIRM ACCOUNT NUMBER',
                              controller: _confirmAccCtrl,
                              hint: 'Re-enter account number',
                              icon: Icons.numbers_rounded,
                              keyboardType: TextInputType.number,
                              tp: tp,
                              ts: ts,
                              border: border,
                              dark: dark,
                              hasMismatch: _confirmAccCtrl.text.isNotEmpty &&
                                  _accCtrl.text != _confirmAccCtrl.text,
                            ),
                            const SizedBox(height: 16),

                            // 5. IFSC Code
                            _buildField(
                              label: 'IFSC CODE',
                              controller: _ifscCtrl,
                              hint: 'e.g. HDFC0001234',
                              icon: Icons.pin_outlined,
                              textCapitalization: TextCapitalization.characters,
                              maxLength: 11,
                              tp: tp,
                              ts: ts,
                              border: border,
                              dark: dark,
                            ),
                            const SizedBox(height: 16),

                            // 6. Account Type Segments
                            Text(
                              'ACCOUNT TYPE',
                              style: TextStyle(
                                color: ts,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.8,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildTypeOption('savings', 'Savings Account', Icons.savings_outlined, dark),
                                const SizedBox(width: 10),
                                _buildTypeOption('current', 'Current Account', Icons.business_outlined, dark),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: (_valid && !_saving) ? _handleSubmit : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2563EB),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                            elevation: 0,
                          ),
                          child: _saving
                              ? const SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.5,
                                  ),
                                )
                              : const Text(
                                  'Verify & Link Account',
                                  style: TextStyle(
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
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required Color tp,
    required Color ts,
    required Color border,
    required bool dark,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
    int? maxLength,
    bool hasMismatch = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                color: ts,
                fontSize: 10.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
            if (hasMismatch)
              const Text(
                'Numbers do not match',
                style: TextStyle(color: Color(0xFFEF4444), fontSize: 10, fontWeight: FontWeight.w700),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Container(
          height: 48,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: hasMismatch ? const Color(0xFFEF4444) : border,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: ts),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textCapitalization: textCapitalization,
                  maxLength: maxLength,
                  buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
                  style: TextStyle(color: tp, fontSize: 13.5, fontWeight: FontWeight.w600),
                  decoration: InputDecoration(
                    hintText: hint,
                    hintStyle: TextStyle(color: ts.withOpacity(0.6), fontSize: 13),
                    border: InputBorder.none,
                    isDense: true,
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTypeOption(String key, String title, IconData icon, bool dark) {
    final active = _accType == key;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _accType = key),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 8),
          decoration: BoxDecoration(
            color: active
                ? const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.1)
                : (dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? const Color(0xFF2563EB) : (dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0)),
              width: active ? 1.5 : 1.0,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: active ? const Color(0xFF2563EB) : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                title,
                style: TextStyle(
                  color: active ? const Color(0xFF2563EB) : (dark ? Colors.white70 : Colors.black87),
                  fontSize: 11.5,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSubmit() async {
    HapticFeedback.lightImpact();
    setState(() => _saving = true);

    final ok = await WalletController.to.addBank(
      accountHolder: _holderCtrl.text.trim(),
      bankName: _bankCtrl.text.trim(),
      accountNumber: _accCtrl.text.trim(),
      ifsc: _ifscCtrl.text.trim().toUpperCase(),
      accountType: _accType,
    );

    setState(() => _saving = false);
    if (ok) {
      Get.back();
      Get.snackbar(
        'Bank Account Linked! 🏦',
        'Your bank account is verified and ready for payouts.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
      );
    }
  }
}
