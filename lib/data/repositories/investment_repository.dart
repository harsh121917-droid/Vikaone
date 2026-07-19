import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/investment_model.dart';

class InvestmentRepository {
  final _dio = ApiClient.instance;

  Future<List<InvestmentModel>> getMyInvestments() async {
    final res = await _dio.get(ApiConstants.myInvestments);
    return (res.data['data'] as List)
        .map((e) => InvestmentModel.fromJson(e))
        .toList();
  }

  Future<Map<String, dynamic>> createOrder({
    required String propertyId,
    required int bricks,
  }) async {
    final res = await _dio.post(
      ApiConstants.createOrder,
      data: {'propertyId': propertyId, 'bricks': bricks},
    );
    return res.data;
  }

  Future<bool> verifyPayment({
    required String razorpayOrderId,
    required String razorpayPaymentId,
    required String razorpaySignature,
    required String investmentId,
  }) async {
    final res = await _dio.post(
      ApiConstants.verifyPayment,
      data: {
        'razorpayOrderId': razorpayOrderId,
        'razorpayPaymentId': razorpayPaymentId,
        'razorpaySignature': razorpaySignature,
        'investmentId': investmentId,
      },
    );
    return res.data['success'] == true;
  }
}
