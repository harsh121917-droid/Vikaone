import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../controllers/wishlist_controller.dart';
import '../../../data/repositories/wishlist_repository.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/property_model.dart';
import '../../../routes/app_routes.dart';

class WishlistView extends StatelessWidget {
  const WishlistView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<WishlistRepository>()) {
      Get.lazyPut<WishlistRepository>(() => WishlistRepository());
    }
    final controller = Get.isRegistered<WishlistController>()
        ? Get.find<WishlistController>()
        : Get.put(WishlistController());

    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF4F7FC);

      return Scaffold(
        backgroundColor: bg,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _HeroHeader(dark: dark, ctrl: controller),
              Expanded(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF2563EB),
                        strokeWidth: 2.5,
                      ),
                    );
                  }
                  if (controller.properties.isEmpty) {
                    return _EmptyState(dark: dark);
                  }

                  final list = controller.properties;
                  return RefreshIndicator(
                    onRefresh: controller.loadWishlist,
                    color: Color(0xFF2563EB),
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      itemCount: list.length + 1,
                      itemBuilder: (ctx, i) {
                        if (i == 0) {
                          return _ValuationBanner(properties: list, dark: dark);
                        }
                        final property = list[i - 1];
                        return _WishlistPropertyCard(
                          property: property,
                          index: i - 1,
                          dark: dark,
                          onRemove: () => controller.toggle(property),
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
}

// ─── Hero Header ──────────────────────────────────────────────────────────────
class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.dark, required this.ctrl});
  final bool dark;
  final WishlistController ctrl;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final btnBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF060B16) : const Color(0xFFF4F7FC),
        border: Border(
          bottom: BorderSide(
            color: dark ? const Color(0xFF141E33) : const Color(0xFFE2E8F0),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  Get.back();
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: btnBg,
                    borderRadius: BorderRadius.circular(13),
                    border: Border.all(color: border),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_rounded,
                    color: tp,
                    size: 20,
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Title and count
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Wishlist',
                          style: TextStyle(
                            color: tp,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: -0.4,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Obx(() {
                          final count = ctrl.properties.length;
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2563EB).withOpacity(dark ? 0.2 : 0.12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: const Color(0xFF2563EB).withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Color(0xFF2563EB),
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          );
                        }),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Curated institutional & luxury assets',
                      style: TextStyle(
                        color: ts,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              // Refresh Button
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  ctrl.loadWishlist();
                },
                child: Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF2563EB).withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
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
        ],
      ),
    );
  }
}

// ─── Target Portfolio Valuation Banner ────────────────────────────────────────
class _ValuationBanner extends StatelessWidget {
  const _ValuationBanner({required this.properties, required this.dark});
  final List<PropertyModel> properties;
  final bool dark;

  String _calculateTotalValuation() {
    num total = 0;
    for (final p in properties) {
      if (p.price.amount != null && p.price.amount! > 0) {
        total += p.price.amount!;
      } else if (p.totalBricks != null && p.brickPrice != null) {
        total += (p.totalBricks! * p.brickPrice!);
      }
    }
    if (total >= 10000000) {
      return '₹${(total / 10000000).toStringAsFixed(2)} Cr';
    } else if (total >= 100000) {
      return '₹${(total / 100000).toStringAsFixed(1)} L';
    } else if (total > 0) {
      return '₹$total';
    }
    return '₹0';
  }

  double _calculateAvgYield() {
    if (properties.isEmpty) return 0;
    double sum = 0;
    int count = 0;
    for (final p in properties) {
      if (p.expectedRentalYield > 0) {
        sum += p.expectedRentalYield;
        count++;
      }
    }
    return count > 0 ? (sum / count) : 7.5;
  }

  @override
  Widget build(BuildContext context) {
    final val = _calculateTotalValuation();
    final avgYield = _calculateAvgYield();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: dark
            ? const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0E1626),
                  Color(0xFF131D33),
                  Color(0xFF0E1626),
                ],
              )
            : const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF1E293B),
                  Color(0xFF0F172A),
                  Color(0xFF1E293B),
                ],
              ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF2563EB).withOpacity(0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.45 : 0.15),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: const Color(0xFF2563EB).withOpacity(0.08),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2563EB).withOpacity(0.18),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.account_balance_outlined,
                      color: Color(0xFF60A5FA),
                      size: 16,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'PORTFOLIO WATCHLIST',
                    style: TextStyle(
                      color: Color(0xFF60A5FA),
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${properties.length} Saved ${properties.length == 1 ? "Asset" : "Assets"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Total Target Valuation',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.65),
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    val,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: const Color(0xFF10B981).withOpacity(0.4),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.trending_up_rounded,
                      color: Color(0xFF10B981),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${avgYield.toStringAsFixed(1)}% Avg Yield',
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Modern Horizontal Wishlist Property Card ─────────────────────────────────
class _WishlistPropertyCard extends StatefulWidget {
  const _WishlistPropertyCard({
    required this.property,
    required this.index,
    required this.dark,
    required this.onRemove,
  });

  final PropertyModel property;
  final int index;
  final bool dark;
  final VoidCallback onRemove;

  @override
  State<_WishlistPropertyCard> createState() => _WishlistPropertyCardState();
}

class _WishlistPropertyCardState extends State<_WishlistPropertyCard> {
  bool _pressed = false;

  (String label, Color color1, Color color2) _getCardBadge(PropertyModel p) {
    if (p.isDirectBuyOnly) {
      return ('Full Ownership', const Color(0xFF6366F1), const Color(0xFF4F46E5));
    }
    if (p.soldPercent >= 60) {
      return ('High Demand', const Color(0xFF10B981), const Color(0xFF059669));
    }
    if (p.featured) {
      return ('Popular', const Color(0xFFF59E0B), const Color(0xFFD97706));
    }
    return ('Featured', const Color(0xFF2563EB), const Color(0xFF1D4ED8));
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
    return p.formattedPrice;
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.property;
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);
    final border = dark ? const Color(0xFF1E2D4A) : const Color(0xFFE2E8F0);
    final chipBg = dark ? const Color(0xFF162032) : const Color(0xFFF1F5F9);

    final badge = _getCardBadge(p);
    final valuationText = _getValuation(p);

    return Padding(
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
            height: 198,
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
                // ── Left: Image + Status Badge ─────────────────────────
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
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [badge.$2, badge.$3],
                            ),
                            borderRadius: BorderRadius.circular(10),
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
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // ── Right: Details Column ───────────────────────────────
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // 1. Title + One-Tap Remove Heart
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
                          const SizedBox(width: 4),
                          GestureDetector(
                            onTap: () {
                              HapticFeedback.mediumImpact();
                              widget.onRemove();
                            },
                            child: Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(dark ? 0.15 : 0.08),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.red.withOpacity(0.35),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.red.withOpacity(0.15),
                                    blurRadius: 6,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.favorite_rounded,
                                color: Colors.red,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 2. Location Row
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            size: 12,
                            color: Color(0xFF2563EB),
                          ),
                          const SizedBox(width: 3),
                          Expanded(
                            child: Text(
                              '${p.location.city ?? "Mumbai"}${p.location.state != null && p.location.state!.isNotEmpty ? ", ${p.location.state!}" : ""}',
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

                      // 3. Mini Chips Row
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

                      // 4. Metrics Row
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p.expectedRentalYield > 0 ? p.expectedRentalYield.toStringAsFixed(1) : "7.2"}%',
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p.expectedAppreciation > 0 ? p.expectedAppreciation.toStringAsFixed(1) : "8.5"}%',
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
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${p.effectiveXirr > 0 ? p.effectiveXirr.toStringAsFixed(1) : "14.8"}%',
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

                      // 5. Valuation & View CTA Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p.isDirectBuyOnly ? 'Valuation' : 'Min. Investment',
                                style: TextStyle(
                                  color: ts,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.isDirectBuyOnly
                                    ? valuationText
                                    : (p.brickPrice != null && p.brickPrice! > 0
                                        ? '₹${p.brickPrice}/brick'
                                        : valuationText),
                                style: TextStyle(
                                  color: dark ? const Color(0xFF60A5FA) : const Color(0xFF2563EB),
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.2,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF2563EB).withOpacity(0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  'View',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(width: 3),
                                Icon(
                                  Icons.arrow_forward_rounded,
                                  color: Colors.white,
                                  size: 12,
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
    );
  }

  Widget _buildMiniTag(String label, Color bg, Color textCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
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

  Widget _ph(bool dark) => Container(
    color: dark ? const Color(0xFF141E33) : const Color(0xFFE2E8F0),
    child: Center(
      child: Icon(
        Icons.apartment_rounded,
        color: dark ? const Color(0xFF334155) : const Color(0xFF94A3B8),
        size: 32,
      ),
    ),
  );
}

// ─── Modern Empty State ───────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.dark});
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF0F172A);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF64748B);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.red.withOpacity(dark ? 0.25 : 0.12),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: Colors.red.withOpacity(0.35),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.15),
                    blurRadius: 24,
                  ),
                ],
              ),
              child: const Icon(
                Icons.favorite_rounded,
                color: Colors.red,
                size: 44,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Saved Properties Yet',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: tp,
                fontSize: 20,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Curate your personal real estate portfolio by tapping the heart icon on any prime commercial, residential, or plot asset.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: ts,
                fontSize: 13,
                height: 1.55,
              ),
            ),
            const SizedBox(height: 28),
            GestureDetector(
              onTap: () {
                HapticFeedback.lightImpact();
                Get.toNamed(AppRoutes.properties);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2563EB).withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.explore_rounded, color: Colors.white, size: 18),
                    SizedBox(width: 8),
                    Text(
                      'Explore Properties',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
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
