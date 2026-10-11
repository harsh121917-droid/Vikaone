import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/business_model.dart';
import '../widgets/schedule_business_call_sheet.dart';

class BusinessDetailView extends StatefulWidget {
  final BusinessModel business;
  const BusinessDetailView({super.key, required this.business});

  @override
  State<BusinessDetailView> createState() => _BusinessDetailViewState();
}

class _BusinessDetailViewState extends State<BusinessDetailView> {
  int _currentImageIndex = 0;
  late final PageController _pageCtrl;

  @override
  void initState() {
    super.initState();
    _pageCtrl = PageController();
  }

  @override
  void dispose() {
    _pageCtrl.dispose();
    super.dispose();
  }

  void _openGalleryModal(BuildContext context, List<String> images, bool dark) {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _BusinessPhotosModal(
        business: widget.business,
        images: images,
        initialIndex: _currentImageIndex,
        dark: dark,
        onPhotoChanged: (index) {
          if (index != _currentImageIndex && index < images.length) {
            setState(() => _currentImageIndex = index);
            if (_pageCtrl.hasClients) {
              _pageCtrl.jumpToPage(index);
            }
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.business;
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF1F5F9);
    final cardBg = dark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = dark ? Colors.white : const Color(0xFF0F172A);
    final subColor = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);
    const primaryBlue = Color(0xFF2563EB);

    final allImages = b.allImageUrls;

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Sliver Hero Image Carousel ──
              SliverAppBar(
                expandedHeight: 310,
                pinned: true,
                elevation: 0,
                backgroundColor: dark ? const Color(0xFF0F172A) : Colors.white,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    backgroundColor: Colors.black.withOpacity(0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 20),
                      onPressed: () => Get.back(),
                    ),
                  ),
                ),
                actions: [
                  if (allImages.length > 1)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
                      child: GestureDetector(
                        onTap: () => _openGalleryModal(context, allImages, dark),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.65),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: Colors.white.withOpacity(0.25)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.photo_library_rounded, color: Colors.white, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                'Photos (${allImages.length})',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.white, size: 19),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.snackbar(
                            'Share Link',
                            'Venture opportunity link copied to clipboard',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: primaryBlue,
                            colorText: Colors.white,
                          );
                        },
                      ),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    children: [
                      PageView.builder(
                        controller: _pageCtrl,
                        itemCount: allImages.length,
                        onPageChanged: (i) => setState(() => _currentImageIndex = i),
                        itemBuilder: (ctx, i) {
                          return Image.network(
                            allImages[i],
                            fit: BoxFit.cover,
                            errorBuilder: (_, err, trace) => Container(
                              color: const Color(0xFF1E293B),
                              child: Center(
                                child: Icon(b.categoryIcon, color: b.categoryColor, size: 64),
                              ),
                            ),
                          );
                        },
                      ),

                      // Gradient Scrim
                      Positioned.fill(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.black.withOpacity(0.5),
                                Colors.transparent,
                                Colors.black.withOpacity(0.85),
                              ],
                              stops: const [0.0, 0.4, 1.0],
                            ),
                          ),
                        ),
                      ),

                      // Floating photo count badge on hero image (bottom-right)
                      Positioned(
                        bottom: 16,
                        right: 16,
                        child: GestureDetector(
                          onTap: () => _openGalleryModal(context, allImages, dark),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.65),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: Colors.white.withOpacity(0.25)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.photo_library_rounded, size: 12, color: Colors.white),
                                const SizedBox(width: 5),
                                Text(
                                  '${_currentImageIndex + 1}/${allImages.length}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Page Dots
                      if (allImages.length > 1)
                        Positioned(
                          bottom: 16,
                          left: 0,
                          right: 0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(allImages.length, (i) {
                              final isSel = i == _currentImageIndex;
                              return AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: const EdgeInsets.symmetric(horizontal: 3),
                                width: isSel ? 20 : 6,
                                height: 6,
                                decoration: BoxDecoration(
                                  color: isSel ? primaryBlue : Colors.white54,
                                  borderRadius: BorderRadius.circular(3),
                                ),
                              );
                            }),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── 2. Content Details ──
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 16, 18, 120),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Tag & Location
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: b.categoryColor.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: b.categoryColor.withOpacity(0.4)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(b.categoryIcon, color: b.categoryColor, size: 14),
                                const SizedBox(width: 6),
                                Text(
                                  b.category,
                                  style: TextStyle(
                                    color: b.categoryColor,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Spacer(),
                          const Icon(Icons.location_on_rounded, color: Color(0xFFEF4444), size: 16),
                          const SizedBox(width: 4),
                          Text(
                            b.location.formatted,
                            style: TextStyle(
                              color: subColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Title
                      Text(
                        b.title,
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // SPV Name Tag
                      if (b.spvName.isNotEmpty) ...[
                        Row(
                          children: [
                            const Icon(Icons.domain_verification_rounded, color: primaryBlue, size: 16),
                            const SizedBox(width: 6),
                            Text(
                              'Operated by SPV: ${b.spvName}',
                              style: const TextStyle(
                                color: primaryBlue,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                      ],

                      // ── Venture Photos Thumbnail Strip (if multi-photo) ──
                      if (allImages.length > 1) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Venture Photos (${allImages.length})',
                              style: TextStyle(
                                color: titleColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _openGalleryModal(context, allImages, dark),
                              child: const Text(
                                'View All',
                                style: TextStyle(
                                  color: primaryBlue,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 72,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: allImages.length,
                            separatorBuilder: (ctx, idx) => const SizedBox(width: 10),
                            itemBuilder: (ctx, i) {
                              final isSel = i == _currentImageIndex;
                              return GestureDetector(
                                onTap: () {
                                  setState(() => _currentImageIndex = i);
                                  _pageCtrl.animateToPage(
                                    i,
                                    duration: const Duration(milliseconds: 250),
                                    curve: Curves.easeInOut,
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  width: 96,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isSel
                                          ? primaryBlue
                                          : (dark ? Colors.white12 : const Color(0xFFE2E8F0)),
                                      width: isSel ? 2.5 : 1,
                                    ),
                                    boxShadow: isSel
                                        ? [
                                            BoxShadow(
                                              color: primaryBlue.withOpacity(0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(8),
                                    child: Image.network(
                                      allImages[i],
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, err, trace) => Container(
                                        color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                                        child: const Center(
                                          child: Icon(Icons.broken_image_rounded, size: 24, color: Colors.grey),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ── 3. Four Key Metrics ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(18),
                          border: Border.all(color: borderColor),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.analytics_rounded, color: primaryBlue, size: 18),
                                const SizedBox(width: 8),
                                Text(
                                  'Key Investment Metrics',
                                  style: TextStyle(
                                    color: primaryBlue,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            GridView.count(
                              crossAxisCount: 2,
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              mainAxisSpacing: 10,
                              crossAxisSpacing: 10,
                              childAspectRatio: 1.9,
                              children: [
                                _DetailMetricBox(
                                  label: 'MIN INVESTMENT',
                                  value: b.formattedMinInvestment,
                                  color: primaryBlue,
                                  sub: 'Accessible Entry Ticket',
                                ),
                                _DetailMetricBox(
                                  label: 'EXPECTED ROI',
                                  value: b.expectedReturns,
                                  color: const Color(0xFFFBBF24),
                                  sub: 'Annualized Target',
                                ),
                                _DetailMetricBox(
                                  label: 'PROJECT SIZE',
                                  value: b.formattedTotalCost,
                                  color: titleColor,
                                  sub: 'Asset Valuation',
                                ),
                                _DetailMetricBox(
                                  label: 'PAYOUT CYCLE',
                                  value: b.payoutFrequency,
                                  color: b.categoryColor,
                                  sub: '${b.investmentTenure} Lock-in',
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 4. Detailed Description ──
                      Text(
                        'About The Opportunity',
                        style: TextStyle(
                          color: titleColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: borderColor),
                        ),
                        child: Text(
                          b.description,
                          style: TextStyle(
                            color: subColor,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ── 5. Project Highlights ──
                      if (b.highlights.isNotEmpty) ...[
                        Text(
                          'Strategic Highlights',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...b.highlights.map((hl) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded, color: primaryBlue, size: 18),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    hl,
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],

                      // ── 6. Verified Documents List ──
                      if (b.documents.isNotEmpty) ...[
                        Text(
                          'Due Diligence & Documents',
                          style: TextStyle(
                            color: titleColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ...b.documents.map((doc) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 20),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        doc.title,
                                        style: TextStyle(color: titleColor, fontSize: 13, fontWeight: FontWeight.w700),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Text(
                                        'Verified Due Diligence Report',
                                        style: TextStyle(color: Color(0xFF64748B), fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: primaryBlue,
                                    side: const BorderSide(color: primaryBlue),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Get.snackbar(
                                      'Document Available',
                                      'Opening ${doc.title}',
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: primaryBlue,
                                      colorText: Colors.white,
                                    );
                                  },
                                  child: const Text('View', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                                ),
                              ],
                            ),
                          );
                        }),
                        const SizedBox(height: 24),
                      ],

                      // ── 7. Due Diligence & Investor Protection ──
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: primaryBlue.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: primaryBlue.withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_outlined, color: primaryBlue, size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Institutional Investor Protection',
                                    style: TextStyle(
                                      color: titleColor,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'All business assets operate under dedicated SPVs with segregated escrow accounts, bankruptcy remoteness, and independent third-party audit reports.',
                                    style: TextStyle(color: subColor, fontSize: 12, height: 1.4),
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
            ],
          ),

          // ── Sticky Bottom CTA Bar ──
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ClipRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  decoration: BoxDecoration(
                    color: (dark ? const Color(0xFF0F172A) : Colors.white).withOpacity(0.92),
                    border: Border(top: BorderSide(color: borderColor)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Row(
                      children: [
                        // Left pricing info
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'MIN INVESTMENT',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF64748B),
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              b.formattedMinInvestment,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: primaryBlue,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Consultation Button
                        Expanded(
                          child: GestureDetector(
                            onTap: () => showScheduleBusinessCallSheet(context, b),
                            child: Container(
                              height: 48,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                                ),
                                borderRadius: BorderRadius.circular(14),
                                boxShadow: [
                                  BoxShadow(
                                    color: primaryBlue.withOpacity(0.35),
                                    blurRadius: 10,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.phone_in_talk_rounded, size: 18, color: Colors.white),
                                  SizedBox(width: 8),
                                  Text(
                                    'Schedule Consultation',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 0.3,
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
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailMetricBox extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final String sub;

  const _DetailMetricBox({
    required this.label,
    required this.value,
    required this.color,
    required this.sub,
  });

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: dark ? Colors.white.withOpacity(0.04) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: dark ? Colors.white.withOpacity(0.06) : const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            sub,
            style: TextStyle(fontSize: 10, color: dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}

class _BusinessPhotosModal extends StatefulWidget {
  final BusinessModel business;
  final List<String> images;
  final int initialIndex;
  final bool dark;
  final ValueChanged<int> onPhotoChanged;

  const _BusinessPhotosModal({
    required this.business,
    required this.images,
    required this.initialIndex,
    required this.dark,
    required this.onPhotoChanged,
  });

  @override
  State<_BusinessPhotosModal> createState() => _BusinessPhotosModalState();
}

class _BusinessPhotosModalState extends State<_BusinessPhotosModal> {
  late int _activeIdx;
  late final PageController _modalPageCtrl;

  @override
  void initState() {
    super.initState();
    _activeIdx = widget.initialIndex;
    _modalPageCtrl = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _modalPageCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dark = widget.dark;
    final bg = dark ? const Color(0xFF0F172A) : Colors.white;
    final textColor = dark ? Colors.white : const Color(0xFF0F172A);
    final subColor = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = dark ? Colors.white.withOpacity(0.1) : const Color(0xFFE2E8F0);
    const primaryBlue = Color(0xFF2563EB);

    return Container(
      height: MediaQuery.of(context).size.height * 0.82,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          // Top notch
          const SizedBox(height: 12),
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: dark ? Colors.white24 : const Color(0xFFCBD5E1),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(height: 12),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Venture Photos (${_activeIdx + 1}/${widget.images.length})',
                        style: TextStyle(
                          color: textColor,
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.business.title,
                        style: TextStyle(color: subColor, fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: dark ? Colors.white.withOpacity(0.08) : const Color(0xFFF1F5F9),
                      shape: BoxShape.circle,
                      border: Border.all(color: borderColor),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: dark ? Colors.white70 : const Color(0xFF475569),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Main Image PageView
          Expanded(
            child: PageView.builder(
              controller: _modalPageCtrl,
              itemCount: widget.images.length,
              onPageChanged: (i) {
                setState(() => _activeIdx = i);
                widget.onPhotoChanged(i);
              },
              itemBuilder: (ctx, i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      widget.images[i],
                      fit: BoxFit.cover,
                      errorBuilder: (_, err, trace) => Container(
                        color: dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0),
                        child: Center(
                          child: Icon(
                            widget.business.categoryIcon,
                            color: widget.business.categoryColor,
                            size: 64,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // Bottom Thumbnail bar
          if (widget.images.length > 1)
            Container(
              height: 70,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: widget.images.length,
                separatorBuilder: (ctx, idx) => const SizedBox(width: 8),
                itemBuilder: (ctx, i) {
                  final isSel = i == _activeIdx;
                  return GestureDetector(
                    onTap: () {
                      _modalPageCtrl.animateToPage(
                        i,
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeInOut,
                      );
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 76,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: isSel ? primaryBlue : (dark ? Colors.white12 : const Color(0xFFCBD5E1)),
                          width: isSel ? 2.5 : 1,
                        ),
                        boxShadow: isSel
                            ? [
                                BoxShadow(
                                  color: primaryBlue.withOpacity(0.35),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ]
                            : null,
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          widget.images[i],
                          fit: BoxFit.cover,
                          errorBuilder: (_, err, trace) => Container(
                            color: Colors.grey.shade800,
                            child: const Icon(Icons.broken_image, size: 20, color: Colors.white54),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
