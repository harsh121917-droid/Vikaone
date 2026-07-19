import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/saving_model.dart';

class SavingRepository {
  final _dio = ApiClient.instance;
  static const _base = '/savings';

  Future<({List<SavingModel> plans, SavingSummary summary})>
  getMySavings() async {
    final res = await _dio.get(_base);
    final list = (res.data['data'] as List)
        .map((e) => SavingModel.fromJson(e))
        .toList();
    final summary = SavingSummary.fromJson(res.data['summary'] ?? {});
    return (plans: list, summary: summary);
  }

  Future<SavingModel> createSaving({
    required String type,
    required int targetAmount,
    required int amountPerCycle,
    String? targetPropertyId,
  }) async {
    final res = await _dio.post(
      _base,
      data: {
        'type': type,
        'targetAmount': targetAmount,
        'amountPerCycle': amountPerCycle,
        if (targetPropertyId != null) 'targetPropertyId': targetPropertyId,
      },
    );
    return SavingModel.fromJson(res.data['data']);
  }

  // Returns Razorpay order details for first payment
  Future<Map<String, dynamic>> initiateFirstPayment(String savingId) async {
    final res = await _dio.post('$_base/$savingId/pay/initiate');
    return res.data as Map<String, dynamic>;
  }

  // Verify first payment after Razorpay SDK callback
  Future<SavingModel> verifyFirstPayment(
    String savingId, {
    required String orderId,
    required String paymentId,
    required String signature,
  }) async {
    final res = await _dio.post(
      '$_base/$savingId/pay/verify',
      data: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
      },
    );
    return SavingModel.fromJson(res.data['data']);
  }

  // Initiate subsequent cycle payment via Razorpay
  Future<Map<String, dynamic>> initiateCyclePayment(
    String savingId, {
    int? amount,
  }) async {
    final res = await _dio.post(
      '$_base/$savingId/pay/cycle/initiate',
      data: {if (amount != null) 'amount': amount},
    );
    return res.data as Map<String, dynamic>;
  }

  // Verify cycle payment
  Future<SavingModel> verifyCyclePayment(
    String savingId, {
    required String orderId,
    required String paymentId,
    required String signature,
    int? amount,
  }) async {
    final res = await _dio.post(
      '$_base/$savingId/pay/cycle/verify',
      data: {
        'razorpay_order_id': orderId,
        'razorpay_payment_id': paymentId,
        'razorpay_signature': signature,
        if (amount != null) 'amount': amount,
      },
    );
    return SavingModel.fromJson(res.data['data']);
  }

  Future<SavingModel> deposit(String id, {int? amount, String? note}) async {
    final res = await _dio.post(
      '$_base/$id/deposit',
      data: {
        if (amount != null) 'amount': amount,
        if (note != null) 'note': note,
      },
    );
    return SavingModel.fromJson(res.data['data']);
  }

  Future<SavingModel> updateSaving(String id, Map<String, dynamic> data) async {
    final res = await _dio.patch('$_base/$id', data: data);
    return SavingModel.fromJson(res.data['data']);
  }

  Future<void> deleteSaving(String id) async {
    await _dio.delete('$_base/$id');
  }
}
