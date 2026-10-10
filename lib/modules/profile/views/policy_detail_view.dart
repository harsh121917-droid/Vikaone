import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/policy_model.dart';

class PolicyDetailView extends StatefulWidget {
  final String slug;
  final String? defaultTitle;

  const PolicyDetailView({
    super.key,
    required this.slug,
    this.defaultTitle,
  });

  @override
  State<PolicyDetailView> createState() => _PolicyDetailViewState();
}

class _PolicyDetailViewState extends State<PolicyDetailView> {
  LegalPolicyModel? _policy;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPolicy();
  }

  Future<void> _fetchPolicy() async {
    setState(() => _isLoading = true);

    try {
      final res = await ApiClient.instance.get('${ApiConstants.policies}/${widget.slug}');
      if (res.data != null && res.data['success'] == true && res.data['data'] != null) {
        setState(() {
          _policy = LegalPolicyModel.fromJson(res.data['data']);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {}

    // Fallback offline content
    setState(() {
      _policy = _getFallbackPolicy(widget.slug);
      _isLoading = false;
    });
  }

  LegalPolicyModel _getFallbackPolicy(String slug) {
    switch (slug) {
      case 'investor-agreement':
        return LegalPolicyModel(
          slug: 'investor-agreement',
          title: 'Framework Investor Agreement & LLP Terms',
          version: 'v2.4 (2026 Edition)',
          content: '''1. PREAMBLE & SPV PARTNERSHIP STRUCTURE
1.1 This Framework Investor Agreement governs fractional co-ownership of real estate assets curated by VikaDrx.
1.2 Each property is held in an SPV registered as an LLP under the Ministry of Corporate Affairs (MCA).
1.3 Investors become legal partners in the SPV proportionate to capital contributed.

2. CAPITAL & BRICK ALLOCATION
2.1 Each Brick represents a verified economic unit of interest.
2.2 Monies are deposited into SEBI-regulated Escrow accounts.
2.3 Form 3 & Form 4 are filed with the ROC within 30 days of campaign closing.

3. RENTAL DISTRIBUTIONS
3.1 Rental proceeds are pooled in the SPV escrow and disbursed quarterly (July, Oct, Jan, April).
3.2 TDS is deducted as per applicable tax rules with Form 16A provided.

4. CUSTODY & TITLES
4.1 Title deeds are held in independent trusteeship custody (Universal Trusteeship / ICICI Escrow).
4.2 Assets cannot be mortgaged without 75% partner affirmative consent.

5. LIQUIDITY & RESALE
5.1 A 12-month initial holding period applies before listing on the secondary liquidity window.''',
        );
      case 'privacy-policy':
        return LegalPolicyModel(
          slug: 'privacy-policy',
          title: 'Privacy & Data Protection Policy',
          version: 'v2.1',
          content: '''1. COMMITMENT TO DATA PROTECTION
VikaDrx complies strictly with the Digital Personal Data Protection Act, 2023 (DPDP) and IT Act.

2. DATA COLLECTED
2.1 KYC Identifiers: PAN, Aadhaar, Passport, residential address, bank accounts for dividend credit.
2.2 Telemetry: Encrypted session logs, device fingerprints for biometric and PIN lock protection.

3. USE OF DATA
3.1 Mandated PMLA KYC compliance and ROC partnership filings.
3.2 Escrow distributions and transactional alerts.

4. ENCRYPTION & CUSTODY
4.1 256-bit AES encryption at rest and TLS 1.3 in transit.
4.2 Indian data residency on certified SOC2 servers.''',
        );
      case 'terms-conditions':
        return LegalPolicyModel(
          slug: 'terms-conditions',
          title: 'Terms of Service & Platform Governance',
          version: 'v3.0',
          content: '''1. ACCEPTANCE
By using the VikaDrx platform you agree to these Terms of Service.

2. INVESTOR ELIGIBILITY
2.1 Minimum age: 18 years. Indian residents and NRIs (FEMA compliant) permitted.
2.2 Verified KYC is mandatory prior to transacting.

3. REAL ESTATE RISKS
3.1 Projections are based on historical and micro-market analysis.
3.2 Real estate investments carry tenant vacancy and macroeconomic risks.

4. JURISDICTION
Arbitration subject to Mumbai jurisdiction under the Arbitration and Conciliation Act, 1996.''',
        );
      default:
        return LegalPolicyModel(
          slug: 'refund-cancellation',
          title: 'Refund, Cancellation & Liquidity Policy',
          version: 'v1.8',
          content: '''1. 48-HOUR COOLING-OFF PERIOD
Investors have an unconditional right to cancel a Brick purchase within 48 hours of initial order placement, prior to MCA deed execution.

2. FAILED TRANSACTIONS
Amounts debited for failed orders are automatically reversed within 3 business days (T+3) by Razorpay / Bank.

3. UNSUCCESSFUL FUNDING
If a property fails to achieve the 90% funding threshold within the campaign period, 100% of escrow capital is refunded without deductions.

4. LIQUIDITY & SECONDARY TRANSFERS
Following the 12-month lock-in period, fractional units may be transferred to verified KYC investors on the platform.''',
        );
    }
  }

  Future<void> _openOrDownloadPdf() async {
    final url = _policy?.pdfUrl;
    if (url == null || url.trim().isEmpty) {
      Get.snackbar(
        'Document Notice',
        'Official certified PDF is currently being finalized by custodians.',
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      final uri = Uri.parse(url.trim());
      Get.snackbar(
        'Opening Document',
        'Launching official ${_policy?.title}...',
        backgroundColor: const Color(0xFF10B981),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
        icon: const Icon(Icons.file_download_rounded, color: Colors.white),
      );
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Could not open document viewer: $e',
        backgroundColor: const Color(0xFFEF4444),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFF8FAFC);
      final cardBg = dark ? const Color(0xFF0F172A) : Colors.white;
      final textP = dark ? const Color(0xFFF1F5F9) : const Color(0xFF0F172A);
      final textS = dark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
      final borderC = dark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);

      final title = _policy?.title ?? widget.defaultTitle ?? 'Legal Document';
      final version = _policy?.version ?? 'v1.0';
      final hasPdf = _policy?.hasPdf ?? false;

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new_rounded, color: textP, size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: Text(
            title,
            style: TextStyle(color: textP, fontSize: 16, fontWeight: FontWeight.w800),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          centerTitle: true,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.accent))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header Card ──────────────────────────────
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderC),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(dark ? 0.25 : 0.03),
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
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: const Color(0xFF6366F1).withOpacity(0.3)),
                                ),
                                child: Text(
                                  version,
                                  style: const TextStyle(color: Color(0xFF818CF8), fontSize: 11, fontWeight: FontWeight.w800),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF10B981).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.verified_rounded, color: Color(0xFF10B981), size: 12),
                                    SizedBox(width: 4),
                                    Text('Verified & Active', style: TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            title,
                            style: TextStyle(
                              color: textP,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Governing fractional SPV investments · VikaDrx Realty',
                            style: TextStyle(color: textS, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // ── PDF Action Card (If attached) ─────────────
                    if (hasPdf) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: dark
                                ? [const Color(0xFF064E3B).withOpacity(0.5), const Color(0xFF0F2E22).withOpacity(0.5)]
                                : [const Color(0xFFECFDF5), const Color(0xFFD1FAE5)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(18),
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
                              child: const Icon(Icons.picture_as_pdf_rounded, color: Color(0xFF10B981), size: 26),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Official Certified PDF Document',
                                    style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w800),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    'Signed & audited digital copy with regulatory seal',
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
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                minimumSize: Size.zero,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              onPressed: _openOrDownloadPdf,
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.download_rounded, size: 15, color: Colors.white),
                                  SizedBox(width: 4),
                                  Text('Download', style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.w800)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],

                    // ── Document Content Card ──────────────────────
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: borderC),
                      ),
                      child: SelectableText(
                        _policy?.content ?? 'No content published yet.',
                        style: TextStyle(
                          color: textP,
                          fontSize: 13.5,
                          height: 1.65,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Regulatory Callout ─────────────────────────
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: dark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: borderC),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.shield_outlined, color: Color(0xFF64748B), size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Legal notice: All transactions and agreements on VikaDrx are subject to jurisdiction in Mumbai, India.',
                              style: TextStyle(color: textS, fontSize: 11, height: 1.35),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      );
    });
  }
}
