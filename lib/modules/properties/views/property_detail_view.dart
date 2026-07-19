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
          final p = controller.property.value;
          if (p == null) return const SizedBox.shrink();
          return _PropertyContent(property: p, dark: dark);
        }),
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
    final cardBg = dark ? DarkColors.surface : AppColors.white;
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
                color: Colors.white.withOpacity(0.15),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.3)),
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
            background: _GallerySection(images: property.images),
          ),
        ),

        SliverToBoxAdapter(
          child: Container(
            color: bg,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + Price card
                  _ThemedCard(
                    dark: dark,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              property.title,
                              style: TextStyle(
                                color: textP,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
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
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              if (property.price.label != null)
                                Text(
                                  property.price.label!,
                                  style: TextStyle(color: textS, fontSize: 12),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        color: AppColors.accent,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.location.display.isNotEmpty
                              ? property.location.display
                              : 'India',
                          style: TextStyle(color: textS, fontSize: 14),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _Animated3DStatsRow(property: property, dark: dark),
                  const SizedBox(height: 24),

                  if (property.description != null &&
                      property.description!.isNotEmpty) ...[
                    Text(
                      'About this property',
                      style: TextStyle(
                        color: textP,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      property.description!,
                      style: TextStyle(color: textS, fontSize: 14, height: 1.7),
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (property.amenities.isNotEmpty) ...[
                    Text(
                      'Amenities',
                      style: TextStyle(
                        color: textP,
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _AnimatedAmenitiesGrid(
                      amenities: property.amenities,
                      dark: dark,
                    ),
                    const SizedBox(height: 24),
                  ],

                  if (property.investmentEnabled &&
                      property.brickPrice != null &&
                      property.totalBricks != null) ...[
                    _BricksSection(property: property, dark: dark),
                    const SizedBox(height: 24),
                  ],

                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
        ),
      ],
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
  const _GallerySection({required this.images});
  final List<PropertyImage> images;

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

  @override
  void initState() {
    super.initState();
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
    _progressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<PropertyDetailController>();
    final dark = widget.dark;
    final sold = widget.property.soldBricks ?? 0;
    final available = widget.property.availableBricks;
    final pct = widget.property.soldPercent;
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final textH = dark ? DarkColors.textHint : AppColors.textHint;
    final inputBg = dark
        ? DarkColors.inputBackground
        : AppColors.inputBackground;

    return Container(
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [DarkColors.surface2, DarkColors.surface],
              )
            : LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.accent.withOpacity(0.12),
                  Colors.white.withOpacity(0.7),
                  AppColors.accent.withOpacity(0.05),
                ],
                stops: const [0, 0.5, 1],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: dark
              ? DarkColors.accent.withOpacity(0.3)
              : AppColors.accent.withOpacity(0.25),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: (dark ? DarkColors.accent : AppColors.accent).withOpacity(
              dark ? 0.15 : 0.15,
            ),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.accent.withOpacity(dark ? 0.2 : 0.12),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.grid_view_rounded,
                        color: AppColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Invest in Bricks',
                          style: TextStyle(
                            color: textP,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Own a fraction of this property',
                          style: TextStyle(color: textS, fontSize: 12),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '$sold sold (${pct.toStringAsFixed(0)}%)',
                      style: TextStyle(color: textS, fontSize: 12),
                    ),
                    Text(
                      '$available available',
                      style: TextStyle(color: textS, fontSize: 12),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AnimatedBuilder(
                  animation: _progressAnim,
                  builder: (_, __) => Container(
                    height: 10,
                    decoration: BoxDecoration(
                      color: inputBg,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: (pct / 100) * _progressAnim.value,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            colors: [Color(0xFFFFB300), DarkColors.goldLight],
                            stops: [0.0, 1.0],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MiniInfoCard(
                      label: 'Price per brick',
                      value:
                          '₹${widget.property.brickPrice?.toLocaleString() ?? '—'}',
                      valueColor: AppColors.accent,
                      dark: dark,
                    ),
                    _MiniInfoCard(
                      label: 'Min. investment',
                      value: '1 brick',
                      valueColor: textP,
                      dark: dark,
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                _GoldButton(
                  label: available > 0 ? 'Buy Bricks' : 'Sold Out',
                  icon: Icons.lock_outline_rounded,
                  onPressed: available > 0
                      ? () => _showBuySheet(context, controller)
                      : null,
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Secured by Razorpay · Test mode',
                    style: TextStyle(color: textH, fontSize: 11),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showBuySheet(
    BuildContext context,
    PropertyDetailController controller,
  ) {
    final dark = widget.dark;
    final qtyCtrl = TextEditingController(text: '1');
    final brickPrice = widget.property.brickPrice ?? 0;
    final available = widget.property.availableBricks;
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
                    color: dark
                        ? DarkColors.inputBorder
                        : AppColors.inputBorder,
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
                          '${((qty / (widget.property.totalBricks ?? 1)) * 100).toStringAsFixed(2)}% ownership',
                          style: TextStyle(color: textS, fontSize: 13),
                        ),
                        const SizedBox(height: 14),
                        _ReturnsProjection(
                          principal: total,
                          appreciation: widget.property.expectedAppreciation,
                          rentalYield: widget.property.expectedRentalYield,
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
                  color: const Color(
                    0xFFF39C12,
                  ).withOpacity(dark ? 0.15 : 0.08),
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
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
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
}

// ─── Mini Info Card ───────────────────────────────────────────────────────────
class _MiniInfoCard extends StatelessWidget {
  const _MiniInfoCard({
    required this.label,
    required this.value,
    required this.valueColor,
    required this.dark,
  });
  final String label, value;
  final Color valueColor;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: dark ? DarkColors.surface2 : Colors.white.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dark ? DarkColors.inputBorder : Colors.white.withOpacity(0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(color: textS, fontSize: 11)),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
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
