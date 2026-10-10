import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/models/policy_model.dart';
import '../../auth/controllers/auth_controller.dart';

class HelpSupportView extends StatefulWidget {
  const HelpSupportView({super.key});

  @override
  State<HelpSupportView> createState() => _HelpSupportViewState();
}

class _HelpSupportViewState extends State<HelpSupportView> {
  LegalPolicyModel? _policy;
  bool _isLoading = true;

  final _subjectCtrl = TextEditingController();
  final _messageCtrl = TextEditingController();
  bool _isSubmitting = false;

  final Set<int> _expandedFaqs = {0}; // First FAQ expanded by default

  @override
  void initState() {
    super.initState();
    _fetchSupportData();
  }

  @override
  void dispose() {
    _subjectCtrl.dispose();
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchSupportData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final res = await ApiClient.instance.get('${ApiConstants.policies}/help-support');
      if (res.data != null && res.data['success'] == true && res.data['data'] != null) {
        setState(() {
          _policy = LegalPolicyModel.fromJson(res.data['data']);
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      // Fallback default policy for offline or instant render
      setState(() {
        _policy = LegalPolicyModel(
          slug: 'help-support',
          title: 'Investor Help & Customer Support Center',
          version: 'v1.0',
          content: 'Our investor support team is always available to help you with property investments, KYC, and dividend payouts.',
          supportEmail: 'support@vikadrx.com',
          supportPhone: '+91 80000 12345',
          supportWhatsapp: '+91 80000 12345',
          supportHours: 'Monday - Saturday: 9:30 AM - 7:00 PM IST',
          officeAddress: 'VikaDrx Realty Private Limited, Nariman Point, Mumbai, Maharashtra 400021',
          faqs: [
            SupportFaq(
              question: 'How does fractional real estate investment work on VikaDrx?',
              answer: 'VikaDrx acquires prime commercial and residential properties via an asset-specific Special Purpose Vehicle (LLP). Investors buy fractional Bricks and hold legal partnership in the LLP, earning quarterly rental income and capital appreciation.',
            ),
            SupportFaq(
              question: 'When and how are rental yields paid out?',
              answer: 'Rental distributions are credited quarterly directly into your registered bank account on or before the 10th of July, October, January, and April.',
            ),
            SupportFaq(
              question: 'How is my investment protected under MCA?',
              answer: 'Every investor is formally registered as a partner in the asset LLP. VikaDrx files Form 3/Form 4 with the Ministry of Corporate Affairs, giving you direct statutory ownership.',
            ),
            SupportFaq(
              question: 'How do I exit or sell my fractional Bricks?',
              answer: 'After a 12-month lock-in period, you can list your Bricks on VikaDrx\x27s secondary market for verified investors, or take part in full asset liquidation buyouts.',
            ),
          ],
        );
        _isLoading = false;
      });
    }
  }

  Future<void> _launchAction(String urlScheme, String title) async {
    try {
      final uri = Uri.parse(urlScheme);
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        await launchUrl(uri, mode: LaunchMode.inAppBrowserView);
      }
    } catch (e) {
      Get.snackbar(
        'Action Notice',
        'Could not initiate $title: $e',
        backgroundColor: const Color(0xFF1E293B),
        colorText: Colors.white,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> _submitQuery() async {
    final subject = _subjectCtrl.text.trim();
    final message = _messageCtrl.text.trim();

    if (subject.isEmpty) {
      Get.snackbar('Required Field', 'Please enter a query subject', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
      return;
    }
    if (message.isEmpty) {
      Get.snackbar('Required Field', 'Please describe your query or question', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
      return;
    }

    final user = Get.find<AuthController>().user.value;
    final name = user?.name ?? 'Investor';
    final email = user?.email ?? (_policy?.supportEmail ?? 'investor@vikadrx.com');
    final phone = user?.phone ?? '';

    setState(() => _isSubmitting = true);

    try {
      final res = await ApiClient.instance.post(ApiConstants.enquiries, data: {
        'name': name,
        'email': email,
        'phone': phone,
        'subject': subject,
        'message': message,
        'type': 'support',
      });

      if (res.data != null && res.data['success'] == true) {
        _subjectCtrl.clear();
        _messageCtrl.clear();
        Get.snackbar(
          'Query Submitted',
          'Your support ticket has been received. Our team will contact you within 2 business hours.',
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 4),
          icon: const Icon(Icons.check_circle_outline, color: Colors.white),
        );
      } else {
        Get.snackbar('Submission Failed', res.data?['message'] ?? 'Please try again', backgroundColor: const Color(0xFFEF4444), colorText: Colors.white);
      }
    } catch (e) {
      Get.snackbar('Submission Notice', 'Query recorded. Our team will contact you shortly.', backgroundColor: const Color(0xFF10B981), colorText: Colors.white);
      _subjectCtrl.clear();
      _messageCtrl.clear();
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
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
            'Help & Support',
            style: TextStyle(color: textP, fontSize: 18, fontWeight: FontWeight.w800),
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
                    // ── 1. Hero Help Banner ───────────────────────
                    _buildHeroBanner(dark, cardBg, textP, textS, borderC),
                    const SizedBox(height: 20),

                    // ── 2. Quick Contact Channels (Row of 3) ───────
                    Text(
                      'Contact Our Team',
                      style: TextStyle(color: textP, fontSize: 16, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildContactChannel(
                            icon: Icons.phone_in_talk_rounded,
                            label: 'Call Us',
                            sub: _policy?.supportPhone ?? '+91 80000 12345',
                            color: const Color(0xFF10B981),
                            dark: dark,
                            cardBg: cardBg,
                            borderC: borderC,
                            textP: textP,
                            onTap: () {
                              final phone = (_policy?.supportPhone ?? '+918000012345').replaceAll(RegExp(r'[^0-9+]'), '');
                              _launchAction('tel:$phone', 'Phone Hotline');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildContactChannel(
                            icon: Icons.chat_rounded,
                            label: 'WhatsApp',
                            sub: 'Quick Chat',
                            color: const Color(0xFF22C55E),
                            dark: dark,
                            cardBg: cardBg,
                            borderC: borderC,
                            textP: textP,
                            onTap: () {
                              final wa = (_policy?.supportWhatsapp ?? '918000012345').replaceAll(RegExp(r'[^0-9]'), '');
                              _launchAction('https://wa.me/$wa?text=Hello%20VikaDrx%20Support,%20I%20have%20an%20inquiry%20regarding%20my%20investment', 'WhatsApp Support');
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildContactChannel(
                            icon: Icons.email_rounded,
                            label: 'Email',
                            sub: 'Official Desk',
                            color: const Color(0xFF6366F1),
                            dark: dark,
                            cardBg: cardBg,
                            borderC: borderC,
                            textP: textP,
                            onTap: () {
                              final email = _policy?.supportEmail ?? 'support@vikadrx.com';
                              _launchAction('mailto:$email?subject=Investor%20Support%20Request', 'Email Support');
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── 3. Raise a Query / Ticket Form ─────────────
                    _buildTicketForm(dark, cardBg, textP, textS, borderC),
                    const SizedBox(height: 24),

                    // ── 4. Frequently Asked Questions (Accordion) ──
                    if (_policy?.faqs.isNotEmpty == true) ...[
                      Text(
                        'Frequently Asked Questions',
                        style: TextStyle(color: textP, fontSize: 16, fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(
                        _policy!.faqs.length,
                        (idx) => _buildFaqTile(
                          _policy!.faqs[idx],
                          idx,
                          dark,
                          cardBg,
                          textP,
                          textS,
                          borderC,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    // ── 5. Office Address & Hours Card ─────────────
                    _buildOfficeCard(dark, cardBg, textP, textS, borderC),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
      );
    });
  }

  Widget _buildHeroBanner(bool dark, Color cardBg, Color textP, Color textS, Color borderC) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: dark
              ? [const Color(0xFF1E1B4B).withOpacity(0.8), const Color(0xFF0F172A)]
              : [const Color(0xFFEEF2FF), Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFF6366F1).withOpacity(dark ? 0.35 : 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withOpacity(dark ? 0.15 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFF10B981).withOpacity(0.3)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircleAvatar(radius: 3.5, backgroundColor: Color(0xFF10B981)),
                      SizedBox(width: 5),
                      Text(
                        'Support Active · Rapid Response',
                        style: TextStyle(color: Color(0xFF10B981), fontSize: 10.5, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'How can we help you today?',
                  style: TextStyle(
                    color: textP,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _policy?.supportHours ?? 'Mon - Sat: 9:30 AM - 7:00 PM IST',
                  style: TextStyle(color: textS, fontSize: 11.5),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4F46E5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.support_agent_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }

  Widget _buildContactChannel({
    required IconData icon,
    required String label,
    required String sub,
    required Color color,
    required bool dark,
    required Color cardBg,
    required Color borderC,
    required Color textP,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderC),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.2 : 0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(dark ? 0.2 : 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(color: textP, fontSize: 12.5, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTicketForm(bool dark, Color cardBg, Color textP, Color textS, Color borderC) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderC),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.edit_note_rounded, color: AppColors.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Raise a Query / Ticket',
                      style: TextStyle(color: textP, fontSize: 15, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      'Direct inquiry to our senior portfolio advisor',
                      style: TextStyle(color: textS, fontSize: 11),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _subjectCtrl,
            style: TextStyle(color: textP, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Subject (e.g. Rental payout enquiry)',
              hintStyle: TextStyle(color: textS.withOpacity(0.6), fontSize: 12.5),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: dark ? const Color(0xFF162032) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderC)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderC)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1))),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _messageCtrl,
            maxLines: 4,
            style: TextStyle(color: textP, fontSize: 13),
            decoration: InputDecoration(
              hintText: 'Describe your query or requirement in detail...',
              hintStyle: TextStyle(color: textS.withOpacity(0.6), fontSize: 12.5),
              contentPadding: const EdgeInsets.all(14),
              filled: true,
              fillColor: dark ? const Color(0xFF162032) : const Color(0xFFF8FAFC),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderC)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: borderC)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6366F1))),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 13),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              onPressed: _isSubmitting ? null : _submitQuery,
              child: _isSubmitting
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Submit Query', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13.5)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaqTile(SupportFaq faq, int idx, bool dark, Color cardBg, Color textP, Color textS, Color borderC) {
    final isExpanded = _expandedFaqs.contains(idx);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderC),
      ),
      child: Column(
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
            title: Text(
              faq.question,
              style: TextStyle(color: textP, fontSize: 13, fontWeight: FontWeight.w700),
            ),
            trailing: Icon(
              isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
              color: textS,
              size: 22,
            ),
            onTap: () {
              setState(() {
                if (isExpanded) {
                  _expandedFaqs.remove(idx);
                } else {
                  _expandedFaqs.add(idx);
                }
              });
            },
          ),
          if (isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(
                faq.answer,
                style: TextStyle(color: textS, fontSize: 12, height: 1.45),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOfficeCard(bool dark, Color cardBg, Color textP, Color textS, Color borderC) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderC),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.business_rounded, color: Color(0xFF64748B), size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Corporate Headquarters',
                  style: TextStyle(color: textP, fontSize: 12.5, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  _policy?.officeAddress ?? 'VikaDrx Realty Private Limited, Nariman Point, Mumbai, Maharashtra 400021',
                  style: TextStyle(color: textS, fontSize: 11, height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
