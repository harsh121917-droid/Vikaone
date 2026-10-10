import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/models/property_model.dart';
import '../../../data/repositories/property_repository.dart';

class PropertiesController extends GetxController {
  final PropertyRepository _repo = Get.find();

  final isLoading = false.obs;
  final properties = <PropertyModel>[].obs;
  final errorMsg = ''.obs;

  // ── Top Category Tabs ──────────────────────────────────────────────────
  // 'All' | 'Full Ownership' | 'Fractional' | 'Residential' | 'Commercial' | 'Plots' | 'Holiday'
  final selectedCategory = 'All'.obs;

  // ── Purchase mode tabs: 'all' | 'bricks' | 'direct' ──────────────────────
  final selectedPurchaseTab = 'all'.obs;

  // ── Filter state ─────────────────────────────────────────────────────────
  final search = ''.obs;
  final sortBy = 'popular'.obs; // popular | xirr_desc | yield_desc | price_asc | price_desc | newest
  final selType = ''.obs; // All | Full Ownership | Fractional | Apartment | Commercial | Plot | Villa
  final selBhk = ''.obs; // 1BHK | 2BHK | 3BHK | 4BHK | ''=all
  final selCity = ''.obs; // City name or ''
  final selBudget = ''.obs; // All | Under ₹50L | ₹50L - ₹1Cr | ₹1Cr - ₹5Cr | ₹5Cr+ | Under ₹5K/Brick
  final minPrice = Rx<int?>(null);
  final maxPrice = Rx<int?>(null);

  // Search visibility toggle for clean header
  final isSearchVisible = false.obs;

  List<String> get availableCities {
    final set = <String>{};
    for (final p in properties) {
      final c = p.location.city?.trim();
      if (c != null && c.isNotEmpty) set.add(c);
    }
    final list = set.toList()..sort();
    return ['All Locations', ...list];
  }

  void setCategory(String cat) {
    selectedCategory.value = cat;
    if (cat.toLowerCase() == 'full ownership') {
      selectedPurchaseTab.value = 'direct';
    } else if (cat.toLowerCase() == 'fractional') {
      selectedPurchaseTab.value = 'bricks';
    } else if (cat.toLowerCase() == 'all') {
      selectedPurchaseTab.value = 'all';
    }
  }

  void setCity(String city) {
    if (city == 'All Locations' || city.toLowerCase() == 'all') {
      selCity.value = '';
    } else {
      selCity.value = city;
    }
  }

  void setType(String type) {
    if (type == 'All Types' || type.toLowerCase() == 'all') {
      selType.value = '';
    } else {
      selType.value = type;
    }
  }

  void setBudget(String budget) {
    if (budget == 'All Budgets' || budget.toLowerCase() == 'all') {
      selBudget.value = '';
      minPrice.value = null;
      maxPrice.value = null;
    } else {
      selBudget.value = budget;
      if (budget == 'Under ₹50L') {
        minPrice.value = null;
        maxPrice.value = 5000000;
      } else if (budget == '₹50L - ₹1Cr') {
        minPrice.value = 5000000;
        maxPrice.value = 10000000;
      } else if (budget == '₹1Cr - ₹5Cr') {
        minPrice.value = 10000000;
        maxPrice.value = 50000000;
      } else if (budget == '₹5Cr+') {
        minPrice.value = 50000000;
        maxPrice.value = null;
      } else {
        minPrice.value = null;
        maxPrice.value = null;
      }
    }
  }

  void setSort(String sort) {
    sortBy.value = sort;
  }

  void toggleSearch() {
    isSearchVisible.value = !isSearchVisible.value;
    if (!isSearchVisible.value) {
      search.value = '';
    }
  }

  List<PropertyModel> get categoryProperties {
    final cat = selectedCategory.value.trim().toLowerCase();
    return properties.where((p) {
      final pt = (p.propertyType ?? '').trim().toLowerCase();
      if (cat == 'all' || cat.isEmpty) {
        return true;
      } else if (cat == 'full ownership' || cat == 'direct') {
        return p.allowsDirectBuy;
      } else if (cat == 'fractional' || cat == 'bricks') {
        return p.allowsBricks;
      } else if (cat == 'residential' || cat == 'apartment') {
        return pt == 'apartment' || pt == 'penthouse' || pt == 'flat' || pt == 'condo' || pt == 'residential';
      } else if (cat == 'commercial' || cat == 'office') {
        return pt == 'office' || pt == 'commercial' || pt == 'retail' || pt == 'warehouse';
      } else if (cat == 'plots' || cat == 'plot' || cat == 'land') {
        return pt == 'land' || pt == 'plot' || pt == 'agricultural';
      } else if (cat == 'holiday' || cat == 'villa') {
        return pt == 'villa' || pt == 'house' || pt == 'farmhouse' || pt == 'holiday';
      }
      return pt == cat;
    }).toList();
  }

  List<PropertyModel> get filteredProperties {
    var list = categoryProperties;

    // Filter by purchase tab if explicitly toggled
    final tab = selectedPurchaseTab.value;
    if (tab == 'bricks') {
      list = list.where((p) => p.allowsBricks).toList();
    } else if (tab == 'direct') {
      list = list.where((p) => p.allowsDirectBuy).toList();
    }

    // Filter by Dropdown City
    if (selCity.value.isNotEmpty) {
      final q = selCity.value.toLowerCase();
      list = list.where((p) {
        final city = (p.location.city ?? '').toLowerCase();
        final state = (p.location.state ?? '').toLowerCase();
        final addr = (p.location.address ?? '').toLowerCase();
        return city.contains(q) || state.contains(q) || addr.contains(q);
      }).toList();
    }

    // Filter by Dropdown Type
    if (selType.value.isNotEmpty) {
      final t = selType.value.toLowerCase();
      if (t == 'full ownership') {
        list = list.where((p) => p.allowsDirectBuy).toList();
      } else if (t == 'fractional' || t == 'fractional bricks') {
        list = list.where((p) => p.allowsBricks).toList();
      } else {
        list = list.where((p) {
          final pt = (p.propertyType ?? '').toLowerCase();
          return pt.contains(t) || t.contains(pt);
        }).toList();
      }
    }

    // Filter by Budget
    if (minPrice.value != null) {
      list = list.where((p) => (p.price.amount ?? 0) >= minPrice.value!).toList();
    }
    if (maxPrice.value != null) {
      list = list.where((p) => (p.price.amount ?? 0) <= maxPrice.value!).toList();
    }
    if (selBudget.value == 'Under ₹5K/Brick') {
      list = list.where((p) => (p.brickPrice ?? 0) <= 5000 && p.allowsBricks).toList();
    }

    // Filter by BHK
    if (selBhk.value.isNotEmpty) {
      final b = selBhk.value.toLowerCase().replaceAll(' ', '');
      list = list.where((p) => (p.bhk ?? '').toLowerCase().replaceAll(' ', '').contains(b)).toList();
    }

    // Search query
    if (search.value.isNotEmpty) {
      final s = search.value.toLowerCase();
      list = list.where((p) {
        final title = p.title.toLowerCase();
        final city = (p.location.city ?? '').toLowerCase();
        final state = (p.location.state ?? '').toLowerCase();
        final type = (p.propertyType ?? '').toLowerCase();
        return title.contains(s) || city.contains(s) || state.contains(s) || type.contains(s);
      }).toList();
    }

    // Sort
    final sorted = List<PropertyModel>.from(list);
    final sortMode = sortBy.value;
    if (sortMode == 'popular') {
      sorted.sort((a, b) {
        if (a.featured != b.featured) return b.featured ? 1 : -1;
        return (b.soldBricks ?? 0).compareTo(a.soldBricks ?? 0);
      });
    } else if (sortMode == 'xirr_desc') {
      sorted.sort((a, b) => b.effectiveXirr.compareTo(a.effectiveXirr));
    } else if (sortMode == 'yield_desc') {
      sorted.sort((a, b) => b.expectedRentalYield.compareTo(a.expectedRentalYield));
    } else if (sortMode == 'price_asc') {
      sorted.sort((a, b) => (a.price.amount ?? 0).compareTo(b.price.amount ?? 0));
    } else if (sortMode == 'price_desc') {
      sorted.sort((a, b) => (b.price.amount ?? 0).compareTo(a.price.amount ?? 0));
    } else if (sortMode == 'newest') {
      // Keep server order
    }

    return sorted;
  }

  int get totalCount => properties.length;
  int get bricksCount => properties.where((p) => p.allowsBricks).length;
  int get directCount => properties.where((p) => p.allowsDirectBuy).length;

  void setPurchaseTab(String tab) {
    selectedPurchaseTab.value = tab;
    if (tab == 'direct') {
      selectedCategory.value = 'Full Ownership';
    } else if (tab == 'bricks') {
      selectedCategory.value = 'Fractional';
    } else {
      selectedCategory.value = 'All';
    }
  }

  // active filter count badge
  int get activeFilters {
    int c = 0;
    if (selectedCategory.value != 'All') c++;
    if (selType.value.isNotEmpty) c++;
    if (selBhk.value.isNotEmpty) c++;
    if (minPrice.value != null || maxPrice.value != null || selBudget.value.isNotEmpty) c++;
    if (selCity.value.isNotEmpty) c++;
    if (sortBy.value != 'popular' && sortBy.value != 'newest') c++;
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
        limit: 50,
      );
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Failed to load';
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String v) {
    search.value = v.trim();
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
  }

  void selectCategory(String type) {
    setCategory(type.isEmpty ? 'All' : type);
  }

  void filterByCategory(String category) {
    setCategory(category.isEmpty ? 'All' : category);
    selBhk.value = '';
    selCity.value = '';
    selType.value = '';
    selBudget.value = '';
    sortBy.value = 'popular';
    minPrice.value = null;
    maxPrice.value = null;
    search.value = '';
  }

  void clearFilters() {
    selectedCategory.value = 'All';
    selectedPurchaseTab.value = 'all';
    selType.value = '';
    selBhk.value = '';
    selCity.value = '';
    selBudget.value = '';
    sortBy.value = 'popular';
    minPrice.value = null;
    maxPrice.value = null;
    search.value = '';
  }
}
