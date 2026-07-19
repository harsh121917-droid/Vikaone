import 'package:get_storage/get_storage.dart';
import '../constants/api_constants.dart';
import '../constants/storage_keys.dart';
import '../network/api_client.dart';
import '../../data/models/user_model.dart';

class AuthService {
  final _dio = ApiClient.instance;
  final _box = GetStorage();

  String? get token => _box.read<String>(StorageKeys.token);
  bool get isLoggedIn => token != null && token!.isNotEmpty;

  UserModel? get currentUser {
    final raw = _box.read<Map>(StorageKeys.user);
    if (raw == null) return null;
    return UserModel.fromJson(Map<String, dynamic>.from(raw));
  }

  Future<UserModel> login(String email, String password) async {
    final res = await _dio.post(ApiConstants.login,
        data: {'email': email, 'password': password});
    _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> register({
    required String name, required String email,
    required String password, String? phone,
  }) async {
    final res = await _dio.post(ApiConstants.register,
        data: {'name': name, 'email': email, 'password': password, 'phone': phone});
    _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  void logout() {
    _box.remove(StorageKeys.token);
    _box.remove(StorageKeys.user);
  }

  void _saveAuth(Map data) {
    _box.write(StorageKeys.token, data['token']);
    _box.write(StorageKeys.user, data['user']);
  }
}
