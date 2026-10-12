// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:get_storage/get_storage.dart';
// import 'package:real_estate/core/theme/controllers/theme_controller.dart';
// import 'core/services/auth_service.dart';
// import 'core/theme/app_theme.dart';
// import 'core/theme/app_colors.dart';
// import 'modules/auth/controllers/auth_controller.dart';
// import 'modules/auth/bindings/auth_binding.dart';
// import 'routes/app_routes.dart';

import 'data/repositories/wallet_repository.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await GetStorage.init();

//   Get.put(AuthService(), permanent: true);
//   Get.put(ThemeController(), permanent: true);

//   runApp(const BharatSqftApp());
// }

// class BharatSqftApp extends StatelessWidget {
//   const BharatSqftApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     final authService = Get.find<AuthService>();
//     final themeCtrl = Get.find<ThemeController>();

//     return Obx(
//       () => GetMaterialApp(
//         title: 'Vika DRX',
//         debugShowCheckedModeBanner: false,
//         theme: AppTheme.light,
//         darkTheme: AppTheme.dark,
//         themeMode: themeCtrl.isDark.value ? ThemeMode.dark : ThemeMode.light,
//         initialRoute: authService.isLoggedIn ? AppRoutes.home : AppRoutes.login,
//         getPages: appPages,
//         initialBinding: BindingsBuilder(() {
//           Get.put(AuthController());
//         }),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'core/services/auth_service.dart';
import 'core/services/lock_service.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/controllers/theme_controller.dart';
import 'modules/auth/controllers/auth_controller.dart';
import 'routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  Get.put(AuthService(), permanent: true);
  Get.put(LockService(), permanent: true);
  Get.put(ThemeController(), permanent: true);
  Get.put(WalletRepository(), permanent: true);

  runApp(const BharatSqftApp());
}

class BharatSqftApp extends StatefulWidget {
  const BharatSqftApp({super.key});
  @override
  State<BharatSqftApp> createState() => _BharatSqftAppState();
}

class _BharatSqftAppState extends State<BharatSqftApp>
    with WidgetsBindingObserver {
  bool _wasBackgrounded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final lock = LockService.to;
    final auth = Get.find<AuthService>();

    // Only truly backgrounded on paused — not inactive (biometric dialog = inactive only)
    if (state == AppLifecycleState.paused) {
      _wasBackgrounded = true;
    }

    if (state == AppLifecycleState.resumed) {
      if (_wasBackgrounded &&
          !lock.isUnlocking &&
          !lock.isLockSuppressed &&
          auth.isLoggedIn &&
          lock.lockEnabled &&
          lock.hasPasscode &&
          Get.currentRoute != AppRoutes.lockScreen) {
        _wasBackgrounded = false;
        Get.toNamed(AppRoutes.lockScreen);
      } else {
        _wasBackgrounded = false;
      }
    }
  }

  String _initialRoute() {
    final auth = Get.find<AuthService>();
    final lock = Get.find<LockService>();
    if (!auth.isLoggedIn) return AppRoutes.login;
    if (lock.lockEnabled && lock.hasPasscode) return AppRoutes.lockScreen;
    return AppRoutes.home;
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GetMaterialApp(
        title: 'Vika DRX',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: Get.find<ThemeController>().isDark.value
            ? ThemeMode.dark
            : ThemeMode.light,
        initialRoute: _initialRoute(),
        getPages: appPages,
        initialBinding: BindingsBuilder(() {
          Get.put(AuthController());
          Get.lazyPut<WalletRepository>(() => WalletRepository());
        }),
      ),
    );
  }
}
