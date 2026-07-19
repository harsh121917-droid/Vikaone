import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:real_estate/core/theme/app_colors.dart';
import 'package:real_estate/data/repositories/gold_repository.dart';

class GoldController extends GetxController {
  static GoldController get to => Get.find();

  final _repo = GoldRepository();

  // ── Observables ──────────────────────────────────────────────────────────
  final isLoading     = false.obs;
  final isBuying      = false.obs;
  final isSelling     = false.obs;
  final rateLoading   = false.obs;

  final rate          = Rxn<GoldRateModel>();
  final balance       = Rxn<GoldBalanceModel>();
  final transactions  = <GoldTxnModel>[].obs;
  final errorMsg      = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    await Future.wait([loadRate(), loadBalance(), loadTransactions()]);
    isLoading.value = false;
  }

  // ── 1. Rate ───────────────────────────────────────────────────────────────
  Future<void> loadRate() async {
    try {
      rateLoading.value = true;
      rate.value = await _repo.getRate();
    } on DioException catch (e) {
      // Use static fallback if API fails
      errorMsg.value = e.response?.data?['message'] ?? 'Rate unavailable';
    } finally { rateLoading.value = false; }
  }

  // ── 2. Balance ────────────────────────────────────────────────────────────
  Future<void> loadBalance() async {
    try {
      balance.value = await _repo.getBalance();
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Balance unavailable';
    }
  }

  // ── 3. Buy Gold (called from BuyGoldView) ─────────────────────────────────
  // Returns the initiate result so the view can open Razorpay
  Future<GoldBuyInitiateResult?> initiateBuy({double? amount, double? grams}) async {
    try {
      isBuying.value = true;
      errorMsg.value = '';
      return await _repo.initiateBuy(amountInRupees: amount, grams: grams);
    } on DioException catch (e) {
      final msg = e.response?.data?['message'] ?? 'Failed to create order';
      Get.snackbar('Error', msg, backgroundColor: AppColors.error, colorText: const Color(0xFFFFFFFF));
      return null;
    } finally { isBuying.value = false; }
  }

  Future<bool> verifyBuy({
    required String orderId, required String paymentId,
    required String signature, required String transactionId,
  }) async {
    try {
      final ok = await _repo.verifyBuy(
          orderId: orderId, paymentId: paymentId,
          signature: signature, transactionId: transactionId);
      if (ok) {
        HapticFeedback.mediumImpact();
        await Future.wait([loadBalance(), loadTransactions()]);
        Get.snackbar('Gold Credited! 🥇', 'Your gold has been added to your account',
            backgroundColor: const Color(0xFFD4A017), colorText: Colors.black,
            snackPosition: SnackPosition.BOTTOM);
      }
      return ok;
    } on DioException catch (_) {
      Get.snackbar('Verification Failed', 'Contact support with your payment ID',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return false;
    }
  }

  // ── 4. Sell Gold ──────────────────────────────────────────────────────────
  Future<bool> sellGold({required double grams, String bankAccountId = 'default'}) async {
    try {
      isSelling.value = true;
      await _repo.sellGold(grams: grams, bankAccountId: bankAccountId);
      await Future.wait([loadBalance(), loadTransactions()]);
      Get.snackbar('Sell Order Placed! 💰',
          'Amount will be credited in 1-2 working hours',
          backgroundColor: const Color(0xFF3B82F6), colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM);
      return true;
    } on DioException catch (e) {
      Get.snackbar('Sell Failed', e.response?.data?['message'] ?? 'Failed to sell',
          backgroundColor: AppColors.error, colorText: Colors.white);
      return false;
    } finally { isSelling.value = false; }
  }

  // ── 5. Transactions ───────────────────────────────────────────────────────
  Future<void> loadTransactions() async {
    try {
      transactions.value = await _repo.getTransactions();
    } on DioException catch (_) {}
  }

  // ── Helpers for UI ────────────────────────────────────────────────────────
  double get buyRate    => rate.value?.buyRate  ?? 7309.0;
  double get sellRate   => rate.value?.sellRate ?? 7256.0;
  double get totalGrams => balance.value?.totalGrams ?? 0;

  double gramsForAmount(double amt)  => amt  / buyRate;
  double amountForGrams(double grams) => grams * buyRate;
  double gstFor(double amt)          => amt  * (rate.value?.gstPct ?? 3.0) / 100;
  double totalFor(double amt)        => amt  + gstFor(amt);
}