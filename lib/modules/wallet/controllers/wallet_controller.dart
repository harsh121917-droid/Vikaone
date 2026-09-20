import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:real_estate/core/services/auth_service.dart';
import 'package:real_estate/data/repositories/wallet_repository.dart';

class WalletController extends GetxController {
  static WalletController get to => Get.find();

  final WalletRepository _repo = Get.isRegistered<WalletRepository>()
      ? Get.find<WalletRepository>()
      : Get.put(WalletRepository());
  late final Razorpay _razorpay;

  final isLoading = false.obs;
  final isAdding = false.obs;
  final isWithdrawing = false.obs;
  final errorMsg = ''.obs;

  final wallet = Rxn<WalletModel>();
  final banks = <BankAccountModel>[].obs;

  double? _pendingAddAmt;

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    loadAll();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaySuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPayError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([loadWallet(), loadBanks()]);
    isLoading.value = false;
  }

  // ── 1. Wallet ──────────────────────────────────────────────────────────────
  Future<void> loadWallet() async {
    try {
      wallet.value = await _repo.getWallet();
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Failed to load wallet';
    }
  }

  // ── 2. Add Money (Razorpay) ────────────────────────────────────────────────
  Future<void> addMoney(double amount) async {
    try {
      isAdding.value = true;
      final data = await _repo.initiateAdd(amount);
      _pendingAddAmt = amount;
      final user = Get.find<AuthService>().currentUser;

      final options = {
        'key': data['key'] ?? '',
        'amount': data['order']['amount'],
        'currency': 'INR',
        'order_id': data['order']['id'],
        'name': 'Vika DRX Wallet',
        'description': 'Add ₹${amount.toStringAsFixed(0)} to Vika DRX wallet',
        'prefill': {'name': user?.name ?? '', 'email': user?.email ?? ''},
        'theme': {'color': '#D4A017'},
      };
      _razorpay.open(options);
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Failed to initiate',
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAdding.value = false;
    }
  }

  // ── Razorpay callbacks ─────────────────────────────────────────────────────
  Future<void> _onPaySuccess(PaymentSuccessResponse r) async {
    try {
      final ok = await _repo.verifyAdd(
        orderId: r.orderId ?? '',
        paymentId: r.paymentId ?? '',
        signature: r.signature ?? '',
        amount: _pendingAddAmt ?? 0,
      );
      if (ok) {
        await loadWallet();
        Get.snackbar(
          'Money Added! 💚',
          '₹${_pendingAddAmt?.toStringAsFixed(0)} added to your Vika DRX wallet',
          backgroundColor: const Color(0xFF2ecc71),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      } else {
        Get.snackbar(
          'Verification Failed',
          'Contact support with Payment ID: ${r.paymentId}',
          backgroundColor: const Color(0xFFe74c3c),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (_) {}
    _pendingAddAmt = null;
  }

  void _onPayError(PaymentFailureResponse r) {
    _pendingAddAmt = null;
    if (r.code != 0) {
      Get.snackbar(
        'Payment Failed',
        r.message ?? 'Payment was not completed',
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _onExternalWallet(ExternalWalletResponse r) {}

  // ── 3. Withdraw ───────────────────────────────────────────────────────────
  Future<bool> withdraw(double amount, String bankAccountId) async {
    try {
      isWithdrawing.value = true;
      await _repo.initiateWithdraw(amount, bankAccountId);
      await loadWallet();
      Get.snackbar(
        'Withdrawal Initiated! 🏦',
        '₹${amount.toStringAsFixed(0)} will reach your bank in 24h',
        backgroundColor: const Color(0xFF3B82F6),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return true;
    } on DioException catch (e) {
      Get.snackbar(
        'Failed',
        e.response?.data?['message'] ?? 'Withdrawal failed',
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isWithdrawing.value = false;
    }
  }

  // ── Bank accounts ─────────────────────────────────────────────────────────
  Future<void> loadBanks() async {
    try {
      banks.value = await _repo.getBankAccounts();
    } on DioException catch (_) {}
  }

  Future<bool> addBank({
    required String accountHolder,
    required String accountNumber,
    required String ifsc,
    required String bankName,
    required String accountType,
  }) async {
    try {
      await _repo.addBankAccount(
        accountHolder: accountHolder,
        accountNumber: accountNumber,
        ifsc: ifsc,
        bankName: bankName,
        accountType: accountType,
      );
      await loadBanks();
      return true;
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Failed to add bank',
        backgroundColor: const Color(0xFFe74c3c),
        colorText: Colors.white,
      );
      return false;
    }
  }

  Future<void> setDefaultBank(String id) async {
    await _repo.setDefaultBank(id);
    await loadBanks();
  }

  Future<void> deleteBank(String id) async {
    await _repo.deleteBank(id);
    await loadBanks();
  }

  // Helper
  BankAccountModel? get defaultBank =>
      banks.firstWhereOrNull((b) => b.isDefault) ?? banks.firstOrNull;
}
