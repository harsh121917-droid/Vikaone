import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/property_model.dart';

class PropertyRepository {
  final _dio = ApiClient.instance;

  Future<List<PropertyModel>> getProperties({
    int page = 1,
    int limit = 20,
    String? city,
    String? type,
    String? bhk,
    String? search,
    bool? featured,
    int? minPrice,
    int? maxPrice,
    String? sortBy,
  }) async {
    final res = await _dio.get(
      ApiConstants.properties,
      queryParameters: {
        'page': page,
        'limit': limit,
        if (city != null && city.isNotEmpty) 'city': city,
        if (type != null && type.isNotEmpty) 'type': type,
        if (bhk != null && bhk.isNotEmpty) 'bhk': bhk,
        if (search != null && search.isNotEmpty) 'search': search,
        if (featured != null) 'featured': featured,
        if (minPrice != null) 'minPrice': minPrice,
        if (maxPrice != null) 'maxPrice': maxPrice,
        if (sortBy != null && sortBy.isNotEmpty) 'sortBy': sortBy,
      },
    );
    return (res.data['data'] as List)
        .map((e) => PropertyModel.fromJson(e))
        .toList();
  }

  Future<PropertyModel> getProperty(String id) async {
    final res = await _dio.get('${ApiConstants.properties}/$id');
    return PropertyModel.fromJson(res.data['data']);
  }
}
