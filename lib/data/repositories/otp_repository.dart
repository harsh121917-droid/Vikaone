import '../../core/network/api_client.dart';

class OtpRepository {
  final _dio = ApiClient.instance;

  /// Step 1 of email/phone + password + OTP login: checks credentials
  /// without issuing a token. Returns the user's registered phone number
  Future<String> verifyCredentials(
      {required String identifier, required String password}) async {
    final res = await _dio.post('/auth/verify-credentials', data: {
      'identifier': identifier,
      'password': password,
    });
    return res.data['phone'].toString();
  }

  /// purpose: "register" | "login"
  Future<int> sendOtp({required String phone, required String purpose}) async {
    final res = await _dio
        .post('/otp/send', data: {'phone': phone, 'purpose': purpose});
    return (res.data['expiresInSeconds'] ?? 300) as int;
  }

  /// Returns the otpRecordId to pass to register-phone/login-phone.
  Future<String> verifyOtp({
    required String phone,
    required String purpose,
    required String code,
  }) async {
    final res = await _dio.post('/otp/verify', data: {
      'phone': phone,
      'purpose': purpose,
      'code': code,
    });
    return res.data['otpRecordId'].toString();
  }
}
