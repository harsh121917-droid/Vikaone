class LegalPolicyModel {
  final String slug;
  final String title;
  final String version;
  final String content;
  final String? pdfUrl;
  final DateTime? lastUpdated;
  final String? supportEmail;
  final String? supportPhone;
  final String? supportWhatsapp;
  final String? supportHours;
  final String? officeAddress;
  final List<SupportFaq> faqs;

  LegalPolicyModel({
    required this.slug,
    required this.title,
    required this.version,
    required this.content,
    this.pdfUrl,
    this.lastUpdated,
    this.supportEmail,
    this.supportPhone,
    this.supportWhatsapp,
    this.supportHours,
    this.officeAddress,
    this.faqs = const [],
  });

  bool get hasPdf => pdfUrl != null && pdfUrl!.trim().isNotEmpty;

  factory LegalPolicyModel.fromJson(Map<String, dynamic> j) {
    return LegalPolicyModel(
      slug: j['slug']?.toString() ?? '',
      title: j['title']?.toString() ?? 'Legal Document',
      version: j['version']?.toString() ?? 'v1.0',
      content: j['content']?.toString() ?? '',
      pdfUrl: j['pdfUrl']?.toString(),
      lastUpdated: j['lastUpdated'] != null ? DateTime.tryParse(j['lastUpdated'].toString()) : null,
      supportEmail: j['supportEmail']?.toString() ?? 'support@vikadrx.com',
      supportPhone: j['supportPhone']?.toString() ?? '+91 80000 12345',
      supportWhatsapp: j['supportWhatsapp']?.toString() ?? '+91 80000 12345',
      supportHours: j['supportHours']?.toString() ?? 'Mon - Sat: 9:30 AM - 7:00 PM IST',
      officeAddress: j['officeAddress']?.toString() ?? 'VikaDrx Realty Private Limited, Nariman Point, Mumbai, Maharashtra 400021',
      faqs: (j['faqs'] as List? ?? [])
          .map((e) => SupportFaq.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'slug': slug,
    'title': title,
    'version': version,
    'content': content,
    'pdfUrl': pdfUrl,
    'lastUpdated': lastUpdated?.toIso8601String(),
    'supportEmail': supportEmail,
    'supportPhone': supportPhone,
    'supportWhatsapp': supportWhatsapp,
    'supportHours': supportHours,
    'officeAddress': officeAddress,
    'faqs': faqs.map((f) => f.toJson()).toList(),
  };
}

class SupportFaq {
  final String question;
  final String answer;

  SupportFaq({
    required this.question,
    required this.answer,
  });

  factory SupportFaq.fromJson(Map<String, dynamic> j) {
    return SupportFaq(
      question: j['question']?.toString() ?? '',
      answer: j['answer']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'question': question,
    'answer': answer,
  };
}
