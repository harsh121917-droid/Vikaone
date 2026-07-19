import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/lock_service.dart';
import '../../../data/models/user_model.dart';
import '../../../routes/app_routes.dart';

class AuthController extends GetxController {
  final AuthService _auth = Get.find();

  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final user = Rx<UserModel?>(null);

  @override
  void onInit() {
    super.onInit();
    user.value = _auth.currentUser;
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

  Future<void> register({
    required String name,
    required String email,
    required String password,
    String? phone,
  }) async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      user.value = await _auth.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _afterAuth();
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Registration failed.';
    } catch (e) {
      errorMsg.value = 'Something went wrong.';
    } finally {
      isLoading.value = false;
    }
  }

  // After login/register: if no passcode set → go to setup, else → home
  void _afterAuth() {
    final lock = LockService.to;
    if (!lock.hasPasscode) {
      Get.offAllNamed(AppRoutes.passcodeSetup);
    } else {
      Get.offAllNamed(AppRoutes.home);
    }
  }

  void logout() {
    _auth.logout();
    // Keep passcode — user will need it if they log back in
    Get.offAllNamed(AppRoutes.login);
  }
}
