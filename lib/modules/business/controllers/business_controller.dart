import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../data/models/business_model.dart';
import '../../../data/repositories/business_repository.dart';

class BusinessController extends GetxController {
  final BusinessRepository _repository = Get.isRegistered<BusinessRepository>()
      ? Get.find<BusinessRepository>()
      : Get.put(BusinessRepository());

  final opportunities = <BusinessModel>[].obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final selectedCategory = 'All'.obs;
  final searchQuery = ''.obs;

  final categories = const [
    'All',
    'Warehouses & Logistics',
    'Petrol Pumps',
    'Dairy Farms',
    'Hotels & Hospitality',
    'CBG (Compressed Biogas) Plants',
    'Other Business Opportunities',
  ];

  @override
  void onInit() {
    super.onInit();
    loadOpportunities();
  }

  Future<void> loadOpportunities() async {
    isLoading.value = true;
    errorMessage.value = '';
    try {
      final items = await _repository.getBusinessOpportunities();
      opportunities.assignAll(items);
    } catch (e) {
      errorMessage.value = 'Failed to load business opportunities. Please pull to refresh.';
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    HapticFeedback.selectionClick();
    selectedCategory.value = category;
  }

  void setSearchQuery(String query) {
    searchQuery.value = query.trim().toLowerCase();
  }

  List<BusinessModel> get filteredOpportunities {
    final cat = selectedCategory.value;
    final query = searchQuery.value;

    return opportunities.where((item) {
      final matchesCategory = (cat == 'All') || (item.category == cat);
      if (!matchesCategory) return false;

      if (query.isEmpty) return true;

      final titleMatch = item.title.toLowerCase().contains(query);
      final cityMatch = item.location.city.toLowerCase().contains(query);
      final stateMatch = item.location.state.toLowerCase().contains(query);
      final descMatch = item.description.toLowerCase().contains(query);
      final categoryMatch = item.category.toLowerCase().contains(query);

      return titleMatch || cityMatch || stateMatch || descMatch || categoryMatch;
    }).toList();
  }

  int getCategoryCount(String category) {
    if (category == 'All') return opportunities.length;
    return opportunities.where((item) => item.category == category).length;
  }
}
