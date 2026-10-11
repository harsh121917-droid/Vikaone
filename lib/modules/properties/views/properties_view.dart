import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/properties_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/property_model.dart';
import '../../../routes/app_routes.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class PropertiesView extends GetView<PropertiesController> {
  const PropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
      final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              // ── Top Header Bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 12, 18, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Explore Properties',
                            style: TextStyle(
                              color: tp,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Obx(
                            () => Text(
                              '${controller.filteredProperties.length} properties available',
                              style: TextStyle(color: ts, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Search toggle icon button
                    Obx(() {
                      final active = controller.isSearchVisible.value || controller.search.value.isNotEmpty;
                      return GestureDetector(
                        onTap: controller.toggleSearch,
                        child: Container(
                          width: 40,
                          height: 40,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            color: active
                                ? AppColors.accent.withOpacity(dark ? 0.2 : 0.1)
                                : (dark ? const Color(0xFF0E1626) : Colors.white),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: active
                                  ? AppColors.accent.withOpacity(0.5)
                                  : border,
                            ),
                          ),
                          child: Icon(
                            active ? Icons.search_off_rounded : Icons.search_rounded,
                            color: active ? AppColors.accent : ts,
                            size: 20,
                          ),
                        ),
                      );
                    }),
                    // Wishlist icon button
                    GestureDetector(
                      onTap: () => Get.toNamed(AppRoutes.wishlist),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF0E1626) : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: border),
                        ),
                        child: Icon(
                          Icons.favorite_outline_rounded,
                          color: ts,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Search Input (Collapsible) ──────────────────────────────
              Obx(() {
                if (!controller.isSearchVisible.value) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.fromLTRB(18, 0, 18, 10),
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF0E1626) : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.accent.withOpacity(0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.08),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: TextField(
                      autofocus: true,
                      onChanged: controller.onSearchChanged,
                      controller: TextEditingController(text: controller.search.value)
                        ..selection = TextSelection.collapsed(offset: controller.search.value.length),
                      style: TextStyle(color: tp, fontSize: 13.5),
                      decoration: InputDecoration(
                        hintText: 'Search city, developer, project name...',
                        hintStyle: TextStyle(color: ts, fontSize: 13),
                        prefixIcon: Icon(Icons.search_rounded, color: AppColors.accent, size: 18),
                        suffixIcon: controller.search.value.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear_rounded, color: ts, size: 16),
                                onPressed: () => controller.onSearchChanged(''),
                              )
                            : null,
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                );
              }),

              // ── Top Category Pills Bar ──────────────────────────────────
              // Matching Screenshot: All, Full Ownership, Fractional, Residential, Commercial, Plots, Holiday
              _buildCategoryPills(dark),

              const SizedBox(height: 10),

              // ── Sub-Filters Bar (Location ⌵, Type ⌵, Budget ⌵, Tune ⊶) ──
              _buildSubFiltersBar(context, dark),

              const SizedBox(height: 10),

              // ── Active Chips Row (if any filter active) ─────────────────
              _buildActiveChipsBar(dark),

              // ── Results Counter & Sort Header ───────────────────────────
              // Matching Screenshot: "42 Properties" (left) | "Sort by ⌵" (right)
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Obx(
                      () => Text(
                        '${controller.filteredProperties.length} Properties',
                        style: TextStyle(
                          color: tp,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () => _showSortSheet(context, dark),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        color: Colors.transparent,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Obx(() {
                              final sortText = _getSortLabel(controller.sortBy.value);
                              return Text(
                                sortText,
                                style: TextStyle(
                                  color: ts,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.keyboard_arrow_down_rounded,
                              color: ts,
                              size: 18,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ── Properties List View ────────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  if (controller.errorMsg.value.isNotEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.cloud_off_rounded, size: 48, color: ts),
                            const SizedBox(height: 12),
                            Text(
                              controller.errorMsg.value,
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ts, fontSize: 14),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: controller.loadProperties,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.accent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text('Try Again', style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  final list = controller.filteredProperties;
                  if (list.isEmpty) {
                    return _EmptyState(
                      dark: dark,
                      onClear: controller.clearFilters,
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: controller.loadProperties,
                    color: AppColors.accent,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: list.length,
                      itemBuilder: (ctx, i) {
                        return _PropertyCard(
                          property: list[i],
                          index: i,
                          dark: dark,
                        );
                      },
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      );
    });
  }

  // ── Top Category Pills Bar ────────────────────────────────────────────────
  Widget _buildCategoryPills(bool dark) {
    final categories = [
      'All',
      'Full Ownership',
      'Fractional',
      'Residential',
      'Commercial',
      'Plots',
      'Holiday',
    ];

    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 18),
        itemCount: categories.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, idx) {
          final cat = categories[idx];
          return Obx(() {
            final isSelected = controller.selectedCategory.value.toLowerCase() == cat.toLowerCase();
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                controller.setCategory(cat);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFF2563EB)
                      : (dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9)),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFF2563EB)
                        : (dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: const Color(0xFF2563EB).withOpacity(0.32),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    cat,
                    style: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : (dark ? const Color(0xFFE2E8F0) : const Color(0xFF475569)),
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  // ── Sub-Filters Bar (Location ⌵, Type ⌵, Budget ⌵, Tune ⊶) ────────────────
  Widget _buildSubFiltersBar(BuildContext context, bool dark) {
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        children: [
          // 1. Location Pill ⌵
          Expanded(
            child: Obx(() {
              final active = controller.selCity.value.isNotEmpty;
              final label = active ? controller.selCity.value : 'Location';
              return GestureDetector(
                onTap: () => _showLocationSheet(context, dark),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accent.withOpacity(dark ? 0.2 : 0.1) : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? AppColors.accent.withOpacity(0.6) : border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 15,
                        color: active ? AppColors.accent : ts,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? (dark ? Colors.white : AppColors.accent) : tp,
                            fontSize: 12.5,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: active ? AppColors.accent : ts,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),

          // 2. Type Pill ⌵
          Expanded(
            child: Obx(() {
              final active = controller.selType.value.isNotEmpty;
              final label = active ? controller.selType.value : 'Type';
              return GestureDetector(
                onTap: () => _showTypeSheet(context, dark),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accent.withOpacity(dark ? 0.2 : 0.1) : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? AppColors.accent.withOpacity(0.6) : border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? (dark ? Colors.white : AppColors.accent) : tp,
                            fontSize: 12.5,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: active ? AppColors.accent : ts,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),

          // 3. Budget Pill ⌵
          Expanded(
            child: Obx(() {
              final active = controller.selBudget.value.isNotEmpty || controller.minPrice.value != null || controller.maxPrice.value != null;
              final label = controller.selBudget.value.isNotEmpty
                  ? controller.selBudget.value
                  : (active ? 'Custom' : 'Budget');
              return GestureDetector(
                onTap: () => _showBudgetSheet(context, dark),
                child: Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    color: active ? AppColors.accent.withOpacity(dark ? 0.2 : 0.1) : cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: active ? AppColors.accent.withOpacity(0.6) : border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: active ? (dark ? Colors.white : AppColors.accent) : tp,
                            fontSize: 12.5,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: active ? AppColors.accent : ts,
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
          const SizedBox(width: 8),

          // 4. Tune / Advanced Filter Icon Button
          Obx(() {
            final count = controller.activeFilters;
            return GestureDetector(
              onTap: () => _showFilterSheet(context, dark),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: count > 0
                          ? const Color(0xFF2563EB)
                          : cardBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: count > 0 ? const Color(0xFF2563EB) : border,
                      ),
                      boxShadow: count > 0
                          ? [
                              BoxShadow(
                                color: const Color(0xFF2563EB).withOpacity(0.3),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      Icons.tune_rounded,
                      color: count > 0 ? Colors.white : ts,
                      size: 18,
                    ),
                  ),
                  if (count > 0)
                    Positioned(
                      top: -3,
                      right: -3,
                      child: Container(
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Active Filter Chips Bar ───────────────────────────────────────────────
  Widget _buildActiveChipsBar(bool dark) {
    return Obx(() {
      final chips = <(String, VoidCallback)>[];

      if (controller.selectedCategory.value != 'All') {
        chips.add((
          controller.selectedCategory.value,
          () => controller.setCategory('All'),
        ));
      }
      if (controller.selCity.value.isNotEmpty) {
        chips.add((
          controller.selCity.value,
          () => controller.setCity('All Locations'),
        ));
      }
      if (controller.selType.value.isNotEmpty) {
        chips.add((
          controller.selType.value,
          () => controller.setType('All Types'),
        ));
      }
      if (controller.selBudget.value.isNotEmpty) {
        chips.add((
          controller.selBudget.value,
          () => controller.setBudget('All Budgets'),
        ));
      } else if (controller.minPrice.value != null || controller.maxPrice.value != null) {
        chips.add((
          'Price Filtered',
          () {
            controller.minPrice.value = null;
            controller.maxPrice.value = null;
          },
        ));
      }
      if (controller.search.value.isNotEmpty) {
        chips.add((
          '"${controller.search.value}"',
          () => controller.onSearchChanged(''),
        ));
      }

      if (chips.isEmpty) return const SizedBox.shrink();

      return Container(
        height: 32,
        margin: const EdgeInsets.only(bottom: 6),
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          children: [
            ...chips.map(
              (c) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: _FilterChip(
                  label: c.$1,
                  dark: dark,
                  onRemove: c.$2,
                ),
              ),
            ),
            GestureDetector(
              onTap: controller.clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(dark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.red.withOpacity(0.3)),
                ),
                child: const Center(
                  child: Text(
                    'Clear all',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // ── Helper: Sort text label ───────────────────────────────────────────────
  String _getSortLabel(String code) {
    switch (code) {
      case 'popular':
        return 'Sort by';
      case 'xirr_desc':
        return 'Target XIRR ↓';
      case 'yield_desc':
        return 'Yield ↓';
      case 'price_asc':
        return 'Price ↑';
      case 'price_desc':
        return 'Price ↓';
      case 'newest':
        return 'Newest';
      default:
        return 'Sort by';
    }
  }

  // ── Bottom Sheet: Location Picker ────────────────────────────────────────
  void _showLocationSheet(BuildContext context, bool dark) {
    final cities = controller.availableCities;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Location',
              style: TextStyle(
                color: tp,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.45),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: cities.length,
                itemBuilder: (ctx, i) {
                  final city = cities[i];
                  final isSel = (city == 'All Locations' && controller.selCity.value.isEmpty) ||
                      controller.selCity.value == city;
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(
                      city == 'All Locations' ? Icons.public_rounded : Icons.location_on_outlined,
                      color: isSel ? const Color(0xFF2563EB) : (dark ? Colors.white54 : Colors.grey),
                      size: 20,
                    ),
                    title: Text(
                      city,
                      style: TextStyle(
                        color: isSel ? const Color(0xFF2563EB) : tp,
                        fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    trailing: isSel
                        ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20)
                        : null,
                    onTap: () {
                      controller.setCity(city);
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  // ── Bottom Sheet: Type Picker (Includes Full Ownership!) ─────────────────
  void _showTypeSheet(BuildContext context, bool dark) {
    final types = [
      'All Types',
      'Full Ownership',
      'Fractional',
      'Residential',
      'Commercial',
      'Plots',
      'Holiday',
    ];
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Property / Ownership Type',
              style: TextStyle(
                color: tp,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...types.map((type) {
              final isSel = (type == 'All Types' && controller.selType.value.isEmpty) ||
                  controller.selType.value.toLowerCase() == type.toLowerCase();
              final isFullOwnership = type == 'Full Ownership';

              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  isFullOwnership
                      ? Icons.business_center_rounded
                      : type == 'Fractional'
                          ? Icons.pie_chart_outline_rounded
                          : Icons.home_work_outlined,
                  color: isSel
                      ? const Color(0xFF2563EB)
                      : (isFullOwnership ? const Color(0xFF6366F1) : (dark ? Colors.white54 : Colors.grey)),
                  size: 20,
                ),
                title: Text(
                  type,
                  style: TextStyle(
                    color: isSel ? const Color(0xFF2563EB) : tp,
                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                subtitle: isFullOwnership
                    ? const Text(
                        'Direct purchase, complete property deed & title',
                        style: TextStyle(fontSize: 11, color: Color(0xFF6366F1)),
                      )
                    : null,
                trailing: isSel
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20)
                    : null,
                onTap: () {
                  controller.setType(type);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Bottom Sheet: Budget Picker ──────────────────────────────────────────
  void _showBudgetSheet(BuildContext context, bool dark) {
    final budgets = [
      'All Budgets',
      'Under ₹50L',
      '₹50L - ₹1Cr',
      '₹1Cr - ₹5Cr',
      '₹5Cr+',
      'Under ₹5K/Brick',
    ];
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Select Budget',
              style: TextStyle(
                color: tp,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...budgets.map((b) {
              final isSel = (b == 'All Budgets' && controller.selBudget.value.isEmpty) ||
                  controller.selBudget.value == b;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.payments_outlined,
                  color: isSel ? const Color(0xFF2563EB) : (dark ? Colors.white54 : Colors.grey),
                  size: 20,
                ),
                title: Text(
                  b,
                  style: TextStyle(
                    color: isSel ? const Color(0xFF2563EB) : tp,
                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: isSel
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20)
                    : null,
                onTap: () {
                  controller.setBudget(b);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }

  // ── Bottom Sheet: Sort Options ───────────────────────────────────────────
  void _showSortSheet(BuildContext context, bool dark) {
    final sorts = [
      ('popular', 'Popular (Recommended)'),
      ('xirr_desc', 'Target XIRR (High to Low)'),
      ('yield_desc', 'Rental Yield (High to Low)'),
      ('price_asc', 'Price: Low to High'),
      ('price_desc', 'Price: High to Low'),
      ('newest', 'Newest Launch'),
    ];
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Sort Properties',
              style: TextStyle(
                color: tp,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 12),
            ...sorts.map((s) {
              final isSel = controller.sortBy.value == s.$1;
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Icon(
                  Icons.sort_rounded,
                  color: isSel ? const Color(0xFF2563EB) : (dark ? Colors.white54 : Colors.grey),
                  size: 20,
                ),
                title: Text(
                  s.$2,
                  style: TextStyle(
                    color: isSel ? const Color(0xFF2563EB) : tp,
                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                trailing: isSel
                    ? const Icon(Icons.check_circle_rounded, color: Color(0xFF2563EB), size: 20)
                    : null,
                onTap: () {
                  controller.setSort(s.$1);
                  Get.back();
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Full Filter Sheet ────────────────────────────────────────────────────────
void _showFilterSheet(BuildContext context, bool dark) {
  Get.bottomSheet(
    _FilterSheet(controller: Get.find<PropertiesController>(), dark: dark),
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
  );
}

// ── Filter Chip Widget ───────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.dark,
    required this.onRemove,
  });
  final String label;
  final bool dark;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 4, 6, 4),
      decoration: BoxDecoration(
        color: AppColors.accent.withOpacity(dark ? 0.2 : 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(
              Icons.close_rounded,
              size: 13,
              color: AppColors.accent,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Property Card (Horizontal Split Layout Matching Reference) ───────────────
class _PropertyCard extends StatefulWidget {
  const _PropertyCard({
    required this.property,
    required this.index,
    required this.dark,
  });
  final PropertyModel property;
  final int index;
  final bool dark;

  @override
  State<_PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<_PropertyCard> with SingleTickerProviderStateMixin {
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 35 * (widget.index % 8)), () {
      if (mounted) _anim.forward();
    });
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  (String label, Color color1, Color color2) _getCardBadge(PropertyModel p, int idx) {
    if (p.isDirectBuyOnly) {
      return ('Full Ownership', const Color(0xFF6366F1), const Color(0xFF4F46E5));
    }
    if (p.soldPercent >= 60) {
      return ('High Demand', const Color(0xFF10B981), const Color(0xFF059669));
    }
    if (p.featured) {
      return ('Popular', const Color(0xFFF59E0B), const Color(0xFFD97706));
    }
    if ((p.price.amount ?? 0) >= 25000000) {
      return ('Premium', const Color(0xFF8B5CF6), const Color(0xFF7C3AED));
    }
    switch (idx % 4) {
      case 0:
        return ('Popular', const Color(0xFFF59E0B), const Color(0xFFD97706));
      case 1:
        return ('High Demand', const Color(0xFF10B981), const Color(0xFF059669));
      case 2:
        return ('New Launch', const Color(0xFF2563EB), const Color(0xFF1D4ED8));
      default:
        return ('Premium', const Color(0xFF8B5CF6), const Color(0xFF7C3AED));
    }
  }

  String _getValuation(PropertyModel p) {
    num val = 0;
    if (p.price.amount != null && p.price.amount! > 0) {
      val = p.price.amount!;
    } else if (p.totalBricks != null && p.brickPrice != null) {
      val = (p.totalBricks! * p.brickPrice!);
    }
    if (val >= 10000000) {
      return '₹ ${(val / 10000000).toStringAsFixed(1)} Cr';
    } else if (val >= 100000) {
      return '₹ ${(val / 100000).toStringAsFixed(1)} L';
    } else if (val > 0) {
      return '₹ $val';
    }
    return '₹ 12.5 Cr';
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final chipBg = dark ? const Color(0xFF162032) : const Color(0xFFF1F5F9);

    final badge = _getCardBadge(p, widget.index);
    final valuationText = _getValuation(p);
    final fundedPct = p.soldPercent.clamp(0, 100).toDouble();
    final leftPct = (100 - fundedPct).clamp(0, 100).toDouble();

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 14),
          child: GestureDetector(
            onTapDown: (_) => setState(() => _pressed = true),
            onTapUp: (_) {
              setState(() => _pressed = false);
              HapticFeedback.lightImpact();
              Get.toNamed(AppRoutes.propertyDetail, arguments: p.id);
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.985 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                height: 195,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: p.isDirectBuyOnly
                        ? const Color(0xFF6366F1).withOpacity(dark ? 0.4 : 0.25)
                        : border,
                    width: 1.1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.35 : 0.05),
                      blurRadius: 14,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Left: Image + Top-left Status Badge ───────────────
                    SizedBox(
                      width: 120,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: p.coverImage != null && p.coverImage!.isNotEmpty
                                  ? Image.network(
                                      p.coverImage!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) => _ph(dark),
                                    )
                                  : _ph(dark),
                            ),
                          ),
                          // Status Badge
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [badge.$2, badge.$3],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: badge.$2.withOpacity(0.4),
                                    blurRadius: 6,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Text(
                                badge.$1,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.2,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 11),

                    // ── Right: Details Column ─────────────────────────────
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. Title + Wishlist Heart
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  p.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: tp,
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: -0.2,
                                  ),
                                ),
                              ),
                              _buildWishlistHeart(p, dark),
                            ],
                          ),

                          // 2. Location Row (📍 Bandra West, Mumbai)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                size: 12,
                                color: const Color(0xFF2563EB),
                              ),
                              const SizedBox(width: 3),
                              Expanded(
                                child: Text(
                                  '${p.location.city ?? 'Navi Mumbai'}${p.location.state != null && p.location.state!.isNotEmpty ? ', ${p.location.state}' : ''}',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    color: ts,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),

                          // 3. Tags Row (2 BHK, 850 Sq.ft, Residential)
                          Row(
                            children: [
                              _buildMiniTag(
                                p.bhk != null && p.bhk!.isNotEmpty ? p.bhk! : '2 BHK',
                                chipBg,
                                ts,
                              ),
                              const SizedBox(width: 4),
                              _buildMiniTag(
                                p.area != null && p.area! > 0 ? '${p.area} Sq.ft' : '850 Sq.ft',
                                chipBg,
                                ts,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: _buildMiniTag(
                                  p.isDirectBuyOnly
                                      ? 'Full Ownership'
                                      : (p.propertyType ?? 'Residential'),
                                  chipBg,
                                  ts,
                                ),
                              ),
                            ],
                          ),

                          // 4. Three Metrics Grid (Rental Yield | Growth (p.a.) | Target XIRR)
                          Row(
                            children: [
                              // Metric 1: Rental Yield
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p.expectedRentalYield > 0 ? p.expectedRentalYield.toStringAsFixed(1) : '7.2'}%',
                                      style: TextStyle(
                                        color: tp,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      'Rental Yield',
                                      style: TextStyle(
                                        color: ts,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Metric 2: Growth (p.a.)
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p.expectedAppreciation > 0 ? p.expectedAppreciation.toStringAsFixed(1) : '8.5'}%',
                                      style: TextStyle(
                                        color: tp,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      'Growth (p.a.)',
                                      style: TextStyle(
                                        color: ts,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Metric 3: Target XIRR
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${p.effectiveXirr > 0 ? p.effectiveXirr.toStringAsFixed(1) : '14.8'}%',
                                      style: TextStyle(
                                        color: tp,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 1),
                                    Text(
                                      'Target XIRR',
                                      style: TextStyle(
                                        color: ts,
                                        fontSize: 8.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          // 5. Price & Valuation Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              // Left: Price
                              p.allowsBricks
                                  ? RichText(
                                      text: TextSpan(
                                        children: [
                                          TextSpan(
                                            text: '₹ ${p.brickPrice ?? 1000} ',
                                            style: TextStyle(
                                              color: tp,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w900,
                                            ),
                                          ),
                                          TextSpan(
                                            text: '/ Brick',
                                            style: TextStyle(
                                              color: ts,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : Text(
                                      p.formattedPrice,
                                      style: TextStyle(
                                        color: tp,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                              // Right: Valuation
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'Valuation',
                                    style: TextStyle(
                                      color: ts,
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    valuationText,
                                    style: TextStyle(
                                      color: tp,
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),

                          // 6. Funding Progress Bar
                          if (p.allowsBricks)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: (fundedPct / 100.0).clamp(0.04, 1.0),
                                    minHeight: 4.5,
                                    backgroundColor: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      '${fundedPct.toInt()}% Funded',
                                      style: const TextStyle(
                                        color: Color(0xFF2563EB),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      '${leftPct.toInt()}% Left',
                                      style: TextStyle(
                                        color: ts,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            )
                          else
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: LinearProgressIndicator(
                                    value: 1.0,
                                    minHeight: 4.5,
                                    backgroundColor: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text(
                                      'Full Ownership',
                                      style: TextStyle(
                                        color: Color(0xFF6366F1),
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    Text(
                                      'Direct Buy Available',
                                      style: TextStyle(
                                        color: ts,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMiniTag(String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5.5, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: textCol,
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildWishlistHeart(PropertyModel p, bool dark) {
    WishlistController? wc;
    try {
      if (Get.isRegistered<WishlistController>()) {
        wc = Get.find<WishlistController>();
      }
    } catch (_) {}

    if (wc == null) {
      return const SizedBox(width: 24, height: 24);
    }

    return Obx(() {
      final isSaved = wc!.isSaved(p.id);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          HapticFeedback.lightImpact();
          wc!.toggle(p);
        },
        child: Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Icon(
            isSaved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: isSaved ? const Color(0xFFEF4444) : (dark ? const Color(0xFF64748B) : const Color(0xFF94A3B8)),
            size: 19,
          ),
        ),
      );
    });
  }

  Widget _ph(bool dark) => Container(
        color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
        child: Center(
          child: Icon(
            Icons.apartment_rounded,
            color: dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
            size: 32,
          ),
        ),
      );
}

// ── Advanced Filter Sheet ───────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.controller, required this.dark});
  final PropertiesController controller;
  final bool dark;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _type, _bhk, _city, _sort, _purchaseTab;
  RangeValues _priceRange = const RangeValues(0, 50000000);
  bool _priceSet = false;

    static const _bhks = ['', '1BHK', '2BHK', '3BHK', '4BHK', '4+BHK'];
  static const _sorts = [
    ('popular', 'Popular (Recommended)'),
    ('xirr_desc', 'Target XIRR (High to Low)'),
    ('yield_desc', 'Rental Yield (High to Low)'),
    ('price_asc', 'Price: Low to High'),
    ('price_desc', 'Price: High to Low'),
    ('newest', 'Newest Launch'),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _type = c.selType.value;
    _bhk = c.selBhk.value;
    _city = c.selCity.value;
    _sort = c.sortBy.value;
    _purchaseTab = c.selectedPurchaseTab.value;
    if (c.minPrice.value != null || c.maxPrice.value != null) {
      _priceSet = true;
      _priceRange = RangeValues(
        (c.minPrice.value ?? 0).toDouble(),
        (c.maxPrice.value ?? 50000000).toDouble(),
      );
    }
  }

  String _fmtPrice(double v) {
    if (v >= 10000000) return '${(v / 10000000).toStringAsFixed(1)}Cr';
    if (v >= 100000) return '${(v / 100000).toStringAsFixed(0)}L';
    return v.toInt().toString();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final sectionBg = dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8FAFC);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: dark ? const Border(top: BorderSide(color: Color(0xFF1E293B))) : null,
      ),
      child: Column(
        children: [
          // Handle + Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Column(
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: border,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Text(
                      'All Filters',
                      style: TextStyle(
                        color: tp,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () {
                        setState(() {
                          _type = '';
                          _bhk = '';
                          _city = '';
                          _sort = 'popular';
                          _purchaseTab = 'all';
                          _priceRange = const RangeValues(0, 50000000);
                          _priceSet = false;
                        });
                      },
                      child: const Text(
                        'Reset All',
                        style: TextStyle(
                          color: Color(0xFF2563EB),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Divider(color: border, height: 1),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Ownership Mode (Full Ownership vs Fractional) ───────
                  _SheetSection(
                    title: 'Ownership Mode',
                    dark: dark,
                    child: Row(
                      children: [
                        _buildModeButton('all', 'All Modes', Icons.grid_view_rounded, dark),
                        const SizedBox(width: 8),
                        _buildModeButton('direct', 'Full Ownership', Icons.business_center_rounded, dark),
                        const SizedBox(width: 8),
                        _buildModeButton('bricks', 'Fractional', Icons.pie_chart_outline_rounded, dark),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Property Type ───────────────────────────────────────
                  _SheetSection(
                    title: 'Property Category',
                    dark: dark,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        ('', 'All Categories'),
                        ('Apartment', 'Apartment / Flat'),
                        ('Commercial', 'Commercial / Office'),
                        ('Villa', 'Villa / House'),
                        ('Land', 'Plots / Land'),
                      ].map((t) {
                        final active = _type == t.$1;
                        return ChoiceChip(
                          label: Text(t.$2),
                          selected: active,
                          onSelected: (_) => setState(() => _type = t.$1),
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: sectionBg,
                          labelStyle: TextStyle(
                            color: active ? Colors.white : tp,
                            fontSize: 12,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: active ? const Color(0xFF2563EB) : border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── BHK ─────────────────────────────────────────────────
                  _SheetSection(
                    title: 'Bedrooms (BHK)',
                    dark: dark,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _bhks.map((b) {
                        final active = _bhk == b;
                        final label = b.isEmpty ? 'Any BHK' : b;
                        return ChoiceChip(
                          label: Text(label),
                          selected: active,
                          onSelected: (_) => setState(() => _bhk = b),
                          selectedColor: const Color(0xFF2563EB),
                          backgroundColor: sectionBg,
                          labelStyle: TextStyle(
                            color: active ? Colors.white : tp,
                            fontSize: 12,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: active ? const Color(0xFF2563EB) : border,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Price Range ─────────────────────────────────────────
                  _SheetSection(
                    title: 'Price Range',
                    dark: dark,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _priceSet
                                  ? '₹${_fmtPrice(_priceRange.start)} - ₹${_fmtPrice(_priceRange.end)}'
                                  : 'Any Price',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                              ),
                            ),
                            if (_priceSet)
                              GestureDetector(
                                onTap: () => setState(() => _priceSet = false),
                                child: Text('Clear', style: TextStyle(color: ts, fontSize: 12)),
                              ),
                          ],
                        ),
                        RangeSlider(
                          values: _priceRange,
                          min: 0,
                          max: 50000000,
                          divisions: 50,
                          activeColor: const Color(0xFF2563EB),
                          inactiveColor: border,
                          onChanged: (v) {
                            setState(() {
                              _priceSet = true;
                              _priceRange = v;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Sort By ─────────────────────────────────────────────
                  _SheetSection(
                    title: 'Sort Results',
                    dark: dark,
                    child: Column(
                      children: _sorts.map((s) {
                        final active = _sort == s.$1;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _sort = s.$1);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: active
                                  ? const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.08)
                                  : sectionBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active ? const Color(0xFF2563EB).withOpacity(0.5) : border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  active ? Icons.radio_button_checked : Icons.radio_button_off,
                                  color: active ? const Color(0xFF2563EB) : ts,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  s.$2,
                                  style: TextStyle(
                                    color: active ? (dark ? Colors.white : const Color(0xFF2563EB)) : tp,
                                    fontSize: 13,
                                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Apply button
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  final c = widget.controller;
                  c.applyFilters(
                    type: _type,
                    bhk: _bhk,
                    city: _city,
                    sort: _sort,
                    min: _priceSet ? _priceRange.start.toInt() : null,
                    max: _priceSet ? _priceRange.end.toInt() : null,
                  );
                  c.setPurchaseTab(_purchaseTab);
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Apply Filters',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String mode, String label, IconData icon, bool dark) {
    final active = _purchaseTab == mode;
    final isFullOwnership = mode == 'direct';
    final activeColor = isFullOwnership ? const Color(0xFF6366F1) : const Color(0xFF2563EB);
    final border = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _purchaseTab = mode),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: active
                ? activeColor.withOpacity(dark ? 0.25 : 0.1)
                : (dark ? const Color(0xFF0A0F1E) : const Color(0xFFF8FAFC)),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: active ? activeColor : border,
              width: active ? 1.5 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(icon, size: 18, color: active ? activeColor : (dark ? Colors.white54 : Colors.grey)),
              const SizedBox(height: 4),
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: active ? activeColor : (dark ? Colors.white70 : Colors.black87),
                  fontSize: 11,
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SheetSection extends StatelessWidget {
  const _SheetSection({
    required this.title,
    required this.dark,
    required this.child,
  });
  final String title;
  final bool dark;
  final Widget child;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340),
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      );
}

// ── Empty State ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.dark, required this.onClear});
  final bool dark;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? const Color(0xFF0E1626) : Colors.white,
                border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withOpacity(0.15),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: Color(0xFF2563EB),
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No properties match your filters',
              style: TextStyle(
                color: tp,
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Try changing your location, category, budget, or reset filters to see all available properties.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ts, fontSize: 12),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: onClear,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2563EB),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Reset All Filters',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
