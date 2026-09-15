import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/properties_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/property_model.dart';
import '../../../routes/app_routes.dart';

class PropertiesView extends GetView<PropertiesController> {
  const PropertiesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFECF0FF);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

      return Container(
        color: bg,
        child: SafeArea(
          child: Column(
            children: [
              // ── Top bar ──────────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
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
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.5,
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
                    // Filter button with badge
                    Obx(() {
                      final count = controller.activeFilters;
                      return GestureDetector(
                        onTap: () => _showFilterSheet(context, dark),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
                              width: 46,
                              height: 46,
                              decoration: BoxDecoration(
                                gradient: count > 0
                                    ? const LinearGradient(
                                        colors: [
                                          AppColors.accent,
                                          AppColors.accentLight,
                                        ],
                                      )
                                    : null,
                                color: count > 0
                                    ? null
                                    : (dark
                                          ? const Color(0xFF0E1626)
                                          : Colors.white),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: count > 0
                                      ? Colors.transparent
                                      : (dark
                                            ? const Color(0xFF1A2B45)
                                            : const Color(0xFFE2E6F0)),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: count > 0
                                        ? AppColors.accent.withOpacity(0.4)
                                        : Colors.black.withOpacity(
                                            dark ? 0.3 : 0.06,
                                          ),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.tune_rounded,
                                color: count > 0
                                    ? Colors.white
                                    : (dark
                                          ? const Color(0xFF8A95B0)
                                          : const Color(0xFF6B7280)),
                                size: 20,
                              ),
                            ),
                            if (count > 0)
                              Positioned(
                                top: -4,
                                right: -4,
                                child: Container(
                                  width: 18,
                                  height: 18,
                                  decoration: const BoxDecoration(
                                    color: Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      '$count',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
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
              ),
              const SizedBox(height: 14),

              // ── Purchase Mode Tab Bar ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Obx(() {
                  final activeTab = controller.selectedPurchaseTab.value;
                  return Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF0E1626) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: dark
                            ? const Color(0xFF1A2B45)
                            : const Color(0xFFE2E6F0),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(dark ? 0.25 : 0.04),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        _PurchaseTabItem(
                          label: 'All Properties',
                          icon: Icons.grid_view_rounded,
                          count: controller.totalCount,
                          isActive: activeTab == 'all',
                          activeColor: AppColors.accent,
                          dark: dark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            controller.setPurchaseTab('all');
                          },
                        ),
                        const SizedBox(width: 4),
                        _PurchaseTabItem(
                          label: 'Bricks Investment',
                          icon: Icons.layers_rounded,
                          count: controller.bricksCount,
                          isActive: activeTab == 'bricks',
                          activeColor: const Color(0xFF10B981),
                          dark: dark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            controller.setPurchaseTab('bricks');
                          },
                        ),
                        const SizedBox(width: 4),
                        _PurchaseTabItem(
                          label: 'Full Ownership',
                          icon: Icons.business_rounded,
                          count: controller.directCount,
                          isActive: activeTab == 'direct',
                          activeColor: const Color(0xFF6366F1),
                          dark: dark,
                          onTap: () {
                            HapticFeedback.selectionClick();
                            controller.setPurchaseTab('direct');
                          },
                        ),
                      ],
                    ),
                  );
                }),
              ),
              const SizedBox(height: 14),

              // ── Search bar ───────────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SearchBar(
                  dark: dark,
                  onChanged: controller.onSearchChanged,
                ),
              ),
              const SizedBox(height: 14),

              // ── Active filter chips ──────────────────────────────────────
              Obx(() {
                final chips = _activeChips();
                if (chips.isEmpty) return const SizedBox.shrink();
                return SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(dark ? 0.15 : 0.08),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'Clear all',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),

              // ── Sort bar ─────────────────────────────────────────────────
              Obx(() {
                final chips = _activeChips();
                return SizedBox(
                  height: 36,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.fromLTRB(
                      20,
                      chips.isEmpty ? 0 : 8,
                      20,
                      0,
                    ),
                    children:
                        [
                          ('newest', 'Newest'),
                          ('price_asc', 'Price ↑'),
                          ('price_desc', 'Price ↓'),
                          ('area_asc', 'Area ↑'),
                        ].map((s) {
                          final active = controller.sortBy.value == s.$1;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                HapticFeedback.selectionClick();
                                controller.sortBy.value = s.$1;
                                controller.loadProperties();
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  gradient: active
                                      ? const LinearGradient(
                                          colors: [
                                            AppColors.accent,
                                            AppColors.accentLight,
                                          ],
                                        )
                                      : null,
                                  color: active
                                      ? null
                                      : (dark
                                            ? const Color(0xFF0E1626)
                                            : Colors.white),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: active
                                        ? Colors.transparent
                                        : (dark
                                              ? const Color(0xFF1A2B45)
                                              : const Color(0xFFE2E6F0)),
                                  ),
                                  boxShadow: active
                                      ? [
                                          BoxShadow(
                                            color: AppColors.accent.withOpacity(
                                              0.35,
                                            ),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ]
                                      : null,
                                ),
                                child: Text(
                                  s.$2,
                                  style: TextStyle(
                                    color: active ? Colors.white : ts,
                                    fontSize: 12,
                                    fontWeight: active
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                );
              }),
              const SizedBox(height: 10),

              // ── Results ───────────────────────────────────────────────────
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.accent,
                        strokeWidth: 2,
                      ),
                    );
                  }
                  if (controller.errorMsg.value.isNotEmpty) {
                    return Center(
                      child: Text(
                        controller.errorMsg.value,
                        style: TextStyle(color: ts),
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
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
                      physics: const BouncingScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (_, i) => _PropertyCard(
                        property: list[i],
                        index: i,
                        dark: dark,
                      ),
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

  List<(String, VoidCallback)> _activeChips() {
    final chips = <(String, VoidCallback)>[];
    if (controller.selType.value.isNotEmpty)
      chips.add((
        controller.selType.value,
        () {
          controller.selType.value = '';
          controller.loadProperties();
        },
      ));
    if (controller.selBhk.value.isNotEmpty)
      chips.add((
        controller.selBhk.value,
        () {
          controller.selBhk.value = '';
          controller.loadProperties();
        },
      ));
    if (controller.selCity.value.isNotEmpty)
      chips.add((
        controller.selCity.value,
        () {
          controller.selCity.value = '';
          controller.loadProperties();
        },
      ));
    if (controller.minPrice.value != null)
      chips.add((
        'Min ₹${_fmtPrice(controller.minPrice.value!)}',
        () {
          controller.minPrice.value = null;
          controller.loadProperties();
        },
      ));
    if (controller.maxPrice.value != null)
      chips.add((
        'Max ₹${_fmtPrice(controller.maxPrice.value!)}',
        () {
          controller.maxPrice.value = null;
          controller.loadProperties();
        },
      ));
    return chips;
  }

  String _fmtPrice(int n) {
    if (n >= 10000000) return '${(n / 10000000).toStringAsFixed(1)}Cr';
    if (n >= 100000) return '${(n / 100000).toStringAsFixed(0)}L';
    return '$n';
  }

  void _showFilterSheet(BuildContext context, bool dark) {
    Get.bottomSheet(
      _FilterSheet(controller: controller, dark: dark),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.dark, required this.onChanged});
  final bool dark;
  final ValueChanged<String> onChanged;
  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final borderC = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final hintC = dark ? const Color(0xFF4A5568) : const Color(0xFFADB5BD);
    final textC = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final iconC = dark ? const Color(0xFF8A95B0) : const Color(0xFF9BA8C0);

    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -2,
          ),
          if (!dark)
            BoxShadow(
              color: Colors.white.withOpacity(0.8),
              blurRadius: 3,
              offset: const Offset(-1, -1),
            ),
        ],
      ),
      child: Row(
        children: [
          const SizedBox(width: 14),
          Icon(Icons.search_rounded, color: iconC, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: onChanged,
              style: TextStyle(color: textC, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search city, title, area...',
                hintStyle: TextStyle(color: hintC, fontSize: 14),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Active Filter Chip ───────────────────────────────────────────────────────
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
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: AppColors.accent.withOpacity(dark ? 0.2 : 0.1),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: AppColors.accent.withOpacity(0.35)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(width: 4),
        GestureDetector(
          onTap: onRemove,
          child: const Icon(
            Icons.close_rounded,
            color: AppColors.accent,
            size: 14,
          ),
        ),
      ],
    ),
  );
}

// ─── Property Card ────────────────────────────────────────────────────────────
// ─── Purchase Mode Tab Item ───────────────────────────────────────────────────
class _PurchaseTabItem extends StatelessWidget {
  const _PurchaseTabItem({
    required this.label,
    required this.icon,
    required this.count,
    required this.isActive,
    required this.activeColor,
    required this.dark,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final int count;
  final bool isActive;
  final Color activeColor;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textInactive = dark
        ? const Color(0xFF94A3B8)
        : const Color(0xFF64748B);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 6),
          decoration: BoxDecoration(
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [activeColor, activeColor.withOpacity(0.82)],
                  )
                : null,
            color: isActive ? null : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: activeColor.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ]
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 13.5,
                    color: isActive ? Colors.white : textInactive,
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      label,
                      style: TextStyle(
                        color: isActive ? Colors.white : textInactive,
                        fontSize: 11,
                        fontWeight: isActive
                            ? FontWeight.w900
                            : FontWeight.w600,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 1.5,
                ),
                decoration: BoxDecoration(
                  color: isActive
                      ? Colors.white.withOpacity(0.24)
                      : (dark
                            ? const Color(0xFF1E293B)
                            : const Color(0xFFE2E8F0)),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isActive ? Colors.white : textInactive,
                    fontSize: 9.5,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Modern Luxury Property Card ──────────────────────────────────────────────
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

class _PropertyCardState extends State<_PropertyCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _f;
  late final Animation<Offset> _s;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _f = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _s = Tween(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 40 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0F172A) : Colors.white;
    final tp = dark ? const Color(0xFFF8FAFC) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final chipBg = dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9);
    final borderColor = dark
        ? const Color(0xFF1E293B)
        : const Color(0xFFE2E8F0);

    final available = p.availableBricks;
    final pct = p.soldPercent;
    final totalIrr = (p.expectedRentalYield + p.expectedAppreciation)
        .toStringAsFixed(1);

    return FadeTransition(
      opacity: _f,
      child: SlideTransition(
        position: _s,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: GestureDetector(
            onTapDown: (_) {
              HapticFeedback.lightImpact();
              setState(() => _pressed = true);
            },
            onTapUp: (_) {
              setState(() => _pressed = false);
              Get.toNamed(AppRoutes.propertyDetail, arguments: p.id);
            },
            onTapCancel: () => setState(() => _pressed = false),
            child: AnimatedScale(
              scale: _pressed ? 0.98 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: p.isDirectBuyOnly
                        ? const Color(
                            0xFF6366F1,
                          ).withOpacity(dark ? 0.35 : 0.25)
                        : borderColor,
                    width: 1.2,
                  ),
                  boxShadow: _pressed
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.45 : 0.08),
                            blurRadius: 22,
                            offset: const Offset(0, 8),
                            spreadRadius: -2,
                          ),
                          if (!dark)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.9),
                              blurRadius: 4,
                              offset: const Offset(-1, -1),
                            ),
                        ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── 1. Hero Image ──────────────────────────────────────
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(23),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9.5,
                            child: p.coverImage != null
                                ? Image.network(
                                    p.coverImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _ph(dark),
                                  )
                                : _ph(dark),
                          ),
                        ),
                        // Dark subtle gradient overlay
                        Positioned.fill(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(23),
                              ),
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black.withOpacity(0.45),
                                  Colors.transparent,
                                  Colors.black.withOpacity(0.75),
                                ],
                                stops: const [0.0, 0.45, 1.0],
                              ),
                            ),
                          ),
                        ),

                        // Top Pills (Location & Potential Return)
                        Positioned(
                          top: 12,
                          left: 12,
                          right: 12,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Location Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  p.location.city ?? 'Navi Mumbai',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                              // Potential Return Pill
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 11,
                                  vertical: 5.5,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 6,
                                      offset: const Offset(0, 2),
                                    ),
                                  ],
                                ),
                                child: Text(
                                  '${((p.expectedAppreciation * 4) + (p.expectedRentalYield * 4)).round()}% Potential Return',
                                  style: const TextStyle(
                                    color: Color(0xFF0F172A),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Bottom Banner: Investment starts from ₹XX,XXX
                        Positioned(
                          bottom: 12,
                          left: 14,
                          right: 14,
                          child: Text(
                            'Investment starts from ₹${(p.brickPrice ?? 10000).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15.5,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.2,
                              shadows: [
                                Shadow(
                                  color: Color(0xCC000000),
                                  blurRadius: 8,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),

                    // ── 2. Card Body ───────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            p.title,
                            style: TextStyle(
                              color: tp,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),

                          // Specs chips
                          Row(
                            children: [
                              if (p.bhk != null) ...[
                                _MiniChip(
                                  icon: Icons.bed_outlined,
                                  label: p.bhk!,
                                  bg: chipBg,
                                  tc: ts,
                                ),
                                const SizedBox(width: 6),
                              ],
                              if (p.area != null) ...[
                                _MiniChip(
                                  icon: Icons.square_foot,
                                  label: '${p.area} sqft',
                                  bg: chipBg,
                                  tc: ts,
                                ),
                                const SizedBox(width: 6),
                              ],
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF10B981,
                                  ).withOpacity(dark ? 0.2 : 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified_rounded,
                                      color: Color(0xFF10B981),
                                      size: 11,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      'Verified SPV',
                                      style: TextStyle(
                                        color: Color(0xFF10B981),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // ── 3-Column Financial Matrix Bar ──────────────────────
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF141E30)
                                  : const Color(0xFFF8FAFC),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: dark
                                    ? const Color(0xFF1E2F48)
                                    : const Color(0xFFE2E8F0),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'RENTAL YIELD',
                                        style: TextStyle(
                                          color: ts,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${p.expectedRentalYield}% p.a.',
                                        style: const TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: dark
                                      ? const Color(0xFF1E2F48)
                                      : const Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'GROWTH',
                                        style: TextStyle(
                                          color: ts,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '${p.expectedAppreciation}% p.a.',
                                        style: const TextStyle(
                                          color: AppColors.accent,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 24,
                                  width: 1,
                                  color: dark
                                      ? const Color(0xFF1E2F48)
                                      : const Color(0xFFE2E8F0),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'TARGET IRR',
                                        style: TextStyle(
                                          color: ts,
                                          fontSize: 9,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 3),
                                      Text(
                                        '$totalIrr% IRR',
                                        style: const TextStyle(
                                          color: Color(0xFF38BDF8),
                                          fontSize: 13,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Funding Progress Bar (if bricks enabled)
                          if (p.allowsBricks && (p.totalBricks ?? 0) > 0) ...[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '${pct.toStringAsFixed(0)}% Funded',
                                  style: TextStyle(
                                    color: ts,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  available > 0
                                      ? '$available bricks left'
                                      : 'Fully Funded',
                                  style: TextStyle(
                                    color: available > 0
                                        ? AppColors.accent
                                        : const Color(0xFF10B981),
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                height: 7,
                                color: dark
                                    ? const Color(0xFF1E293B)
                                    : const Color(0xFFE2E8F0),
                                child: FractionallySizedBox(
                                  alignment: Alignment.centerLeft,
                                  widthFactor: (pct / 100).clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: const BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFFFB300),
                                          DarkColors.goldLight,
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                          ],

                          Divider(
                            height: 1,
                            color: borderColor.withOpacity(0.7),
                          ),
                          const SizedBox(height: 14),

                          // ── 3. Price & Action Footer ───────────────────
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if (p.allowsBricks &&
                                        p.brickPrice != null) ...[
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Flexible(
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                '₹${p.brickPrice!.toLocaleString()}',
                                                style: const TextStyle(
                                                  color: AppColors.accent,
                                                  fontSize: 20,
                                                  fontWeight: FontWeight.w900,
                                                ),
                                              ),
                                            ),
                                          ),
                                          Text(
                                            ' / brick',
                                            style: TextStyle(
                                              color: ts,
                                              fontSize: 11.5,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Valuation: ${p.formattedPrice}',
                                        style: TextStyle(
                                          color: ts,
                                          fontSize: 11,
                                        ),
                                      ),
                                    ] else ...[
                                      FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          p.formattedPrice,
                                          style: const TextStyle(
                                            color: Color(0xFF6366F1),
                                            fontSize: 20,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        '100% Full Ownership',
                                        style: TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),

                              // Luxury CTA Button
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: p.isDirectBuyOnly
                                        ? const [
                                            Color(0xFF6366F1),
                                            Color(0xFF4F46E5),
                                          ]
                                        : const [
                                            AppColors.accent,
                                            AppColors.accentLight,
                                          ],
                                  ),
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color:
                                          (p.isDirectBuyOnly
                                                  ? const Color(0xFF6366F1)
                                                  : AppColors.accent)
                                              .withOpacity(0.4),
                                      blurRadius: 10,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      p.isDirectBuyOnly
                                          ? 'Buyout'
                                          : 'Invest Now',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12.5,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                    const SizedBox(width: 5),
                                    const Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ],
                                ),
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

  Widget _ph(bool dark) => Container(
    color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0F2F8),
    child: Icon(
      Icons.home_outlined,
      color: dark ? const Color(0xFF4A5C7A) : AppColors.inputIcon,
      size: 40,
    ),
  );
}

class _MiniChip extends StatelessWidget {
  const _MiniChip({
    required this.icon,
    required this.label,
    required this.bg,
    required this.tc,
  });
  final IconData icon;
  final String label;
  final Color bg, tc;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(7),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: tc, size: 11),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: tc,
            fontSize: 10,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─── Filter Bottom Sheet ──────────────────────────────────────────────────────
class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.controller, required this.dark});
  final PropertiesController controller;
  final bool dark;
  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late String _type, _bhk, _city, _sort;
  RangeValues _priceRange = const RangeValues(0, 50000000);
  bool _priceSet = false;

  static const _types = ['', 'House', 'Apartment', 'Villa', 'Office', 'Land'];
  static const _bhks = ['', '1BHK', '2BHK', '3BHK', '4BHK', '4+BHK'];
  static const _sorts = [
    ('newest', 'Newest First'),
    ('price_asc', 'Price: Low to High'),
    ('price_desc', 'Price: High to Low'),
    ('area_asc', 'Area: Smallest First'),
  ];

  @override
  void initState() {
    super.initState();
    final c = widget.controller;
    _type = c.selType.value;
    _bhk = c.selBhk.value;
    _city = c.selCity.value;
    _sort = c.sortBy.value;
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
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
    final sectionBg = dark ? const Color(0xFF0A0F1E) : const Color(0xFFF4F7FF);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.88,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: dark
            ? const Border(top: BorderSide(color: Color(0xFF1A2B45)))
            : null,
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
                      'Filters',
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
                          _sort = 'newest';
                          _priceRange = const RangeValues(0, 50000000);
                          _priceSet = false;
                        });
                      },
                      child: Text(
                        'Reset',
                        style: TextStyle(
                          color: AppColors.accent,
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
          const SizedBox(height: 4),
          Divider(color: border, height: 1),

          // Scrollable content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Sort ──────────────────────────────────────────────────────
                  _SheetSection(
                    title: 'Sort By',
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
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: active
                                  ? AppColors.accent.withOpacity(
                                      dark ? 0.2 : 0.1,
                                    )
                                  : sectionBg,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: active
                                    ? AppColors.accent.withOpacity(0.45)
                                    : border,
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    s.$2,
                                    style: TextStyle(
                                      color: active ? AppColors.accent : tp,
                                      fontSize: 13,
                                      fontWeight: active
                                          ? FontWeight.w700
                                          : FontWeight.w500,
                                    ),
                                  ),
                                ),
                                if (active)
                                  const Icon(
                                    Icons.check_rounded,
                                    color: AppColors.accent,
                                    size: 18,
                                  ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Property Type ─────────────────────────────────────────────
                  _SheetSection(
                    title: 'Property Type',
                    dark: dark,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _types.map((t) {
                        final label = t.isEmpty ? 'All' : t;
                        final active = _type == t;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _type = t);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              gradient: active
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.accent,
                                        AppColors.accentLight,
                                      ],
                                    )
                                  : null,
                              color: active ? null : sectionBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? Colors.transparent : border,
                              ),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(
                                          0.35,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: active ? Colors.white : tp,
                                fontSize: 13,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── BHK ───────────────────────────────────────────────────────
                  _SheetSection(
                    title: 'BHK',
                    dark: dark,
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _bhks.map((b) {
                        final label = b.isEmpty ? 'Any' : b;
                        final active = _bhk == b;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _bhk = b);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 180),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 9,
                            ),
                            decoration: BoxDecoration(
                              gradient: active
                                  ? const LinearGradient(
                                      colors: [
                                        AppColors.accent,
                                        AppColors.accentLight,
                                      ],
                                    )
                                  : null,
                              color: active ? null : sectionBg,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: active ? Colors.transparent : border,
                              ),
                              boxShadow: active
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(
                                          0.35,
                                        ),
                                        blurRadius: 8,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              label,
                              style: TextStyle(
                                color: active ? Colors.white : tp,
                                fontSize: 13,
                                fontWeight: active
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // ── Price Range ───────────────────────────────────────────────
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
                              '₹${_fmtPrice(_priceRange.start)}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            Text(
                              '₹${_fmtPrice(_priceRange.end)}',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.accent,
                            inactiveTrackColor: border,
                            thumbColor: Colors.white,
                            thumbShape: const RoundSliderThumbShape(
                              enabledThumbRadius: 10,
                              elevation: 4,
                            ),
                            overlayColor: AppColors.accent.withOpacity(0.15),
                            trackHeight: 4,
                            rangeThumbShape: const RoundRangeSliderThumbShape(
                              enabledThumbRadius: 10,
                              elevation: 4,
                            ),
                          ),
                          child: RangeSlider(
                            values: _priceRange,
                            min: 0,
                            max: 50000000,
                            divisions: 100,
                            onChanged: (v) => setState(() {
                              _priceRange = v;
                              _priceSet = true;
                            }),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '₹0',
                              style: TextStyle(color: ts, fontSize: 11),
                            ),
                            Text(
                              '₹5Cr+',
                              style: TextStyle(color: ts, fontSize: 11),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                ],
              ),
            ),
          ),

          // ── Apply button ─────────────────────────────────────────────────
          Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              0,
              20,
              MediaQuery.paddingOf(context).bottom + 20,
            ),
            child: GestureDetector(
              onTap: () {
                Get.back();
                widget.controller.applyFilters(
                  type: _type,
                  bhk: _bhk,
                  city: _city,
                  sort: _sort,
                  min: _priceSet && _priceRange.start > 0
                      ? _priceRange.start.toInt()
                      : null,
                  max: _priceSet && _priceRange.end < 50000000
                      ? _priceRange.end.toInt()
                      : null,
                );
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.5),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 5,
                      offset: const Offset(2, 6),
                    ),
                  ],
                ),
                child: const Center(
                  child: Text(
                    'Apply Filters',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
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

// ─── Empty State ──────────────────────────────────────────────────────────────
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
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? const Color(0xFF0E1626) : Colors.white,
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.15),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: const Icon(
                Icons.search_off_rounded,
                color: AppColors.accent,
                size: 36,
              ),
            ),
            const SizedBox(height: 18),
            Text(
              'No properties found',
              style: TextStyle(
                color: tp,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your filters\nor search term.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ts, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onClear,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(dark ? 0.15 : 0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                ),
                child: const Text(
                  'Clear Filters',
                  style: TextStyle(
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _IntExt on int {
  String toLocaleString() => toString().replaceAllMapped(
    RegExp(r'(\d+?)(?=(\d\d)+(\d)(?!\d))(\.\d+)?'),
    (m) => '${m[1]},',
  );
}
