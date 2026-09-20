import '../../properties/controllers/properties_controller.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../data/models/home_video_model.dart';
import 'dart:async';
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
                  onSeeAll: () {
                    final propCtrl = Get.isRegistered<PropertiesController>()
                        ? Get.find<PropertiesController>()
                        : Get.put(PropertiesController());
                    propCtrl.clearFilters();
                    controller.selectedCategory.value = -1;
                    if (Get.isRegistered<MainShellController>()) {
                      Get.find<MainShellController>().changeTab(1);
                    } else {
                      Get.toNamed(AppRoutes.properties);
                    }
                  },
                  dark: dark,
                ),
                const SizedBox(height: 14),
                Obx(
                  () => _CategoryRow(
                    categories: _categories,
                    selected: controller.selectedCategory.value,
                    onTap: (i) {
                      controller.selectedCategory.value = i;
                      final catName = _categories[i].label;
                      final propCtrl = Get.isRegistered<PropertiesController>()
                          ? Get.find<PropertiesController>()
                          : Get.put(PropertiesController());
                      propCtrl.filterByCategory(catName);
                      if (Get.isRegistered<MainShellController>()) {
                        Get.find<MainShellController>().changeTab(1);
                      } else {
                        Get.toNamed(AppRoutes.properties);
                      }
                    },
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
                const SizedBox(height: 28),
                // ── YouTube Video Spotlights & Tours Slider ──
                _HomeVideoSliderSection(controller: controller, dark: dark),
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
                const SizedBox(height: 32),

                // ── How It Works (Interactive Partnership Calculator) ──
                _HowItWorksSection(dark: dark),
                const SizedBox(height: 32),

                // ── Institutional & Banking Partners Strip ───────────────────
                _PartnershipTrustStrip(dark: dark),
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

                // Dark gradient scrim for badge legibility
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black.withOpacity(0.55),
                          Colors.transparent,
                          Colors.black.withOpacity(0.25),
                        ],
                        stops: const [0.0, 0.45, 1.0],
                      ),
                    ),
                  ),
                ),

                // Top Left Badges (Featured + Purchase Mode) - constrained to not overlap with Wishlist
                Positioned(
                  top: 10,
                  left: 10,
                  right: 52, // Guarantees 0 overlap with the 34px wishlist button on top-right
                  child: Wrap(
                    spacing: 5,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (property.featured)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3.5,
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFD97706), Color(0xFFF59E0B)],
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFF59E0B).withOpacity(0.4),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Text(
                                '★ FEATURED',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 8.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.4,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 3.5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.78),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: property.isDirectBuyOnly
                                    ? const Color(0xFF818CF8)
                                    : (property.isBricksOnly
                                        ? const Color(0xFF34D399)
                                        : AppColors.accent),
                                width: 0.9,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  property.isDirectBuyOnly
                                      ? Icons.business_rounded
                                      : (property.isBricksOnly
                                          ? Icons.grid_view_rounded
                                          : Icons.stars_rounded),
                                  color: property.isDirectBuyOnly
                                      ? const Color(0xFF818CF8)
                                      : (property.isBricksOnly
                                          ? const Color(0xFF34D399)
                                          : AppColors.accent),
                                  size: 10.5,
                                ),
                                const SizedBox(width: 3.5),
                                Text(
                                  property.isDirectBuyOnly
                                      ? 'Direct Buy'
                                      : (property.isBricksOnly
                                          ? 'Bricks'
                                          : 'Bricks + Buy'),
                                  style: TextStyle(
                                    color: property.isDirectBuyOnly
                                        ? const Color(0xFFC7D2FE)
                                        : (property.isBricksOnly
                                            ? const Color(0xFFA7F3D0)
                                            : const Color(0xFFFDE68A)),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Top Right: Frosted Wishlist Favorite Button
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
                                  : Colors.black.withOpacity(0.4),
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
            Stack(
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
                Positioned(
                  bottom: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2.5,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.75),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: property.isDirectBuyOnly
                            ? const Color(0xFF818CF8)
                            : (property.isBricksOnly
                                ? const Color(0xFF34D399)
                                : AppColors.accent),
                        width: 0.8,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          property.isDirectBuyOnly
                              ? Icons.business_rounded
                              : (property.isBricksOnly
                                  ? Icons.grid_view_rounded
                                  : Icons.stars_rounded),
                          color: property.isDirectBuyOnly
                              ? const Color(0xFF818CF8)
                              : (property.isBricksOnly
                                  ? const Color(0xFF34D399)
                                  : AppColors.accent),
                          size: 10,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          property.isDirectBuyOnly
                              ? 'Direct Buy'
                              : (property.isBricksOnly
                                  ? 'Bricks Only'
                                  : 'Bricks + Direct'),
                          style: TextStyle(
                            color: property.isDirectBuyOnly
                                ? const Color(0xFFC7D2FE)
                                : (property.isBricksOnly
                                    ? const Color(0xFFA7F3D0)
                                    : const Color(0xFFFDE68A)),
                            fontSize: 8.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
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


// ══════════════════════════════════════════════════════════════════════
// How It Works — Interactive Fractional Real Estate Partnership Calculator
// ══════════════════════════════════════════════════════════════════════
class _HowItWorksSection extends StatefulWidget {
  final bool dark;
  const _HowItWorksSection({required this.dark});

  @override
  State<_HowItWorksSection> createState() => _HowItWorksSectionState();
}

class _HowItWorksSectionState extends State<_HowItWorksSection> {
  double _investAmount = 100000;
  final double _propertyPrice = 10000000; // ₹1,00,00,000

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final double partnershipPercent = (_investAmount / _propertyPrice) * 100;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'How it works',
                style: TextStyle(
                  color: textP,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'FRACTIONAL LLP',
                  style: TextStyle(
                    color: Color(0xFF10B981),
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: borderC),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.35 : 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            padding: const EdgeInsets.all(22),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top "You get X.XX% partnership"
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      'You get ',
                      style: TextStyle(
                        color: textS,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '${partnershipPercent.toStringAsFixed(2)}%',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Text(
                      ' partnership',
                      style: TextStyle(
                        color: textS,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // Split: You invest | Property price
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'You invest',
                            style: TextStyle(
                              color: textS,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹${_investAmount.toInt().toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}',
                            style: TextStyle(
                              color: textP,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 38,
                      color: borderC,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Property price',
                            style: TextStyle(
                              color: textS,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '₹1,00,00,000',
                            style: TextStyle(
                              color: textP,
                              fontSize: 19,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Text(
                  'Your partnership = Investment amount ÷ Property price',
                  style: TextStyle(
                    color: textS.withOpacity(0.85),
                    fontSize: 11.5,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 14),

                // Interactive slider
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: const Color(0xFF10B981),
                    inactiveTrackColor: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    thumbColor: dark ? Colors.white : const Color(0xFF0E1626),
                    overlayColor: const Color(0xFF10B981).withOpacity(0.18),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
                    trackHeight: 4,
                  ),
                  child: Slider(
                    value: _investAmount,
                    min: 10000,
                    max: 1000000,
                    divisions: 99,
                    onChanged: (val) {
                      setState(() {
                        _investAmount = val;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 16),
                Divider(color: borderC, height: 1),
                const SizedBox(height: 18),

                // 3-step vertical timeline
                _TimelineStep(
                  number: '1',
                  title: 'Vikaone Realty Series LLP',
                  subtitle: 'holds the title of the property',
                  dark: dark,
                  isLast: false,
                ),
                _TimelineStep(
                  number: '2',
                  title: 'You get ${partnershipPercent.toStringAsFixed(2)}% partnership in this LLP',
                  subtitle: 'Based on your investment contribution',
                  dark: dark,
                  isLast: false,
                ),
                _TimelineStep(
                  number: '3',
                  title: 'Your partnership is filed in MCA',
                  subtitle: 'Vikaone does the filing on your behalf every quarter',
                  dark: dark,
                  isLast: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineStep extends StatelessWidget {
  final String number;
  final String title;
  final String subtitle;
  final bool dark;
  final bool isLast;

  const _TimelineStep({
    required this.number,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final dotBg = dark ? const Color(0xFF1E293B) : const Color(0xFFE6F4EA);
    const dotText = Color(0xFF10B981);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: dotBg,
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: const TextStyle(
                    color: dotText,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 1.5,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textP,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textS,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════════
// Institutional & Banking Partners Strip (DigiLocker, RBL, Razorpay, IDFC, Central Bank)
// ══════════════════════════════════════════════════════════════════════
class _PartnershipTrustStrip extends StatefulWidget {
  final bool dark;
  const _PartnershipTrustStrip({required this.dark});

  @override
  State<_PartnershipTrustStrip> createState() => _PartnershipTrustStripState();
}

class _PartnershipTrustStripState extends State<_PartnershipTrustStrip> {
  late final ScrollController _scrollController;
  Timer? _autoScrollTimer;
  bool _isUserInteracting = false;

  final List<_PartnerBadge> _basePartners = [
    _PartnerBadge(
      name: 'Razorpay',
      imagePath: 'assets/images/partners/razorpay.webp',
      desc: 'Escrow Payment Gateway',
      isAsset: true,
    ),
    _PartnerBadge(
      name: 'Central Bank',
      imagePath: 'assets/images/partners/central_bank.jpg',
      desc: 'Institutional Banking Partner',
      isAsset: true,
    ),
    _PartnerBadge(
      name: 'ICICI Bank',
      imagePath: 'assets/images/partners/icici_mutual.jpg',
      desc: 'Trustee Escrow Services',
      isAsset: true,
    ),
    _PartnerBadge(
      name: 'DigiLocker',
      desc: 'Govt. Verified Document Vault',
      icon: Icons.folder_shared_rounded,
      iconColor: const Color(0xFF4F46E5),
    ),
    _PartnerBadge(
      name: 'Universal Trusteeship',
      desc: 'SEBI Registered Custodian',
      icon: Icons.assured_workload_rounded,
      iconColor: const Color(0xFFD97706),
    ),
    _PartnerBadge(
      name: 'RBL Bank',
      desc: 'Banking Escrow & Clearing',
      icon: Icons.account_balance_rounded,
      iconColor: const Color(0xFFDC2626),
    ),
    _PartnerBadge(
      name: 'SEBI Securities',
      imagePath: 'assets/images/partners/SEBI_securities.png',
      desc: 'Regulatory Investor Protection',
      isAsset: true,
    ),
    _PartnerBadge(
      name: 'NSE / BSE',
      imagePath: 'assets/images/partners/NSE.png',
      desc: 'Securities & Market Custody',
      isAsset: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAutoScroll();
    });
  }

  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!_scrollController.hasClients || _isUserInteracting) return;
      final max = _scrollController.position.maxScrollExtent;
      final current = _scrollController.offset;
      if (current >= max - 2) {
        _scrollController.jumpTo(0);
      } else {
        _scrollController.jumpTo(current + 1.0);
      }
    });
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textP = widget.dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = widget.dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final cardBg = widget.dark ? const Color(0xFF0E1626) : Colors.white;
    final borderC = widget.dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    // Repeat items to allow smooth continuous scrolling without sudden bounds
    final repeatedPartners = [
      ..._basePartners,
      ..._basePartners,
      ..._basePartners,
      ..._basePartners,
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF3B82F6).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.verified_user_rounded,
                  color: Color(0xFF3B82F6),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Institutional & Banking Partners',
                style: TextStyle(
                  color: textP,
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Your investments are backed by institutional custodians, trustees, and regulated banks.',
            style: TextStyle(
              color: textS,
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 14),
          Listener(
            onPointerDown: (_) => setState(() => _isUserInteracting = true),
            onPointerUp: (_) => setState(() => _isUserInteracting = false),
            onPointerCancel: (_) => setState(() => _isUserInteracting = false),
            child: SizedBox(
              height: 72,
              child: ListView.separated(
                controller: _scrollController,
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: repeatedPartners.length,
                separatorBuilder: (_, ___) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final p = repeatedPartners[index];
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: cardBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderC),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(widget.dark ? 0.2 : 0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (p.isAsset && p.imagePath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: Image.asset(
                              p.imagePath!,
                              height: 36,
                              width: 52,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Icon(
                                Icons.account_balance_rounded,
                                color: Color(0xFF3B82F6),
                                size: 26,
                              ),
                            ),
                          )
                        else
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: (p.iconColor ?? const Color(0xFF3B82F6)).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              p.icon ?? Icons.account_balance_rounded,
                              color: p.iconColor ?? const Color(0xFF3B82F6),
                              size: 20,
                            ),
                          ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.name,
                              style: TextStyle(
                                color: textP,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              p.desc,
                              style: TextStyle(
                                color: textS,
                                fontSize: 10.5,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PartnerBadge {
  final String name;
  final String desc;
  final String? imagePath;
  final IconData? icon;
  final Color? iconColor;
  final bool isAsset;

  _PartnerBadge({
    required this.name,
    required this.desc,
    this.imagePath,
    this.icon,
    this.iconColor,
    this.isAsset = false,
  });
}


// ═════════════════════════════════════════════════════════════════════════════
// ── HOME YOUTUBE VIDEO SLIDER (AUTO-SLIDING & MANUAL SWIPE CAROUSEL) ─────────
// ═════════════════════════════════════════════════════════════════════════════

class _HomeVideoSliderSection extends StatelessWidget {
  final HomeController controller;
  final bool dark;

  const _HomeVideoSliderSection({
    required this.controller,
    required this.dark,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isVideosLoading.value && controller.homeVideos.isEmpty) {
        return Container(
          height: 220,
          margin: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: dark ? const Color(0xFF0D1527) : const Color(0xFFE2E8F0),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              color: Color(0xFFEF4444),
              strokeWidth: 2.5,
            ),
          ),
        );
      }

      final videos = controller.homeVideos;
      if (videos.isEmpty) {
        return const SizedBox.shrink();
      }

      final currentIndex = controller.currentVideoIndex.value;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Section Header ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: const Color(0xFFEF4444).withOpacity(0.35),
                      width: 1,
                    ),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Color(0xFFEF4444),
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Video Tours',
                        style: TextStyle(
                          color: dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A),
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Watch 4K project showcases & walkthroughs',
                        style: TextStyle(
                          color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Counter pill
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Text(
                    '${currentIndex + 1} / ${videos.length}',
                    style: TextStyle(
                      color: dark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // ── Auto-sliding & Manual Swipe PageView ──
          NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification is ScrollStartNotification) {
                controller.pauseAutoSlide();
              } else if (notification is ScrollEndNotification) {
                controller.resumeAutoSlide();
              }
              return false;
            },
            child: SizedBox(
              height: 220,
              child: PageView.builder(
                controller: controller.videoPageController,
                itemCount: videos.length,
                onPageChanged: controller.onVideoPageChanged,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final video = videos[index];
                  return _HomeVideoCard(
                    video: video,
                    dark: dark,
                    onPlaybackStateChange: (isPlaying) {
                      controller.setVideoPlaying(isPlaying);
                    },
                  );
                },
              ),
            ),
          ),

          const SizedBox(height: 12),

          // ── Bottom Navigation Row: Dots + Manual Controls ──
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                // Animated indicator dots
                Row(
                  children: List.generate(videos.length, (idx) {
                    final isActive = idx == currentIndex;
                    return GestureDetector(
                      onTap: () {
                        controller.videoPageController?.animateToPage(
                          idx,
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeInOut,
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.only(right: 6),
                        width: isActive ? 22 : 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: isActive
                              ? const Color(0xFFEF4444)
                              : (dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    );
                  }),
                ),
                const Spacer(),
                // Manual prev / next arrows
                GestureDetector(
                  onTap: () => controller.prevVideo(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: dark ? Colors.white70 : const Color(0xFF334155),
                      size: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => controller.nextVideo(),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                      ),
                    ),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: dark ? Colors.white70 : const Color(0xFF334155),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }
}

// ── Individual Video Slide Card ───────────────────────────────────────────────
class _HomeVideoCard extends StatefulWidget {
  final HomeVideoModel video;
  final bool dark;
  final ValueChanged<bool> onPlaybackStateChange;

  const _HomeVideoCard({
    required this.video,
    required this.dark,
    required this.onPlaybackStateChange,
  });

  @override
  State<_HomeVideoCard> createState() => _HomeVideoCardState();
}

class _HomeVideoCardState extends State<_HomeVideoCard> {
  YoutubePlayerController? _controller;
  bool _isPlaying = false;
  bool _isReady = false;
  bool _isFullScreenOpen = false;
  int _lastExitTime = 0;

  @override
  void dispose() {
    _controller?.close();
    super.dispose();
  }

  void _startInlinePlayback() async {
    widget.onPlaybackStateChange(true);
    setState(() {
      _isPlaying = true;
    });

    if (_controller == null) {
      _controller = YoutubePlayerController(
        params: const YoutubePlayerParams(
          showControls: true,
          showFullscreenButton: true,
          mute: false,
          showVideoAnnotations: false,
          enableCaption: false,
          playsInline: true,
          strictRelatedVideos: true,
        ),
      );

      _controller!.setFullScreenListener((isFullscreen) {
        final now = DateTime.now().millisecondsSinceEpoch;
        if (isFullscreen) {
          if (!_isFullScreenOpen && (now - _lastExitTime >= 2500) && mounted) {
            _openFullScreenMode();
          } else {
            _controller?.exitFullScreen();
          }
        }
      });

      try {
        await _controller!.initWithParams(params: _controller!.params);
        final cleanId = widget.video.youtubeVideoId.trim();
        await _controller!.loadVideoById(videoId: cleanId);
        await _controller!.playVideo();
        if (mounted) {
          setState(() => _isReady = true);
        }
      } catch (e) {
        debugPrint('Error starting home YouTube video inline playback: $e');
      }
    } else {
      await _controller!.playVideo();
    }
  }

  Future<void> _openFullScreenMode() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_isFullScreenOpen || (now - _lastExitTime < 2500) || !mounted) return;
    _isFullScreenOpen = true;
    widget.onPlaybackStateChange(true);

    double currentPos = 0.0;
    try {
      if (_isPlaying && _controller != null) {
        currentPos = await _controller!.currentTime;
        await _controller!.pauseVideo();
      }
    } catch (_) {}

    if (!mounted) {
      _isFullScreenOpen = false;
      return;
    }

    final returnPos = await Navigator.of(context).push<double>(
      MaterialPageRoute(
        builder: (context) => _HomeVideoFullScreenPage(
          videoId: widget.video.youtubeVideoId.trim(),
          title: widget.video.title,
          startSeconds: currentPos,
        ),
      ),
    );

    _lastExitTime = DateTime.now().millisecondsSinceEpoch;
    _isFullScreenOpen = false;

    if (mounted) {
      _controller?.exitFullScreen();
      setState(() {
        _isPlaying = true;
      });
      if (returnPos != null && returnPos > 0 && _controller != null) {
        try {
          await _controller!.seekTo(seconds: returnPos);
          await _controller!.playVideo();
        } catch (_) {}
      }
    }
  }

  Future<void> _openExternalYouTube() async {
    final cleanId = widget.video.youtubeVideoId.trim();
    final uri = Uri.parse('https://www.youtube.com/watch?v=$cleanId');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(uri);
      }
    } catch (e) {
      debugPrint('Could not launch YouTube: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF0B111E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: widget.dark ? const Color(0xFF1E2E4A) : const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(widget.dark ? 0.45 : 0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Player or Thumbnail Cover
          if (_isPlaying && _controller != null)
            Stack(
              fit: StackFit.expand,
              children: [
                WebViewWidget(controller: _controller!.webViewController),
                if (!_isReady)
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                        strokeWidth: 2.5,
                      ),
                    ),
                  ),
              ],
            )
          else
            _buildThumbnailCover(),

          // Overlays when not playing
          if (!_isPlaying) ...[
            // Top row: Spotlight badge & Fullscreen button
            PositionBar(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFEF4444), Color(0xFFB91C1C)],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFEF4444).withOpacity(0.4),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.ondemand_video_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'DRX TOUR',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: _openExternalYouTube,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.open_in_new_rounded,
                            color: Colors.white,
                            size: 14,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: _openFullScreenMode,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.6),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Icon(
                            Icons.fullscreen_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Large Center Play Button
            Center(
              child: GestureDetector(
                onTap: _startInlinePlayback,
                child: Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFEF4444), Color(0xFFDC2626)],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFEF4444).withOpacity(0.55),
                        blurRadius: 20,
                        spreadRadius: 2,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Title & Subtitle Card
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 20, 14, 12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.85),
                      Colors.black.withOpacity(0.96),
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.video.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.2,
                        shadows: [
                          Shadow(blurRadius: 6, color: Colors.black),
                        ],
                      ),
                    ),
                    if (widget.video.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 2),
                      Text(
                        widget.video.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.75),
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildThumbnailCover() {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          widget.video.effectiveThumbnail,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Container(
            color: const Color(0xFF0F172A),
            child: const Center(
              child: Icon(Icons.video_library_rounded, color: Colors.white38, size: 42),
            ),
          ),
        ),
        // Dark translucent scrim
        Container(
          color: Colors.black.withOpacity(0.35),
        ),
      ],
    );
  }
}

class PositionBar extends StatelessWidget {
  final Widget child;
  const PositionBar({required this.child, super.key});

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 12,
      left: 12,
      right: 12,
      child: child,
    );
  }
}

// ── Full-Screen Landscape Player Page for Home Videos ─────────────────────────
class _HomeVideoFullScreenPage extends StatefulWidget {
  final String videoId;
  final String title;
  final double startSeconds;

  const _HomeVideoFullScreenPage({
    required this.videoId,
    required this.title,
    this.startSeconds = 0.0,
  });

  @override
  State<_HomeVideoFullScreenPage> createState() => _HomeVideoFullScreenPageState();
}

class _HomeVideoFullScreenPageState extends State<_HomeVideoFullScreenPage> {
  late final YoutubePlayerController _fsController;
  bool _isExiting = false;
  bool _isFsReady = false;

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    _fsController = YoutubePlayerController(
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        showVideoAnnotations: false,
        enableCaption: false,
        playsInline: true,
        strictRelatedVideos: true,
      ),
    );

    _fsController.setFullScreenListener((isFullscreen) {
      if (!isFullscreen && !_isExiting && mounted) {
        _exitFullscreen();
      }
    });

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _fsController.initWithParams(params: _fsController.params);
      final cleanId = widget.videoId.trim();
      if (widget.startSeconds > 0) {
        await _fsController.loadVideoById(
          videoId: cleanId,
          startSeconds: widget.startSeconds,
        );
      } else {
        await _fsController.loadVideoById(videoId: cleanId);
      }
      await _fsController.playVideo();
      if (mounted) {
        setState(() => _isFsReady = true);
      }
    } catch (e) {
      debugPrint('Error initializing fullscreen YouTube player: $e');
    }
  }

  Future<void> _exitFullscreen() async {
    if (_isExiting) return;
    _isExiting = true;

    double pos = widget.startSeconds;
    try {
      pos = await _fsController.currentTime;
      await _fsController.pauseVideo();
    } catch (_) {}

    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    await Future.delayed(const Duration(milliseconds: 120));

    if (mounted) {
      Navigator.of(context).pop(pos);
    }
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _fsController.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isExiting) {
          _exitFullscreen();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            Center(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: WebViewWidget(
                  controller: _fsController.webViewController,
                ),
              ),
            ),
            if (!_isFsReady)
              Container(
                color: Colors.black,
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                  ),
                ),
              ),
            SafeArea(
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black87,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.black54,
                          padding: const EdgeInsets.all(8),
                        ),
                        tooltip: 'Exit Fullscreen',
                        onPressed: _exitFullscreen,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          widget.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(blurRadius: 6, color: Colors.black),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: _exitFullscreen,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white24),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.fullscreen_exit_rounded, color: Colors.white, size: 18),
                              SizedBox(width: 4),
                              Text(
                                'Exit Fullscreen',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
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
