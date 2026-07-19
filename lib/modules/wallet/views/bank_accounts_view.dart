import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';

const _dummyBanks = [
  _Bank(
    id: '1',
    name: 'HDFC Bank',
    holder: 'Rahul Sharma',
    acc: '••••••1234',
    ifsc: 'HDFC0001234',
    isDefault: true,
  ),
  _Bank(
    id: '2',
    name: 'SBI Bank',
    holder: 'Rahul Sharma',
    acc: '••••••5678',
    ifsc: 'SBIN0001234',
    isDefault: false,
  ),
];

class BankAccountsView extends StatefulWidget {
  const BankAccountsView({super.key});
  @override
  State<BankAccountsView> createState() => _BankAccountsViewState();
}

class _BankAccountsViewState extends State<BankAccountsView> {
  final _banks = List<_Bank>.from(_dummyBanks);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF5F0E8);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;

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
            'Bank Accounts',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            // Info strip
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF3B82F6).withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF3B82F6).withOpacity(0.2),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF3B82F6),
                    size: 15,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Your bank account is used for gold sale payouts and wallet withdrawals.',
                      style: TextStyle(color: Color(0xFF3B82F6), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Bank cards
            ..._banks.map(
              (b) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: b.isDefault
                          ? const Color(0xFFD4A017).withOpacity(0.5)
                          : border,
                      width: b.isDefault ? 1.5 : 1,
                    ),
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
                          Container(
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: const Color(0xFF3B82F6).withOpacity(0.10),
                              borderRadius: BorderRadius.circular(13),
                              border: Border.all(
                                color: const Color(0xFF3B82F6).withOpacity(0.3),
                              ),
                            ),
                            child: const Icon(
                              Icons.account_balance_rounded,
                              color: Color(0xFF3B82F6),
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      b.name,
                                      style: TextStyle(
                                        color: tp,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    if (b.isDefault) ...[
                                      const SizedBox(width: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFD4A017,
                                          ).withOpacity(0.12),
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Text(
                                          'Default',
                                          style: TextStyle(
                                            color: Color(0xFFD4A017),
                                            fontSize: 9,
                                            fontWeight: FontWeight.w800,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  b.holder,
                                  style: TextStyle(color: ts, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          // More options
                          PopupMenuButton<String>(
                            color: cardBg,
                            icon: Icon(
                              Icons.more_vert_rounded,
                              color: ts,
                              size: 20,
                            ),
                            onSelected: (v) {
                              if (v == 'default') {
                                setState(() {
                                  for (var bank in _banks)
                                    bank = _Bank(
                                      id: bank.id,
                                      name: bank.name,
                                      holder: bank.holder,
                                      acc: bank.acc,
                                      ifsc: bank.ifsc,
                                      isDefault: bank.id == b.id,
                                    );
                                });
                                Get.snackbar(
                                  'Default Updated',
                                  '${b.name} set as default',
                                  backgroundColor: const Color(0xFFD4A017),
                                  colorText: Colors.black,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else if (v == 'delete') {
                                setState(
                                  () => _banks.removeWhere((x) => x.id == b.id),
                                );
                                Get.snackbar(
                                  'Removed',
                                  '${b.name} removed',
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              }
                            },
                            itemBuilder: (_) => [
                              if (!b.isDefault)
                                const PopupMenuItem(
                                  value: 'default',
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.star_outline_rounded,
                                        size: 18,
                                        color: Color(0xFFD4A017),
                                      ),
                                      SizedBox(width: 10),
                                      Text('Set as Default'),
                                    ],
                                  ),
                                ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Color(0xFFe74c3c),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      'Remove',
                                      style: TextStyle(
                                        color: Color(0xFFe74c3c),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Divider(color: border, height: 1),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          _BankDetail('A/c No.', b.acc, ts, tp),
                          _BankDetail('IFSC', b.ifsc, ts, tp),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Add new
            GestureDetector(
              onTap: () => Get.bottomSheet(
                _AddBankSheet(dark: dark),
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
              ),
              child: Container(
                height: 58,
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFD4A017).withOpacity(0.4),
                    style: BorderStyle.solid,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.2 : 0.04),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_circle_outline_rounded,
                        color: Color(0xFFD4A017),
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Text(
                        'Add New Bank Account',
                        style: TextStyle(
                          color: Color(0xFFD4A017),
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      );
    });
  }
}

// ─── Add Bank Sheet ───────────────────────────────────────────────────────────
class _AddBankSheet extends StatefulWidget {
  const _AddBankSheet({required this.dark});
  final bool dark;
  @override
  State<_AddBankSheet> createState() => _AddBankSheetState();
}

class _AddBankSheetState extends State<_AddBankSheet> {
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
    final dark = widget.dark;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

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
          padding: const EdgeInsets.fromLTRB(20, 14, 20, 36),
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
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_rounded, color: tp, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Add Bank Account',
                    style: TextStyle(
                      color: tp,
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 22),

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
              const SizedBox(height: 20),

              // Save button
              GestureDetector(
                onTap: _valid && !_saving
                    ? () async {
                        setState(() => _saving = true);
                        await Future.delayed(const Duration(milliseconds: 800));
                        Get.back();
                        Get.snackbar(
                          'Bank Added! 🏦',
                          'Your bank account has been saved',
                          backgroundColor: const Color(0xFF2ecc71),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.BOTTOM,
                        );
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
                              color: const Color(0xFFD4A017).withOpacity(0.45),
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

class _Bank {
  final String id, name, holder, acc, ifsc;
  final bool isDefault;
  const _Bank({
    required this.id,
    required this.name,
    required this.holder,
    required this.acc,
    required this.ifsc,
    required this.isDefault,
  });
}

class _BankDetail extends StatelessWidget {
  const _BankDetail(this.label, this.value, this.ts, this.tp);
  final String label, value;
  final Color ts, tp;
  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: ts, fontSize: 10)),
        const SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: tp,
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    ),
  );
}
