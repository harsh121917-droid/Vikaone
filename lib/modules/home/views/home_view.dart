import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/property_model.dart';
import '../../../routes/app_routes.dart';
import '../controllers/main_shell_controller.dart';
import '../../wishlist/controllers/wishlist_controller.dart';

class CategoryModel {
  final String label;
  final String icon;
  const CategoryModel({required this.label, required this.icon});
}

const _categories = [
  CategoryModel(label: 'House', icon: 'assets/icons/home.png'),
  CategoryModel(label: 'Apartment', icon: 'assets/icons/apartment.png'),
  CategoryModel(label: 'Villa', icon: 'assets/icons/villa.png'),
  CategoryModel(label: 'Office', icon: 'assets/icons/office.png'),
  CategoryModel(label: 'Land', icon: 'assets/icons/land.png'),
];

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    final searchCtrl = TextEditingController();
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFEEF2FF);

      return AnnotatedRegion<SystemUiOverlayStyle>(
        value: dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
        child: Container(
          color: bg,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Hero3DHeader(greeting: _greeting(), dark: dark),
                const SizedBox(height: 20),
                _GlassSearchBar(controller: searchCtrl, dark: dark),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Browse by Category',
                  onSeeAll: () {},
                  dark: dark,
                ),
                const SizedBox(height: 14),
                Obx(
                  () => _CategoryRow(
                    categories: _categories,
                    selected: controller.selectedCategory.value,
                    onTap: (i) => controller.selectedCategory.value = i,
                    dark: dark,
                  ),
                ),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Featured Properties',
                  onSeeAll: () => Get.find<MainShellController>().changeTab(1),
                  dark: dark,
                ),
                const SizedBox(height: 14),
                Obx(() {
                  if (controller.isLoading.value) {
                    return const SizedBox(
                      height: 280,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: AppColors.accent,
                        ),
                      ),
                    );
                  }
                  if (controller.featuredProps.isEmpty) {
                    return SizedBox(
                      height: 100,
                      child: Center(
                        child: Text(
                          'No properties found',
                          style: TextStyle(
                            color: dark
                                ? const Color(0xFF8A95B0)
                                : AppColors.textSecondary,
                          ),
                        ),
                      ),
                    );
                  }
                  return _FeaturedList(
                    properties: controller.featuredProps,
                    dark: dark,
                  );
                }),
                const SizedBox(height: 28),
                _SectionHeader(
                  title: 'Recommended For You',
                  onSeeAll: () {},
                  dark: dark,
                ),
                const SizedBox(height: 14),
                Obx(() {
                  if (controller.featuredProps.isEmpty) return const SizedBox();
                  return _RecommendedList(
                    properties: controller.featuredProps,
                    dark: dark,
                  );
                }),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      );
    });
  }
}

// ─── Hero ─────────────────────────────────────────────────────────────────────
class _Hero3DHeader extends StatelessWidget {
  const _Hero3DHeader({required this.greeting, required this.dark});
  final String greeting;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return SizedBox(
      height: size.height * 0.48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/hero_house.png',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, 0.2),
                  ),
                  // Dark overlay — heavier in dark mode
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: dark
                            ? [
                                const Color(0xEE060B16),
                                const Color(0xAA060B16),
                                const Color(0x661A2340),
                                Colors.transparent,
                              ]
                            : [
                                const Color(0xCC1A2340),
                                const Color(0x881A2340),
                                const Color(0x331A2340),
                                Colors.transparent,
                              ],
                        stops: const [0.0, 0.3, 0.6, 1.0],
                      ),
                    ),
                  ),
                  // Bottom fade to bg
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    height: 80,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            dark
                                ? const Color(0xFF060B16)
                                : const Color(0xFFEEF2FF),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Builder(
                        builder: (ctx) => _GlassIconButton(
                          icon: Icons.menu_rounded,
                          onTap: () => Scaffold.of(ctx).openDrawer(),
                        ),
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.3),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  color: AppColors.accent,
                                  size: 16,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'Premium Homes',
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.95),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      _GlassIconButton(
                        icon: Icons.notifications_outlined,
                        onTap: () {},
                        badge: true,
                      ),
                      const SizedBox(width: 8),
                      _GlassIconButton(
                        icon: Icons.favorite_rounded,
                        onTap: () => Get.toNamed(AppRoutes.wishlist),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    greeting,
                    style: TextStyle(
                      color: AppColors.accent.withOpacity(0.95),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Find Your\nDream Home',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.8,
                      height: 1.15,
                      shadows: [
                        Shadow(
                          color: Color(0x551A2340),
                          blurRadius: 12,
                          offset: Offset(0, 4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Let's find a perfect space\nfor you to live in.",
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.75),
                      fontSize: 13,
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 20),
                  _GlassStatsBar(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.onTap,
    this.badge = false,
  });
  final IconData icon;
  final VoidCallback onTap;
  final bool badge;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Stack(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.18),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Icon(icon, color: Colors.white, size: 22),
            ),
            if (badge)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.accent,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

class _GlassStatsBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(18),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.18),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _SI('2K+', 'Properties'),
            _VD(),
            _SI('500+', 'Happy Buyers'),
            _VD(),
            _SI('50+', 'Cities'),
          ],
        ),
      ),
    ),
  );
}

class _SI extends StatelessWidget {
  const _SI(this.v, this.l);
  final String v, l;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Text(
        v,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        l,
        style: TextStyle(
          color: Colors.white.withOpacity(0.7),
          fontSize: 10,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

class _VD extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 28, color: Colors.white.withOpacity(0.25));
}

// ─── Search Bar ───────────────────────────────────────────────────────────────
class _GlassSearchBar extends StatelessWidget {
  const _GlassSearchBar({required this.controller, required this.dark});
  final TextEditingController controller;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final fillC = dark
        ? const Color(0xFF0E1626).withOpacity(0.90)
        : Colors.white.withOpacity(0.72);
    final borderC = dark
        ? Colors.white.withOpacity(0.08)
        : Colors.white.withOpacity(0.6);
    final textC = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final hintC = dark ? const Color(0xFF4A5568) : AppColors.textHint;
    final iconC = dark ? const Color(0xFF8A95B0) : AppColors.inputIcon;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 58,
            decoration: BoxDecoration(
              color: fillC,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: borderC, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.35 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 8),
                ),
                if (!dark)
                  BoxShadow(
                    color: Colors.white.withOpacity(0.8),
                    blurRadius: 4,
                    offset: const Offset(-2, -2),
                  ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 18),
                Icon(Icons.search_rounded, color: iconC, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: controller,
                    onSubmitted: (_) =>
                        Get.find<MainShellController>().changeTab(1),
                    style: TextStyle(color: textC, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'Search location, city or area',
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
                GestureDetector(
                  onTap: () => Get.find<MainShellController>().changeTab(1),
                  child: Container(
                    margin: const EdgeInsets.all(9),
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.45),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.tune_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.onSeeAll,
    required this.dark,
  });
  final String title;
  final VoidCallback onSeeAll;
  final bool dark;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            color: dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        GestureDetector(
          onTap: onSeeAll,
          child: const Text(
            'See All',
            style: TextStyle(
              color: AppColors.accent,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    ),
  );
}

// ─── Category Row ─────────────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.selected,
    required this.onTap,
    required this.dark,
  });
  final List<CategoryModel> categories;
  final int selected;
  final ValueChanged<int> onTap;
  final bool dark;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 118,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final active = i == selected;
        final cardBg = active
            ? AppColors.primary
            : (dark ? const Color(0xFF0E1626) : Colors.white);
        final iconBg = active
            ? Colors.white.withOpacity(0.10)
            : (dark ? const Color(0xFF1A2B45) : const Color(0xFFF4F5F9));
        final labelC = active
            ? Colors.white
            : (dark ? const Color(0xFF8A95B0) : AppColors.textSecondary);
        final borderC = active
            ? Colors.transparent
            : (dark ? const Color(0xFF1A2B45) : AppColors.inputBorder);

        return GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            onTap(i);
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            width: 88,
            margin: const EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderC, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: active
                      ? AppColors.primary.withOpacity(0.35)
                      : Colors.black.withOpacity(dark ? 0.3 : 0.07),
                  blurRadius: active ? 20 : 10,
                  offset: Offset(0, active ? 8 : 3),
                ),
                if (active)
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(2, 5),
                  ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 62,
                  height: 62,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  padding: const EdgeInsets.all(6),
                  child: Container(
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: AssetImage(categories[i].icon),
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  categories[i].label,
                  style: TextStyle(
                    color: labelC,
                    fontSize: 11,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  );
}

// ─── Featured List ────────────────────────────────────────────────────────────
class _FeaturedList extends StatelessWidget {
  const _FeaturedList({required this.properties, required this.dark});
  final List<PropertyModel> properties;
  final bool dark;
  @override
  Widget build(BuildContext context) => SizedBox(
    height: 290,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      physics: const BouncingScrollPhysics(),
      itemCount: properties.length,
      itemBuilder: (_, i) => _FeaturedCard(property: properties[i], dark: dark),
    ),
  );
}

class _FeaturedCard extends StatelessWidget {
  const _FeaturedCard({required this.property, required this.dark});
  final PropertyModel property;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final chipBg = dark ? const Color(0xFF1A2B45) : AppColors.surfaceVariant;

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.propertyDetail, arguments: property.id),
      child: Container(
        width: 210,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(24),
          border: dark ? Border.all(color: const Color(0xFF1A2B45)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.45 : 0.10),
              blurRadius: 24,
              offset: const Offset(0, 8),
              spreadRadius: -3,
            ),
            if (!dark)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: property.coverImage != null
                      ? Image.network(
                          property.coverImage!,
                          height: 155,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _ph(dark),
                        )
                      : _ph(dark),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Obx(() {
                    final saved = WishlistController.to.isSaved(property.id);
                    return GestureDetector(
                      onTap: () {
                        HapticFeedback.lightImpact();
                        WishlistController.to.toggle(property);
                      },
                      child: ClipOval(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 250),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: saved
                                  ? Colors.red.withOpacity(0.85)
                                  : Colors.white.withOpacity(0.25),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: saved
                                    ? Colors.red
                                    : Colors.white.withOpacity(0.4),
                              ),
                            ),
                            child: Icon(
                              saved
                                  ? Icons.favorite_rounded
                                  : Icons.favorite_border_rounded,
                              color: Colors.white,
                              size: 17,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                if (property.featured)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withOpacity(0.85),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'Featured',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.title,
                    style: TextStyle(
                      color: textP,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        color: dark
                            ? const Color(0xFF8A95B0)
                            : AppColors.inputIcon,
                        size: 13,
                      ),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          property.location.city ?? 'India',
                          style: TextStyle(color: textS, fontSize: 12),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    property.formattedPrice,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (property.bhk != null || property.area != null)
                    Row(
                      children: [
                        if (property.bhk != null)
                          _GlassChip(
                            icon: Icons.bed_outlined,
                            label: property.bhk!,
                            dark: dark,
                            chipBg: chipBg,
                            textC: textS,
                          ),
                        if (property.bhk != null && property.area != null)
                          const SizedBox(width: 8),
                        if (property.area != null)
                          _GlassChip(
                            icon: Icons.square_foot,
                            label: '${property.area} sqft',
                            dark: dark,
                            chipBg: chipBg,
                            textC: textS,
                          ),
                      ],
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _ph(bool dark) => Container(
    height: 155,
    color: dark ? const Color(0xFF1A2B45) : AppColors.surfaceVariant,
    child: Center(
      child: Icon(
        Icons.home_outlined,
        color: dark ? const Color(0xFF4A5C7A) : AppColors.inputIcon,
        size: 40,
      ),
    ),
  );
}

class _GlassChip extends StatelessWidget {
  const _GlassChip({
    required this.icon,
    required this.label,
    required this.dark,
    required this.chipBg,
    required this.textC,
  });
  final IconData icon;
  final String label;
  final bool dark;
  final Color chipBg, textC;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    decoration: BoxDecoration(
      color: chipBg,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: textC, size: 12),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: textC,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ─── Recommended List ─────────────────────────────────────────────────────────
class _RecommendedList extends StatelessWidget {
  const _RecommendedList({required this.properties, required this.dark});
  final List<PropertyModel> properties;
  final bool dark;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Column(
      children: properties
          .take(3)
          .map((p) => _RecommendedCard(property: p, dark: dark))
          .toList(),
    ),
  );
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.property, required this.dark});
  final PropertyModel property;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final phBg = dark ? const Color(0xFF1A2B45) : AppColors.surfaceVariant;
    final phIcon = dark ? const Color(0xFF4A5C7A) : AppColors.inputIcon;

    return GestureDetector(
      onTap: () =>
          Get.toNamed(AppRoutes.propertyDetail, arguments: property.id),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        height: 110,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: dark ? Border.all(color: const Color(0xFF1A2B45)) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.40 : 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
              spreadRadius: -2,
            ),
            if (!dark)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 4,
                offset: const Offset(-2, -2),
              ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(20),
              ),
              child: SizedBox(
                width: 110,
                height: 110,
                child: property.coverImage != null
                    ? Image.network(
                        property.coverImage!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: phBg,
                          child: Icon(
                            Icons.home_outlined,
                            color: phIcon,
                            size: 32,
                          ),
                        ),
                      )
                    : Container(
                        color: phBg,
                        child: Icon(
                          Icons.home_outlined,
                          color: phIcon,
                          size: 32,
                        ),
                      ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      property.title,
                      style: TextStyle(
                        color: textP,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          color: dark
                              ? const Color(0xFF8A95B0)
                              : AppColors.inputIcon,
                          size: 12,
                        ),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            property.location.city ?? 'India',
                            style: TextStyle(color: textS, fontSize: 11),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      property.formattedPrice,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(right: 14),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(dark ? 0.2 : 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.arrow_forward_ios_rounded,
                color: AppColors.accent,
                size: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
