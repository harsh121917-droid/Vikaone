import 'property_document_viewer_screen.dart';
import '../../../core/services/lock_service.dart';
import 'package:real_estate/modules/wallet/controllers/wallet_controller.dart';
import 'package:youtube_player_iframe/youtube_player_iframe.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/property_detail_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/property_model.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../auth/controllers/auth_controller.dart';


Future<void> _previewPdfDocument(String? url,
  String title, {
  String? category,
}) async {
  if (url == null || url.trim().isEmpty) {
    Get.snackbar(
      'Document Notice',
      'The official PDF document for "$title" has not been uploaded yet.',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8)),
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
    return;
  }

  final cleanUrl = url.trim();

  // Suppress any background lock triggers during document preview
  if (Get.isRegistered<LockService>()) {
    LockService.to.suppressLockFor(const Duration(minutes: 10));
  }

  // Open the in-app document viewer directly inside Flutter.
  // This keeps the Flutter Activity in the foreground and NEVER pauses or triggers the passcode screen.
  Get.to(
    () => PropertyDocumentViewerScreen(
      url: cleanUrl,
      title: title,
      category: category,
    ),
    transition: Transition.cupertino,
  );
}

Future<void> _downloadPdfDocument(String? url, String title) async {
  if (Get.isRegistered<LockService>()) {
    LockService.to.suppressLockFor(const Duration(minutes: 10));
  }
  if (url == null || url.trim().isEmpty) {
    Get.snackbar(
      'Download Notice',
      'The official document for "$title" is not available for download yet.',
      backgroundColor: const Color(0xFF1E293B),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      icon: const Icon(Icons.info_outline_rounded, color: Color(0xFF38BDF8)),
      margin: const EdgeInsets.all(14),
      borderRadius: 14,
      duration: const Duration(seconds: 3),
    );
    return;
  }

  final cleanUrl = url.trim();
  Get.snackbar(
    'Downloading',
    'Starting download for $title...',
    backgroundColor: const Color(0xFF10B981),
    colorText: Colors.white,
    snackPosition: SnackPosition.BOTTOM,
    icon: const Icon(Icons.download_rounded, color: Colors.white),
    margin: const EdgeInsets.all(14),
    borderRadius: 14,
    duration: const Duration(seconds: 2),
  );

  try {
    final uri = Uri.parse(cleanUrl);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
    }
  } catch (e) {
    Get.snackbar(
      'Download Error',
      'Could not download document: $e',
      backgroundColor: const Color(0xFFEF4444),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}

Future<void> _launchDocumentUrl(String? url, String title) async {
  if (Get.isRegistered<LockService>()) {
    LockService.to.suppressLockFor(const Duration(minutes: 10));
  }
  final ctx = Get.context;
  if (ctx != null) {
    await _previewPdfDocument(url, title);
  } else {
    await _downloadPdfDocument(url, title);
  }
}

class PropertyDetailView extends StatelessWidget {
  final String? propertyId;
  const PropertyDetailView({super.key, this.propertyId});

  @override
  Widget build(BuildContext context) {
    final effectiveId = propertyId ??
        Get.parameters['id'] ??
        (Get.arguments is String ? Get.arguments as String : null);

    final controller = Get.isRegistered<PropertyDetailController>(tag: effectiveId)
        ? Get.find<PropertyDetailController>(tag: effectiveId)
        : Get.put(
            PropertyDetailController(propertyId: effectiveId),
            tag: effectiveId,
          );

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
          return _PropertyContent(
            property: p,
            dark: dark,
            controller: controller,
          );
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

class _PropertyContent extends StatefulWidget {
  final PropertyModel property;
  final bool dark;
  final PropertyDetailController controller;
  const _PropertyContent({
    required this.property,
    required this.dark,
    required this.controller,
  });

  @override
  State<_PropertyContent> createState() => _PropertyContentState();
}

class _PropertyContentState extends State<_PropertyContent> {
  int _selectedTab = 0; // 0: Investment, 1: Legal, 2: Returns, 3: Security, 4: Testimonials
  late double _investmentSliderAmount;
  String? _expandedAccordion; // 'about', 'protected', 'legal', 'calculator', 'security'

  void _toggleAccordion(String section) {
    setState(() {
      if (_expandedAccordion == section) {
        _expandedAccordion = null;
      } else {
        _expandedAccordion = section;
      }
    });
  }

  final ScrollController _scrollController = ScrollController();
  final GlobalKey _investmentKey = GlobalKey();
  final GlobalKey _legalKey = GlobalKey();
  final GlobalKey _returnsKey = GlobalKey();
  final GlobalKey _securityKey = GlobalKey();
  final GlobalKey _testimonialsKey = GlobalKey();

  bool _isManualTabScrolling = false;

  @override
  void initState() {
    super.initState();
    _investmentSliderAmount = (widget.property.brickPrice ?? 10000).toDouble();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isManualTabScrolling) return;
    final keys = [_investmentKey, _legalKey, _returnsKey, _securityKey, _testimonialsKey];
    for (int i = keys.length - 1; i >= 0; i--) {
      final key = keys[i];
      final ctx = key.currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox?;
        if (box != null && box.hasSize) {
          final pos = box.localToGlobal(Offset.zero);
          // When top of section reaches below sticky header (~160px)
          if (pos.dy <= 165) {
            if (_selectedTab != i) {
              setState(() => _selectedTab = i);
            }
            break;
          }
        }
      }
    }
  }

  void _scrollToSection(int index) async {
    setState(() => _selectedTab = index);
    _isManualTabScrolling = true;
    final keys = [_investmentKey, _legalKey, _returnsKey, _securityKey, _testimonialsKey];
    final ctx = keys[index].currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        duration: const Duration(milliseconds: 380),
        curve: Curves.easeInOutCubic,
        alignment: 0.08,
      );
    }
    _isManualTabScrolling = false;
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final dark = widget.dark;
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final bg = dark ? DarkColors.background : AppColors.background;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final totalAssetValuation = (property.price.amount != null && property.price.amount! > 0)
        ? property.price.amount!
        : (((property.brickPrice ?? 10000) * (property.totalBricks ?? 1000)));

    final double totalAssetPrice = totalAssetValuation.toDouble();

    final double partnershipPct = totalAssetPrice > 0
        ? (_investmentSliderAmount / totalAssetPrice) * 100
        : 0.0;

    // Real dynamic funding metrics
    final double realSoldPercent = property.soldPercent > 0
        ? property.soldPercent
        : ((property.soldBricks != null && property.totalBricks != null && property.totalBricks! > 0)
            ? (property.soldBricks! / property.totalBricks!) * 100.0
            : 62.0);

    final double investedAmount = (property.soldBricks != null && property.brickPrice != null && property.soldBricks! > 0)
        ? (property.soldBricks! * property.brickPrice!).toDouble()
        : (totalAssetValuation * (realSoldPercent / 100.0));

    String formattedInvested;
    if (investedAmount >= 10000000) {
      formattedInvested = '₹${(investedAmount / 10000000).toStringAsFixed(2)} Cr';
    } else if (investedAmount >= 100000) {
      formattedInvested = '₹${(investedAmount / 100000).toStringAsFixed(1)} Lacs';
    } else {
      formattedInvested = '₹${investedAmount.round()}';
    }

    final int viewsToday = (property.id.hashCode.abs() % 350) + 175;

    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── 1. Top Hero Image & Overlapping Card ─────────────────────
        SliverToBoxAdapter(
          child: Container(
            color: bg,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Image gallery
                SizedBox(
                  height: 330,
                  width: double.infinity,
                  child: _GallerySection(property: property),
                ),

                // Top View Gallery button (Back button is persistent at Scaffold root)
                Positioned(
                  top: MediaQuery.of(context).padding.top + 8,
                  right: 16,
                  child: GestureDetector(
                    onTap: () => _showAllPhotosModal(context, property, dark),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.55),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white.withOpacity(0.3)),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_rounded, color: Colors.white, size: 14),
                              const SizedBox(width: 6),
                              Text(
                                'Gallery (${property.images.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // Hero Card: Non-positioned in stack with top margin = 275px
                // Ensures it renders ON TOP of image, sizes stack height correctly, and has 0 gap!
                Container(
                  margin: const EdgeInsets.only(top: 275, left: 18, right: 18, bottom: 12),
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: borderC),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(dark ? 0.45 : 0.08),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title & View Details link
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
                          const SizedBox(width: 10),
                          GestureDetector(
                            onTap: () => _scrollToSection(0),
                            child: const Padding(
                              padding: EdgeInsets.only(top: 4),
                              child: Text(
                                'View Details',
                                style: TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF10B981),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        property.location.display.isNotEmpty
                            ? property.location.display
                            : (property.location.city ?? 'Navi Mumbai, Maharashtra'),
                        style: TextStyle(
                          color: textS,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Spec Chips: [ Under Construction ] [ Apartment ] [ BHK ]
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: [
                            _SpecBadge(icon: Icons.construction_rounded, label: 'Under Construction', dark: dark),
                            const SizedBox(width: 8),
                            _SpecBadge(icon: Icons.apartment_rounded, label: property.propertyType ?? 'Apartment', dark: dark),
                            if (property.bhk != null) ...[
                              const SizedBox(width: 8),
                              _SpecBadge(icon: Icons.meeting_room_rounded, label: property.bhk!, dark: dark),
                            ],
                            if (property.area != null) ...[
                              const SizedBox(width: 8),
                              _SpecBadge(icon: Icons.square_foot_rounded, label: '${property.area} sq.ft', dark: dark),
                            ],
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(0.12),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 12),
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
                      const SizedBox(height: 14),

                      // Swipable 1/7 Cashback & Benefits Carousel
                      _CashbackBenefitsCarousel(dark: dark),
                      const SizedBox(height: 14),

                      // Real Dynamic Funded Status Bar
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF131E33) : const Color(0xFFF8FAFC),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: borderC),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: Color(0xFF10B981),
                                    shape: BoxShape.circle,
                                    boxShadow: [
                                      BoxShadow(
                                        color: Color(0xFF10B981),
                                        blurRadius: 6,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '$formattedInvested invested',
                                  style: TextStyle(
                                    color: textP,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  '· $viewsToday views',
                                  style: TextStyle(
                                    color: textS,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const Spacer(),
                                GestureDetector(
                                  onTap: () => _showFundingBreakdownSheet(
                                    context,
                                    property,
                                    dark,
                                    totalAssetValuation,
                                    investedAmount,
                                    realSoldPercent,
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: dark ? const Color(0xFF1E293B) : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: borderC),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          'View',
                                          style: TextStyle(
                                            color: textP,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        const SizedBox(width: 2),
                                        Icon(Icons.chevron_right_rounded, size: 14, color: textS),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: (realSoldPercent / 100.0).clamp(0.05, 1.0),
                                minHeight: 6,
                                backgroundColor: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
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

        // ── 2. Sticky Persistent Section Tab Bar (Pinned) ───────────
        SliverPersistentHeader(
          pinned: true,
          delegate: _StickyTabBarDelegate(
            height: 52.0,
            child: Container(
              color: bg.withOpacity(0.96),
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: borderC, width: 1.2),
                      ),
                    ),
                    alignment: Alignment.centerLeft,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: [
                          _buildTabButton('Investment', 0),
                          _buildTabButton('Legal', 1),
                          _buildTabButton('Returns', 2),
                          _buildTabButton('Security', 3),
                          _buildTabButton('Testimonials', 4),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── 3. Continuous Content Sections (With Scroll-Spy Keys) ───
        SliverToBoxAdapter(
          child: Container(
            color: bg,
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Investment Section
                Container(
                  key: _investmentKey,
                  child: _buildInvestmentTab(
                    property,
                    dark,
                    textP,
                    textS,
                    cardBg,
                    borderC,
                    totalAssetPrice,
                    partnershipPct,
                  ),
                ),
                const SizedBox(height: 36),

                // 2. Legal Section
                Container(
                  key: _legalKey,
                  child: _buildLegalTab(
                    property,
                    dark,
                    textP,
                    textS,
                    cardBg,
                    borderC,
                    partnershipPct,
                  ),
                ),
                const SizedBox(height: 36),

                // 3. Returns Section
                Container(
                  key: _returnsKey,
                  child: _buildReturnsTab(
                    property,
                    dark,
                    textP,
                    textS,
                    cardBg,
                    borderC,
                  ),
                ),
                const SizedBox(height: 36),

                // 4. Security Section
                Container(
                  key: _securityKey,
                  child: _buildSecurityTab(
                    property,
                    dark,
                    textP,
                    textS,
                    cardBg,
                    borderC,
                  ),
                ),
                const SizedBox(height: 36),

                // 5. Testimonials Section
                Container(
                  key: _testimonialsKey,
                  child: _buildTestimonialsTab(
                    property,
                    dark,
                    textP,
                    textS,
                    cardBg,
                    borderC,
                  ),
                ),
                const SizedBox(height: 36),

                // 6. Similar & Recommended Properties Section
                _buildSuggestedPropertiesSection(
                  property,
                  dark,
                  textP,
                  textS,
                  cardBg,
                  borderC,
                  widget.controller,
                ),

                const SizedBox(height: 110),
              ],
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildSuggestedPropertiesSection(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
    PropertyDetailController controller,
  ) {
    return Obx(() {
      if (controller.isSuggestionsLoading.value) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSuggestedHeader(textP, textS),
              const SizedBox(height: 16),
              const SizedBox(
                height: 180,
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColors.accent,
                    strokeWidth: 2,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      final suggestions = controller.suggestedProperties
          .where((p) => p.id != property.id)
          .toList();

      if (suggestions.isEmpty) {
        return const SizedBox.shrink();
      }

      return Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSuggestedHeader(textP, textS),
            const SizedBox(height: 16),
            SizedBox(
              height: 275,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                itemCount: suggestions.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, i) {
                  final p = suggestions[i];
                  return _SuggestedPropertyCard(
                    property: p,
                    dark: dark,
                    textP: textP,
                    textS: textS,
                    cardBg: cardBg,
                    borderC: borderC,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      Get.to(
                        () => PropertyDetailView(propertyId: p.id),
                        preventDuplicates: false,
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildSuggestedHeader(Color textP, Color textS) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: AppColors.accent,
                size: 18,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Similar & Recommended Properties',
              style: TextStyle(
                color: textP,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Handpicked properties you might also be interested in',
          style: TextStyle(
            color: textS,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(String title, int index) {
    final active = _selectedTab == index;
    final dark = widget.dark;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;

    return GestureDetector(
      onTap: () => _scrollToSection(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: active
              ? (dark ? const Color(0xFF10B981) : AppColors.primary)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          border: active
              ? null
              : Border.all(
                  color: dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1),
                  width: 1,
                ),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: active ? Colors.white : (dark ? textS : const Color(0xFF475569)),
            fontSize: 13,
            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ── Dialogs & Sheets ──────────────────────────────────────────
  void _showFundingBreakdownSheet(
    BuildContext context,
    PropertyModel property,
    bool dark,
    int totalValuation,
    double investedAmount,
    double soldPct,
  ) {
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
          border: Border.all(color: borderC),
        ),
        padding: const EdgeInsets.all(22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Funding & Asset Breakdown',
                  style: TextStyle(color: textP, fontSize: 17, fontWeight: FontWeight.w800),
                ),
                IconButton(
                  icon: Icon(Icons.close_rounded, color: textS),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 14),
            _metricDetailRow('Total Property Valuation', property.formattedPrice, textP, textS),
            _metricDetailRow('Funded Capital Raised', '₹${(investedAmount / 100000).toStringAsFixed(1)} Lacs (${soldPct.toStringAsFixed(1)}%)', textP, textS),
            _metricDetailRow('Total Asset Bricks', '${property.totalBricks ?? 1000} Bricks', textP, textS),
            _metricDetailRow('Available Bricks', '${property.availableBricks} Bricks', textP, textS),
            _metricDetailRow('Minimum Ticket Size', '₹${(property.brickPrice ?? 10000).toLocaleString()}', textP, textS),
            _metricDetailRow('SPV Legal Entity', property.spvName, textP, textS),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _metricDetailRow(String label, String value, Color tp, Color ts) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: ts, fontSize: 13)),
          Text(value, style: TextStyle(color: tp, fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }


Widget _buildInvestmentTab(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
    double totalAssetPrice,
    double partnershipPct,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Heading
        Text(
          'Select Investment Amount',
          style: TextStyle(
            color: textP,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Interactive Partnership Slider Card (Screenshot 4)
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderC),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.35 : 0.04),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top percentage
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
                    ' ${partnershipPct.toStringAsFixed(2)} %',
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
                          '₹${_investmentSliderAmount.toInt().toLocaleString()}',
                          style: TextStyle(
                            color: textP,
                            fontSize: 19,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(width: 1, height: 38, color: borderC),
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
                          property.formattedPrice,
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
              const SizedBox(height: 10),

              Text(
                'Your partnership = Investment amount ÷ Property price',
                style: TextStyle(
                  color: textS.withOpacity(0.85),
                  fontSize: 11.5,
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 14),

              // Slider
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
                  value: _investmentSliderAmount.clamp(10000.0, totalAssetPrice),
                  min: 10000.0,
                  max: totalAssetPrice > 10000.0 ? totalAssetPrice : 10000000.0,
                  onChanged: (val) {
                    setState(() {
                      _investmentSliderAmount = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 14),
              Divider(color: borderC, height: 1),
              const SizedBox(height: 12),

              // Valuation report row (Screenshot 4)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property price',
                        style: TextStyle(color: textS, fontSize: 11.5),
                      ),
                      Text(
                        property.formattedPrice,
                        style: TextStyle(color: textP, fontSize: 15, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showValuationReportDialog(context, property, dark),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.description_outlined, color: Color(0xFF10B981), size: 15),
                        SizedBox(width: 4),
                        Text(
                          'View Valuation Report',
                          style: TextStyle(
                            color: Color(0xFF10B981),
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF10B981),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // In-App YouTube Video Walkthrough (Preserved!)
        if (property.youtubeVideoId != null) ...[
          _PropertyVideoSection(
            videoId: property.youtubeVideoId!,
            fallbackImageUrl: property.coverImage,
            dark: dark,
          ),
          const SizedBox(height: 20),
        ],

        // Financial Highlights Matrix
        _FinancialHighlightsGrid(property: property, dark: dark),
        const SizedBox(height: 20),

        // About Property (Accordion)
        if (property.description != null && property.description!.isNotEmpty) ...[
          _ThemedCard(
            dark: dark,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    onTap: () => _toggleAccordion('about'),
                    borderRadius: BorderRadius.circular(10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'About This Property',
                          style: TextStyle(
                            color: textP,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        AnimatedRotation(
                          turns: _expandedAccordion == 'about' ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 240),
                          curve: Curves.easeInOut,
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: textP,
                            size: 24,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedCrossFade(
                    duration: const Duration(milliseconds: 240),
                    firstCurve: Curves.easeInOut,
                    secondCurve: Curves.easeInOut,
                    sizeCurve: Curves.easeInOut,
                    crossFadeState: _expandedAccordion == 'about'
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: const SizedBox.shrink(),
                    secondChild: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 12),
                        Divider(color: borderC.withOpacity(0.6), height: 1),
                        const SizedBox(height: 12),
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
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Amenities Grid
        if (property.amenities.isNotEmpty) ...[
          Text(
            'Amenities & Features',
            style: TextStyle(
              color: textP,
              fontSize: 16,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          _AnimatedAmenitiesGrid(amenities: property.amenities, dark: dark),
          const SizedBox(height: 20),
        ],
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB 1: LEGAL (Screenshot 5)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildLegalTab(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
    double partnershipPct,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Legal Ownership',
          style: TextStyle(
            color: textP,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Legal 3-step vertical card (Screenshot 5)
        Container(
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: borderC),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _TimelineStep(
                number: '1',
                title: property.spvName,
                subtitle: 'holds the title of the property',
                dark: dark,
                isLast: false,
              ),
              _TimelineStep(
                number: '2',
                title: 'You get ${partnershipPct.toStringAsFixed(2)}% partnership in this LLP',
                subtitle: 'Based on your investment contribution',
                dark: dark,
                isLast: false,
              ),
              _TimelineStep(
                number: '3',
                title: 'Your partnership is filed in MCA',
                subtitle: 'VikaDrx does the filing on your behalf every quarter',
                dark: dark,
                isLast: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Talk to your Advisor Card (Screenshot 5)
        _AdvisorCard(
          dark: dark,
          property: property,
          controller: widget.controller,
        ),
        const SizedBox(height: 20),

        // Institutional Custody Card (Accordion)
        _InstitutionalTrustCard(
          dark: dark,
          property: property,
          isExpanded: _expandedAccordion == 'protected',
          onToggle: () => _toggleAccordion('protected'),
        ),
        const SizedBox(height: 20),

        // Property Legal & Compliance Documents Section (Accordion)
        _PropertyDocumentsSection(
          property: property,
          dark: dark,
          textP: textP,
          textS: textS,
          cardBg: cardBg,
          borderC: borderC,
          isExpanded: _expandedAccordion == 'legal',
          onToggle: () => _toggleAccordion('legal'),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB 2: RETURNS (Screenshot 5)
  // ══════════════════════════════════════════════════════════════════
  Widget _buildReturnsTab(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Projected Returns*',
              style: TextStyle(
                color: textP,
                fontSize: 18,
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'TARGET CAGR',
                style: TextStyle(
                  color: Color(0xFF10B981),
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Visual Projected Returns Bar Chart (Screenshot 5)
        _ProjectedReturnsBarChart(dark: dark),
        const SizedBox(height: 20),

        // Return Simulator (Accordion)
        _InvestmentSimulator(
          property: property,
          dark: dark,
          isExpanded: _expandedAccordion == 'calculator',
          onToggle: () => _toggleAccordion('calculator'),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB 3: SECURITY
  // ══════════════════════════════════════════════════════════════════
  Widget _buildSecurityTab(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
  ) {
    final isExpanded = _expandedAccordion == 'security';
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => _toggleAccordion('security'),
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(dark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.security_rounded,
                    color: Color(0xFF10B981),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Institutional Security & Protection',
                        style: TextStyle(
                          color: textP,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Ownership protection, escrow trust & FAQ safeguards',
                        style: TextStyle(color: textS, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textP,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Divider(color: borderC.withOpacity(0.6), height: 1),
                const SizedBox(height: 16),
                _SecurityFaqAccordion(dark: dark),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════════════
  // TAB 4: TESTIMONIALS
  // ══════════════════════════════════════════════════════════════════
  Widget _buildTestimonialsTab(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Investor Testimonials & Reviews',
          style: TextStyle(
            color: textP,
            fontSize: 18,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        _TestimonialsSection(dark: dark),
      ],
    );
  }

  // ── Dialogs ──────────────────────────────────────────────────
  

  void _showValuationReportDialog(BuildContext context, PropertyModel property, bool dark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ProjectedReturnsReportModal(property: property, dark: dark),
    );
  }

  void _showAllPhotosModal(BuildContext context, PropertyModel property, bool dark) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _PhotosGalleryModal(property: property, dark: dark),
    );
  }
}





// ══════════════════════════════════════════════════════════════════
// Sticky Persistent Tab Bar Delegate
// ══════════════════════════════════════════════════════════════════
class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  final double height;

  _StickyTabBarDelegate({required this.child, this.height = 52.0});

  @override
  double get minExtent => height;
  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return child;
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}

// ══════════════════════════════════════════════════════════════════
// Swipable 1/7 Cashback & Investor Benefits Carousel
// ══════════════════════════════════════════════════════════════════
class _CashbackBenefitsCarousel extends StatefulWidget {
  final bool dark;
  const _CashbackBenefitsCarousel({required this.dark});

  @override
  State<_CashbackBenefitsCarousel> createState() => _CashbackBenefitsCarouselState();
}

class _CashbackBenefitsCarouselState extends State<_CashbackBenefitsCarousel> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;

  final List<Map<String, dynamic>> _benefits = [
    {
      'title': '6% cashback',
      'subtitle': 'On investments above ₹5,00,000 · Instant linked credit',
      'badge': 'OFFER',
      'icon': Icons.percent_rounded,
      'color': Color(0xFF10B981),
      'bgDark': Color(0xFF064E3B),
      'bgLight': Color(0xFFE6F4EA),
    },
    {
      'title': 'Zero Platform Fee',
      'subtitle': 'Save 100% processing fee on your first 2 Brick purchases',
      'badge': 'ZERO FEE',
      'icon': Icons.money_off_csred_rounded,
      'color': Color(0xFF3B82F6),
      'bgDark': Color(0xFF1E3A8A),
      'bgLight': Color(0xFFEFF6FF),
    },
    {
      'title': 'Quarterly Rental Yield',
      'subtitle': 'Earn up to 8.5% p.a. distributed quarterly into your account',
      'badge': 'YIELD',
      'icon': Icons.trending_up_rounded,
      'color': Color(0xFF8B5CF6),
      'bgDark': Color(0xFF4C1D95),
      'bgLight': Color(0xFFF5F3FF),
    },
    {
      'title': '100% MCA Protected SPV',
      'subtitle': 'Direct LLP partnership filed with Ministry of Corporate Affairs',
      'badge': 'MCA SAFE',
      'icon': Icons.verified_user_rounded,
      'color': Color(0xFF14B8A6),
      'bgDark': Color(0xFF134E4A),
      'bgLight': Color(0xFFF0FDFA),
    },
    {
      'title': 'Zero Brokerage & Direct Custody',
      'subtitle': 'Direct fractional ownership with 0 brokerage or hidden transaction fees',
      'badge': '0% FEE',
      'icon': Icons.verified_rounded,
      'color': Color(0xFFF59E0B),
      'bgDark': Color(0xFF78350F),
      'bgLight': Color(0xFFFFFBEB),
    },
    {
      'title': 'CBRE & JLL Valuations',
      'subtitle': 'Institutional grade appraisal reports included for every asset',
      'badge': 'VERIFIED',
      'icon': Icons.apartment_rounded,
      'color': Color(0xFF6366F1),
      'bgDark': Color(0xFF312E81),
      'bgLight': Color(0xFFEEF2FF),
    },
    {
      'title': 'Flexible 12M Exit Window',
      'subtitle': 'Sell or transfer your property bricks with 0 penalty after 1 year',
      'badge': 'EXIT',
      'icon': Icons.swap_horiz_rounded,
      'color': Color(0xFFF43F5E),
      'bgDark': Color(0xFF881337),
      'bgLight': Color(0xFFFFF1F2),
    },
  ];

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 4), (timer) {
      if (_pageController.hasClients) {
        final next = (_currentPage + 1) % _benefits.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;

    return Column(
      children: [
        SizedBox(
          height: 68,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _benefits.length,
            onPageChanged: (idx) {
              setState(() => _currentPage = idx);
            },
            itemBuilder: (context, index) {
              final b = _benefits[index];
              final Color accentColor = b['color'] as Color;
              final Color bgColor = dark
                  ? (b['bgDark'] as Color).withOpacity(0.4)
                  : (b['bgLight'] as Color);

              return Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: accentColor.withOpacity(0.3), width: 1.2),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: accentColor.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        b['icon'] as IconData,
                        color: accentColor,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                                                    Row(
                            children: [
                              Flexible(
                                child: Text(
                                  b['title'] as String,
                                  style: TextStyle(
                                    color: dark ? Colors.white : const Color(0xFF0F172A),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: accentColor.withOpacity(0.18),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  b['badge'] as String,
                                  style: TextStyle(
                                    color: accentColor,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Text(
                            b['subtitle'] as String,
                            style: TextStyle(
                              color: textS,
                              fontSize: 11,
                              height: 1.2,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF1E293B) : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: accentColor.withOpacity(0.3)),
                      ),
                      child: Text(
                        '${index + 1}/${_benefits.length}',
                        style: TextStyle(
                          color: accentColor,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),

        // Dot indicators
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_benefits.length, (i) {
            final active = _currentPage == i;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.symmetric(horizontal: 2.5),
              width: active ? 16 : 5,
              height: 4,
              decoration: BoxDecoration(
                color: active
                    ? const Color(0xFF10B981)
                    : (dark ? const Color(0xFF334155) : const Color(0xFFCBD5E1)),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
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

// ─── Gallery with Auto Image Slider ──────────────────────────────────────────
class _GallerySection extends StatefulWidget {
  const _GallerySection({required this.property});
  final PropertyModel property;

  @override
  State<_GallerySection> createState() => _GallerySectionState();
}

class _GallerySectionState extends State<_GallerySection> {
  late final PageController _pageController;
  Timer? _sliderTimer;
  final PropertyDetailController controller = Get.find<PropertyDetailController>();

  List<PropertyImage> get images => widget.property.images;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: controller.currentImg.value);
    _startTimer();
  }

  void _startTimer() {
    _sliderTimer?.cancel();
    if (images.length > 1) {
      _sliderTimer = Timer.periodic(const Duration(milliseconds: 3500), (_) {
        if (!mounted || !_pageController.hasClients) return;
        final next = (controller.currentImg.value + 1) % images.length;
        _pageController.animateToPage(
          next,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      });
    }
  }

  void _pauseTimer() {
    _sliderTimer?.cancel();
  }

  @override
  void dispose() {
    _sliderTimer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

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
    return Listener(
      onPointerDown: (_) => _pauseTimer(),
      onPointerUp: (_) => _startTimer(),
      onPointerCancel: (_) => _startTimer(),
      child: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: images.length,
            onPageChanged: controller.setImage,
            itemBuilder: (_, i) => Image.network(
              images[i].url,
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, error, stackTrace) => Container(
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
                  color: widget.property.isDirectBuyOnly
                      ? const Color(0xFF818CF8)
                      : (widget.property.isBricksOnly
                            ? const Color(0xFF34D399)
                            : AppColors.accent),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    widget.property.isDirectBuyOnly
                        ? Icons.business_rounded
                        : (widget.property.isBricksOnly
                              ? Icons.grid_view_rounded
                              : Icons.stars_rounded),
                    color: widget.property.isDirectBuyOnly
                        ? const Color(0xFF818CF8)
                        : (widget.property.isBricksOnly
                              ? const Color(0xFF34D399)
                              : AppColors.accent),
                    size: 13,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    widget.property.isDirectBuyOnly
                        ? 'Full Ownership Only'
                        : (widget.property.isBricksOnly
                              ? 'Bricks Investment'
                              : 'Bricks + Full Buy'),
                    style: TextStyle(
                      color: widget.property.isDirectBuyOnly
                          ? const Color(0xFFC7D2FE)
                          : (widget.property.isBricksOnly
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
      ),
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
                      ? () => showScheduleCallSheet(
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
                                available > 0 ? 'Schedule a Call (100% Ownership) →' : 'Sold Out',
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
                    'Speak with an investment advisor · Dedicated NRI & HNIs desk',
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
                              'Property Price ($_brickQty Brick${_brickQty > 1 ? "s" : ""})',
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
                                style: TextStyle(
                                  color: textP,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
                          Row(
                            children: [
                              Text(
                                'Platform Fee',
                                style: TextStyle(
                                  color: textS,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF2563EB).withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                                ),
                                child: const Text(
                                  '1%',
                                  style: TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '₹${(_brickQty > 0 ? (subtotal * 0.01).round() : 0).toLocaleString()}',
                                style: TextStyle(
                                  color: textP,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
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
                              'Total Payable Amount',
                              style: TextStyle(
                                color: textP,
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                '₹${(subtotal + (_brickQty > 0 ? (subtotal * 0.01).round() : 0)).toLocaleString()}',
                                style: const TextStyle(
                                  color: Color(0xFF2563EB),
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
                                    ? 'Buy $_brickQty Brick${_brickQty > 1 ? "s" : ""} · ₹${(subtotal + (_brickQty > 0 ? (subtotal * 0.01).round() : 0)).toLocaleString()} →'
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
              builder: (_, val, child) {
                final qty = int.tryParse(val.text) ?? 0;
                final subtotal = qty * brickPrice;
                final platformFee = qty > 0 ? (subtotal * 0.01).round() : 0;
                final totalPayable = subtotal + platformFee;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (qty > 0) ...[
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1E2838) : const Color(0xFFF8FAFC),
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
                                Text(
                                  'Property Price ($qty Brick${qty > 1 ? "s" : ""})',
                                  style: TextStyle(color: textS, fontSize: 13, fontWeight: FontWeight.w600),
                                ),
                                Text(
                                  '₹${subtotal.toLocaleString()}',
                                  style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      'Platform Fee',
                                      style: TextStyle(color: textS, fontSize: 13, fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF2563EB).withOpacity(0.12),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(color: const Color(0xFF2563EB).withOpacity(0.3)),
                                      ),
                                      child: const Text(
                                        '1%',
                                        style: TextStyle(
                                          color: Color(0xFF2563EB),
                                          fontSize: 10,
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Text(
                                  '₹${platformFee.toLocaleString()}',
                                  style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w700),
                                ),
                              ],
                            ),
                            const Divider(height: 18),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Total Payable Amount',
                                  style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w800),
                                ),
                                Text(
                                  '₹${totalPayable.toLocaleString()}',
                                  style: const TextStyle(
                                    color: Color(0xFF2563EB),
                                    fontSize: 17,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        '${((qty / (property.totalBricks ?? 1)) * 100).toStringAsFixed(2)}% ownership',
                        style: TextStyle(color: textS, fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 14),
                      _ReturnsProjection(
                        principal: subtotal,
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
  showScheduleCallSheet(
    context: context,
    controller: controller,
    property: property,
    dark: dark,
  );
}

void showScheduleCallSheet({
  required BuildContext context,
  required PropertyDetailController controller,
  required PropertyModel property,
  required bool dark,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (sheetCtx) => _ScheduleCallSheet(property: property, dark: dark),
  );
}

/// "Request Callback" bottom sheet (matches schedule_call_ref.png).
/// Advisor title/subtitle/photo, time slots and number of days are admin-configurable per property.
class _ScheduleCallSheet extends StatefulWidget {
  const _ScheduleCallSheet({required this.property, required this.dark});
  final PropertyModel property;
  final bool dark;

  @override
  State<_ScheduleCallSheet> createState() => _ScheduleCallSheetState();
}

class _ScheduleCallSheetState extends State<_ScheduleCallSheet> {
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  static const _months = ['JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN', 'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC'];

  late final List<DateTime> _dates;
  late final List<String> _slots;
  int? _dateIdx;
  String? _slot;
  bool _submitting = false;
  String? _error;
  final _phoneCtrl = TextEditingController();
  String _userName = 'Investor';
  String _userEmail = '';
  bool _needPhone = true;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    _dates = List.generate(widget.property.scheduleDays, (i) => today.add(Duration(days: i)));
    _slots = widget.property.scheduleSlots;
    try {
      final u = Get.find<AuthController>().user.value;
      if (u != null) {
        _userName = (u.name).toString().trim().isNotEmpty ? u.name : 'Investor';
        _userEmail = (u.email).toString();
        final ph = (u.phone ?? '').toString().trim();
        if (ph.isNotEmpty) {
          _phoneCtrl.text = ph;
          _needPhone = false;
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _phoneCtrl.dispose();
    super.dispose();
  }

  bool get _canConfirm => _dateIdx != null && _slot != null && !_submitting;

  Future<void> _submit() async {
    final phone = _phoneCtrl.text.trim();
    if (phone.replaceAll(RegExp(r'[^0-9]'), '').length < 10) {
      setState(() {
        _needPhone = true;
        _error = 'Please enter a valid 10-digit phone number.';
      });
      return;
    }
    final d = _dates[_dateIdx!];
    final dateStr = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    final prettyDate = '${_days[d.weekday - 1]} ${d.day.toString().padLeft(2, '0')} ${_months[d.month - 1]}';
    final p = widget.property;

    setState(() {
      _submitting = true;
      _error = null;
    });
    try {
      final res = await ApiClient.instance.post(
        ApiConstants.enquiries,
        data: {
          'name': _userName,
          if (_userEmail.contains('@')) 'email': _userEmail,
          'phone': phone,
          'subject': 'Callback Request - ${p.title}',
          'message': 'Investor requested an advisor callback for "${p.title}" on $prettyDate at $_slot.',
          'type': 'full_ownership_lead',
          'propertyId': p.id,
          'propertyTitle': p.title,
          'preferredDate': dateStr,
          'preferredTime': _slot,
          'source': 'app',
        },
      );
      final ok = res.data is Map ? (res.data['success'] != false) : true;
      if (!ok) throw Exception(res.data['message'] ?? 'Request failed');
      if (!mounted) return;
      Navigator.of(context).pop();
      _showSuccess(prettyDate);
    } catch (e) {
      String msg = 'Could not schedule the call. Please check your internet and try again.';
      try {
        final dynamic err = e;
        final data = err.response?.data;
        if (data is Map && data['message'] != null) msg = data['message'].toString();
      } catch (_) {}
      if (mounted) {
        setState(() {
          _submitting = false;
          _error = msg;
        });
      }
    }
  }

  void _showSuccess(String prettyDate) {
    final dark = widget.dark;
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        backgroundColor: dark ? DarkColors.surface : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF10B981), size: 36),
              ),
              const SizedBox(height: 16),
              Text(
                'Callback Scheduled!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: dark ? DarkColors.textPrimary : AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Our advisor will call you on $prettyDate at $_slot regarding "${widget.property.title}".',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.45,
                  color: dark ? DarkColors.textSecondary : AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(Get.overlayContext ?? Get.context!).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: dark ? Colors.white : const Color(0xFF111111),
                    foregroundColor: dark ? Colors.black : Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                  child: const Text('Got it', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final p = widget.property;
    final bg = dark ? DarkColors.surface : Colors.white;
    final textP = dark ? DarkColors.textPrimary : const Color(0xFF111111);
    final textS = dark ? DarkColors.textSecondary : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF334155) : const Color(0xFFE5E7EB);
    final selBorder = dark ? Colors.white : const Color(0xFF111111);
    final selFill = dark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6);
    final mq = MediaQuery.of(context);

    Widget sectionTitle(String t) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(t, style: TextStyle(color: textP, fontSize: 16, fontWeight: FontWeight.w600)),
        );

    final img = (p.scheduleAdvisorImage ?? '').trim();
    final advisorAvatar = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: 72,
        height: 72,
        child: img.isNotEmpty
            ? Image.network(
                img,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _advisorFallback(dark),
              )
            : _advisorFallback(dark),
      ),
    );

    return Container(
      constraints: BoxConstraints(maxHeight: mq.size.height * 0.92),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(bottom: mq.viewInsets.bottom),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF475569) : const Color(0xFF374151),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 18),
            Text('Request Callback', style: TextStyle(color: textP, fontSize: 20, fontWeight: FontWeight.w700)),
            const SizedBox(height: 16),
            Divider(height: 1, color: border),
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Advisor
                    Row(
                      children: [
                        advisorAvatar,
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(p.scheduleTitle,
                                  style: TextStyle(color: textP, fontSize: 15, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text(p.scheduleSubtitle,
                                  style: TextStyle(color: textS, fontSize: 13.5, height: 1.3)),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Dates
                    sectionTitle('Select date'),
                    SizedBox(
                      height: 92,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _dates.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final d = _dates[i];
                          final sel = _dateIdx == i;
                          return GestureDetector(
                            onTap: () => setState(() {
                              _dateIdx = i;
                              _error = null;
                            }),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 160),
                              width: 64,
                              decoration: BoxDecoration(
                                color: sel ? selFill : bg,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: sel ? selBorder : border, width: sel ? 1.6 : 1),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(_days[d.weekday - 1],
                                      style: TextStyle(color: sel ? textP : textS, fontSize: 13, fontWeight: FontWeight.w500)),
                                  const SizedBox(height: 4),
                                  Text(d.day.toString().padLeft(2, '0'),
                                      style: TextStyle(
                                          color: sel ? textP : textS, fontSize: 20, fontWeight: FontWeight.w700)),
                                  const SizedBox(height: 4),
                                  Text(_months[d.month - 1],
                                      style: TextStyle(color: sel ? textP : textS, fontSize: 10, fontWeight: FontWeight.w500)),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Times
                    sectionTitle('Select time'),
                    LayoutBuilder(builder: (_, c) {
                      const gap = 12.0;
                      final w = (c.maxWidth - gap * 2) / 3;
                      return Wrap(
                        spacing: gap,
                        runSpacing: gap,
                        children: [
                          for (final s in _slots)
                            GestureDetector(
                              onTap: () => setState(() {
                                _slot = s;
                                _error = null;
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 160),
                                width: w,
                                padding: const EdgeInsets.symmetric(vertical: 11),
                                decoration: BoxDecoration(
                                  color: _slot == s ? selFill : bg,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                      color: _slot == s ? selBorder : border, width: _slot == s ? 1.6 : 1),
                                ),
                                alignment: Alignment.center,
                                child: Text(s,
                                    style: TextStyle(
                                      color: _slot == s ? textP : textS,
                                      fontSize: 14,
                                      fontWeight: _slot == s ? FontWeight.w600 : FontWeight.w400,
                                    )),
                              ),
                            ),
                        ],
                      );
                    }),

                    // Phone (only if not on profile, or invalid)
                    if (_needPhone) ...[
                      const SizedBox(height: 22),
                      sectionTitle('Phone number'),
                      TextField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        maxLength: 13,
                        style: TextStyle(color: textP, fontSize: 14),
                        decoration: InputDecoration(
                          counterText: '',
                          hintText: 'Number for advisor callback',
                          hintStyle: TextStyle(color: textS),
                          prefixIcon: Icon(Icons.phone_rounded, color: textS, size: 18),
                          isDense: true,
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: border)),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: selBorder)),
                        ),
                      ),
                    ],

                    if (_error != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEF4444).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(_error!,
                            style: const TextStyle(color: Color(0xFFEF4444), fontSize: 12.5, fontWeight: FontWeight.w600)),
                      ),
                    ],
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: TextButton(
                        onPressed: _submitting ? null : () => Navigator.of(context).pop(),
                        style: TextButton.styleFrom(
                          backgroundColor: dark ? const Color(0xFF1F2937) : const Color(0xFFF3F4F6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(color: border),
                          ),
                        ),
                        child: Text('Cancel',
                            style: TextStyle(color: textS, fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _canConfirm ? _submit : null,
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          backgroundColor: dark ? Colors.white : const Color(0xFF111111),
                          foregroundColor: dark ? Colors.black : Colors.white,
                          disabledBackgroundColor: dark ? const Color(0xFF374151) : const Color(0xFFA3A3A3),
                          disabledForegroundColor: dark ? const Color(0xFF6B7280) : const Color(0xFFD4D4D4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: _submitting
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: dark ? Colors.black : Colors.white),
                              )
                            : const Text('Confirm', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _advisorFallback(bool dark) => Container(
        color: dark ? const Color(0xFF1E293B) : const Color(0xFFEEF2FF),
        child: Icon(Icons.support_agent_rounded,
            size: 38, color: dark ? const Color(0xFFA5B4FC) : const Color(0xFF4F46E5)),
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
                title: (property.targetXirr ?? 0) > 0 ? 'Target XIRR' : 'Target Growth',
                value: (property.targetXirr ?? 0) > 0 ? '${property.targetXirr}%' : '${property.expectedAppreciation}% p.a.',
                subtitle: (property.targetXirr ?? 0) > 0 ? 'Annualized Return' : 'Capital Growth',
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
  const _InvestmentSimulator({
    required this.property,
    required this.dark,
    this.isExpanded = false,
    this.onToggle,
  });
  final PropertyModel property;
  final bool dark;
  final bool isExpanded;
  final VoidCallback? onToggle;

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
          InkWell(
            onTap: widget.onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Row(
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Investment Return Calculator',
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
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textP,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
            crossFadeState: widget.isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                Divider(color: borderColor.withOpacity(0.6), height: 1),
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
          ),
        ],
      ),
    );
  }
}

// ─── Institutional Trust & Protection Card (Screenshots 1-4 Feature) ─────────
class _InstitutionalTrustCard extends StatelessWidget {
  const _InstitutionalTrustCard({
    required this.dark,
    required this.property,
    this.isExpanded = false,
    this.onToggle,
  });

  final bool dark;
  final PropertyModel property;
  final bool isExpanded;
  final VoidCallback? onToggle;

  @override
  Widget build(BuildContext context) {
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.25 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_rounded,
                    color: Color(0xFF10B981),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'How Is Your Investment Protected',
                        style: TextStyle(
                          color: textP,
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Institutional safeguards & SEBI-regulated escrow',
                        style: TextStyle(
                          color: textS,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textP,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Divider(color: borderColor.withOpacity(0.6), height: 1),
                const SizedBox(height: 16),

          // Row 1: ICICI / Dynamic escrow account
          _ProtectionInteractiveRow(
            icon: Icons.account_balance_rounded,
            iconBg: const Color(0xFFF97316).withOpacity(dark ? 0.2 : 0.1),
            iconColor: const Color(0xFFF97316),
            title: '${property.spvEscrowBank.isNotEmpty ? property.spvEscrowBank : "ICICI Bank"} escrow account',
            subtitle:
                'Funds are routed through an ${property.spvEscrowBank.isNotEmpty ? property.spvEscrowBank : "ICICI Bank"} escrow account with no direct access by platform',
            badgeText: (property.spvEscrowCertificateUrl != null && property.spvEscrowCertificateUrl!.isNotEmpty)
                ? 'PDF ATTACHED'
                : null,
            dark: dark,
            onTap: () => _showIciciEscrowSheet(context, property, dark),
          ),
          const SizedBox(height: 12),

          // Row 2: Universal Trustee (Screenshot 1 & 3)
          _ProtectionInteractiveRow(
            icon: Icons.shield_rounded,
            iconBg: const Color(0xFF3B82F6).withOpacity(dark ? 0.2 : 0.1),
            iconColor: const Color(0xFF3B82F6),
            title: property.trusteeShortName,
            subtitle:
                '${property.spvTrusteeName} acts as an independent SEBI-registered trustee safeguarding investor interests',
            badgeText: (property.spvTrusteeCertificateUrl != null && property.spvTrusteeCertificateUrl!.isNotEmpty)
                ? 'PDF ATTACHED'
                : null,
            dark: dark,
            onTap: () => _showUniversalTrusteeSheet(context, property, dark),
          ),
          const SizedBox(height: 12),

          // Row 3: Buy and Sell anytime (Screenshot 1 & 4)
          _ProtectionInteractiveRow(
            icon: Icons.sync_alt_rounded,
            iconBg: const Color(0xFF10B981).withOpacity(dark ? 0.2 : 0.1),
            iconColor: const Color(0xFF10B981),
            title: 'Buy and Sell anytime',
            subtitle:
                'Liquidity window allows investors to sell their fractional units or buy more at fair market value',
            dark: dark,
            onTap: () => _showBuySellAnytimeSheet(context, property, dark),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionInteractiveRow extends StatelessWidget {
  const _ProtectionInteractiveRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.dark,
    required this.onTap,
    this.badgeText,
  });

  final String? badgeText;

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final rowBg = dark ? const Color(0xFF142033) : const Color(0xFFF8FAFC);
    final rowBorder = dark ? const Color(0xFF1E2E4A) : const Color(0xFFE2E8F0);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: rowBg,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: rowBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            title,
                            style: TextStyle(
                              color: textP,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        if (badgeText != null) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFF10B981).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              badgeText!,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textS,
                        fontSize: 11.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Icon(
                  Icons.chevron_right_rounded,
                  color: dark ? Colors.white54 : Colors.black45,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── ICICI Bank Escrow Certificate Modal (Screenshot 2) ──────────────────────
void _showIciciEscrowSheet(
  BuildContext context,
  PropertyModel property,
  bool dark,
) {
  final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
  final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
  final sheetBg = dark ? const Color(0xFF0F172A) : Colors.white;
  final cardBg = dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  final borderC = dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  final hasPdf = property.spvEscrowCertificateUrl != null &&
      property.spvEscrowCertificateUrl!.trim().isNotEmpty;
  final escrowBank = property.spvEscrowBank.isNotEmpty ? property.spvEscrowBank : 'ICICI Bank';

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            // Drag handle
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 14, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF97316).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.account_balance_rounded,
                      color: Color(0xFFF97316),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '$escrowBank escrow account',
                          style: TextStyle(
                            color: textP,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'Dedicated institutional bank holding certificate',
                          style: TextStyle(color: textS, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: textS,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            // Certificate Details
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prominent Uploaded PDF Preview Card
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF142033) : const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasPdf
                              ? const Color(0xFFF97316).withOpacity(0.4)
                              : (dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    hasPdf ? 'Official Bank Certificate PDF' : 'Certificate Pending Upload',
                                    style: TextStyle(
                                      color: textP,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: hasPdf
                                      ? const Color(0xFF10B981).withOpacity(0.15)
                                      : Colors.grey.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  hasPdf ? 'PDF ATTACHED' : 'PENDING',
                                  style: TextStyle(
                                    color: hasPdf ? const Color(0xFF10B981) : textS,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (hasPdf) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Official $escrowBank escrow account holding document verified and digitally signed.',
                              style: TextStyle(color: textS, fontSize: 11, height: 1.35),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.visibility_rounded, size: 15),
                                    label: const Text('Preview PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFF97316),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _previewPdfDocument(property.spvEscrowCertificateUrl,
                                      '$escrowBank Escrow Certificate',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.download_rounded, size: 15),
                                    label: const Text('Download', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFFF97316),
                                      side: const BorderSide(color: Color(0xFFF97316)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _downloadPdfDocument(
                                      property.spvEscrowCertificateUrl,
                                      '$escrowBank Escrow Certificate',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    // Certificate Container matching Screenshot 2
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderC),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
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
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF97316),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      escrowBank,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    property.escrowDivision,
                                    style: TextStyle(
                                      color: textS,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'SEBI ESCROW',
                                  style: TextStyle(
                                    color: Color(0xFF10B981),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'ACCOUNT HOLDING CERTIFICATE',
                            style: TextStyle(
                              color: textP,
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'TO WHOMSOEVER IT MAY CONCERN',
                            style: TextStyle(
                              color: textS,
                              fontSize: 10.5,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                          const SizedBox(height: 14),

                          _CertDetailRow(
                            label: 'Account Name',
                            value: property.escrowAccountName,
                            textP: textP,
                            textS: textS,
                          ),
                          _CertDetailRow(
                            label: 'Account Number',
                            value: property.spvEscrowAccountNo,
                            textP: textP,
                            textS: textS,
                            isMonospace: true,
                          ),
                          _CertDetailRow(
                            label: 'Account Type',
                            value: property.escrowAccountType,
                            textP: textP,
                            textS: textS,
                          ),
                          _CertDetailRow(
                            label: 'IFSC Code',
                            value: property.spvEscrowIfsc,
                            textP: textP,
                            textS: textS,
                            isMonospace: true,
                          ),
                          _CertDetailRow(
                            label: 'Bank Branch',
                            value: property.spvEscrowBranch,
                            textP: textP,
                            textS: textS,
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: dark
                                  ? const Color(0xFF0F172A)
                                  : Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: borderC),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.verified_rounded,
                                  color: Color(0xFF10B981),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    property.escrowNote,
                                    style: TextStyle(
                                      color: textS,
                                      fontSize: 10.5,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Key Escrow Safeguards',
                      style: TextStyle(
                        color: textP,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final s in property.escrowSafeguards)
                      _EscrowBullet(text: s, dark: dark),
                  ],
                ),
              ),
            ),

            // Bottom action buttons: Preview PDF + Download
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text(
                          'Preview Official PDF',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF97316),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          _previewPdfDocument(property.spvEscrowCertificateUrl,
                            '$escrowBank Escrow Certificate',
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textP,
                          side: BorderSide(color: borderC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          _downloadPdfDocument(
                            property.spvEscrowCertificateUrl,
                            '$escrowBank Escrow Certificate',
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
// ─── Universal Trustee Appointment Certificate Modal (Screenshot 3) ──────────
void _showUniversalTrusteeSheet(
  BuildContext context,
  PropertyModel property,
  bool dark,
) {
  final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
  final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
  final sheetBg = dark ? const Color(0xFF0F172A) : Colors.white;
  final cardBg = dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  final borderC = dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
  final hasPdf = property.spvTrusteeCertificateUrl != null &&
      property.spvTrusteeCertificateUrl!.trim().isNotEmpty;

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.90,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 14, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF3B82F6).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.security_rounded,
                      color: Color(0xFF3B82F6),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          property.trusteeShortName,
                          style: TextStyle(
                            color: textP,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          property.trusteeTagline,
                          style: TextStyle(color: textS, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: textS,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Prominent Uploaded Trustee PDF Preview Card
                    Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF142033) : const Color(0xFFEFF6FF),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: hasPdf
                              ? const Color(0xFF3B82F6).withOpacity(0.4)
                              : (dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0)),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.picture_as_pdf_rounded,
                                    color: Color(0xFFEF4444),
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    hasPdf ? 'Official Trustee Appointment PDF' : 'Certificate Pending Upload',
                                    style: TextStyle(
                                      color: textP,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: hasPdf
                                      ? const Color(0xFF10B981).withOpacity(0.15)
                                      : Colors.grey.withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  hasPdf ? 'PDF ATTACHED' : 'PENDING',
                                  style: TextStyle(
                                    color: hasPdf ? const Color(0xFF10B981) : textS,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (hasPdf) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Official appointment deed appointing ${property.spvTrusteeName} as custodian.',
                              style: TextStyle(color: textS, fontSize: 11, height: 1.35),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    icon: const Icon(Icons.visibility_rounded, size: 15),
                                    label: const Text('Preview PDF', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF3B82F6),
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _previewPdfDocument(property.spvTrusteeCertificateUrl,
                                      'Universal Trustee Appointment Certificate',
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.download_rounded, size: 15),
                                    label: const Text('Download', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: const Color(0xFF3B82F6),
                                      side: const BorderSide(color: Color(0xFF3B82F6)),
                                      padding: const EdgeInsets.symmetric(vertical: 10),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                    ),
                                    onPressed: () => _downloadPdfDocument(
                                      property.spvTrusteeCertificateUrl,
                                      'Universal Trustee Appointment Certificate',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: borderC),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      property.trusteeShortName.toUpperCase(),
                                      style: const TextStyle(
                                        color: Color(0xFF3B82F6),
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w900,
                                        letterSpacing: 0.5,
                                      ),
                                    ),
                                    Text(
                                      property.trusteeRegNo,
                                      style: TextStyle(
                                        color: textS,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF3B82F6).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'OFFICIAL TRUSTEE',
                                  style: TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'CERTIFICATE OF APPOINTMENT AS TRUSTEE',
                            style: TextStyle(
                              color: textP,
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            property.trusteeCertificateText,
                            style: TextStyle(
                              color: textS,
                              fontSize: 11.5,
                              height: 1.45,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'The Trustee holds the legal charge over the asset on behalf of fractional investors, supervises escrow accounts, and ensures rent & exit distributions follow strict fiduciary compliance.',
                            style: TextStyle(
                              color: textS,
                              fontSize: 11,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 14),
                          _CertDetailRow(
                            label: 'Trustee Name',
                            value: property.spvTrusteeName,
                            textP: textP,
                            textS: textS,
                          ),
                          _CertDetailRow(
                            label: 'Registered Office',
                            value: property.spvTrusteeAddress,
                            textP: textP,
                            textS: textS,
                          ),
                          _CertDetailRow(
                            label: 'Beneficiaries',
                            value: property.trusteeBeneficiaries,
                            textP: textP,
                            textS: textS,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    Text(
                      'Role of the Trustee',
                      style: TextStyle(
                        color: textP,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 10),
                    for (final r in property.trusteeRoles)
                      _EscrowBullet(text: r, dark: dark),
                  ],
                ),
              ),
            ),

            // Bottom action buttons: Preview PDF + Download
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.visibility_rounded, size: 18),
                        label: const Text(
                          'Preview Official PDF',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF3B82F6),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          _previewPdfDocument(property.spvTrusteeCertificateUrl,
                            'Universal Trustee Appointment Certificate',
                          );
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: SizedBox(
                      height: 48,
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text(
                          'Download',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: textP,
                          side: BorderSide(color: borderC),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        onPressed: () {
                          _downloadPdfDocument(
                            property.spvTrusteeCertificateUrl,
                            'Universal Trustee Appointment Certificate',
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
// ─── Buy & Sell Anytime Bottom Sheet (Screenshot 4) ──────────────────────────
void _showBuySellAnytimeSheet(
  BuildContext context,
  PropertyModel property,
  bool dark,
) {
  final textP = dark ? DarkColors.textPrimary : AppColors.textPrimary;
  final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
  final sheetBg = dark ? const Color(0xFF0F172A) : Colors.white;
  final cardBg = dark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC);
  final borderC = dark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.88,
        ),
        decoration: BoxDecoration(
          color: sheetBg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 44,
                height: 4,
                decoration: BoxDecoration(
                  color: dark ? Colors.white24 : Colors.black26,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 14, 12),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF10B981).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.sync_alt_rounded,
                      color: Color(0xFF10B981),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Buy and Sell anytime',
                          style: TextStyle(
                            color: textP,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          'VikaDrx Liquidity & Secondary Market Mechanism',
                          style: TextStyle(color: textS, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    color: textS,
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    _LiquidityCard(
                      icon: Icons.add_shopping_cart_rounded,
                      iconColor: const Color(0xFF3B82F6),
                      title: 'Buy Anytime',
                      desc:
                          'Invest in fractional bricks anytime during open windows. Choose from 1 brick to full property allocations with seamless instant payment.',
                      dark: dark,
                      cardBg: cardBg,
                      borderC: borderC,
                      textP: textP,
                      textS: textS,
                    ),
                    const SizedBox(height: 12),
                    _LiquidityCard(
                      icon: Icons.sell_rounded,
                      iconColor: const Color(0xFFF97316),
                      title: 'Sell Anytime',
                      desc:
                          'List your verified fractional bricks on the VikaDrx Secondary Market at current NAV valuation or fair market clearing price without lock-in penalties.',
                      dark: dark,
                      cardBg: cardBg,
                      borderC: borderC,
                      textP: textP,
                      textS: textS,
                    ),
                    const SizedBox(height: 12),
                    _LiquidityCard(
                      icon: Icons.bolt_rounded,
                      iconColor: const Color(0xFFEAB308),
                      title: 'Instant Buyer Match',
                      desc:
                          'Our peer-to-peer liquidity protocol pairs your sell orders with incoming prospective buyers and institutional liquidity pools for quick settlements.',
                      dark: dark,
                      cardBg: cardBg,
                      borderC: borderC,
                      textP: textP,
                      textS: textS,
                    ),
                    const SizedBox(height: 12),
                    _LiquidityCard(
                      icon: Icons.receipt_long_rounded,
                      iconColor: const Color(0xFF10B981),
                      title: 'Tax Implications & Transfer',
                      desc:
                          'TDS deductions and capital gains are handled transparently as per IT Act guidelines for SPV fractional real estate. Ownership transfers execute seamlessly.',
                      dark: dark,
                      cardBg: cardBg,
                      borderC: borderC,
                      textP: textP,
                      textS: textS,
                    ),

                    if (property.spvLiquidityPolicy != null &&
                        property.spvLiquidityPolicy!.trim().isNotEmpty) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.08),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF10B981).withOpacity(0.25),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(
                              Icons.info_outline_rounded,
                              color: Color(0xFF10B981),
                              size: 18,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                property.spvLiquidityPolicy!,
                                style: TextStyle(
                                  color: textP,
                                  fontSize: 11.5,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Understood & Close',
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    },
  );
}

// ─── Helpers for Protection Sheets ────────────────────────────────────────────
class _CertDetailRow extends StatelessWidget {
  const _CertDetailRow({
    required this.label,
    required this.value,
    required this.textP,
    required this.textS,
    this.isMonospace = false,
  });

  final String label;
  final String value;
  final Color textP;
  final Color textS;
  final bool isMonospace;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: textS,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: textP,
                fontSize: 11.5,
                fontWeight: FontWeight.w700,
                fontFamily: isMonospace ? 'monospace' : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EscrowBullet extends StatelessWidget {
  const _EscrowBullet({required this.text, required this.dark});
  final String text;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final textS = dark ? DarkColors.textSecondary : AppColors.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 4, right: 8),
            child: Icon(
              Icons.check_circle_rounded,
              color: Color(0xFF10B981),
              size: 14,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: textS,
                fontSize: 11.5,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LiquidityCard extends StatelessWidget {
  const _LiquidityCard({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.desc,
    required this.dark,
    required this.cardBg,
    required this.borderC,
    required this.textP,
    required this.textS,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String desc;
  final bool dark;
  final Color cardBg;
  final Color borderC;
  final Color textP;
  final Color textS;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderC),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textP,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  desc,
                  style: TextStyle(
                    color: textS,
                    fontSize: 11,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

    return Material(
      elevation: 20,
      color: barBg,
      child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Real DRX Wallet balance banner (only shown if user has active positive DRX balance)
        Builder(
          builder: (context) {
            if (!Get.isRegistered<WalletController>()) return const SizedBox.shrink();
            final wCtrl = WalletController.to;
            return Obx(() {
              final bal = wCtrl.wallet.value?.availableBalance ?? 0.0;
              if (bal <= 0) return const SizedBox.shrink();
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 16),
                color: const Color(0xFF064E3B),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.account_balance_wallet_rounded, color: Color(0xFF10B981), size: 14),
                    const SizedBox(width: 6),
                    Text(
                      'Vika DRX Wallet: ₹${bal.toStringAsFixed(0)}. Auto-applied on checkout',
                      style: const TextStyle(
                        color: Color(0xFFA7F3D0),
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              );
            });
          },
        ),
        Container(
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
                  onTap: () => showScheduleCallSheet(
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
                          Icons.phone_in_talk_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Schedule Call',
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
                  onTap: () => showScheduleCallSheet(
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
                          Icons.calendar_month_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Schedule a Call (100%)',
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
                        SizedBox(width: 7),
                        Text(
                          'Buy Bricks',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize: 14.5,
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
    ),
  ],
));
  }
}


// ── Property Video Tour Section (In-Tree Player with True Fullscreen Architecture) ──
class _PropertyVideoSection extends StatefulWidget {
  final String videoId;
  final String? fallbackImageUrl;
  final bool dark;
  const _PropertyVideoSection({
    required this.videoId,
    this.fallbackImageUrl,
    required this.dark,
  });

  @override
  State<_PropertyVideoSection> createState() => _PropertyVideoSectionState();
}

class _PropertyVideoSectionState extends State<_PropertyVideoSection> {
  late final YoutubePlayerController _controller;
  bool _isPlaying = false;
  bool _isReady = false;
  bool _isFullScreenOpen = false;
  int _lastExitTime = 0;

  @override
  void initState() {
    super.initState();
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

    // Fullscreen trigger from YouTube iframe player controls
    _controller.setFullScreenListener((isFullscreen) {
      final now = DateTime.now().millisecondsSinceEpoch;
      if (isFullscreen) {
        if (!_isFullScreenOpen && (now - _lastExitTime >= 2500) && mounted) {
          _openFullScreenMode();
        } else {
          // Ignore spurious re-trigger during cooldown or while already open
          _controller.exitFullScreen();
        }
      }
    });

    _initPlayer();
  }

  Future<void> _initPlayer() async {
    try {
      await _controller.initWithParams(params: _controller.params);
      final cleanId = widget.videoId.trim();
      await _controller.cueVideoById(videoId: cleanId);
      if (mounted) {
        setState(() => _isReady = true);
      }
    } catch (e) {
      debugPrint('Error initializing YouTube player controller: $e');
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  void _startPlayback() async {
    setState(() {
      _isPlaying = true;
    });
    final cleanId = widget.videoId.trim();
    if (!_isReady) {
      try {
        await _controller.initWithParams(params: _controller.params);
        _isReady = true;
      } catch (e) {
        debugPrint('Error during player playback init: $e');
      }
    }
    await _controller.loadVideoById(videoId: cleanId);
    await _controller.playVideo();
  }

  Future<void> _openFullScreenMode() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_isFullScreenOpen || (now - _lastExitTime < 2500) || !mounted) return;
    _isFullScreenOpen = true;

    double currentPos = 0.0;
    try {
      if (_isPlaying) {
        currentPos = await _controller.currentTime;
        await _controller.pauseVideo();
      }
    } catch (_) {}

    if (!mounted) {
      _isFullScreenOpen = false;
      return;
    }

    final returnPos = await Navigator.of(context).push<double>(
      MaterialPageRoute(
        builder: (context) => _FullScreenVideoPage(
          videoId: widget.videoId.trim(),
          startSeconds: currentPos,
        ),
      ),
    );

    _lastExitTime = DateTime.now().millisecondsSinceEpoch;
    _isFullScreenOpen = false;

    if (mounted) {
      // Reset full screen option on inline controller
      _controller.exitFullScreen();

      setState(() {
        _isPlaying = true;
      });

      if (returnPos != null && returnPos > 0) {
        try {
          await _controller.seekTo(seconds: returnPos);
          await _controller.playVideo();
        } catch (_) {}
      }
    }
  }

  Future<void> _openExternalYouTube() async {
    final cleanId = widget.videoId.trim();
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

  Widget _buildPlaceholderCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: widget.dark
              ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFF1E293B), const Color(0xFF334155)],
        ),
      ),
      child: const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.video_library_rounded, color: Color(0xFFEF4444), size: 42),
            SizedBox(height: 8),
            Text(
              'Official Property Tour',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThumbnail() {
    final ytThumbnail = 'https://img.youtube.com/vi/${widget.videoId}/hqdefault.jpg';
    final fallbackUrl = widget.fallbackImageUrl;

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          ytThumbnail,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            if (fallbackUrl != null && fallbackUrl.trim().isNotEmpty) {
              return Image.network(
                fallbackUrl.trim(),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildPlaceholderCard(),
              );
            }
            return _buildPlaceholderCard();
          },
        ),
        Container(
          color: Colors.black.withOpacity(0.28),
        ),
        Center(
          child: GestureDetector(
            onTap: _startPlayback,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withOpacity(0.55),
                    blurRadius: 18,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow_rounded,
                color: Colors.white,
                size: 38,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 12,
          left: 12,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.75),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.15)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.play_circle_outline_rounded, color: Colors.white, size: 14),
                SizedBox(width: 5),
                Text(
                  'Tap to play tour',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final textP = widget.dark ? DarkColors.textPrimary : AppColors.textPrimary;
    final textS = widget.dark ? DarkColors.textSecondary : AppColors.textSecondary;
    final borderC = widget.dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return _ThemedCard(
      dark: widget.dark,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEF4444).withOpacity(widget.dark ? 0.2 : 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.play_circle_fill_rounded,
                    color: Color(0xFFEF4444),
                    size: 18,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Property Video Tour',
                        style: TextStyle(
                          color: textP,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        'Watch the official walkthrough & architectural tour',
                        style: TextStyle(
                          color: textS,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
                // Fullscreen Quick Action Button
                GestureDetector(
                  onTap: _openFullScreenMode,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(widget.dark ? 0.2 : 0.1),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.35),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.fullscreen_rounded,
                          color: Color(0xFFEF4444),
                          size: 15,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Fullscreen',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                // Open in External YouTube App
                GestureDetector(
                  onTap: _openExternalYouTube,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEF4444).withOpacity(widget.dark ? 0.15 : 0.08),
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: const Color(0xFFEF4444).withOpacity(0.3),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.open_in_new_rounded,
                          color: Color(0xFFEF4444),
                          size: 12,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'YouTube',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: borderC),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(widget.dark ? 0.35 : 0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(13),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: _isPlaying
                      ? Stack(
                          fit: StackFit.expand,
                          children: [
                            WebViewWidget(
                              controller: _controller.webViewController,
                            ),
                            if (!_isReady)
                              Container(
                                color: Colors.black,
                                child: const Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFEF4444)),
                                  ),
                                ),
                              ),
                          ],
                        )
                      : _buildThumbnail(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dedicated Full-Screen Immersive Landscape Player Page ─────────────────────
class _FullScreenVideoPage extends StatefulWidget {
  final String videoId;
  final double startSeconds;

  const _FullScreenVideoPage({
    required this.videoId,
    this.startSeconds = 0.0,
  });

  @override
  State<_FullScreenVideoPage> createState() => _FullScreenVideoPageState();
}

class _FullScreenVideoPageState extends State<_FullScreenVideoPage> {
  late final YoutubePlayerController _fsController;
  bool _isExiting = false;
  bool _isFsReady = false;

  @override
  void initState() {
    super.initState();
    // 1. Force landscape orientation for cinematic fullscreen experience
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    // 2. Hide status bar and navigation bars for immersive display
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

    // 1. Restore portrait orientation
    await SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    // 2. Restore system UI overlay
    await SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    // 3. Small pause to allow device orientation transition to begin
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
            // Top Navigation & Overlay Controls Bar
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
                      const Text(
                        'Property Video Tour',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          shadows: [
                            Shadow(blurRadius: 6, color: Colors.black),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Exit Fullscreen Button
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

class _AdvisorCard extends StatelessWidget {
  final bool dark;
  final PropertyModel property;
  final PropertyDetailController controller;

  const _AdvisorCard({
    required this.dark,
    required this.property,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final advisorTitle = (property.scheduleAdvisorTitle != null && property.scheduleAdvisorTitle!.trim().isNotEmpty)
        ? property.scheduleAdvisorTitle!.trim()
        : 'Talk to your Advisor';
    final advisorSubtitle = (property.scheduleAdvisorSubtitle != null && property.scheduleAdvisorSubtitle!.trim().isNotEmpty)
        ? property.scheduleAdvisorSubtitle!.trim()
        : "Hello, I'm here to answer all your questions about real estate investing.";
    final advisorImg = (property.scheduleAdvisorImage ?? '').trim();

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      advisorTitle,
                      style: TextStyle(
                        color: textP,
                        fontSize: 16.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      advisorSubtitle,
                      style: TextStyle(
                        color: textS,
                        fontSize: 12.5,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Advisor photo container
              Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFFF1F5F9),
                      border: Border.all(color: const Color(0xFF10B981), width: 2),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF10B981).withOpacity(0.2),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: advisorImg.isNotEmpty
                          ? Image.network(
                              advisorImg,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.person, color: Color(0xFF64748B), size: 36),
                              ),
                            )
                          : Image.network(
                              'https://images.unsplash.com/photo-1573496359142-b8d87734a5a2?auto=format&fit=crop&w=200&q=80',
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(
                                child: Icon(Icons.person, color: Color(0xFF64748B), size: 36),
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '• Expert Advisor',
                      style: TextStyle(
                        color: textP,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => showScheduleCallSheet(
              context: context,
              controller: controller,
              property: property,
              dark: dark,
            ),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF020617) : const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.35 : 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.phone_in_talk_rounded, color: Colors.white, size: 16),
                  SizedBox(width: 8),
                  Text(
                    'Schedule a call',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
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

// ══════════════════════════════════════════════════════════════════
// Projected Returns Bar Chart (VikaDrx Style - Screenshot 5)
// ══════════════════════════════════════════════════════════════════
class _ProjectedReturnsBarChart extends StatelessWidget {
  final bool dark;
  const _ProjectedReturnsBarChart({required this.dark});

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final bars = [
      {'year': '3Y', 'pct': '+27%', 'height': 85.0},
      {'year': '5Y', 'pct': '+42%', 'height': 125.0},
      {'year': '7Y', 'pct': '+60%', 'height': 165.0},
      {'year': '10Y', 'pct': '+80%', 'height': 190.0},
    ];

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 250,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: bars.map((b) {
                final height = b['height'] as double;
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Text(
                      b['pct'] as String,
                      style: const TextStyle(
                        color: Color(0xFF10B981),
                        fontSize: 14.5,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      width: 44,
                      height: height,
                      decoration: BoxDecoration(
                        color: const Color(0xFF064E3B),
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
                        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
                        gradient: const LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Color(0xFF10B981),
                            Color(0xFF047857),
                            Color(0xFF064E3B),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      b['year'] as String,
                      style: TextStyle(
                        color: textS,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          Divider(color: borderC, height: 1),
          const SizedBox(height: 12),
          Text(
            '*Past returns or projections are modeled on historical micro-market appreciation & lease indexation. Capital at risk.',
            style: TextStyle(
              color: textS.withOpacity(0.8),
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Valuation Report Modal
// ══════════════════════════════════════════════════════════════════
// ══════════════════════════════════════════════════════════════════
// Projected Returns Report Document Viewer (Exact Match to Screenshot)
// ══════════════════════════════════════════════════════════════════
class _ProjectedReturnsReportModal extends StatefulWidget {
  final PropertyModel property;
  final bool dark;
  const _ProjectedReturnsReportModal({required this.property, required this.dark});

  @override
  State<_ProjectedReturnsReportModal> createState() => _ProjectedReturnsReportModalState();
}

class _ProjectedReturnsReportModalState extends State<_ProjectedReturnsReportModal> {
  final PageController _pageController = PageController();
  int _activePage = 0; // 0: Report, 1: Growth Drivers, 2: Due Diligence

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int page) {
    if (page >= 0 && page <= 2) {
      _pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  String _formatInr(double amount) {
    final rounded = amount.round();
    if (rounded >= 10000000) {
      return '₹${(amount / 10000000).toStringAsFixed(2)} Cr';
    } else if (rounded >= 100000) {
      return '₹${(amount / 100000).toStringAsFixed(2)} L';
    } else {
      return '₹$rounded';
    }
  }

  @override
  Widget build(BuildContext context) {
    final property = widget.property;
    final dark = widget.dark;
    final bg = dark ? const Color(0xFF09101C) : Colors.white;
    final cardBg = dark ? const Color(0xFF0F1A2E) : const Color(0xFFF8FAFC);
    final textP = dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
    final textS = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    return Container(
      height: MediaQuery.of(context).size.height * 0.94,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        children: [
          // ── Header Bar ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 16, 14),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(bottom: BorderSide(color: borderC)),
            ),
            child: Row(
              children: [
                // VikaDrx brand logo & Node title
                Expanded(
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'VIKADRX',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              property.valuationReportTitle ?? 'Valuation & Audit Report',
                              style: TextStyle(
                                color: textP,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              property.valuationReportDate != null && property.valuationReportDate!.isNotEmpty
                                  ? '${property.valuationReportDate!} · Report'
                                  : 'October 2026 · Report',
                              style: TextStyle(color: textS, fontSize: 10),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),

                // Page Navigation (1/3 with arrows) & Close
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderC),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GestureDetector(
                            onTap: () => _goToPage(_activePage - 1),
                            child: Icon(
                              Icons.keyboard_arrow_left_rounded,
                              size: 18,
                              color: _activePage > 0 ? textP : textS.withOpacity(0.3),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            child: Text(
                              '${_activePage + 1}/3',
                              style: TextStyle(
                                color: textP,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => _goToPage(_activePage + 1),
                            child: Icon(
                              Icons.keyboard_arrow_right_rounded,
                              size: 18,
                              color: _activePage < 2 ? textP : textS.withOpacity(0.3),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton(
                      icon: Icon(Icons.close_rounded, color: textS, size: 22),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Page Content ───────────────────────────────────────
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (idx) => setState(() => _activePage = idx),
              children: [
                _buildPage1Report(property, dark, textP, textS, cardBg, borderC),
                _buildPage2GrowthDrivers(property, dark, textP, textS, cardBg, borderC),
                _buildPage3ValuationDiligence(property, dark, textP, textS, cardBg, borderC),
              ],
            ),
          ),

          // ── Bottom Action Bar ──────────────────────────────────
          Container(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              MediaQuery.of(context).padding.bottom > 0
                  ? MediaQuery.of(context).padding.bottom + 6
                  : 14,
            ),
            decoration: BoxDecoration(
              color: bg,
              border: Border(top: BorderSide(color: borderC)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF10B981),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _launchDocumentUrl(
                        property.valuationReportUrl,
                        property.valuationReportTitle ?? 'Valuation & Audit Report',
                      );
                    },
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.download_rounded, size: 18, color: Colors.white),
                        SizedBox(width: 6),
                        Text('Download Full Report (PDF)', style: TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () {
                    Get.snackbar(
                      'Report Shared',
                      'Investment report link copied to clipboard.',
                      backgroundColor: const Color(0xFF10B981),
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: borderC),
                    ),
                    child: Icon(Icons.share_outlined, color: textP, size: 20),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Page 1: Projected Returns Report (Dynamic Property Binding) ───
  Widget _buildPage1Report(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
  ) {
    final locationDisplay = property.location.display.isNotEmpty
        ? property.location.display
        : (property.location.city != null && property.location.city!.isNotEmpty
            ? '${property.location.city!}, ${property.location.state ?? ""}'
            : 'Prime Location');

    final priceAmount = (property.price.amount ?? 0).toDouble();
    final hasArea = property.area != null && property.area! > 0;
    final double baseRate = hasArea
        ? (priceAmount / property.area!)
        : priceAmount;

    final baseCagr = property.effectiveXirr > 0 ? property.effectiveXirr : 12.5;
    final bearCagr = (baseCagr - 3.0).clamp(1.0, 50.0);
    final bullCagr = (baseCagr + 3.0).clamp(1.0, 60.0);

    String calcCell(double cagr, int years) {
      final mult = pow(1.0 + (cagr / 100.0), years).toDouble();
      final pct = ((mult - 1.0) * 100.0).round();
      final projRate = baseRate * mult;
      final valStr = hasArea
          ? '₹${projRate.round().toString()}/sq ft'
          : _formatInr(projRate);
      return '+$pct% · ${mult.toStringAsFixed(2)}x\n$valStr';
    }

    final statRateValue = hasArea
        ? '₹${baseRate.round().toString()}/sq ft'
        : property.formattedPrice;
    final statRateLabel = hasArea ? 'Carpet rate base' : 'Asset valuation';

    final statAreaValue = hasArea
        ? '${property.area} sq ft'
        : ((property.totalBricks ?? 0) > 0 ? '${property.totalBricks} Bricks' : '100% Equity');
    final statAreaLabel = hasArea ? 'RERA registered area' : 'Unit allocation';

    final propTypeLabel = (property.propertyType ?? 'Real Estate').toUpperCase();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Category tag
          Text(
            'Summary and projection · $propTypeLabel, $locationDisplay',
            style: TextStyle(color: textS, fontSize: 11.5, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),

          // Main Header Title
          Text(
            'Projected Returns Report',
            style: TextStyle(
              color: textP,
              fontSize: 24,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 4),

          // Subtitle (Property Title | Location)
          Text(
            '${property.title.toUpperCase()} | $locationDisplay',
            style: TextStyle(
              color: textP.withOpacity(0.85),
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 16),

          // ── Key Metrics 4-Box Row ──────────────────────────────
          Row(
            children: [
              Expanded(
                child: _statBox(
                  '${baseCagr.toStringAsFixed(1)}% p.a.',
                  'Target net XIRR',
                  const Color(0xFF10B981),
                  dark,
                  cardBg,
                  borderC,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statBox(
                  statRateValue,
                  statRateLabel,
                  textP,
                  dark,
                  cardBg,
                  borderC,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statBox(
                  statAreaValue,
                  statAreaLabel,
                  textP,
                  dark,
                  cardBg,
                  borderC,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _statBox(
                  property.formattedPrice,
                  'Total valuation',
                  textP,
                  dark,
                  cardBg,
                  borderC,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),

          // ── Narrative Section ──────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderC),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'PROJECT & VALUE PROPOSITION',
                  style: TextStyle(
                    color: textS,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  property.valuationSummary != null && property.valuationSummary!.trim().isNotEmpty
                      ? property.valuationSummary!
                      : 'Executive summary. ${property.title} represents an institutional-grade $propTypeLabel investment in $locationDisplay. With a total underwritten valuation of ${property.formattedPrice}, the project targets an annualized return of ${baseCagr.toStringAsFixed(1)}% XIRR, comprising an expected rental yield of ${property.expectedRentalYield.toStringAsFixed(1)}% p.a. and capital appreciation of ${property.expectedAppreciation.toStringAsFixed(1)}% p.a.',
                  style: TextStyle(color: textP, fontSize: 12, height: 1.45, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Text(
                  'The asset is supported by strong regional commercial absorption and infrastructure connectivity in ${property.location.city ?? property.location.state ?? "the region"}. Established lease covenants and ongoing micro-market infill establish a resilient floor for long-term yields.',
                  style: TextStyle(color: textS, fontSize: 11.5, height: 1.4),
                ),
                const SizedBox(height: 10),
                Text(
                  'Our base case of ${baseCagr.toStringAsFixed(1)}% a year is structured around verifiable comparable sales and institutional underwriting standards. Investor rights are secured via a dedicated asset SPV (${property.spvName}) with SEBI-regulated independent trustee escrow oversight.',
                  style: TextStyle(color: textS, fontSize: 11.5, height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // ── Scenario Analysis Table ────────────────────────────
          Text(
            'Scenario Analysis & Return Horizons',
            style: TextStyle(color: textP, fontSize: 14.5, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 10),

          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderC),
              ),
              child: DataTable(
                headingRowHeight: 40,
                dataRowHeight: 65,
                columnSpacing: 18,
                horizontalMargin: 14,
                headingTextStyle: TextStyle(
                  color: textS,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
                columns: const [
                  DataColumn(label: Text('Scenario')),
                  DataColumn(label: Text('2 year · 2028')),
                  DataColumn(label: Text('3 year · 2029')),
                  DataColumn(label: Text('4 year · 2030')),
                  DataColumn(label: Text('5 year · 2031')),
                ],
                rows: [
                  // Bear case
                  _scenarioRow(
                    'Bear case',
                    '${bearCagr.toStringAsFixed(1)}% CAGR',
                    calcCell(bearCagr, 2),
                    calcCell(bearCagr, 3),
                    calcCell(bearCagr, 4),
                    calcCell(bearCagr, 5),
                    false,
                    textP,
                    textS,
                    dark,
                  ),
                  // Base case (Highlighted Green)
                  _scenarioRow(
                    'Base case',
                    '${baseCagr.toStringAsFixed(1)}% CAGR',
                    calcCell(baseCagr, 2),
                    calcCell(baseCagr, 3),
                    calcCell(baseCagr, 4),
                    calcCell(baseCagr, 5),
                    true,
                    textP,
                    textS,
                    dark,
                  ),
                  // Bull case
                  _scenarioRow(
                    'Bull case',
                    '${bullCagr.toStringAsFixed(1)}% CAGR',
                    calcCell(bullCagr, 2),
                    calcCell(bullCagr, 3),
                    calcCell(bullCagr, 4),
                    calcCell(bullCagr, 5),
                    false,
                    textP,
                    textS,
                    dark,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // How the rates are set
          Text(
            'How the rates are set. Each case applies one constant annual compounding rate from the appraised asset valuation base of ${property.formattedPrice}. Rates are calibrated on realised regional appreciation in ${property.location.city ?? property.location.state ?? "the corridor"}, comparable transaction records, and the delivery calendar of local infrastructure. Implied values exclude preferential location charges, duties, and taxes.',
            style: TextStyle(color: textS, fontSize: 11, height: 1.35),
          ),
          const SizedBox(height: 16),

          // ── Our View ───────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: dark ? const Color(0xFF064E3B) : const Color(0xFF0F766E),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.lightbulb_outline_rounded, color: Color(0xFF6EE7B7), size: 16),
                    SizedBox(width: 8),
                    Text(
                      'Our view',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 13.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'The base case at ${baseCagr.toStringAsFixed(1)}% a year represents our underwritten target for ${property.title} in $locationDisplay. The asset offers an attractive risk-adjusted yield spread above traditional fixed income, with clear capital protection via institutional SPV custodianship and SEBI-registered escrow oversight.',
                  style: const TextStyle(
                    color: Color(0xFFE6FFFA),
                    fontSize: 11.5,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Sources footer
          Text(
            'Sources: Certified listing data, ${property.valuationReportDate != null && property.valuationReportDate!.isNotEmpty ? property.valuationReportDate! : "October 2026"}. ${property.reraNumber != null && property.reraNumber!.isNotEmpty ? "RERA Regn: ${property.reraNumber!}. " : ""}Independent Valuer: ${property.valuationAuthority != null && property.valuationAuthority!.isNotEmpty ? property.valuationAuthority! : "Independent RICS / IBBI Registered Valuer"}. VikaDrx Research Desk.',
            style: TextStyle(color: textS.withOpacity(0.6), fontSize: 9.5, height: 1.3),
          ),
        ],
      ),
    );
  }

  // ── Page 2: Growth Drivers (Project Specific) ─────────────────────
  Widget _buildPage2GrowthDrivers(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
  ) {
    final cityName = property.location.city ?? property.location.state ?? 'Regional Corridor';

    // If custom growthProjections were provided by admin, display them
    final customNarrative = property.growthProjections?.trim() ?? '';

    final drivers = [
      {
        'num': '01 · Strategic Connectivity & Transit',
        'cost': 'Prime Transit Access',
        'badge': 'CONNECTIVITY',
        'icon': Icons.alt_route_rounded,
        'desc': 'Direct connectivity to major arterial highways, state corridors, and rapid transit networks in $cityName, ensuring convenient accessibility for commercial tenants, logistics operators, and visitors.',
      },
      {
        'num': '02 · Institutional Catchment & Tenant Pool',
        'cost': 'High Absorption',
        'badge': 'COMMERCIAL DEMAND',
        'icon': Icons.corporate_fare_rounded,
        'desc': 'Proximity to high-density employment centers, commercial developments, and established retail ecosystems driving strong occupancy rates and consistent rental demand.',
      },
      {
        'num': '03 · Micro-Market Capital Appreciation',
        'cost': 'Capital Growth',
        'badge': 'APPRECIATION',
        'icon': Icons.trending_up_rounded,
        'desc': 'Sustained capital appreciation supported by limited supply of Grade-A prime land and ongoing municipal infrastructure investments across the $cityName region.',
      },
      {
        'num': '04 · Statutory RERA & Institutional Custody',
        'cost': 'Legal Protection',
        'badge': 'REGULATORY',
        'icon': Icons.verified_user_rounded,
        'desc': '100% clear and marketable freehold title backed by statutory registrations, independent escrow oversight, and institutional quarterly compliance filings.',
      },
    ];

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Regional catalysts & infrastructure',
            style: TextStyle(color: textS, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Growth Drivers: ${property.title}',
            style: TextStyle(
              color: textP,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Key macroeconomic, infrastructure, and commercial catalysts underwriting capital appreciation and steady rental absorption.',
            style: TextStyle(color: textS, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 16),

          if (customNarrative.isNotEmpty) ...[
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF10B981).withOpacity(dark ? 0.15 : 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.stars_rounded, color: Color(0xFF10B981), size: 18),
                      const SizedBox(width: 8),
                      Text(
                        'Project Specific Catalysts',
                        style: TextStyle(color: textP, fontSize: 13.5, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    customNarrative,
                    style: TextStyle(color: textP, fontSize: 12, height: 1.45),
                  ),
                ],
              ),
            ),
          ],

          ...drivers.map((d) {
            return Container(
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderC),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(d['icon'] as IconData, color: const Color(0xFF10B981), size: 18),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              d['num'] as String,
                              style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w800),
                            ),
                            Text(
                              d['cost'] as String,
                              style: const TextStyle(
                                color: Color(0xFF10B981),
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          d['badge'] as String,
                          style: TextStyle(color: textS, fontSize: 9, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    d['desc'] as String,
                    style: TextStyle(color: textS, fontSize: 11.5, height: 1.4),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Page 3: Valuation & SPV Diligence ─────────────────────────────
  Widget _buildPage3ValuationDiligence(
    PropertyModel property,
    bool dark,
    Color textP,
    Color textS,
    Color cardBg,
    Color borderC,
  ) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Institutional due diligence',
            style: TextStyle(color: textS, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Valuation & Legal Governance',
            style: TextStyle(
              color: textP,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 16),

          // Valuation Report PDF Action Card
          Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: dark
                    ? [const Color(0xFF064E3B).withOpacity(0.4), const Color(0xFF0F2E22).withOpacity(0.4)]
                    : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.35)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF10B981), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        property.valuationReportTitle ?? 'Certified Valuation & Audit Report',
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w800),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        property.valuationReportUrl != null && property.valuationReportUrl!.isNotEmpty
                            ? 'Official certified report attached'
                            : 'Institutional audit in progress',
                        style: TextStyle(color: textS, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _launchDocumentUrl(
                    property.valuationReportUrl,
                    property.valuationReportTitle ?? 'Valuation & Audit Report',
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.download_rounded, size: 14, color: Colors.white),
                      SizedBox(width: 4),
                      Text('PDF', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: borderC),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('Asset Appraised Valuation', property.formattedPrice, textP, textS),
                _detailRow('Valuation Method', property.valuationMethodology != null && property.valuationMethodology!.isNotEmpty ? property.valuationMethodology! : 'Discounted Cash Flow (DCF) + Comparable Sales Approach', textP, textS),
                _detailRow('Independent Valuer', property.valuationAuthority != null && property.valuationAuthority!.isNotEmpty ? property.valuationAuthority! : 'Independent RICS & IBBI Registered Valuer', textP, textS),
                _detailRow('Title Clearance', 'Clear & Marketable (100% Encumbrance Free)', textP, textS),
                _detailRow('RERA Status', property.reraNumber != null && property.reraNumber!.isNotEmpty ? 'Verified (${property.reraNumber!})' : 'Verified & Compliant', textP, textS),
                _detailRow('SPV Entity', property.spvName, textP, textS),
                _detailRow('Custodian / Escrow', '${property.spvTrusteeName} & ${property.spvEscrowBank.isNotEmpty ? property.spvEscrowBank : "ICICI"} Escrow', textP, textS),
                _detailRow('MCA Quarterly Filing', 'Guaranteed Q1–Q4 Form 3 / Form 4 filings with MCA', textP, textS),
              ],
            ),
          ),
          const SizedBox(height: 18),

          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(dark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '100% Capital Custody & Escrow',
                        style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Investor capital is held strictly in SEBI-regulated escrow until MCA registration is completed.',
                        style: TextStyle(color: textS, fontSize: 11, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox(
    String value,
    String label,
    Color color,
    bool dark,
    Color cardBg,
    Color borderC,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 10),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            value,
            style: TextStyle(
              color: color,
              fontSize: 16,
              fontWeight: FontWeight.w900,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            label,
            style: TextStyle(
              color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B),
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              height: 1.25,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  DataRow _scenarioRow(
    String scenario,
    String cagr,
    String col2,
    String col3,
    String col4,
    String col5,
    bool isBase,
    Color tp,
    Color ts,
    bool dark,
  ) {
    final cellBg = isBase
        ? (dark ? const Color(0xFF064E3B).withOpacity(0.35) : const Color(0xFFE6F4EA))
        : Colors.transparent;

    return DataRow(
      color: MaterialStateProperty.all(cellBg),
      cells: [
        DataCell(
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scenario,
                style: TextStyle(
                  color: isBase ? const Color(0xFF10B981) : tp,
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                cagr,
                style: TextStyle(
                  color: isBase ? const Color(0xFF10B981) : ts,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        DataCell(Text(col2, style: TextStyle(color: tp, fontSize: 10.5, height: 1.25))),
        DataCell(Text(col3, style: TextStyle(color: tp, fontSize: 10.5, height: 1.25))),
        DataCell(Text(col4, style: TextStyle(color: tp, fontSize: 10.5, height: 1.25))),
        DataCell(Text(col5, style: TextStyle(color: tp, fontSize: 10.5, height: 1.25, fontWeight: isBase ? FontWeight.w800 : FontWeight.normal))),
      ],
    );
  }

  Widget _detailRow(String l, String v, Color tp, Color ts) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(l, style: TextStyle(color: ts, fontSize: 12.5))),
          const SizedBox(width: 8),
          Text(v, style: TextStyle(color: tp, fontSize: 12.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}


class _PhotosGalleryModal extends StatelessWidget {
  final PropertyModel property;
  final bool dark;
  const _PhotosGalleryModal({required this.property, required this.dark});

  @override
  Widget build(BuildContext context) {
    final bg = dark ? const Color(0xFF09101C) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Property Photos (${property.images.length})',
                style: TextStyle(color: textP, fontSize: 18, fontWeight: FontWeight.w800),
              ),
              IconButton(
                icon: Icon(Icons.close_rounded, color: textS),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2,
              ),
              itemCount: property.images.length,
              itemBuilder: (context, i) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    property.images[i].url,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Security FAQ Accordion
// ══════════════════════════════════════════════════════════════════
class _SecurityFaqAccordion extends StatelessWidget {
  final bool dark;
  const _SecurityFaqAccordion({required this.dark});

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final faqs = [
      {'q': 'How is my fractional title secured?', 'a': 'Ownership is held by an SPV (LLP) where every investor is a registered partner in Ministry of Corporate Affairs (MCA) records.'},
      {'q': 'Who manages the rent distribution?', 'a': 'Rental distributions are processed automatically on the 5th of every calendar month via our escrow banking partner.'},
      {'q': 'Can I exit or sell my bricks anytime?', 'a': 'Yes! Bricks can be sold on our peer-to-peer liquidity window or purchased in whole by direct buyers.'},
    ];

    return Column(
      children: faqs.map((f) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderC),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.shield_rounded, color: Color(0xFF10B981), size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(f['q']!, style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(f['a']!, style: TextStyle(color: textS, fontSize: 12.5, height: 1.4)),
          ],
        ),
      )).toList(),
    );
  }
}

// ══════════════════════════════════════════════════════════════════
// Verified Testimonials Section
// ══════════════════════════════════════════════════════════════════
class _TestimonialsSection extends StatelessWidget {
  final bool dark;
  const _TestimonialsSection({required this.dark});

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final textP = dark ? const Color(0xFFEDF0FF) : AppColors.textPrimary;
    final textS = dark ? const Color(0xFF8A95B0) : AppColors.textSecondary;
    final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

    final reviews = [
      {
        'name': 'Aman Verma',
        'city': 'Mumbai',
        'amt': '₹2,50,000 invested',
        'comment': 'Smooth fractional onboarding. Monthly rentals arrive like clockwork directly into my bank account.',
        'rating': 5,
      },
      {
        'name': 'Pooja Hegde',
        'city': 'Bengaluru',
        'amt': '₹5,00,000 invested',
        'comment': 'The LLP legal transparency and MCA filing gave me total peace of mind for institutional grade real estate.',
        'rating': 5,
      },
    ];

    return Column(
      children: reviews.map((r) => Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: borderC),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: const Color(0xFF10B981).withOpacity(0.15),
                  child: Text((r['name'] as String)[0], style: const TextStyle(color: Color(0xFF10B981), fontWeight: FontWeight.bold)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r['name'] as String, style: TextStyle(color: textP, fontSize: 14, fontWeight: FontWeight.w800)),
                      Text('${r['city']} • ${r['amt']}', style: TextStyle(color: textS, fontSize: 11.5)),
                    ],
                  ),
                ),
                Row(
                  children: List.generate(5, (_) => const Icon(Icons.star_rounded, color: Color(0xFFF59E0B), size: 16)),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(r['comment'] as String, style: TextStyle(color: textP, fontSize: 13, height: 1.4)),
          ],
        ),
      )).toList(),
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

// ─── Property Legal & Compliance Documents Section ─────────────────────────────
class _PropertyDocumentsSection extends StatelessWidget {
  final PropertyModel property;
  final bool dark;
  final Color textP;
  final Color textS;
  final Color cardBg;
  final Color borderC;
  final bool isExpanded;
  final VoidCallback? onToggle;

  const _PropertyDocumentsSection({
    required this.property,
    required this.dark,
    required this.textP,
    required this.textS,
    required this.cardBg,
    required this.borderC,
    this.isExpanded = false,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final docs = property.documents;
    final hasValuation = property.valuationReportUrl != null && property.valuationReportUrl!.trim().isNotEmpty;
    final totalCount = docs.length + (hasValuation ? 1 : 0);

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderC),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.04),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header (Accordion)
          InkWell(
            onTap: onToggle,
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1).withOpacity(dark ? 0.25 : 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.folder_shared_rounded, color: Color(0xFF818CF8), size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Legal & Compliance',
                        style: TextStyle(
                          color: textP,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Audited by legal counsel & institutional custodians',
                        style: TextStyle(color: textS, fontSize: 11),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '$totalCount Verified',
                        style: const TextStyle(
                          color: Color(0xFF10B981),
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                AnimatedRotation(
                  turns: isExpanded ? 0.5 : 0.0,
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeInOut,
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: textP,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 240),
            firstCurve: Curves.easeInOut,
            secondCurve: Curves.easeInOut,
            sizeCurve: Curves.easeInOut,
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16),
                Divider(color: borderC.withOpacity(0.6), height: 1),
                const SizedBox(height: 16),

          // 1. Valuation Report Card (if uploaded)
          if (hasValuation) ...[
            _buildDocItem(
              title: property.valuationReportTitle ?? 'CBRE & JLL Valuation Report',
              type: 'Certified Valuation Appraisal',
              icon: Icons.analytics_outlined,
              iconColor: const Color(0xFF10B981),
              url: property.valuationReportUrl!,
            ),
            const SizedBox(height: 12),
          ],

          // 2. Attached Property Documents from Admin
          if (docs.isNotEmpty) ...[
            ...docs.map((doc) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildDocItem(
                title: doc.title,
                type: doc.type ?? 'Due Diligence Document',
                icon: Icons.picture_as_pdf_rounded,
                iconColor: const Color(0xFFEF4444),
                url: doc.url,
              ),
            )),
          ],

          // 3. If no docs uploaded yet, show institutional placeholder verified records
          if (docs.isEmpty && !hasValuation) ...[
            _buildStaticDocItem(
              title: 'Title Search & Clearance Report (30-Year)',
              type: 'Title Clearance',
              badge: 'Verified Clear',
            ),
            const SizedBox(height: 10),
            _buildStaticDocItem(
              title: 'RERA Project Registration Certificate',
              type: 'RERA Compliance',
              badge: 'Registered',
            ),
            const SizedBox(height: 10),
            _buildStaticDocItem(
              title: 'Encumbrance Certificate (Form 15 & 16)',
              type: 'Legal Due Diligence',
              badge: 'Nil Encumbrance',
            ),
            const SizedBox(height: 10),
            _buildStaticDocItem(
              title: 'Sanctioned Master Layout & Building Plan',
              type: 'Municipal Approvals',
              badge: 'Approved',
            ),
          ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDocItem({
    required String title,
    required String type,
    required IconData icon,
    required Color iconColor,
    required String url,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF162238) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderC),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: textP,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  type,
                  style: TextStyle(
                    color: textS,
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // View Button
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              side: BorderSide(color: const Color(0xFF6366F1).withOpacity(0.5)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _previewPdfDocument(url, title),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.remove_red_eye_outlined, size: 14, color: Color(0xFF818CF8)),
                SizedBox(width: 4),
                Text(
                  'Preview',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Color(0xFF818CF8)),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          // Download Button
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              minimumSize: Size.zero,
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => _downloadPdfDocument(url, title),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.download_rounded, size: 14, color: Colors.white),
                SizedBox(width: 4),
                Text(
                  'Download',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStaticDocItem({
    required String title,
    required String type,
    required String badge,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF162238) : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderC),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.description_outlined, color: Color(0xFF818CF8), size: 18),
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  type,
                  style: TextStyle(color: textS, fontSize: 10.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.12),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              badge,
              style: const TextStyle(
                color: Color(0xFF10B981),
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


class _SuggestedPropertyCard extends StatelessWidget {
  final PropertyModel property;
  final bool dark;
  final Color textP;
  final Color textS;
  final Color cardBg;
  final Color borderC;
  final VoidCallback onTap;

  const _SuggestedPropertyCard({
    required this.property,
    required this.dark,
    required this.textP,
    required this.textS,
    required this.cardBg,
    required this.borderC,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final imgUrl = property.images.isNotEmpty ? property.images.first.url : null;
    final city = property.location.city ?? '';
    final propType = (property.propertyType ?? 'Property').toUpperCase();

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 250,
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: borderC, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.35 : 0.07),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image container with badges
              Stack(
                children: [
                  SizedBox(
                    height: 135,
                    width: double.infinity,
                    child: imgUrl != null && imgUrl.isNotEmpty
                        ? Image.network(
                            imgUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                              child: const Icon(Icons.apartment_rounded, color: Colors.grey, size: 36),
                            ),
                          )
                        : Container(
                            color: dark ? const Color(0xFF1E293B) : const Color(0xFFF1F5F9),
                            child: const Icon(Icons.apartment_rounded, color: Colors.grey, size: 36),
                          ),
                  ),
                  // Property Type Badge
                  Positioned(
                    top: 10,
                    right: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.72),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: Text(
                        propType,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Yield Badge if available
                  if (property.expectedRentalYield > 0)
                    Positioned(
                      top: 10,
                      left: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.90),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.trending_up_rounded, color: Colors.white, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              '${property.expectedRentalYield.toStringAsFixed(1)}% Yield',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),

              // Property details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
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
                          if (city.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(Icons.location_on_outlined, size: 12, color: textS),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    city,
                                    style: TextStyle(color: textS, fontSize: 11),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),

                      // Price and Brick
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Price',
                                style: TextStyle(color: textS, fontSize: 10),
                              ),
                              Text(
                                property.formattedPrice,
                                style: const TextStyle(
                                  color: AppColors.accent,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                          if (property.allowsBricks && property.brickPrice != null)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981).withOpacity(dark ? 0.2 : 0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                              ),
                              child: Text(
                                '₹${property.brickPrice}/brick',
                                style: const TextStyle(
                                  color: Color(0xFF10B981),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
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
