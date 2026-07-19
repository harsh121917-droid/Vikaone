import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/property_repository.dart';

class PropertiesController extends GetxController {
  final PropertyRepository _repo = Get.find();

  final isLoading = false.obs;
  final properties = <PropertyModel>[].obs;
  final errorMsg = ''.obs;

  // ── Filter state ─────────────────────────────────────────────────────────
  final search = ''.obs;
  final sortBy = 'newest'.obs; // newest | price_asc | price_desc | area_asc
  final selType = ''.obs; // House | Apartment | Villa | Office | Land | ''=all
  final selBhk = ''.obs; // 1BHK | 2BHK | 3BHK | 4BHK | ''=all
  final minPrice = Rx<int?>(null);
  final maxPrice = Rx<int?>(null);
  final selCity = ''.obs;

  // active filter count badge
  int get activeFilters {
    int c = 0;
    if (selType.value.isNotEmpty) c++;
    if (selBhk.value.isNotEmpty) c++;
    if (minPrice.value != null) c++;
    if (maxPrice.value != null) c++;
    if (selCity.value.isNotEmpty) c++;
    if (sortBy.value != 'newest') c++;
    return c;
  }

  @override
  void onInit() {
    super.onInit();
    loadProperties();
  }

  Future<void> loadProperties() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      properties.value = await _repo.getProperties(
        limit: 40,
        search: search.value.isEmpty ? null : search.value,
        type: selType.value.isEmpty ? null : selType.value,
        bhk: selBhk.value.isEmpty ? null : selBhk.value,
        city: selCity.value.isEmpty ? null : selCity.value,
        minPrice: minPrice.value,
        maxPrice: maxPrice.value,
        sortBy: sortBy.value,
      );
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Failed to load';
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String v) {
    search.value = v;
    loadProperties();
  }

  void applyFilters({
    required String type,
    required String bhk,
    required String city,
    required String sort,
    required int? min,
    required int? max,
  }) {
    selType.value = type;
    selBhk.value = bhk;
    selCity.value = city;
    sortBy.value = sort;
    minPrice.value = min;
    maxPrice.value = max;
    loadProperties();
  }

  void clearFilters() {
    selType.value = '';
    selBhk.value = '';
    selCity.value = '';
    sortBy.value = 'newest';
    minPrice.value = null;
    maxPrice.value = null;
    loadProperties();
  }
}
