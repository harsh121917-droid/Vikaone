import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_detail_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/property_model.dart';

class PropertyDetailView extends GetView<PropertyDetailController> {
  const PropertyDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? DarkColors.background : AppColors.background;
      final p = controller.property.value;

      return Scaffold(
        backgroundColor: bg,
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.accent),
            );
          }
          if (controller.errorMsg.value.isNotEmpty) {
            return _ErrorState(msg: controller.errorMsg.value, dark: dark);
          }
          if (p == null) return const SizedBox.shrink();
          return _PropertyContent(property: p, dark: dark);
        }),
        bottomNavigationBar: (p != null && p.investmentEnabled)
            ? _PropertyStickyBottomBar(
                property: p,
                dark: dark,
                controller: controller,
              )
            : null,
      );
    });
  }
}

class _PropertyContent extends GetView<PropertyDetailController> {
  const _PropertyContent({required this.property, required this.dark});
  final PropertyModel property;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final bg = dark ? DarkColors.background : AppColors.background;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverAppBar(
          expandedHeight: 340,
          pinned: true,
          backgroundColor: dark ? DarkColors.primary : AppColors.primary,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.25)),
              ),
              child: ClipOval(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
          flexibleSpace: FlexibleSpaceBar(
            background: _GallerySection(property: property),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: bg,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── 1. Hero Overview Card ──────────────────────────────
                  _ThemedCard(
                    dark: dark,
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  property.title,
                                  style: TextStyle(
                                    color: textP,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: -0.3,
                                    height: 1.25,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    property.formattedPrice,
                                    style: const TextStyle(
                                      color: AppColors.accent,
                                      fontSize: 20,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  Text(
                                    property.isDirectBuyOnly
                                        ? 'Full Valuation'
                                        : 'Asset Valuation',
                                    style: TextStyle(
                                      color: textS,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),

                          // Location row
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_rounded,
                                color: AppColors.accent,
                                size: 16,
                              ),
                              const SizedBox(width: 5),
                              Expanded(
                                child: Text(
                                  property.location.display.isNotEmpty
                                      ? property.location.display
                                      : (property.location.city ?? 'India'),
                                  style: TextStyle(
                                    color: textS,
                                    fontSize: 13,
                                    height: 1.3,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),

                          // Specs chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                if (property.bhk != null) ...[
                                  _SpecBadge(
                                    icon: Icons.bed_outlined,
                                    label: property.bhk!,
                                    dark: dark,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (property.area != null) ...[
                                  _SpecBadge(
                                    icon: Icons.square_foot,
                                    label: '${property.area} sqft',
                                    dark: dark,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                if (property.propertyType != null) ...[
                                  _SpecBadge(
                                    icon: Icons.apartment_outlined,
                                    label: property.propertyType!,
                                    dark: dark,
                                  ),
                                  const SizedBox(width: 8),
                                ],
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 9,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(
                                      0xFF10B981,
                                    ).withOpacity(dark ? 0.2 : 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: const Color(
                                        0xFF10B981,
                                      ).withOpacity(0.3),
                                    ),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_rounded,
                                        color: Color(0xFF10B981),
                                        size: 12,
                                      ),
                                      SizedBox(width: 4),
                                      Text(
                                        'Verified Asset',
                                        style: TextStyle(
                                          color: Color(0xFF10B981),
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),

                  // ── 2. Financial Highlights Grid ────────────────────────
                  _FinancialHighlightsGrid(property: property, dark: dark),
                  const SizedBox(height: 18),

                  // ── 3. Investment Returns Calculator ───────────────────
                  if (property.investmentEnabled &&
                      property.brickPrice != null) ...[
                    _InvestmentSimulator(property: property, dark: dark),
                    const SizedBox(height: 18),
                  ],

                  // ── 4. Purchase Options Card ───────────────────────────
                  if (property.investmentEnabled &&
                      property.brickPrice != null &&
                      property.totalBricks != null) ...[
                    _BricksSection(property: property, dark: dark),
                    const SizedBox(height: 18),
                  ],

                  // ── 5. About Property ──────────────────────────────────
                  if (property.description != null &&
                      property.description!.isNotEmpty) ...[
                    _ThemedCard(
                      dark: dark,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'About this Property',
                              style: TextStyle(
                                color: textP,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              property.description!,
                              style: TextStyle(
                                color: textS,
                                fontSize: 13.5,
                                height: 1.65,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── 6. Amenities ───────────────────────────────────────
                  if (property.amenities.isNotEmpty) ...[
                    _ThemedCard(
                      dark: dark,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Amenities & Features',
                              style: TextStyle(
                                color: textP,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 14),
                            _AnimatedAmenitiesGrid(
                              amenities: property.amenities,
                              dark: dark,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                  ],

                  // ── 7. Institutional Trust & Security ──────────────────
                  _InstitutionalTrustCard(dark: dark),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SpecBadge extends StatelessWidget {
  const _SpecBadge({
    required this.icon,
    required this.label,
    required this.dark,
  });

  final IconData icon;
  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF162338) : const Color(0xFFF1F4F9),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: dark ? const Color(0xFF223452) : const Color(0xFFE2E6F0),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.accent),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: dark ? DarkColors.textPrimary : AppColors.textPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Themed Card ──────────────────────────────────────────────────────────────
class _ThemedCard extends StatelessWidget {
  const _ThemedCard({required this.child, required this.dark});
  final Widget child;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    if (dark) {
      return Container(
        decoration: BoxDecoration(
          color: DarkColors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: DarkColors.inputBorder),
          // Gold shimmer top edge
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [DarkColors.surface2, DarkColors.surface],
          ),
        ),
        child: child,
      );
    }
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.85),
            Colors.white.withOpacity(0.6),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 4,
            offset: const Offset(-2, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: child,
        ),
      ),
    );
  }
}

// ─── Gallery ─────────────────────────────────────────────────────────────────
class _GallerySection extends GetView<PropertyDetailController> {
  const _GallerySection({required this.property});
  final PropertyModel property;
  List<PropertyImage> get images => property.images;

  @override
  Widget build(BuildContext context) {
    if (images.isEmpty) {
      return Container(
        color: AppColors.surfaceVariant,
        child: const Center(
          child: Icon(
            Icons.home_outlined,
            color: AppColors.inputIcon,
            size: 60,
          ),
        ),
      );
    }
    return Stack(
      children: [
        PageView.builder(
          itemCount: images.length,
          onPageChanged: controller.setImage,
          itemBuilder: (_, i) => Image.network(
            images[i].url,
            fit: BoxFit.cover,
            width: double.infinity,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.surfaceVariant,
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  color: AppColors.inputIcon,
                  size: 40,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          height: 100,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Colors.black.withOpacity(0.5), Colors.transparent],
              ),
            ),
          ),
        ),
        if (images.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Obx(
              () => Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  images.length,
                  (i) => AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: controller.currentImg.value == i ? 20 : 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: controller.currentImg.value == i
                          ? AppColors.accent
                          : Colors.white.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
            ),
          ),
        // Mode badge on image
        Positioned(
          bottom: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.8),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: property.isDirectBuyOnly
                    ? const Color(0xFF818CF8)
                    : (property.isBricksOnly
                          ? const Color(0xFF34D399)
                          : AppColors.accent),
                width: 1,
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
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  property.isDirectBuyOnly
                      ? 'Full Ownership Only'
                      : (property.isBricksOnly
                            ? 'Bricks Investment'
                            : 'Bricks + Full Buy'),
                  style: TextStyle(
                    color: property.isDirectBuyOnly
                        ? const Color(0xFFC7D2FE)
                        : (property.isBricksOnly
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFDE68A)),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 60,
          right: 16,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Obx(
                  () => Text(
                    '${controller.currentImg.value + 1}/${images.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Animated 3D Stats Row ────────────────────────────────────────────────────
class _Animated3DStatsRow extends StatefulWidget {
  const _Animated3DStatsRow({required this.property, required this.dark});
  final PropertyModel property;
  final bool dark;

  @override
  State<_Animated3DStatsRow> createState() => _Animated3DStatsRowState();
}

class _Animated3DStatsRowState extends State<_Animated3DStatsRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    Future.delayed(const Duration(milliseconds: 100), () => _ctrl.forward());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stats = <_StatItem>[
      if (widget.property.bhk != null)
        _StatItem(
          icon: Icons.bed_outlined,
          label: widget.property.bhk!,
          hint: 'BHK',
        ),
      if (widget.property.area != null)
        _StatItem(
          icon: Icons.square_foot,
          label: '${widget.property.area}',
          hint: 'Sqft',
        ),
      if (widget.property.propertyType != null)
        _StatItem(
          icon: Icons.apartment_outlined,
          label: widget.property.propertyType!,
          hint: 'Type',
        ),
    ];
    if (stats.isEmpty) return const SizedBox.shrink();

    return FadeTransition(
      opacity: _fade,
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            color: widget.dark ? DarkColors.surface : null,
            gradient: widget.dark
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.92),
                      Colors.white.withOpacity(0.72),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: widget.dark
                  ? DarkColors.inputBorder
                  : Colors.white.withOpacity(0.7),
              width: 1.5,
            ),
            boxShadow: widget.dark
                ? [
                    BoxShadow(
                      color: DarkColors.accent.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.12),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.9),
                      blurRadius: 4,
                      offset: const Offset(-2, -2),
                    ),
                  ],
          ),
          child: Row(
            children: stats
                .map(
                  (s) => Expanded(
                    child: _3DStatItem(stat: s, dark: widget.dark),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _3DStatItem extends StatefulWidget {
  const _3DStatItem({required this.stat, required this.dark});
  final _StatItem stat;
  final bool dark;
  @override
  State<_3DStatItem> createState() => _3DStatItemState();
}

class _3DStatItemState extends State<_3DStatItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textP = widget.dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = widget.dark
        ? DarkColors.textSecondary
        : AppColors.textSecondary;

    return Column(
      children: [
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Transform.scale(
            scale: 1.0 + _pulse.value * 0.06,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accent.withOpacity(0.18 + _pulse.value * 0.08),
                    AppColors.accent.withOpacity(0.04),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.25 * _pulse.value),
                    blurRadius: 14,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Icon(widget.stat.icon, color: AppColors.accent, size: 22),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.stat.label,
          style: TextStyle(
            color: textP,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(widget.stat.hint, style: TextStyle(color: textS, fontSize: 11)),
      ],
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label, hint;
  const _StatItem({
    required this.icon,
    required this.label,
    required this.hint,
  });
}

// ─── Amenities Grid ───────────────────────────────────────────────────────────
class _AnimatedAmenitiesGrid extends StatelessWidget {
  const _AnimatedAmenitiesGrid({required this.amenities, required this.dark});
  final List<String> amenities;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: List.generate(
        amenities.length,
        (i) => _AmenityChip(label: amenities[i], delay: i * 60, dark: dark),
      ),
    );
  }
}

class _AmenityChip extends StatefulWidget {
  const _AmenityChip({
    required this.label,
    required this.delay,
    required this.dark,
  });
  final String label;
  final int delay;
  final bool dark;

  @override
  State<_AmenityChip> createState() => _AmenityChipState();
}

class _AmenityChipState extends State<_AmenityChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;

    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(
        position: _slide,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: dark ? DarkColors.surface : null,
            gradient: dark
                ? null
                : LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.9),
                      AppColors.accent.withOpacity(0.05),
                    ],
                  ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.accent.withOpacity(dark ? 0.4 : 0.3),
            ),
            boxShadow: dark
                ? null
                : [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle_outline,
                color: AppColors.accent,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  color: textP,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Bricks Section ───────────────────────────────────────────────────────────
class _BricksSection extends StatefulWidget {
  const _BricksSection({required this.property, required this.dark});
  final PropertyModel property;
  final bool dark;

  @override
  State<_BricksSection> createState() => _BricksSectionState();
}

class _BricksSectionState extends State<_BricksSection>
    with SingleTickerProviderStateMixin {
  late AnimationController _progressCtrl;
  late Animation<double> _progressAnim;
  late int _selectedMode; // 0 = Fractional Bricks, 1 = Full Property Direct Buy
  int _brickQty = 1;
  late TextEditingController _qtyController;
  late FocusNode _qtyFocusNode;

  @override
  void initState() {
    super.initState();
    final avail = widget.property.availableBricks;
    _selectedMode = widget.property.isDirectBuyOnly ? 1 : 0;
    _brickQty = avail >= 5 ? 5 : (avail > 0 ? avail : 1);

    _qtyController = TextEditingController(text: '$_brickQty');
    _qtyFocusNode = FocusNode();
    _qtyFocusNode.addListener(() {
      if (!_qtyFocusNode.hasFocus) {
        final val = int.tryParse(_qtyController.text.replaceAll(',', '').trim()) ?? 1;
        _setQty(val, syncText: true);
      }
      if (mounted) setState(() {});
    });

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeOutCubic,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _progressCtrl.forward();
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _qtyFocusNode.dispose();
    _progressCtrl.dispose();
    super.dispose();
  }

  void _setQty(int q, {bool syncText = true}) {
    final avail = widget.property.availableBricks;
    if (avail <= 0) return;
    HapticFeedback.selectionClick();
    final clamped = q.clamp(1, avail);
    setState(() {
      _brickQty = clamped;
    });
    if (syncText) {
      _qtyController.text = '$clamped';
      _qtyController.selection = TextSelection.fromPosition(
        TextPosition(offset: _qtyController.text.length),
      );
    }
  }

  void _onTextChanged(String text) {
    if (text.trim().isEmpty) return;
    final val = int.tryParse(text.replaceAll(',', '').trim());
    if (val != null && val > 0) {
      final avail = widget.property.availableBricks;
      final clamped = val > avail ? avail : val;
      setState(() {
        _brickQty = clamped;
      });
      if (val > avail) {
        _qtyController.text = '$avail';
        _qtyController.selection = TextSelection.fromPosition(
          TextPosition(offset: _qtyController.text.length),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertyDetailController>();
    final dark = widget.dark;
    final sold = widget.property.soldBricks ?? 0;
    final available = widget.property.availableBricks;
    final totalBricks = widget.property.totalBricks ?? 1;
    final pct = widget.property.soldPercent;
    final brickPrice = widget.property.brickPrice ?? 0;
    final yieldRate = widget.property.expectedRentalYield;

    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final inputBg = dark ? DarkColors.inputBackground : AppColors.inputBackground;

    final allowsBoth = widget.property.allowsBricks && widget.property.allowsDirectBuy;
    final isDirectMode = _selectedMode == 1;

    // Calculations for bricks mode
    final subtotal = _brickQty * brickPrice;
    final ownershipPct = (_brickQty / totalBricks) * 100;
    final estMonthlyRent = ((subtotal * (yieldRate / 100)) / 12).round();

    // Calculations for direct buyout
    final buyoutTotal = available * brickPrice;

    return Container(
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F172A) : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDirectMode
              ? const Color(0xFF6366F1).withOpacity(dark ? 0.45 : 0.35)
              : (dark ? const Color(0xFF24334D) : const Color(0xFFE2E8F0)),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (isDirectMode ? const Color(0xFF6366F1) : (dark ? Colors.black : AppColors.accent))
                .withOpacity(dark ? 0.35 : 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Top Mode Switcher / Banner ──────────────────────────────
              if (allowsBoth) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF070C16) : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dark ? const Color(0xFF1E293B) : const Color(0xFFCBD5E1),
                    ),
                  ),
                  child: Row(
                    children: [
                      // Tab 1: Fractional Bricks
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedMode = 0);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                            decoration: BoxDecoration(
                              gradient: _selectedMode == 0
                                  ? const LinearGradient(
                                      colors: [AppColors.accent, AppColors.accentLight],
                                    )
                                  : null,
                              color: _selectedMode == 0 ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _selectedMode == 0
                                  ? [
                                      BoxShadow(
                                        color: AppColors.accent.withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.layers_rounded,
                                      size: 14,
                                      color: _selectedMode == 0 ? Colors.white : textS,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Fractional Bricks',
                                          style: TextStyle(
                                            color: _selectedMode == 0 ? Colors.white : textP,
                                            fontWeight: _selectedMode == 0 ? FontWeight.w800 : FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'From 1 Brick onwards',
                                  style: TextStyle(
                                    color: _selectedMode == 0 ? Colors.white.withOpacity(0.85) : textS,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),

                      // Tab 2: Full Property Buyout
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _selectedMode = 1);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
                            decoration: BoxDecoration(
                              color: _selectedMode == 1 ? const Color(0xFF6366F1) : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: _selectedMode == 1
                                  ? [
                                      BoxShadow(
                                        color: const Color(0xFF6366F1).withOpacity(0.4),
                                        blurRadius: 10,
                                        offset: const Offset(0, 3),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.business_rounded,
                                      size: 14,
                                      color: _selectedMode == 1 ? Colors.white : textS,
                                    ),
                                    const SizedBox(width: 5),
                                    Flexible(
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Text(
                                          'Full Buyout (100%)',
                                          style: TextStyle(
                                            color: _selectedMode == 1 ? Colors.white : textP,
                                            fontWeight: _selectedMode == 1 ? FontWeight.w800 : FontWeight.w600,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  '100% Sole Legal Title',
                                  style: TextStyle(
                                    color: _selectedMode == 1 ? Colors.white.withOpacity(0.85) : textS,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (widget.property.isDirectBuyOnly) ...[
                // Safe non-overflowing Direct Buy Only banner
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(dark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.4),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        color: Color(0xFF818CF8),
                        size: 15,
                      ),
                      SizedBox(width: 6),
                      Flexible(
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Direct Buy Only · 100% Sole Asset Purchase',
                            style: TextStyle(
                              color: Color(0xFF818CF8),
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // ════════════════════════════════════════════════════════════
              // ── DIRECT BUY VIEW ──────────────────────────────────────────
              // ════════════════════════════════════════════════════════════
              if (isDirectMode) ...[
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6366F1).withOpacity(dark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.business_rounded,
                        color: Color(0xFF818CF8),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Direct Buyout — 100% Full Ownership',
                            style: TextStyle(
                              color: textP,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Sole title deed & full rental entitlements',
                            style: TextStyle(color: textS, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),

                // 4 Pillars Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF141D2E) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: dark ? const Color(0xFF263750) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      _DirectBenefitRow(
                        icon: Icons.account_balance_rounded,
                        title: '100% Legal Title Deed',
                        desc: 'Registered directly under your PAN/entity name with SPV deed.',
                        dark: dark,
                      ),
                      const Divider(height: 18),
                      _DirectBenefitRow(
                        icon: Icons.payments_rounded,
                        title: '100% Rental Distribution',
                        desc:
                            'Full tenant payout (~₹${((buyoutTotal * (yieldRate / 100)) / 12).round().toLocaleString()}/mo) straight to your bank.',
                        dark: dark,
                      ),
                      const Divider(height: 18),
                      _DirectBenefitRow(
                        icon: Icons.trending_up_rounded,
                        title: 'Sole Capital Appreciation',
                        desc: 'You capture 100% of future property value growth with full exit control.',
                        dark: dark,
                      ),
                      const Divider(height: 18),
                      _DirectBenefitRow(
                        icon: Icons.shield_rounded,
                        title: 'Zero Shared Equity',
                        desc: 'All remaining $available bricks are transferred directly to your portfolio.',
                        dark: dark,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Valuation Box
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: dark
                          ? [const Color(0xFF1E1B4B), const Color(0xFF172554)]
                          : [const Color(0xFFEEF2FF), const Color(0xFFF0FDF4)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFF6366F1).withOpacity(0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Acquisition Cost',
                              style: TextStyle(
                                color: dark ? const Color(0xFFC7D2FE) : const Color(0xFF4338CA),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text(
                                '₹${buyoutTotal.toLocaleString()}',
                                style: const TextStyle(
                                  color: Color(0xFF6366F1),
                                  fontSize: 22,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          decoration: BoxDecoration(
                            color: const Color(0xFF10B981).withOpacity(0.18),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: const Color(0xFF10B981).withOpacity(0.4),
                            ),
                          ),
                          child: const FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '100% Ownership',
                              style: TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Direct Buy Button (Overflow Safe)
                GestureDetector(
                  onTap: available > 0
                      ? () => showDirectBuySheet(
                            context: context,
                            controller: controller,
                            property: widget.property,
                            dark: dark,
                          )
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: available > 0
                          ? const LinearGradient(
                              colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                            )
                          : null,
                      color: available <= 0 ? Colors.grey.withOpacity(0.3) : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: available > 0
                          ? [
                              BoxShadow(
                                color: const Color(0xFF6366F1).withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            available > 0 ? Icons.verified_user_rounded : Icons.lock_outline_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                available > 0 ? 'Buy Full Property (100% Ownership) →' : 'Sold Out',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Protected by Regulated Escrow & Razorpay',
                    style: TextStyle(
                      color: dark ? DarkColors.textHint : AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ),
              ] else ...[
                // ════════════════════════════════════════════════════════════
                // ── FRACTIONAL BRICKS VIEW ────────────────────────────────────
                // ════════════════════════════════════════════════════════════
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.accent.withOpacity(dark ? 0.25 : 0.15),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(
                        Icons.layers_rounded,
                        color: AppColors.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Invest in Fractional Bricks',
                            style: TextStyle(
                              color: textP,
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Own a fraction of this luxury asset from 1 brick',
                            style: TextStyle(color: textS, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Funding Progress
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${pct.toStringAsFixed(0)}% Sold ($sold / $totalBricks bricks)',
                      style: TextStyle(
                        color: textS,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$available Bricks Left',
                      style: TextStyle(
                        color: available > 0 ? AppColors.accent : const Color(0xFF10B981),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      height: 10,
                      color: inputBg,
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: ((pct / 100) * _progressAnim.value).clamp(0.0, 1.0),
                        child: Container(
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFFFFB300), DarkColors.goldLight],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // ── Pro Interactive Brick Selector (Input Box + Slider + Steppers) ──
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: dark ? const Color(0xFF141D2E) : const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: dark ? const Color(0xFF263750) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Bricks to Purchase',
                            style: TextStyle(
                              color: textS,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                            decoration: BoxDecoration(
                              color: AppColors.accent.withOpacity(dark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '₹${brickPrice.toLocaleString()} / brick',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),

                      // Stepper + Tap-To-Type Input Field
                      Row(
                        children: [
                          _StepperButton(
                            icon: Icons.remove_rounded,
                            onTap: _brickQty > 1
                                ? () => _setQty(_brickQty - 1, syncText: true)
                                : null,
                            dark: dark,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: dark ? const Color(0xFF0F172A) : Colors.white,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: _qtyFocusNode.hasFocus
                                      ? AppColors.accent
                                      : (dark ? const Color(0xFF2E4160) : const Color(0xFFCBD5E1)),
                                  width: _qtyFocusNode.hasFocus ? 1.8 : 1.2,
                                ),
                                boxShadow: [
                                  if (_qtyFocusNode.hasFocus)
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.25),
                                      blurRadius: 10,
                                      spreadRadius: 1,
                                    ),
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Flexible(
                                        child: IntrinsicWidth(
                                          child: TextField(
                                            controller: _qtyController,
                                            focusNode: _qtyFocusNode,
                                            keyboardType: TextInputType.number,
                                            inputFormatters: [
                                              FilteringTextInputFormatter.digitsOnly,
                                            ],
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              color: textP,
                                              fontSize: 26,
                                              fontWeight: FontWeight.w900,
                                              height: 1.15,
                                            ),
                                            decoration: const InputDecoration(
                                              isDense: true,
                                              contentPadding: EdgeInsets.zero,
                                              border: InputBorder.none,
                                            ),
                                            onChanged: _onTextChanged,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      Icon(
                                        Icons.edit_rounded,
                                        size: 13,
                                        color: _qtyFocusNode.hasFocus
                                            ? AppColors.accent
                                            : (dark ? Colors.white38 : Colors.black38),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _brickQty == 1 ? 'Brick · Tap to edit' : 'Bricks · Tap to edit',
                                    style: TextStyle(
                                      color: textS,
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          _StepperButton(
                            icon: Icons.add_rounded,
                            onTap: _brickQty < available
                                ? () => _setQty(_brickQty + 1, syncText: true)
                                : null,
                            dark: dark,
                          ),
                        ],
                      ),

                      // Interactive Drag Slider
                      if (available > 1) ...[
                        const SizedBox(height: 12),
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            activeTrackColor: AppColors.accent,
                            inactiveTrackColor: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                            thumbColor: AppColors.accent,
                            overlayColor: AppColors.accent.withOpacity(0.2),
                            trackHeight: 4.5,
                            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8.5),
                          ),
                          child: Slider(
                            value: _brickQty.toDouble().clamp(1.0, available.toDouble()),
                            min: 1.0,
                            max: available.toDouble(),
                            divisions: available > 1 ? (available > 100 ? 100 : available - 1) : 1,
                            onChanged: (val) {
                              _setQty(val.round(), syncText: true);
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '1 brick',
                                style: TextStyle(color: textS, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                              Text(
                                'Drag or type quantity',
                                style: TextStyle(
                                  color: AppColors.accent.withOpacity(0.85),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                '$available max',
                                style: TextStyle(color: textS, fontSize: 10, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 14),

                      // Quick Pills (+1, +5, +10, +25, +50, Max)
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _QuickPill(
                              label: '+1',
                              onTap: () => _setQty(_brickQty + 1, syncText: true),
                              dark: dark,
                            ),
                            _QuickPill(
                              label: '+5',
                              onTap: () => _setQty(_brickQty + 5, syncText: true),
                              dark: dark,
                            ),
                            _QuickPill(
                              label: '+10',
                              onTap: () => _setQty(_brickQty + 10, syncText: true),
                              dark: dark,
                            ),
                            _QuickPill(
                              label: '+25',
                              onTap: () => _setQty(_brickQty + 25, syncText: true),
                              dark: dark,
                            ),
                            _QuickPill(
                              label: '+50',
                              onTap: () => _setQty(_brickQty + 50, syncText: true),
                              dark: dark,
                            ),
                            if (available > 0)
                              _QuickPill(
                                label: 'Max ($available)',
                                isHighlight: true,
                                onTap: () => _setQty(available, syncText: true),
                                dark: dark,
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── Live Calculation Summary Strip ───────────────────────
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: dark
                          ? [const Color(0xFF1E2838), const Color(0xFF141F30)]
                          : [const Color(0xFFF8FAFC), const Color(0xFFF1F5F9)],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: dark ? const Color(0xFF2B3C56) : const Color(0xFFE2E8F0),
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Total Amount',
                              style: TextStyle(
                                color: textS,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '₹${subtotal.toLocaleString()}',
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Legal Ownership Share',
                              style: TextStyle(color: textS, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '${ownershipPct.toStringAsFixed(3)}%',
                                style: TextStyle(
                                  color: textP,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              'Est. Monthly Rental Payout',
                              style: TextStyle(color: textS, fontSize: 13),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '₹${estMonthlyRent.toLocaleString()} / mo',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Primary Buy Bricks Button
                GestureDetector(
                  onTap: available > 0
                      ? () => showBuySheet(
                            context: context,
                            controller: controller,
                            property: widget.property,
                            dark: dark,
                            initialQty: _brickQty,
                          )
                      : null,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: available > 0
                          ? const LinearGradient(
                              colors: [AppColors.accent, AppColors.accentLight],
                            )
                          : null,
                      color: available <= 0 ? Colors.grey.withOpacity(0.3) : null,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: available > 0
                          ? [
                              BoxShadow(
                                color: AppColors.accent.withOpacity(0.4),
                                blurRadius: 16,
                                offset: const Offset(0, 4),
                              ),
                            ]
                          : null,
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            available > 0 ? Icons.shopping_bag_outlined : Icons.lock_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                available > 0
                                    ? 'Buy $_brickQty Brick${_brickQty > 1 ? "s" : ""} · ₹${subtotal.toLocaleString()} →'
                                    : 'Sold Out',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Secured by Razorpay · Institutional Escrow Protection',
                    style: TextStyle(
                      color: dark ? DarkColors.textHint : AppColors.textHint,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Direct Buy Benefit Row ──────────────────────────────────────────────────
class _DirectBenefitRow extends StatelessWidget {
  const _DirectBenefitRow({
    required this.icon,
    required this.title,
    required this.desc,
    required this.dark,
  });

  final IconData icon;
  final String title, desc;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: const Color(0xFF6366F1).withOpacity(dark ? 0.25 : 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF818CF8), size: 16),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: dark ? DarkColors.textPrimary : AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(
                  color: dark ? DarkColors.textSecondary : AppColors.textSecondary,
                  fontSize: 11.5,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Stepper Button ───────────────────────────────────────────────────────────
class _StepperButton extends StatelessWidget {
  const _StepperButton({
    required this.icon,
    required this.onTap,
    required this.dark,
  });

  final IconData icon;
  final VoidCallback? onTap;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: enabled
              ? (dark ? const Color(0xFF223048) : Colors.white)
              : (dark ? const Color(0xFF141D2C) : const Color(0xFFF1F5F9)),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: dark ? const Color(0xFF2F4263) : const Color(0xFFCBD5E1),
          ),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Icon(
          icon,
          color: enabled
              ? (dark ? Colors.white : AppColors.textPrimary)
              : (dark ? Colors.white24 : Colors.black26),
          size: 22,
        ),
      ),
    );
  }
}

// ─── Quick Add Pill ───────────────────────────────────────────────────────────
class _QuickPill extends StatelessWidget {
  const _QuickPill({
    required this.label,
    required this.onTap,
    required this.dark,
    this.isHighlight = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool dark, isHighlight;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: isHighlight
                ? AppColors.accent.withOpacity(dark ? 0.25 : 0.15)
                : (dark ? const Color(0xFF1E2B40) : const Color(0xFFEEF2F7)),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isHighlight
                  ? AppColors.accent.withOpacity(0.5)
                  : (dark ? const Color(0xFF293B58) : const Color(0xFFCBD5E1)),
            ),
          ),
          child: Text(
            label,
            style: TextStyle(
              color: isHighlight
                  ? AppColors.accent
                  : (dark ? DarkColors.textPrimary : AppColors.textPrimary),
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Top-level Bottom Sheets ──────────────────────────────────────────────────
void showBuySheet({
  required BuildContext context,
  required PropertyDetailController controller,
  required PropertyModel property,
  required bool dark,
  int initialQty = 1,
}) {
  final qtyCtrl = TextEditingController(text: '$initialQty');
  final brickPrice = property.brickPrice ?? 0;
  final available = property.availableBricks;
  final agreedTerms = false.obs;

  final sheetBg = dark ? DarkColors.surface : Colors.white;
  final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
  final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;

  Get.bottomSheet(
    Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: dark
            ? const Border(top: BorderSide(color: DarkColors.inputBorder))
            : null,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? DarkColors.inputBorder : AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Buy Bricks',
              style: TextStyle(
                color: textP,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Max $available bricks available',
              style: TextStyle(color: textS, fontSize: 13),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: qtyCtrl,
              keyboardType: TextInputType.number,
              style: TextStyle(color: textP),
              decoration: InputDecoration(
                labelText: 'Number of bricks',
                hintText: '1 - $available',
                prefixIcon: const Icon(
                  Icons.grid_view_rounded,
                  color: AppColors.accent,
                ),
                filled: true,
                fillColor: dark
                    ? DarkColors.inputBackground
                    : AppColors.inputBackground,
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide(
                    color: dark
                        ? DarkColors.inputBorder
                        : AppColors.inputBorder,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: AppColors.accent,
                    width: 1.5,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder(
              valueListenable: qtyCtrl,
              builder: (_, val, __) {
                final qty = int.tryParse(val.text) ?? 0;
                final total = qty * brickPrice;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (qty > 0) ...[
                      Text(
                        'Total: ₹${total.toLocaleString()}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${((qty / (property.totalBricks ?? 1)) * 100).toStringAsFixed(2)}% ownership',
                        style: TextStyle(color: textS, fontSize: 13),
                      ),
                      const SizedBox(height: 14),
                      _ReturnsProjection(
                        principal: total,
                        appreciation: property.expectedAppreciation,
                        rentalYield: property.expectedRentalYield,
                        dark: dark,
                      ),
                    ],
                  ],
                );
              },
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF39C12).withOpacity(dark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFFF39C12).withOpacity(0.3),
                ),
              ),
              child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: agreedTerms.value,
                        onChanged: (v) => agreedTerms.value = v ?? false,
                        activeColor: AppColors.accent,
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'This is a fractional real-estate investment. Returns are estimates only. I agree to the Terms & Risk Disclosure.',
                        style: TextStyle(
                          color: textS,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final purchasing = controller.isPurchasing.value;
              final status = controller.purchaseStatus.value;
              String label = 'Proceed to Pay';
              if (status == 'creating_order') label = 'Creating order...';
              if (status == 'awaiting_payment') label = 'Opening payment...';
              if (status == 'verifying') label = 'Verifying payment...';
              return _GoldButton(
                label: purchasing ? label : 'Proceed to Pay',
                icon: Icons.payment_rounded,
                loading: purchasing,
                onPressed: purchasing
                    ? null
                    : () {
                        final qty = int.tryParse(qtyCtrl.text) ?? 0;
                        if (qty < 1 || qty > available) {
                          Get.snackbar(
                            'Invalid',
                            'Enter between 1 and $available bricks',
                            backgroundColor: AppColors.error,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        if (!agreedTerms.value) {
                          Get.snackbar(
                            'Required',
                            'Please agree to the Terms & Risk Disclosure',
                            backgroundColor: AppColors.error,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        Get.back();
                        controller.initiateBrickPurchase(qty);
                      },
              );
            }),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Secured by Razorpay',
                style: TextStyle(
                  color: dark ? DarkColors.textHint : AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

void showDirectBuySheet({
  required BuildContext context,
  required PropertyDetailController controller,
  required PropertyModel property,
  required bool dark,
}) {
  final available = property.availableBricks;
  final brickPrice = property.brickPrice ?? 0;
  final totalAmount = available * brickPrice;
  final agreedTerms = false.obs;

  final sheetBg = dark ? DarkColors.surface : Colors.white;
  final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
  final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;

  Get.bottomSheet(
    Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 32,
      ),
      decoration: BoxDecoration(
        color: sheetBg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: dark
            ? const Border(top: BorderSide(color: DarkColors.inputBorder))
            : null,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? DarkColors.inputBorder : AppColors.inputBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.business_rounded,
                    color: Color(0xFF6366F1),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Direct Buy (Full Property)',
                        style: TextStyle(
                          color: textP,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '100% Sole Ownership Acquisition',
                        style: TextStyle(color: textS, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: dark ? DarkColors.surface2 : const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: dark ? DarkColors.inputBorder : AppColors.inputBorder,
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Property',
                        style: TextStyle(color: textS, fontSize: 13),
                      ),
                      Flexible(
                        child: Text(
                          property.title,
                          style: TextStyle(
                            color: textP,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Ownership Share',
                        style: TextStyle(color: textS, fontSize: 13),
                      ),
                      const Text(
                        '100% Full Ownership',
                        style: TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Allocated Bricks',
                        style: TextStyle(color: textS, fontSize: 13),
                      ),
                      Text(
                        'All $available remaining bricks',
                        style: TextStyle(
                          color: textP,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Purchase Price',
                        style: TextStyle(
                          color: textP,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        '₹${totalAmount.toLocaleString()}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            _ReturnsProjection(
              principal: totalAmount,
              appreciation: property.expectedAppreciation,
              rentalYield: property.expectedRentalYield,
              dark: dark,
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(dark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF6366F1).withOpacity(0.3),
                ),
              ),
              child: Obx(
                () => Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: Checkbox(
                        value: agreedTerms.value,
                        onChanged: (v) => agreedTerms.value = v ?? false,
                        activeColor: const Color(0xFF6366F1),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'I confirm I am acquiring this complete property in full (Direct Buy). Upon successful transaction, 100% legal title and rental entitlement transfer to my portfolio.',
                        style: TextStyle(
                          color: textS,
                          fontSize: 11,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Obx(() {
              final purchasing = controller.isPurchasing.value;
              final status = controller.purchaseStatus.value;
              String label = 'Proceed to Buy Full Property';
              if (status == 'creating_order')
                label = 'Creating direct order...';
              if (status == 'awaiting_payment') label = 'Opening payment...';
              if (status == 'verifying') label = 'Verifying payment...';
              return _GoldButton(
                label: purchasing ? label : 'Proceed to Buy Full Property',
                icon: Icons.verified_user_rounded,
                loading: purchasing,
                onPressed: purchasing
                    ? null
                    : () {
                        if (!agreedTerms.value) {
                          Get.snackbar(
                            'Required',
                            'Please agree to the Direct Buy & Title Transfer Terms',
                            backgroundColor: AppColors.error,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        Get.back();
                        controller.initiateDirectBuy();
                      },
              );
            }),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Secured by Razorpay · 100% Title Guarantee',
                style: TextStyle(
                  color: dark ? DarkColors.textHint : AppColors.textHint,
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    ),
    isScrollControlled: true,
  );
}

// ─── Gold Press Button ────────────────────────────────────────────────────────
class _GoldButton extends StatefulWidget {
  const _GoldButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    this.loading = false,
  });
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  State<_GoldButton> createState() => _GoldButtonState();
}

class _GoldButtonState extends State<_GoldButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
    _scale = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (widget.onPressed != null) _ctrl.forward();
      },
      onTapUp: (_) {
        _ctrl.reverse();
        if (widget.onPressed != null) widget.onPressed!();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: widget.onPressed != null
                ? const LinearGradient(
                    colors: [Color(0xFFFFB347), DarkColors.goldLight],
                  )
                : null,
            color: widget.onPressed == null ? AppColors.inputBorder : null,
            boxShadow: widget.onPressed != null
                ? [
                    BoxShadow(
                      color: const Color(0xFFFF6B35).withOpacity(0.5),
                      blurRadius: 18,
                      offset: const Offset(0, 6),
                    ),
                    BoxShadow(
                      color: DarkColors.goldLight.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: widget.loading
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(widget.icon, color: Colors.white, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      widget.label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── Returns Projection ───────────────────────────────────────────────────────
class _ReturnsProjection extends StatelessWidget {
  const _ReturnsProjection({
    required this.principal,
    required this.appreciation,
    required this.rentalYield,
    required this.dark,
  });
  final int principal;
  final double appreciation, rentalYield;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final totalRate = (appreciation + rentalYield) / 100;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final textH = dark ? DarkColors.textHint : AppColors.textHint;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: dark ? DarkColors.surface2 : null,
        gradient: dark
            ? null
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF2ecc71).withOpacity(0.08),
                  Colors.white.withOpacity(0.6),
                ],
              ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF2ecc71).withOpacity(dark ? 0.3 : 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                color: Color(0xFF2ecc71),
                size: 16,
              ),
              SizedBox(width: 6),
              Text(
                'Projected Returns',
                style: TextStyle(
                  color: Color(0xFF2ecc71),
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...[1, 3, 5].map((y) {
            final fv = principal * pow(1 + totalRate, y);
            final pct = ((fv - principal) / principal * 100);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Year $y',
                    style: TextStyle(
                      color: textS,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '₹${fv.round().toLocaleString()}',
                        style: const TextStyle(
                          color: Color(0xFF2ecc71),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '(+${pct.toStringAsFixed(1)}%)',
                        style: TextStyle(color: textS, fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 6),
          Text(
            '*Estimates based on $appreciation% appreciation + $rentalYield% rental yield. Not guaranteed.',
            style: TextStyle(color: textH, fontSize: 10, height: 1.3),
          ),
        ],
      ),
    );
  }
}

// ─── Error State ──────────────────────────────────────────────────────────────
class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.msg, required this.dark});
  final String msg;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final iconC = dark ? DarkColors.inputIcon : AppColors.inputIcon;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: iconC, size: 64),
            const SizedBox(height: 16),
            Text(
              msg,
              textAlign: TextAlign.center,
              style: TextStyle(color: textS, fontSize: 15),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Get.back(),
              child: const Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}

extension IntExt on int {
  String toLocaleString() => toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );
}

// ─── Financial Highlights Grid ────────────────────────────────────────────────
class _FinancialHighlightsGrid extends StatelessWidget {
  const _FinancialHighlightsGrid({required this.property, required this.dark});
  final PropertyModel property;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final cardBg = dark ? const Color(0xFF101928) : Colors.white;
    final borderColor = dark
        ? const Color(0xFF1E2E4A)
        : const Color(0xFFE2E6F0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Financial & Investment Highlights',
          style: TextStyle(
            color: textP,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.trending_up_rounded,
                iconColor: const Color(0xFF10B981),
                title: 'Rental Yield',
                value: '${property.expectedRentalYield}% p.a.',
                subtitle: 'Monthly Payout',
                dark: dark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.show_chart_rounded,
                iconColor: AppColors.accent,
                title: 'Target Growth',
                value: '${property.expectedAppreciation}% p.a.',
                subtitle: 'Capital Growth',
                dark: dark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _MetricCard(
                icon: Icons.grid_view_rounded,
                iconColor: const Color(0xFF38BDF8),
                title: 'Min. Ticket Size',
                value: property.allowsBricks && property.brickPrice != null
                    ? '1 Brick (₹${property.brickPrice!.toLocaleString()})'
                    : property.formattedPrice,
                subtitle: property.allowsBricks
                    ? 'Fractional Entry'
                    : 'Full Asset',
                dark: dark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _MetricCard(
                icon: Icons.verified_user_rounded,
                iconColor: const Color(0xFF6366F1),
                title: 'Ownership Title',
                value: '100% SPV',
                subtitle: 'Legally Registered',
                dark: dark,
                cardBg: cardBg,
                borderColor: borderColor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.dark,
    required this.cardBg,
    required this.borderColor,
  });

  final IconData icon;
  final Color iconColor, cardBg, borderColor;
  final String title, value, subtitle;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(dark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: iconColor, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: dark
                        ? DarkColors.textSecondary
                        : AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              color: dark ? DarkColors.textPrimary : AppColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w900,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: TextStyle(
              color: dark ? DarkColors.textHint : AppColors.textHint,
              fontSize: 10,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Investment Returns Simulator ─────────────────────────────────────────────
class _InvestmentSimulator extends StatefulWidget {
  const _InvestmentSimulator({required this.property, required this.dark});
  final PropertyModel property;
  final bool dark;

  @override
  State<_InvestmentSimulator> createState() => _InvestmentSimulatorState();
}

class _InvestmentSimulatorState extends State<_InvestmentSimulator> {
  late int _selectedBricks;

  @override
  void initState() {
    super.initState();
    final maxB = widget.property.availableBricks;
    _selectedBricks = maxB > 0 ? (maxB >= 5 ? 5 : maxB) : 1;
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final p = widget.property;
    final brickPrice = p.brickPrice ?? 0;
    final total = _selectedBricks * brickPrice;
    final yieldRate = p.expectedRentalYield;
    final annualRental = total * (yieldRate / 100);
    final monthlyRental = (annualRental / 12).round();
    final appRate = p.expectedAppreciation;
    final futureVal = total * pow(1 + (appRate / 100), 3);
    final totalProfit = (futureVal - total + (annualRental * 3)).round();

    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final cardBg = dark ? const Color(0xFF101928) : Colors.white;
    final borderColor = dark
        ? const Color(0xFF1E2E4A)
        : const Color(0xFFE2E6F0);
    final maxB = p.availableBricks;

    final presets = [1, 5, 10, 25, if (maxB > 0) maxB];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.35 : 0.05),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(dark ? 0.2 : 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.calculate_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Investment Returns Calculator',
                    style: TextStyle(
                      color: textP,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    'Simulate potential rental income & growth',
                    style: TextStyle(color: textS, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),

          Text(
            'Select Number of Bricks',
            style: TextStyle(
              color: textS,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: presets.map((b) {
                final isSelected = _selectedBricks == b;
                final isFull = b == maxB && maxB > 0;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedBricks = b);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isFull
                                  ? const Color(0xFF6366F1)
                                  : AppColors.accent)
                            : (dark
                                  ? const Color(0xFF162238)
                                  : const Color(0xFFF1F4F9)),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected
                              ? Colors.transparent
                              : (dark
                                    ? const Color(0xFF223452)
                                    : const Color(0xFFE2E6F0)),
                        ),
                      ),
                      child: Text(
                        isFull
                            ? 'Full Asset ($b)'
                            : '$b ${b == 1 ? "Brick" : "Bricks"}',
                        style: TextStyle(
                          color: isSelected ? Colors.white : textP,
                          fontSize: 12,
                          fontWeight: isSelected
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [const Color(0xFF18263E), const Color(0xFF0F1827)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFEEF2F6)],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: dark ? const Color(0xFF263A5C) : const Color(0xFFDFE5EF),
              ),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total Investment',
                      style: TextStyle(color: textS, fontSize: 13),
                    ),
                    Text(
                      '₹${total.toLocaleString()}',
                      style: TextStyle(
                        color: textP,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.calendar_month_rounded,
                            color: Color(0xFF10B981),
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              'Est. Monthly Rental',
                              style: TextStyle(color: textS, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹${monthlyRental.toLocaleString()} / mo',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          const Icon(
                            Icons.auto_graph_rounded,
                            color: AppColors.accent,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              '3-Yr Projected Value',
                              style: TextStyle(color: textS, fontSize: 13),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '₹${futureVal.round().toLocaleString()}',
                          style: const TextStyle(
                            color: AppColors.accent,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Divider(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Total Estimated 3-Yr Return',
                        style: TextStyle(
                          color: textP,
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          '+₹${totalProfit.toLocaleString()}',
                          style: const TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Center(
            child: Text(
              'Estimates based on $yieldRate% rental yield + $appRate% appreciation p.a.',
              style: TextStyle(
                color: dark ? DarkColors.textHint : AppColors.textHint,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Institutional Trust Card ─────────────────────────────────────────────────
class _InstitutionalTrustCard extends StatelessWidget {
  const _InstitutionalTrustCard({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final cardBg = dark ? const Color(0xFF101928) : Colors.white;
    final borderColor = dark
        ? const Color(0xFF1E2E4A)
        : const Color(0xFFE2E6F0);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.shield_rounded,
                color: Color(0xFF10B981),
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Institutional Investor Protection',
                style: TextStyle(
                  color: textP,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _TrustRow(
            icon: Icons.account_balance_rounded,
            title: 'Regulated Escrow Account',
            desc: 'Funds held securely until complete title deed registration.',
            dark: dark,
          ),
          const SizedBox(height: 12),
          _TrustRow(
            icon: Icons.description_rounded,
            title: 'SPV Ownership Certificate',
            desc:
                'Legally binding ownership deed allocated directly to your PAN.',
            dark: dark,
          ),
          const SizedBox(height: 12),
          _TrustRow(
            icon: Icons.real_estate_agent_rounded,
            title: 'Zero Landlord Hassles',
            desc:
                'Vikaone DRX oversees tenant sourcing, lease management & payouts.',
            dark: dark,
          ),
        ],
      ),
    );
  }
}

class _TrustRow extends StatelessWidget {
  const _TrustRow({
    required this.icon,
    required this.title,
    required this.desc,
    required this.dark,
  });

  final IconData icon;
  final String title, desc;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFF10B981).withOpacity(dark ? 0.18 : 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: const Color(0xFF10B981), size: 15),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: textP,
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                desc,
                style: TextStyle(color: textS, fontSize: 11, height: 1.35),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Sticky Glassmorphic Bottom Bar ───────────────────────────────────────────
class _PropertyStickyBottomBar extends StatelessWidget {
  const _PropertyStickyBottomBar({
    required this.property,
    required this.dark,
    required this.controller,
  });

  final PropertyModel property;
  final bool dark;
  final PropertyDetailController controller;

  @override
  Widget build(BuildContext context) {
    final available = property.availableBricks;
    final barBg = dark ? const Color(0xFF09101C) : Colors.white;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;

    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        MediaQuery.of(context).padding.bottom > 0
            ? MediaQuery.of(context).padding.bottom + 6
            : 16,
      ),
      decoration: BoxDecoration(
        color: barBg.withOpacity(dark ? 0.94 : 0.97),
        border: Border(
          top: BorderSide(
            color: dark ? const Color(0xFF1E2E4A) : const Color(0xFFE2E6F0),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.45 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Row(
            children: [
              // Price Info
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (property.allowsBricks &&
                        property.brickPrice != null) ...[
                      Text(
                        '₹${property.brickPrice!.toLocaleString()}',
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
                      Text(
                        'per brick · $available available',
                        style: TextStyle(color: textS, fontSize: 11),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ] else ...[
                      Text(
                        property.formattedPrice,
                        style: const TextStyle(
                          color: AppColors.accent,
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                        ),
                      ),
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

              // Action Buttons
              if (available <= 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Text(
                    'Sold Out',
                    style: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                )
              else if (property.allowsBricks && property.allowsDirectBuy) ...[
                // Both allowed: show two compact buttons
                GestureDetector(
                  onTap: () => showBuySheet(
                    context: context,
                    controller: controller,
                    property: property,
                    dark: dark,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Buy Bricks',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () => showDirectBuySheet(
                    context: context,
                    controller: controller,
                    property: property,
                    dark: dark,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Buyout',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else if (property.isDirectBuyOnly) ...[
                GestureDetector(
                  onTap: () => showDirectBuySheet(
                    context: context,
                    controller: controller,
                    property: property,
                    dark: dark,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF6366F1).withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.business_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Buy Full Property (100%)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                GestureDetector(
                  onTap: () => showBuySheet(
                    context: context,
                    controller: controller,
                    property: property,
                    dark: dark,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 22,
                      vertical: 12,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentLight],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.4),
                          blurRadius: 10,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.grid_view_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Buy Bricks',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
