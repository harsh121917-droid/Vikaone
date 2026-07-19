import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';

class ApiClient {
  ApiClient._();
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 15),
      headers: {'Content-Type': 'application/json'},
    ),
  )..interceptors.add(_AuthInterceptor());
  static Dio get instance => _dio;
}

class _AuthInterceptor extends Interceptor {
  final _box = GetStorage();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = _box.read<String>(StorageKeys.token);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      GetStorage().remove(StorageKeys.token);
      GetStorage().remove(StorageKeys.user);
      Get.offAllNamed('/login');
    }
    handler.next(err);
  }
}
