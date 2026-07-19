import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/property_model.dart';
import '../../../routes/app_routes.dart';

class WishlistView extends GetView<WishlistController> {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFECF0FF);

      return Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            _Header(dark: dark, ctrl: controller),
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
                if (controller.properties.isEmpty) {
                  return _EmptyState(dark: dark);
                }
                return RefreshIndicator(
                  onRefresh: controller.loadWishlist,
                  color: AppColors.accent,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    physics: const BouncingScrollPhysics(),
                    itemCount: controller.properties.length,
                    itemBuilder: (_, i) => _WishlistCard(
                      property: controller.properties[i],
                      index: i,
                      dark: dark,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────
class _Header extends StatelessWidget {
  const _Header({required this.dark, required this.ctrl});
  final bool dark;
  final WishlistController ctrl;
  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 20),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: dark ? const Color(0xFF0E1626) : Colors.white,
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(
                    color: dark
                        ? const Color(0xFF1A2B45)
                        : const Color(0xFFE2E6F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Wishlist',
                    style: TextStyle(
                      color: tp,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Obx(
                    () => Text(
                      '${ctrl.properties.length} saved propert${ctrl.properties.length == 1 ? 'y' : 'ies'}',
                      style: TextStyle(color: ts, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            // Refresh
            GestureDetector(
              onTap: ctrl.loadWishlist,
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(13),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Wishlist Card ────────────────────────────────────────────────────────────
class _WishlistCard extends StatefulWidget {
  const _WishlistCard({
    required this.property,
    required this.index,
    required this.dark,
  });
  final PropertyModel property;
  final int index;
  final bool dark;
  @override
  State<_WishlistCard> createState() => _WishlistCardState();
}

class _WishlistCardState extends State<_WishlistCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entry;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _entry = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );
    _fade = CurvedAnimation(parent: _entry, curve: Curves.easeOut);
    _slide = Tween(
      begin: const Offset(0, 0.07),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entry, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _entry.forward();
    });
  }

  @override
  void dispose() {
    _entry.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final textS = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
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
              scale: _pressed ? 0.975 : 1.0,
              duration: const Duration(milliseconds: 120),
              child: Container(
                decoration: BoxDecoration(
                  color: cardBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: dark
                        ? const Color(0xFF1A2B45)
                        : const Color(0xFFE2E6F0).withOpacity(0.5),
                  ),
                  boxShadow: _pressed
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.45 : 0.09),
                            blurRadius: 20,
                            offset: const Offset(0, 8),
                            spreadRadius: -3,
                          ),
                          if (!dark)
                            BoxShadow(
                              color: Colors.white.withOpacity(0.9),
                              blurRadius: 4,
                              offset: const Offset(-2, -2),
                            ),
                        ],
                ),
                child: Row(
                  children: [
                    // Image
                    ClipRRect(
                      borderRadius: const BorderRadius.horizontal(
                        left: Radius.circular(20),
                      ),
                      child: Stack(
                        children: [
                          SizedBox(
                            width: 110,
                            height: 110,
                            child: p.coverImage != null
                                ? Image.network(
                                    p.coverImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => _ph(dark),
                                  )
                                : _ph(dark),
                          ),
                          // Featured badge
                          if (p.featured)
                            Positioned(
                              top: 8,
                              left: 8,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 7,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.accent,
                                  borderRadius: BorderRadius.circular(8),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.4),
                                      blurRadius: 6,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  'Featured',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(14, 14, 10, 14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              p.title,
                              style: TextStyle(
                                color: textP,
                                fontSize: 14,
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
                                    p.location.city ?? 'India',
                                    style: TextStyle(
                                      color: textS,
                                      fontSize: 11,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              p.formattedPrice,
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (p.bhk != null || p.area != null) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  if (p.bhk != null)
                                    _InfoChip(
                                      label: p.bhk!,
                                      icon: Icons.bed_outlined,
                                      dark: dark,
                                    ),
                                  if (p.bhk != null && p.area != null)
                                    const SizedBox(width: 6),
                                  if (p.area != null)
                                    _InfoChip(
                                      label: '${p.area} sqft',
                                      icon: Icons.square_foot,
                                      dark: dark,
                                    ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),

                    // Remove button
                    Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: GestureDetector(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          WishlistController.to.toggle(p);
                        },
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(dark ? 0.15 : 0.08),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.red.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.15),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.favorite_rounded,
                            color: Colors.red,
                            size: 18,
                          ),
                        ),
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
    width: 110,
    height: 110,
    color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0F2F8),
    child: Icon(
      Icons.home_outlined,
      color: dark ? const Color(0xFF4A5C7A) : AppColors.inputIcon,
      size: 32,
    ),
  );
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({
    required this.label,
    required this.icon,
    required this.dark,
  });
  final String label;
  final IconData icon;
  final bool dark;
  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF1A2B45) : const Color(0xFFF0F2F8);
    final tc = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    return Container(
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
}

// ─── Empty State ──────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.dark});
  final bool dark;
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
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: dark ? const Color(0xFF0E1626) : Colors.white,
                border: Border.all(color: Colors.red.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.15),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_outline_rounded,
                color: Colors.red,
                size: 38,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'No Saved Properties',
              style: TextStyle(
                color: tp,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the heart icon on any property\nto save it here for later.',
              textAlign: TextAlign.center,
              style: TextStyle(color: ts, fontSize: 13, height: 1.5),
            ),
            const SizedBox(height: 26),
            GestureDetector(
              onTap: () => Get.back(),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.45),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(2, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.search_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Browse Properties',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
