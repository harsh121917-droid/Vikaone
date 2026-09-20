import 'package:dio/dio.dart';
import 'package:flutter/material.dart' show Color, Colors, TextButton, Text, FontWeight, TextStyle;
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/investment_repository.dart';

class PropertyDetailController extends GetxController {
  final String? propertyId;
  PropertyDetailController({this.propertyId});
  final PropertyRepository   _repo    = Get.find();
  final InvestmentRepository _invRepo = Get.find();
  final AuthService          _auth    = Get.find();

  final isLoading     = false.obs;
  final property      = Rx<PropertyModel?>(null);
  final errorMsg       = ''.obs;
  final currentImg     = 0.obs;

  final suggestedProperties   = <PropertyModel>[].obs;
  final isSuggestionsLoading = false.obs;

  final isPurchasing   = false.obs;
  final purchaseStatus = ''.obs; // '', 'creating_order', 'awaiting_payment', 'verifying', 'success', 'failed'

  late Razorpay _razorpay;

  // Holds context for the in-flight order so we can verify after payment
  String? _pendingInvestmentId;
  int?    _pendingBricks;
  bool    _isDirectBuyInFlight = false;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _onPaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _onPaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _onExternalWallet);

    final id = propertyId ?? Get.parameters['id'] ?? (Get.arguments is String ? Get.arguments as String : null);
    if (id != null) loadProperty(id);
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> loadProperty(String id) async {
    try {
      isLoading.value = true;
      errorMsg.value  = '';
      property.value  = await _repo.getProperty(id);
      if (property.value != null) {
        loadSuggestions(
          id,
          category: property.value?.propertyType,
          city: property.value?.location.city,
        );
      }
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Property not found';
    } catch (e) {
      errorMsg.value = 'Something went wrong';
    } finally {
      isLoading.value = false;
    }
  }

  void setImage(int index) => currentImg.value = index;

  /* ── Buy Bricks → create order → open Razorpay checkout ── */
  Future<void> initiateBrickPurchase(int bricks) async {
    final p = property.value;
    if (p == null) return;

    if (bricks < 1) {
      Get.snackbar('Invalid', 'Please enter a valid number of bricks');
      return;
    }
    if (bricks > p.availableBricks) {
      Get.snackbar('Not enough bricks', 'Only ${p.availableBricks} bricks available');
      return;
    }

    try {
      isPurchasing.value   = true;
      purchaseStatus.value = 'creating_order';
      _isDirectBuyInFlight = false;

      final data = await _invRepo.createOrder(propertyId: p.id, bricks: bricks);

      if (data['success'] != true) {
        purchaseStatus.value = 'failed';
        Get.snackbar('Order failed', data['message'] ?? 'Could not create order',
          backgroundColor: const Color(0xFFE53E3E), colorText: const Color(0xFFFFFFFF));
        return;
      }

      _pendingInvestmentId = data['investment']['id'];
      _pendingBricks       = bricks;

      final order = data['order'];
      final key   = data['key'];
      final user  = _auth.currentUser;

      purchaseStatus.value = 'awaiting_payment';

      final options = {
        'key': key,
        'amount': order['amount'],
        'currency': order['currency'],
        'order_id': order['id'],
        'name': 'Bharat SQFT',
        'description': '$bricks Brick${bricks > 1 ? "s" : ""} — ${p.title}',
        'prefill': {
          'contact': user?.phone ?? '',
          'email':   user?.email ?? '',
        },
        'theme': {'color': '#D4A017'},
      };

      _razorpay.open(options);
    } on DioException catch (e) {
      isPurchasing.value    = false;
      purchaseStatus.value  = 'failed';
      final msg = e.response?.data?['message'] ?? 'Order creation failed';
      final code = e.response?.data?['code'];
      if (code == 'KYC_REQUIRED') {
        Get.snackbar('KYC Required', msg,
          backgroundColor: const Color(0xFFF39C12), colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () {
              Get.closeCurrentSnackbar();
              Get.toNamed('/kyc');
            },
            child: const Text('Complete KYC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ));
      } else {
        Get.snackbar('Error', msg, backgroundColor: const Color(0xFFE53E3E), colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      isPurchasing.value   = false;
      purchaseStatus.value = 'failed';
      Get.snackbar('Error', 'Connection error. Please try again.');
    }
  }



  /* ── Direct Buy (Full Property 100% Ownership) → create order → Razorpay ── */
  Future<void> initiateDirectBuy() async {
    final p = property.value;
    if (p == null) return;

    if (p.availableBricks <= 0) {
      Get.snackbar('Sold Out', 'This property is already fully sold or funded.');
      return;
    }

    try {
      isPurchasing.value   = true;
      purchaseStatus.value = 'creating_order';
      _isDirectBuyInFlight = true;

      final data = await _invRepo.createOrder(
        propertyId: p.id,
        bricks: p.availableBricks,
        isDirectBuy: true,
      );

      if (data['success'] != true) {
        purchaseStatus.value = 'failed';
        _isDirectBuyInFlight = false;
        Get.snackbar('Order failed', data['message'] ?? 'Could not create order',
          backgroundColor: const Color(0xFFE53E3E), colorText: const Color(0xFFFFFFFF));
        return;
      }

      _pendingInvestmentId = data['investment']['id'];
      _pendingBricks       = data['investment']['bricks'] ?? p.availableBricks;

      final order = data['order'];
      final key   = data['key'];
      final user  = _auth.currentUser;

      purchaseStatus.value = 'awaiting_payment';

      final options = {
        'key': key,
        'amount': order['amount'],
        'currency': order['currency'],
        'order_id': order['id'],
        'name': 'Bharat SQFT',
        'description': 'Direct Buy (Full Property) — ${p.title}',
        'prefill': {
          'contact': user?.phone ?? '',
          'email':   user?.email ?? '',
        },
        'theme': {'color': '#D4A017'},
      };

      _razorpay.open(options);
    } on DioException catch (e) {
      isPurchasing.value    = false;
      purchaseStatus.value  = 'failed';
      _isDirectBuyInFlight = false;
      final msg = e.response?.data?['message'] ?? 'Order creation failed';
      final code = e.response?.data?['code'];
      if (code == 'KYC_REQUIRED') {
        Get.snackbar('KYC Required', msg,
          backgroundColor: const Color(0xFFF39C12), colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
          mainButton: TextButton(
            onPressed: () {
              Get.closeCurrentSnackbar();
              Get.toNamed('/kyc');
            },
            child: const Text('Complete KYC', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
          ));
      } else {
        Get.snackbar('Error', msg, backgroundColor: const Color(0xFFE53E3E), colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      isPurchasing.value   = false;
      purchaseStatus.value = 'failed';
      _isDirectBuyInFlight = false;
      Get.snackbar('Error', 'Connection error. Please try again.');
    }
  }

  Future<void> _onPaymentSuccess(PaymentSuccessResponse response) async {
    purchaseStatus.value = 'verifying';
    try {
      final ok = await _invRepo.verifyPayment(
        razorpayOrderId:   response.orderId ?? '',
        razorpayPaymentId: response.paymentId ?? '',
        razorpaySignature: response.signature ?? '',
        investmentId:      _pendingInvestmentId ?? '',
      );

      if (ok) {
        purchaseStatus.value = 'success';
        final wasDirect = _isDirectBuyInFlight;
        _isDirectBuyInFlight = false;
        // refresh property to show updated sold bricks
        if (property.value != null) await loadProperty(property.value!.id);
        Get.snackbar(
          'Success! 🎉',
          wasDirect
              ? 'Congratulations! You have purchased the full property with 100% ownership!'
              : 'You now own $_pendingBricks brick${(_pendingBricks ?? 0) > 1 ? "s" : ""} of this property',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 5),
        );
      } else {
        purchaseStatus.value = 'failed';
        Get.snackbar('Verification failed', 'Contact support with payment ID: ${response.paymentId}',
          backgroundColor: const Color(0xFFE53E3E), colorText: const Color(0xFFFFFFFF));
      }
    } catch (e) {
      purchaseStatus.value = 'failed';
      Get.snackbar('Verification error', 'Contact support with payment ID: ${response.paymentId}',
        backgroundColor: const Color(0xFFE53E3E), colorText: const Color(0xFFFFFFFF));
    } finally {
      isPurchasing.value = false;
    }
  }

  void _onPaymentError(PaymentFailureResponse response) {
    isPurchasing.value   = false;
    purchaseStatus.value = 'failed';
    Get.snackbar('Payment Failed', response.message ?? 'Payment was not completed',
      backgroundColor: const Color(0xFFE53E3E), colorText: const Color(0xFFFFFFFF));
  }

  void _onExternalWallet(ExternalWalletResponse response) {
    Get.snackbar('External Wallet', response.walletName ?? '');
  }

  Future<void> loadSuggestions(String currentId, {String? category, String? city}) async {
    try {
      isSuggestionsLoading.value = true;
      final List<PropertyModel> results = [];

      // 1. Fetch properties matching category if available
      if (category != null && category.isNotEmpty) {
        final sameCat = await _repo.getProperties(type: category, limit: 12);
        results.addAll(sameCat.where((p) => p.id != currentId));
      }

      // 2. Fetch general properties to guarantee rich continuous suggestions
      if (results.length < 3) {
        final all = await _repo.getProperties(limit: 20);
        for (final p in all) {
          if (p.id != currentId && !results.any((r) => r.id == p.id)) {
            results.add(p);
          }
        }
      }

      suggestedProperties.assignAll(results);
    } catch (_) {
    } finally {
      isSuggestionsLoading.value = false;
    }
  }

}
