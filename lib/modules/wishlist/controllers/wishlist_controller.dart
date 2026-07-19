import 'dart:ui';

import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/wishlist_repository.dart';

class WishlistController extends GetxController {
  static WishlistController get to => Get.find();

  final WishlistRepository _repo = Get.find();

  final isLoading = false.obs;
  final properties = <PropertyModel>[].obs;
  // set of saved property IDs for O(1) lookup
  final savedIds = <String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadWishlist();
  }

  Future<void> loadWishlist() async {
    try {
      isLoading.value = true;
      final list = await _repo.getWishlist();
      properties.value = list;
      savedIds.value = list.map((p) => p.id).toSet();
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Failed to load wishlist',
        backgroundColor: AppColors.error,
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isLoading.value = false;
    }
  }

  bool isSaved(String propertyId) => savedIds.contains(propertyId);

  Future<void> toggle(PropertyModel property) async {
    final id = property.id;
    final alreadySaved = isSaved(id);
    // Optimistic update
    if (alreadySaved) {
      savedIds.remove(id);
      properties.removeWhere((p) => p.id == id);
    } else {
      savedIds.add(id);
      properties.insert(0, property);
    }

    try {
      if (alreadySaved) {
        await _repo.removeFromWishlist(id);
        Get.snackbar(
          'Removed',
          'Removed from wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFF0E1626),
          colorText: const Color(0xFFEDF0FF),
        );
      } else {
        await _repo.addToWishlist(id);
        Get.snackbar(
          'Saved! ❤️',
          'Added to your wishlist',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: AppColors.accent,
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } on DioException catch (e) {
      // Revert on failure
      if (alreadySaved) {
        savedIds.add(id);
        properties.insert(0, property);
      } else {
        savedIds.remove(id);
        properties.removeWhere((p) => p.id == id);
      }
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Failed',
        backgroundColor: AppColors.error,
        colorText: const Color(0xFFFFFFFF),
      );
    }
  }

  Future<void> removeById(String id) async {
    final prop = properties.firstWhereOrNull((p) => p.id == id);
    if (prop != null) toggle(prop);
  }
}
