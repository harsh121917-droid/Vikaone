import 'dart:io';
import 'package:dio/dio.dart';
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
    final res = await _dio.post(
      ApiConstants.login,
      data: {'email': email, 'password': password},
    );
    _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
    required String otpRecordId,
    String? phone,
    String? referralCode,
  }) async {
    final res = await _dio.post(
      ApiConstants.register,
      data: {
        'name': name,
        'email': email,
        'password': password,
        'phone': phone,
        'otpRecordId': otpRecordId,
        if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
      },
    );
    _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> registerWithOtp({
    required String name,
    required String phone,
    required String otpRecordId,
    String? email,
    String? referralCode,
  }) async {
    final res = await _dio.post(
      '/auth/register-phone',
      data: {
        'name': name,
        'phone': phone,
        'otpRecordId': otpRecordId,
        if (email != null && email.isNotEmpty) 'email': email,
        if (referralCode != null && referralCode.isNotEmpty) 'referralCode': referralCode,
      },
    );
    _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> loginWithOtp({
    required String phone,
    required String otpRecordId,
    String? email,
  }) async {
    final res = await _dio.post(
      '/auth/login-phone',
      data: {
        'phone': phone,
        'otpRecordId': otpRecordId,
        if (email != null) 'email': email,
      },
    );
    _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> updateProfile({
    String? name,
    String? email,
  }) async {
    final res = await _dio.patch(
      '/auth/update-profile',
      data: {
        if (name != null) 'name': name,
        if (email != null) 'email': email,
      },
    );
    _saveAuth(res.data);
    return UserModel.fromJson(res.data['user']);
  }

  Future<UserModel> refreshUser() async {
    final res = await _dio.get('/auth/me');
    if (res.data['success'] == true) {
      _box.write(StorageKeys.user, res.data['user']);
    }
    return currentUser!;
  }

  void logout() {
    _box.remove(StorageKeys.token);
    _box.remove(StorageKeys.user);
  }

  Future<bool> resetPassword({
    required String phone,
    required String otpRecordId,
    required String newPassword,
    String? email,
  }) async {
    final res = await _dio.post(
      '/auth/reset-password',
      data: {
        'phone': phone,
        'otpRecordId': otpRecordId,
        'newPassword': newPassword,
        if (email != null) 'email': email,
      },
    );
    return res.data['success'] == true;
  }

  Future<Map<String, dynamic>> initiateForgotPassword({
    required String email,
  }) async {
    final res = await _dio.post(
      '/auth/forgot-password/initiate',
      data: {'email': email},
    );
    return Map<String, dynamic>.from(res.data);
  }

  void _saveAuth(Map data) {
    _box.write(StorageKeys.token, data['token']);
    _box.write(StorageKeys.user, data['user']);
  }

  Future<UserModel> uploadProfilePicture(File imageFile) async {
    final fileName = imageFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: fileName,
      ),
    });

    final res = await _dio.post(
      '/users/profile-picture',
      data: formData,
    );

    if (res.data['success'] == true && res.data['user'] != null) {
      final updatedMap = Map<String, dynamic>.from(res.data['user']);
      _box.write(StorageKeys.user, updatedMap);
      return UserModel.fromJson(updatedMap);
    } else {
      throw Exception(res.data['message'] ?? 'Failed to upload profile picture');
    }
  }

  Future<UserModel> removeProfilePicture() async {
    final res = await _dio.delete('/users/profile-picture');
    if (res.data['success'] == true && res.data['user'] != null) {
      final updatedMap = Map<String, dynamic>.from(res.data['user']);
      _box.write(StorageKeys.user, updatedMap);
      return UserModel.fromJson(updatedMap);
    } else {
      throw Exception(res.data['message'] ?? 'Failed to remove profile picture');
    }
  }

}
