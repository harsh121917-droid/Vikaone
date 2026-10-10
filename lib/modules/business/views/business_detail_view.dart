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

  @override
  Widget build(BuildContext context) {
    final b = widget.business;
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF1F5F9);
    final cardBg = dark ? const Color(0xFF0F172A) : Colors.white;
    final titleColor = dark ? Colors.white : const Color(0xFF0F172A);
    final subColor = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final borderColor = dark ? Colors.white.withOpacity(0.08) : const Color(0xFFE2E8F0);

    final allImages = b.images.isNotEmpty ? b.images.map((i) => i.url).toList() : [b.coverImage];

    return Scaffold(
      backgroundColor: bg,
      body: Stack(
        children: [
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // ── 1. Sliver Hero Image Carousel ──
              SliverAppBar(
                expandedHeight: 300,
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
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: CircleAvatar(
                      backgroundColor: Colors.black.withOpacity(0.6),
                      child: IconButton(
                        icon: const Icon(Icons.share_outlined, color: Colors.white, size: 20),
                        onPressed: () {
                          HapticFeedback.lightImpact();
                          Get.snackbar('Share Link', 'Project link copied to clipboard',
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: const Color(0xFF00D09C),
                              colorText: Colors.black);
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
                            errorBuilder: (_, __, ___) => Container(
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
                                  color: isSel ? const Color(0xFF00D09C) : Colors.white54,
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
                      if (b.spvName.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'SPV: ${b.spvName}',
                          style: TextStyle(color: const Color(0xFF00D09C), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                      ],
                      const SizedBox(height: 20),

                      // ── 3. High-Yield Financial Summary Card ──
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: cardBg,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: borderColor),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(dark ? 0.3 : 0.05),
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.analytics_rounded, color: Color(0xFF00D09C), size: 18),
                                SizedBox(width: 8),
                                Text(
                                  'VENTURE FINANCIAL HIGHLIGHTS',
                                  style: TextStyle(
                                    color: Color(0xFF00D09C),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24, thickness: 0.8),

                            // Grid of 4 main metrics
                            Row(
                              children: [
                                Expanded(
                                  child: _DetailMetricBox(
                                    label: 'MIN INVESTMENT',
                                    value: b.formattedMinInvestment,
                                    color: const Color(0xFF00D09C),
                                    sub: 'Ticket size',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DetailMetricBox(
                                    label: 'TARGET RETURNS',
                                    value: b.expectedReturns,
                                    color: const Color(0xFFFBBF24),
                                    sub: 'Projected yield',
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _DetailMetricBox(
                                    label: 'TOTAL PROJECT SIZE',
                                    value: b.formattedTotalCost,
                                    color: titleColor,
                                    sub: 'Capital outlay',
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: _DetailMetricBox(
                                    label: 'INVESTMENT TENURE',
                                    value: b.investmentTenure,
                                    color: b.categoryColor,
                                    sub: '${b.payoutFrequency} payouts',
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 4. Project Overview / Description ──
                      Text(
                        'Project Overview & Business Model',
                        style: TextStyle(color: titleColor, fontSize: 17, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
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
                            height: 1.55,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // ── 5. Key Highlights / Investment Thesis ──
                      if (b.highlights.isNotEmpty) ...[
                        Text(
                          'Strategic Investment Advantages',
                          style: TextStyle(color: titleColor, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: cardBg,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: borderColor),
                          ),
                          child: Column(
                            children: b.highlights.map((h) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00D09C), size: 18),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Text(
                                        h,
                                        style: TextStyle(color: titleColor, fontSize: 13, height: 1.35, fontWeight: FontWeight.w500),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── 6. Project Documents ──
                      if (b.documents.isNotEmpty) ...[
                        Text(
                          'Project Documents & Reports',
                          style: TextStyle(color: titleColor, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 10),
                        ...b.documents.map((doc) {
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: cardBg,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: borderColor),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 40,
                                  height: 40,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEF4444).withOpacity(0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFFEF4444), size: 22),
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
                                    foregroundColor: const Color(0xFF00D09C),
                                    side: const BorderSide(color: Color(0xFF00D09C)),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  ),
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    Get.snackbar('Document Available', 'Opening ${doc.title}',
                                        snackPosition: SnackPosition.BOTTOM,
                                        backgroundColor: const Color(0xFF00D09C),
                                        colorText: Colors.black);
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
                          color: const Color(0xFF00D09C).withOpacity(0.06),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: const Color(0xFF00D09C).withOpacity(0.2)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.shield_outlined, color: Color(0xFF00D09C), size: 24),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Institutional Investor Protection',
                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
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
                              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: Color(0xFF64748B), letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              b.formattedMinInvestment,
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF00D09C)),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),

                        // Consultation Button
                        Expanded(
                          child: SizedBox(
                            height: 48,
                            child: ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF00D09C),
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                elevation: 0,
                              ),
                              icon: const Icon(Icons.phone_in_talk_rounded, size: 18),
                              label: const Text(
                                'Schedule Consultation',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, letterSpacing: 0.3),
                              ),
                              onPressed: () => showScheduleBusinessCallSheet(context, b),
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
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.04),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.06)),
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
            style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
          ),
        ],
      ),
    );
  }
}
