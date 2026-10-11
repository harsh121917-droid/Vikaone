import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../controllers/business_controller.dart';
import '../widgets/business_card.dart';

class BusinessView extends GetView<BusinessController> {
  const BusinessView({super.key});

  @override
  Widget build(BuildContext context) {
    // Ensure controller is registered
    final ctrl = Get.isRegistered<BusinessController>()
        ? Get.find<BusinessController>()
        : Get.put(BusinessController());

    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF1F5F9);
    final titleColor = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final subColor = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    const primaryBlue = Color(0xFF2563EB);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: RefreshIndicator(
          color: primaryBlue,
          backgroundColor: dark ? const Color(0xFF0F172A) : Colors.white,
          onRefresh: () => ctrl.loadOpportunities(),
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
            slivers: [
              // ── 1. Top Header ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'Business',
                                  style: TextStyle(
                                    color: titleColor,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.6,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: primaryBlue.withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: primaryBlue.withOpacity(0.3)),
                                  ),
                                  child: const Text(
                                    'VENTURES',
                                    style: TextStyle(
                                      color: primaryBlue,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.8,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'High-yield commercial & franchise opportunities',
                              style: TextStyle(color: subColor, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 2. Search Bar ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
                  child: Container(
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF0F172A) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      style: TextStyle(color: titleColor, fontSize: 14),
                      onChanged: ctrl.setSearchQuery,
                      decoration: InputDecoration(
                        hintText: 'Search warehouses, petrol pumps, dairy...',
                        hintStyle: TextStyle(color: subColor, fontSize: 13),
                        prefixIcon: const Icon(Icons.search_rounded, color: primaryBlue, size: 20),
                        suffixIcon: Obx(() {
                          if (ctrl.searchQuery.value.isEmpty) return const SizedBox.shrink();
                          return IconButton(
                            icon: Icon(
                              Icons.clear_rounded,
                              size: 18,
                              color: dark ? Colors.white54 : const Color(0xFF64748B),
                            ),
                            onPressed: () => ctrl.setSearchQuery(''),
                          );
                        }),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                    ),
                  ),
                ),
              ),

              // ── 3. Category Horizontal Pills ──
              SliverToBoxAdapter(
                child: Container(
                  height: 52,
                  margin: const EdgeInsets.only(top: 8, bottom: 4),
                  child: ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    scrollDirection: Axis.horizontal,
                    itemCount: ctrl.categories.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                    itemBuilder: (ctx, i) {
                      final category = ctrl.categories[i];
                      return Obx(() {
                        final isSel = ctrl.selectedCategory.value == category;
                        final count = ctrl.getCategoryCount(category);

                        return GestureDetector(
                          onTap: () => ctrl.selectCategory(category),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSel
                                  ? primaryBlue
                                  : (dark ? const Color(0xFF0F172A) : Colors.white),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: isSel
                                    ? primaryBlue
                                    : (dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0)),
                                width: 1.2,
                              ),
                              boxShadow: isSel
                                  ? [
                                      BoxShadow(
                                        color: primaryBlue.withOpacity(0.35),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _getCategoryIcon(category),
                                  size: 15,
                                  color: isSel ? Colors.white : primaryBlue,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  category,
                                  style: TextStyle(
                                    color: isSel ? Colors.white : titleColor,
                                    fontSize: 12,
                                    fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                                  ),
                                ),
                                if (count > 0) ...[
                                  const SizedBox(width: 6),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: isSel
                                          ? Colors.white.withOpacity(0.25)
                                          : (dark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      '$count',
                                      style: TextStyle(
                                        color: isSel ? Colors.white : subColor,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ),
              ),

              // ── 4. Verified Commercial SPV Banner ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: dark
                            ? [
                                primaryBlue.withOpacity(0.12),
                                const Color(0xFF1D4ED8).withOpacity(0.04),
                              ]
                            : [
                                primaryBlue.withOpacity(0.1),
                                const Color(0xFF3B82F6).withOpacity(0.05),
                              ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: primaryBlue.withOpacity(0.25)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: primaryBlue.withOpacity(0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.security_rounded, color: primaryBlue, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Institutional Due-Diligence & Escrow Safeguards',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Every business is held in a dedicated bankruptcy-remote SPV with bank escrow.',
                                style: TextStyle(color: subColor, fontSize: 11, height: 1.3),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ── 5. Opportunities List / Loader / Empty State ──
              Obx(() {
                if (ctrl.isLoading.value) {
                  return const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.symmetric(vertical: 60),
                      child: Center(
                        child: CircularProgressIndicator(
                          color: primaryBlue,
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  );
                }

                if (ctrl.errorMessage.value.isNotEmpty && ctrl.opportunities.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            const Icon(Icons.wifi_off_rounded, color: Colors.orangeAccent, size: 48),
                            const SizedBox(height: 12),
                            Text(
                              ctrl.errorMessage.value,
                              style: TextStyle(color: subColor, fontSize: 13),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: () => ctrl.loadOpportunities(),
                              child: const Text('Try Again'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                final list = ctrl.filteredOpportunities;

                if (list.isEmpty) {
                  return SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
                      child: Center(
                        child: Column(
                          children: [
                            Icon(Icons.search_off_rounded, color: subColor.withOpacity(0.5), size: 54),
                            const SizedBox(height: 14),
                            Text(
                              'No opportunities found',
                              style: TextStyle(color: titleColor, fontSize: 16, fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Try selecting another category or clearing your search.',
                              style: TextStyle(color: subColor, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => BusinessCard(business: list[i]),
                    childCount: list.length,
                  ),
                );
              }),

              const SliverToBoxAdapter(child: SizedBox(height: 30)),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Warehouses & Logistics':
        return Icons.warehouse_rounded;
      case 'Petrol Pumps':
        return Icons.local_gas_station_rounded;
      case 'Dairy Farms':
        return Icons.agriculture_rounded;
      case 'Hotels & Hospitality':
        return Icons.hotel_rounded;
      case 'CBG (Compressed Biogas) Plants':
        return Icons.eco_rounded;
      default:
        return Icons.business_center_rounded;
    }
  }
}
