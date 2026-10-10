import '../../core/constants/api_constants.dart';
import '../../core/network/api_client.dart';
import '../models/business_model.dart';

class BusinessRepository {
  final _dio = ApiClient.instance;

  Future<List<BusinessModel>> getBusinessOpportunities({
    String? category,
    String? search,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final res = await _dio.get(
        ApiConstants.business,
        queryParameters: {
          'page': page,
          'limit': limit,
          if (category != null && category.isNotEmpty && category != 'All')
            'category': category,
          if (search != null && search.isNotEmpty) 'search': search,
        },
      );

      if (res.data != null && res.data['data'] is List) {
        return (res.data['data'] as List)
            .map((e) => BusinessModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<BusinessModel> getBusinessOpportunityById(String id) async {
    try {
      final res = await _dio.get('${ApiConstants.business}/$id');
      return BusinessModel.fromJson(res.data['data'] as Map<String, dynamic>);
    } catch (e) {
      rethrow;
    }
  }

  Future<bool> submitBusinessLead({
    required String businessId,
    required String businessTitle,
    required String name,
    required String phone,
    String? email,
    String? preferredDate,
    String? preferredTime,
    String? message,
  }) async {
    try {
      final res = await _dio.post(
        '${ApiConstants.business}/$businessId/enquire',
        data: {
          'name': name,
          'phone': phone,
          'email': email,
          'preferredDate': preferredDate,
          'preferredTime': preferredTime,
          'message': message,
          'source': 'app',
        },
      );
      return res.data != null && res.data['success'] == true;
    } catch (e) {
      rethrow;
    }
  }
}
