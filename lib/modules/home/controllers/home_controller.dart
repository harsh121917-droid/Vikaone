import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/property_repository.dart';

class HomeController extends GetxController {
  final PropertyRepository _repo = Get.find();

  final isLoading       = false.obs;
  final featuredProps   = <PropertyModel>[].obs;
  final errorMsg        = ''.obs;
  final selectedCategory = 0.obs;
  final selectedTab     = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadFeatured();
  }

  Future<void> loadFeatured() async {
    try {
      isLoading.value = true;
      var props = await _repo.getProperties(featured: true, limit: 20);
      if (props.isEmpty) props = await _repo.getProperties(limit: 20);
      featuredProps.value = props;
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Failed to load';
    } finally {
      isLoading.value = false;
    }
  }
}
