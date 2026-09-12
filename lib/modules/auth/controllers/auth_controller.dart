import 'dart:io';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/lock_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';
import '../../wallet/controllers/wallet_controller.dart';
import '../../kyc/controllers/kyc_controller.dart';

class AuthController extends GetxController {
  final AuthService _auth = Get.find();

  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final user = Rx<UserModel?>(null);
  final isUploadingAvatar = false.obs;

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
    if (isLoggedIn) {
      fetchCurrentUser();
    }
  }

  Future<void> fetchCurrentUser() async {
    try {
      user.value = await _auth.refreshUser();
    } catch (_) {}
  }

  bool get isLoggedIn => _auth.isLoggedIn;

  Future<void> login(String email, String password) async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      user.value = await _auth.login(email, password);
      _afterAuth();
    } on DioException catch (e) {
      errorMsg.value =
          e.response?.data?['message'] ?? 'Login failed. Check credentials.';
    } catch (e) {
      errorMsg.value = 'Something went wrong.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String otpRecordId,
    String? phone,
    String? referralCode,
  }) async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      user.value = await _auth.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
        otpRecordId: otpRecordId,
        referralCode: referralCode,
      );
      _afterAuth();
      return true;
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Registration failed.';
      return false;
    } catch (e) {
      errorMsg.value = 'Something went wrong.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> registerWithOtp({
    required String name,
    required String phone,
    required String otpRecordId,
    String? email,
    String? referralCode,
  }) async {
    try {
      isLoading.value = true;
      user.value = await _auth.registerWithOtp(
        name: name,
        phone: phone,
        otpRecordId: otpRecordId,
        email: email,
        referralCode: referralCode,
      );
      _afterAuth();
      return true;
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Registration failed.';
      return false;
    } catch (e) {
      errorMsg.value = 'Something went wrong.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> loginWithOtp({
    required String phone,
    required String otpRecordId,
    String? email,
  }) async {
    try {
      isLoading.value = true;
      user.value = await _auth.loginWithOtp(
        phone: phone,
        otpRecordId: otpRecordId,
        email: email,
      );
      _afterAuth();
      return true;
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Login failed.';
      return false;
    } catch (e) {
      errorMsg.value = 'Something went wrong.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void _afterAuth() {
    final lock = LockService.to;
    if (!lock.hasPasscode) {
      Get.offAllNamed(AppRoutes.passcodeSetup);
    } else {
      Get.offAllNamed(AppRoutes.lockScreen);
    }
  }

  Future<bool> updateProfile({String? name, String? email}) async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      user.value = await _auth.updateProfile(name: name, email: email);
      return true;
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Failed to update profile.';
      return false;
    } catch (e) {
      errorMsg.value = 'Something went wrong.';
      return false;
    } finally {
      isLoading.value = false;
    }
  }

  void logout() {
    _auth.logout();
    LockService.to.disableLock();

    if (Get.isRegistered<WalletController>()) Get.delete<WalletController>(force: true);
    if (Get.isRegistered<KycController>()) Get.delete<KycController>(force: true);

    Get.offAllNamed(AppRoutes.login);
  }

  Future<bool> uploadProfilePicture(File file) async {
    try {
      isUploadingAvatar.value = true;
      final updated = await _auth.uploadProfilePicture(file);
      user.value = updated;
      return true;
    } on DioException catch (e) {
      Get.snackbar(
        'Upload Failed',
        e.response?.data?['message'] ?? 'Could not upload profile picture.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Upload Failed',
        'Could not upload profile picture. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isUploadingAvatar.value = false;
    }
  }

  Future<bool> removeProfilePicture() async {
    try {
      isUploadingAvatar.value = true;
      final updated = await _auth.removeProfilePicture();
      user.value = updated;
      return true;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not remove profile picture.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return false;
    } finally {
      isUploadingAvatar.value = false;
    }
  }
}
