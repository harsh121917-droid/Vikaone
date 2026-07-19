import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/property_model.dart';

class WishlistRepository {
  final _dio = ApiClient.instance;
  static const _base = '/wishlist';

  Future<List<PropertyModel>> getWishlist() async {
    final res = await _dio.get(_base);
    return (res.data['data'] as List)
        .map((e) => PropertyModel.fromJson(e))
        .toList();
  }

  Future<bool> addToWishlist(String propertyId) async {
    final res = await _dio.post('$_base/$propertyId');
    return res.data['saved'] as bool;
  }

  Future<bool> removeFromWishlist(String propertyId) async {
    final res = await _dio.delete('$_base/$propertyId');
    return res.data['saved'] as bool;
  }

  Future<bool> checkWishlist(String propertyId) async {
    final res = await _dio.get('$_base/check/$propertyId');
    return res.data['saved'] as bool;
  }
}
