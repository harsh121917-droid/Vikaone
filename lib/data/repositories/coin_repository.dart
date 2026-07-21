import 'package:dio/dio.dart';
import 'package:real_estate/core/network/api_client.dart';

class CoinModel {
  final String id, name, metal;
  final double grams,
      ratePerGram,
      value,
      makingCharge,
      totalValue,
      makingChargePct;
  final bool redeemable;

  const CoinModel({
    required this.id,
    required this.name,
    required this.metal,
    required this.grams,
    required this.ratePerGram,
    required this.value,
    required this.makingCharge,
    required this.totalValue,
    required this.makingChargePct,
    required this.redeemable,
  });

  factory CoinModel.fromJson(Map<String, dynamic> j) => CoinModel(
    id: j['id'] ?? '',
    name: j['name'] ?? '',
    metal: j['metal'] ?? 'gold',
    grams: (j['grams'] ?? 0) * 1.0,
    ratePerGram: (j['ratePerGram'] ?? 0) * 1.0,
    value: (j['value'] ?? 0) * 1.0,
    makingCharge: (j['makingCharge'] ?? 0) * 1.0,
    totalValue: (j['totalValue'] ?? 0) * 1.0,
    makingChargePct: (j['makingChargePct'] ?? 0) * 1.0,
    redeemable: j['redeemable'] ?? false,
  );
}

class CoinRepository {
  final _dio = ApiClient.instance;
  static const _base = '/coins';

  Future<List<CoinModel>> getCoins() async {
    final res = await _dio.get(_base);
    return (res.data['data'] as List)
        .map((e) => CoinModel.fromJson(e))
        .toList();
  }

  Future<Map<String, dynamic>> redeemCoin({
    required String coinId,
    required String addressLine,
    required String pincode,
    required String phone,
  }) async {
    final res = await _dio.post(
      '$_base/redeem',
      data: {
        'coinId': coinId,
        'addressLine': addressLine,
        'pincode': pincode,
        'phone': phone,
      },
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<List<dynamic>> getOrders() async {
    final res = await _dio.get('$_base/orders');
    return res.data['data'] as List;
  }
}
