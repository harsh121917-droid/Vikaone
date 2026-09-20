import 'package:dio/dio.dart';
import '../../core/network/api_client.dart';
import '../models/home_video_model.dart';

class HomeVideoRepository {
  final Dio _dio = ApiClient.instance;

  Future<List<HomeVideoModel>> getHomeVideos() async {
    try {
      final res = await _dio.get('/home-videos');
      if (res.data['success'] == true && res.data['data'] != null) {
        final list = res.data['data'] as List;
        return list.map((item) => HomeVideoModel.fromJson(item as Map<String, dynamic>)).toList();
      }
      return [];
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }
}
