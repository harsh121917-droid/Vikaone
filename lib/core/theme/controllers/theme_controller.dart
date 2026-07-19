import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ThemeController extends GetxController {
  static ThemeController get to => Get.find();

  final _box = GetStorage();
  static const _key = 'isDarkMode';

  final isDark = false.obs;

  @override
  void onInit() {
    super.onInit();
    isDark.value = _box.read<bool>(_key) ?? false;
    AppC.setDark(isDark.value);
    _applyTheme();
  }

  void toggle() {
    isDark.value = !isDark.value;
    AppC.setDark(isDark.value);
    _box.write(_key, isDark.value);
    _applyTheme();
  }

  void _applyTheme() {
    Get.changeTheme(isDark.value ? AppTheme.dark : AppTheme.light);
  }
}
