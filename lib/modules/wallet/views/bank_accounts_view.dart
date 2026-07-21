import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import 'package:real_estate/routes/app_routes.dart';
import '../../../core/theme/controllers/theme_controller.dart';

class BankAccountsView extends StatefulWidget {
  const BankAccountsView({super.key});
  @override
  State<BankAccountsView> createState() => _BankAccountsViewState();
}

class _BankAccountsViewState extends State<BankAccountsView> {
  final _ctrl = WalletController.to;

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
            if (_ctrl.banks.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: Text(
                    'No bank accounts added yet',
                    style: TextStyle(color: ts, fontSize: 13),
                  ),
                ),
              ),
            ..._ctrl.banks.map(
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
                                      b.bankName,
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
                                  b.accountHolder,
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
                            onSelected: (v) async {
                              if (v == 'default') {
                                await _ctrl.setDefaultBank(b.id);
                                Get.snackbar(
                                  'Default Updated',
                                  '${b.bankName} set as default',
                                  backgroundColor: const Color(0xFFD4A017),
                                  colorText: Colors.black,
                                  snackPosition: SnackPosition.BOTTOM,
                                );
                              } else if (v == 'delete') {
                                await _ctrl.deleteBank(b.id);
                                Get.snackbar(
                                  'Removed',
                                  '${b.bankName} removed',
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
                          _BankDetail('A/c No.', b.maskedAcc, ts, tp),
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
              onTap: () => Get.toNamed(AppRoutes.addBankAccount),
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
