import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/saving_model.dart';
import '../../../data/repositories/saving_repository.dart';
import '../../../routes/app_routes.dart';

class SavingsController extends GetxController {
  final SavingRepository _repo = Get.find();
  late Razorpay _razorpay;

  final isLoading = false.obs;
  final isPaying = false.obs;
  final errorMsg = ''.obs;
  final plans = <SavingModel>[].obs;
  final summary = Rxn<SavingSummary>();
  final activeTab = 0.obs; // 0=all, 1=daily, 2=monthly — used in MyPlansView

  // tracks which plan is currently going through Razorpay
  String? _pendingPaymentSavingId;
  bool _pendingIsCycle = false; // true = cycle payment, false = first payment
  int? _pendingCycleAmount;

  List<SavingModel> get dailyPlans =>
      plans.where((p) => p.type == 'daily').toList();
  List<SavingModel> get monthlyPlans =>
      plans.where((p) => p.type == 'monthly').toList();

  @override
  void onInit() {
    super.onInit();
    _initRazorpay();
    loadSavings();
  }

  void _initRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  // ── Load ────────────────────────────────────────────────────────────────────
  Future<void> loadSavings() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final result = await _repo.getMySavings();
      plans.value = result.plans;
      summary.value = result.summary;
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Failed to load savings';
    } finally {
      isLoading.value = false;
    }
  }

  // ── Create plan ─────────────────────────────────────────────────────────────
  Future<SavingModel?> createSavingPlan({
    required String type,
    required int targetAmount,
    required int amountPerCycle,
    String? targetPropertyId,
  }) async {
    try {
      final plan = await _repo.createSaving(
        type: type,
        targetAmount: targetAmount,
        amountPerCycle: amountPerCycle,
        targetPropertyId: targetPropertyId,
      );
      plans.insert(0, plan);
      summary.value = SavingSummary(
        totalSaved: summary.value?.totalSaved ?? 0,
        totalTarget: (summary.value?.totalTarget ?? 0) + targetAmount,
        activePlans: (summary.value?.activePlans ?? 0) + 1,
      );
      return plan;
    } on DioException catch (e) {
      if (!_handleKyc(e)) {
        Get.snackbar(
          'Error',
          e.response?.data?['message'] ?? 'Failed to create plan',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
      return null;
    } catch (_) {
      Get.snackbar(
        'Error',
        'Something went wrong.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return null;
    }
  }

  Future<bool> createPlan({
    required String type,
    required int targetAmount,
    required int amountPerCycle,
    String? targetPropertyId,
  }) async {
    final res = await createSavingPlan(
      type: type,
      targetAmount: targetAmount,
      amountPerCycle: amountPerCycle,
      targetPropertyId: targetPropertyId,
    );
    return res != null;
  }

  // ── Initiate first Razorpay payment ─────────────────────────────────────────
  Future<void> initiatePayment(String savingId) async {
    if (isPaying.value) return; // debounce double-taps
    try {
      isPaying.value = true;
      _pendingPaymentSavingId = savingId;

      final data = await _repo.initiateFirstPayment(savingId);

      final options = {
        'key': data['keyId'],
        'amount': data['amount'],
        'currency': data['currency'],
        'order_id': data['orderId'],
        'name': 'Bharat SQFT',
        'description':
            '${data['planType'] == 'daily' ? 'Daily' : 'Monthly'} saving plan — ₹${data['amountPerCycle']}',
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#2563EB'},
      };

      _razorpay.open(options);
      // Note: isPaying stays true until _onPaymentSuccess / _onPaymentError fires
    } on DioException catch (e) {
      isPaying.value = false;
      _pendingPaymentSavingId = null;
      if (!_handleKyc(e)) {
        Get.snackbar(
          'Payment Error',
          e.response?.data?['message'] ??
              'Could not initiate payment. Try again.',
          backgroundColor: AppColors.error,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      isPaying.value = false;
      _pendingPaymentSavingId = null;
      Get.snackbar(
        'Error',
        'Something went wrong: ${e.toString()}',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  // ── Initiate cycle (subsequent) Razorpay payment ────────────────────────────
  Future<void> initiateCyclePayment(String savingId, {int? amount}) async {
    if (isPaying.value) return;
    try {
      isPaying.value = true;
      _pendingPaymentSavingId = savingId;
      _pendingIsCycle = true;
      _pendingCycleAmount = amount;

      final data = await _repo.initiateCyclePayment(savingId, amount: amount);

      final options = {
        'key': data['keyId'],
        'amount': data['amount'],
        'currency': data['currency'],
        'order_id': data['orderId'],
        'name': 'Bharat SQFT',
        'description': 'Add savings — ₹${data['cycleAmount']}',
        'prefill': {'contact': '', 'email': ''},
        'theme': {'color': '#2563EB'},
      };

      _razorpay.open(options);
    } on DioException catch (e) {
      isPaying.value = false;
      _pendingPaymentSavingId = null;
      _pendingIsCycle = false;
      _pendingCycleAmount = null;
      Get.snackbar(
        'Payment Error',
        e.response?.data?['message'] ?? 'Could not initiate payment.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } catch (e) {
      isPaying.value = false;
      _pendingPaymentSavingId = null;
      _pendingIsCycle = false;
      _pendingCycleAmount = null;
      Get.snackbar(
        'Error',
        e.toString(),
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  void _onPaymentSuccess(PaymentSuccessResponse res) async {
    try {
      final savingId = _pendingPaymentSavingId;
      if (savingId == null) return;

      SavingModel updated;

      if (_pendingIsCycle) {
        // Subsequent cycle payment
        updated = await _repo.verifyCyclePayment(
          savingId,
          orderId: res.orderId ?? '',
          paymentId: res.paymentId ?? '',
          signature: res.signature ?? '',
          amount: _pendingCycleAmount,
        );
        Get.snackbar(
          '✅ Savings Added!',
          '₹${_pendingCycleAmount ?? updated.amountPerCycle} added to your plan.',
          backgroundColor: const Color(0xFF2ecc71),
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      } else {
        // First payment
        updated = await _repo.verifyFirstPayment(
          savingId,
          orderId: res.orderId ?? '',
          paymentId: res.paymentId ?? '',
          signature: res.signature ?? '',
        );
        Get.snackbar(
          '✅ Plan Activated!',
          'First instalment paid. Keep saving every ${updated.type == 'daily' ? 'day' : 'month'}!',
          backgroundColor: const Color(0xFF2ecc71),
          colorText: Colors.white,
          duration: const Duration(seconds: 4),
        );
      }

      final idx = plans.indexWhere((p) => p.id == savingId);
      if (idx != -1) plans[idx] = updated;
      plans.refresh();

      summary.value = SavingSummary(
        totalSaved:
            (summary.value?.totalSaved ?? 0) +
            (_pendingCycleAmount ?? updated.amountPerCycle),
        totalTarget: summary.value?.totalTarget ?? 0,
        activePlans: summary.value?.activePlans ?? 0,
      );
    } on DioException catch (_) {
      Get.snackbar(
        'Verify Failed',
        'Payment done but verification failed. Contact support.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      isPaying.value = false;
      _pendingPaymentSavingId = null;
      _pendingIsCycle = false;
      _pendingCycleAmount = null;
    }
  }

  void _onPaymentError(PaymentFailureResponse res) {
    isPaying.value = false;
    _pendingPaymentSavingId = null;
    _pendingIsCycle = false;
    _pendingCycleAmount = null;
    Get.snackbar(
      'Payment Failed',
      res.message ?? 'Payment was not completed.',
      backgroundColor: AppColors.error,
      colorText: Colors.white,
    );
  }

  void _onExternalWallet(ExternalWalletResponse res) {
    isPaying.value = false;
    Get.snackbar('External Wallet', 'Redirecting to ${res.walletName}...');
  }

  // ── Deposit (subsequent cycles, manual) ────────────────────────────────────
  Future<void> deposit(String planId, {int? amount}) async {
    try {
      final idxBefore = plans.indexWhere((p) => p.id == planId);
      final fallbackAmount = idxBefore != -1
          ? plans[idxBefore].amountPerCycle
          : 0;
      final deposited = amount ?? fallbackAmount;

      final updated = await _repo.deposit(planId, amount: amount);
      final idx = plans.indexWhere((p) => p.id == planId);
      if (idx != -1) plans[idx] = updated;
      plans.refresh();

      summary.value = SavingSummary(
        totalSaved: (summary.value?.totalSaved ?? 0) + deposited,
        totalTarget: summary.value?.totalTarget ?? 0,
        activePlans: summary.value?.activePlans ?? 0,
      );

      Get.snackbar(
        'Saved!',
        '₹$deposited added.',
        backgroundColor: const Color(0xFF2ecc71),
        colorText: Colors.white,
      );
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Deposit failed',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  // ── Toggle pause ─────────────────────────────────────────────────────────────
  Future<void> togglePause(SavingModel plan) async {
    try {
      final updated = await _repo.updateSaving(plan.id, {
        'isActive': !plan.isActive,
      });
      final idx = plans.indexWhere((p) => p.id == plan.id);
      if (idx != -1) plans[idx] = updated;
      plans.refresh();
    } on DioException catch (_) {
      Get.snackbar(
        'Error',
        'Could not update plan.',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  // ── Delete ───────────────────────────────────────────────────────────────────
  Future<void> deletePlan(String id) async {
    try {
      await _repo.deleteSaving(id);
      plans.removeWhere((p) => p.id == id);
      Get.snackbar('Deleted', 'Saving plan removed.');
    } on DioException catch (_) {}
  }

  // ── Navigate to My Plans screen ─────────────────────────────────────────────
  void goToMyPlans() => Get.toNamed(AppRoutes.myPlans);

  // ── KYC redirect helper ──────────────────────────────────────────────────────
  bool _handleKyc(DioException e) {
    if (e.response?.data?['code'] == 'KYC_REQUIRED') {
      Get.snackbar(
        'KYC Required',
        e.response?.data?['message'] ?? 'Complete KYC to proceed.',
        backgroundColor: const Color(0xFFF39C12),
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () => Get.toNamed(AppRoutes.kyc),
          child: const Text(
            'Go to KYC',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ),
      );
      return true;
    }
    return false;
  }
}
