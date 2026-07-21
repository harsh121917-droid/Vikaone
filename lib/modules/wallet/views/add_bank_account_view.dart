import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class AddBankAccountView extends StatefulWidget {
  const AddBankAccountView({super.key});
  @override
  State<AddBankAccountView> createState() => _AddBankAccountViewState();
}

class _AddBankAccountViewState extends State<AddBankAccountView> {
  final _holderCtrl = TextEditingController();
  final _accCtrl = TextEditingController();
  final _ifscCtrl = TextEditingController();
  final _bankCtrl = TextEditingController();
  String _accType = 'savings';
  bool _saving = false;

  bool get _valid =>
      _holderCtrl.text.trim().length > 2 &&
      _accCtrl.text.trim().length >= 8 &&
      _ifscCtrl.text.trim().length == 11 &&
      _bankCtrl.text.trim().length > 2;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

      return Scaffold(
        backgroundColor: bg,
        resizeToAvoidBottomInset: true,
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
            'Add Bank Account',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Field(
                  'Account Holder Name',
                  _holderCtrl,
                  tp,
                  ts,
                  border,
                  dark,
                  hint: 'As per bank records',
                ),
                _Field(
                  'Bank Name',
                  _bankCtrl,
                  tp,
                  ts,
                  border,
                  dark,
                  hint: 'e.g. HDFC Bank',
                ),
                _Field(
                  'Account Number',
                  _accCtrl,
                  tp,
                  ts,
                  border,
                  dark,
                  hint: 'Enter account number',
                  type: TextInputType.number,
                ),
                _Field(
                  'IFSC Code',
                  _ifscCtrl,
                  tp,
                  ts,
                  border,
                  dark,
                  hint: 'e.g. HDFC0001234',
                  onChanged: (v) => setState(() {
                    _ifscCtrl.text = v.toUpperCase();
                    _ifscCtrl.selection = TextSelection.fromPosition(
                      TextPosition(offset: _ifscCtrl.text.length),
                    );
                  }),
                ),

                // Account type
                const SizedBox(height: 4),
                Text(
                  'Account Type',
                  style: TextStyle(
                    color: ts,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: ['savings', 'current'].map((t) {
                    final active = _accType == t;
                    return Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _accType = t);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(vertical: 11),
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
                                        : const Color(0xFFF8F5F0)),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: active ? Colors.transparent : border,
                              ),
                            ),
                            child: Text(
                              t[0].toUpperCase() + t.substring(1),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: active ? Colors.black : ts,
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
                  }).toList(),
                ),
                const SizedBox(height: 28),

                // Save button
                GestureDetector(
                  onTap: _valid && !_saving
                      ? () async {
                          setState(() => _saving = true);
                          final ok = await WalletController.to.addBank(
                            accountHolder: _holderCtrl.text.trim(),
                            accountNumber: _accCtrl.text.trim(),
                            ifsc: _ifscCtrl.text.trim(),
                            bankName: _bankCtrl.text.trim(),
                            accountType: _accType,
                          );
                          setState(() => _saving = false);
                          if (ok) {
                            Get.back();
                            Get.snackbar(
                              'Bank Added! 🏦',
                              'Your bank account has been saved',
                              backgroundColor: const Color(0xFF2ecc71),
                              colorText: Colors.white,
                              snackPosition: SnackPosition.BOTTOM,
                            );
                          }
                        }
                      : null,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    height: 54,
                    decoration: BoxDecoration(
                      gradient: _valid
                          ? const LinearGradient(
                              colors: [Color(0xFFD4A017), Color(0xFFFFD700)],
                            )
                          : null,
                      color: _valid
                          ? null
                          : const Color(0xFFD4A017).withOpacity(0.25),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: _valid
                          ? [
                              BoxShadow(
                                color: const Color(
                                  0xFFD4A017,
                                ).withOpacity(0.45),
                                blurRadius: 14,
                                offset: const Offset(0, 5),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: _saving
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : Text(
                              _valid ? 'Save Bank Account' : 'Fill all fields',
                              style: TextStyle(
                                color: _valid ? Colors.black : Colors.white38,
                                fontSize: 14,
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
    });
  }
}

Widget _Field(
  String label,
  TextEditingController ctrl,
  Color tp,
  Color ts,
  Color border,
  bool dark, {
  String hint = '',
  TextInputType? type,
  ValueChanged<String>? onChanged,
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
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: ctrl,
          keyboardType: type,
          onChanged: onChanged,
          style: TextStyle(
            color: tp,
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: ts.withOpacity(0.5), fontSize: 14),
            filled: true,
            fillColor: dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8F5F0),
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
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    ),
  );
}
