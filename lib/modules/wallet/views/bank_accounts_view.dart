import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';
import '../controllers/wallet_controller.dart';

class BankAccountsView extends StatefulWidget {
  const BankAccountsView({super.key});

  @override
  State<BankAccountsView> createState() => _BankAccountsViewState();
}

class _BankAccountsViewState extends State<BankAccountsView> {
  @override
  void initState() {
    super.initState();
    if (!Get.isRegistered<WalletController>()) {
      Get.put(WalletController());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = WalletController.to;

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
      final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;

      final banks = ctrl.banks;

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
                            'Bank Accounts',
                            style: TextStyle(
                              color: tp,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Payout accounts for rental yield & withdrawals',
                            style: TextStyle(color: ts, fontSize: 11.5),
                          ),
                        ],
                      ),
                    ),
                    // Quick Add button
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.addBankAccount),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2563EB),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF2563EB).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(Icons.add_rounded, color: Colors.white, size: 16),
                            SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Main Content ─────────────────────────────────────────────
              Expanded(
                child: RefreshIndicator(
                  onRefresh: ctrl.loadBanks,
                  color: const Color(0xFF2563EB),
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(
                      parent: BouncingScrollPhysics(),
                    ),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 90),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Verification Info Box
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: const Color(0xFF2563EB).withOpacity(dark ? 0.12 : 0.06),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: const Color(0xFF2563EB).withOpacity(0.25),
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(7),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(
                                  Icons.verified_outlined,
                                  color: Color(0xFF2563EB),
                                  size: 18,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Monthly rental dividend payouts and wallet withdrawals are automatically credited to your Primary Bank Account.',
                                  style: TextStyle(
                                    color: dark ? const Color(0xFF93C5FD) : const Color(0xFF1E40AF),
                                    fontSize: 11.5,
                                    height: 1.35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 18),

                        // Section Title
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'LINKED ACCOUNTS (${banks.length})',
                              style: TextStyle(
                                color: ts,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.0,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 10),

                        // Empty State or Bank List
                        if (banks.isEmpty)
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: border),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.08),
                                    shape: BoxShape.circle,
                                  ),
                                  child: const Icon(
                                    Icons.account_balance_rounded,
                                    color: Color(0xFF2563EB),
                                    size: 32,
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'No Bank Account Linked',
                                  style: TextStyle(
                                    color: tp,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Add your bank account to enable instant withdrawals and automatic monthly rental yields.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: ts, fontSize: 12),
                                ),
                                const SizedBox(height: 18),
                                ElevatedButton.icon(
                                  onPressed: () => Get.toNamed(AppRoutes.addBankAccount),
                                  icon: const Icon(Icons.add_rounded, size: 16, color: Colors.white),
                                  label: const Text('Add Bank Account', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2563EB),
                                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 0,
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: banks.length,
                            separatorBuilder: (_, _) => const SizedBox(height: 12),
                            itemBuilder: (context, i) {
                              final b = banks[i];
                              final isDef = b.isDefault;

                              return Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: cardBg,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: isDef
                                        ? const Color(0xFF10B981).withOpacity(0.5)
                                        : border,
                                    width: isDef ? 1.4 : 1.1,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
                                      blurRadius: 12,
                                      offset: const Offset(0, 4),
                                    ),
                                  ],
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Row 1: Bank Icon + Name + Default Badge / Delete
                                    Row(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          width: 44,
                                          height: 44,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.08),
                                            borderRadius: BorderRadius.circular(14),
                                          ),
                                          child: const Icon(
                                            Icons.account_balance_rounded,
                                            color: Color(0xFF2563EB),
                                            size: 22,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      b.bankName,
                                                      maxLines: 1,
                                                      overflow: TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        color: tp,
                                                        fontSize: 15,
                                                        fontWeight: FontWeight.w800,
                                                      ),
                                                    ),
                                                  ),
                                                  if (isDef)
                                                    Container(
                                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                                      decoration: BoxDecoration(
                                                        color: const Color(0xFF10B981).withOpacity(0.15),
                                                        borderRadius: BorderRadius.circular(8),
                                                        border: Border.all(
                                                          color: const Color(0xFF10B981).withOpacity(0.35),
                                                        ),
                                                      ),
                                                      child: Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: const [
                                                          Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 12),
                                                          SizedBox(width: 4),
                                                          Text(
                                                            'PRIMARY',
                                                            style: TextStyle(
                                                              color: Color(0xFF10B981),
                                                              fontSize: 9.5,
                                                              fontWeight: FontWeight.w900,
                                                              letterSpacing: 0.5,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                b.accountHolder,
                                                style: TextStyle(color: ts, fontSize: 12),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),

                                    const SizedBox(height: 14),

                                    // Row 2: Masked Account Number & Details
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                      decoration: BoxDecoration(
                                        color: dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: border),
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ACCOUNT NUMBER',
                                                style: TextStyle(color: ts, fontSize: 9.5, fontWeight: FontWeight.w700),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                '•••• •••• •••• ${b.accountNumber.length > 4 ? b.accountNumber.substring(b.accountNumber.length - 4) : b.accountNumber}',
                                                style: TextStyle(color: tp, fontSize: 13, fontWeight: FontWeight.w800),
                                              ),
                                            ],
                                          ),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Text(
                                                'IFSC CODE',
                                                style: TextStyle(color: ts, fontSize: 9.5, fontWeight: FontWeight.w700),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                b.ifsc,
                                                style: TextStyle(color: tp, fontSize: 12.5, fontWeight: FontWeight.w700),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),

                                    const SizedBox(height: 12),

                                    // Row 3: Account Type & Action buttons
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: (dark ? Colors.white10 : Colors.black.withOpacity(0.05)),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            b.accountType.toUpperCase(),
                                            style: TextStyle(color: ts, fontSize: 10, fontWeight: FontWeight.w700),
                                          ),
                                        ),
                                        const Spacer(),
                                        if (!isDef)
                                          TextButton(
                                            onPressed: () {
                                              HapticFeedback.lightImpact();
                                              ctrl.setDefaultBank(b.id);
                                            },
                                            child: const Text(
                                              'Set as Primary',
                                              style: TextStyle(
                                                color: Color(0xFF2563EB),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline_rounded, color: Color(0xFFEF4444), size: 19),
                                          onPressed: () => _confirmDeleteBank(context, ctrl, b.id, b.bankName, dark),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        bottomSheet: Container(
          color: bg,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 20),
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton.icon(
              onPressed: () => Get.toNamed(AppRoutes.addBankAccount),
              icon: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
              label: const Text(
                'Add New Bank Account',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ),
      );
    });
  }

  void _confirmDeleteBank(BuildContext context, WalletController ctrl, String id, String name, bool dark) {
    HapticFeedback.mediumImpact();
    Get.dialog(
      AlertDialog(
        backgroundColor: dark ? const Color(0xFF0E1626) : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Remove Bank Account?'),
        content: Text('Are you sure you want to remove $name from your linked payout accounts?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Get.back();
              await ctrl.deleteBank(id);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Remove', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
