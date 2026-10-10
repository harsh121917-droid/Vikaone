class PropertyModel {
  final String id;
  final String title;
  final String? description;
  final String? propertyType;
  final String? bhk;
  final int? area;
  final bool featured;
  final bool investmentEnabled;
  final int? brickPrice;
  final int? totalBricks;
  final int? soldBricks;
  final double expectedAppreciation;
  final double expectedRentalYield;
  final PropertyLocation location;
  final PropertyPrice price;
  final List<PropertyImage> images;
  final List<String> amenities;
  final String status;
  final String purchaseMode;
  final String? youtubeUrl;
  final String? valuationReportUrl;
  final String? valuationReportTitle;
  final String? valuationReportDate;
  final String? valuationAuthority;
  final String? valuationMethodology;
  final String? valuationSummary;
  final String? reraNumber;
  final double? targetXirr;
  final String? growthProjections;
  final List<PropertyDocument> documents;
  final String spvName;
  final String spvEscrowBank;
  final String spvEscrowAccountNo;
  final String spvEscrowIfsc;
  final String spvEscrowBranch;
  final String? spvEscrowCertificateUrl;
  final String spvTrusteeName;
  final String spvTrusteeAddress;
  final String? spvTrusteeCertificateUrl;
  final String? spvLiquidityPolicy;

  // Admin-customisable text (null/blank -> default getters below)
  final String? spvEscrowAccountName;
  final String? spvEscrowAccountType;
  final String? spvEscrowDivision;
  final String? spvEscrowNote;
  final String? spvEscrowSafeguards;
  final String? spvTrusteeShortName;
  final String? spvTrusteeTagline;
  final String? spvTrusteeRegNo;
  final String? spvTrusteeBeneficiaries;
  final String? spvTrusteeCertificateText;
  final String? spvTrusteeRoles;
  final String? scheduleAdvisorTitle;
  final String? scheduleAdvisorSubtitle;
  final String? scheduleAdvisorImage;
  final String? scheduleTimeSlots;
  final int scheduleDaysAhead;

  PropertyModel({
    required this.id,
    required this.title,
    this.description,
    this.propertyType,
    this.bhk,
    this.area,
    required this.featured,
    required this.investmentEnabled,
    this.brickPrice,
    this.totalBricks,
    this.soldBricks,
    this.expectedAppreciation = 8,
    this.expectedRentalYield = 3,
    required this.location,
    required this.price,
    required this.images,
    required this.amenities,
    required this.status,
    this.purchaseMode = 'both',
    this.youtubeUrl,
    this.valuationReportUrl,
    this.valuationReportTitle,
    this.valuationReportDate,
    this.valuationAuthority,
    this.valuationMethodology,
    this.valuationSummary,
    this.reraNumber,
    this.targetXirr,
    this.growthProjections,
    this.documents = const [],
    this.spvName = 'VIKADRX REALTY SERIES 001 LLP',
    this.spvEscrowBank = 'ICICI Bank',
    this.spvEscrowAccountNo = '705105000036',
    this.spvEscrowIfsc = 'ICIC0007051',
    this.spvEscrowBranch = 'ICICI Bank Ltd, Shop No 12,13,14, Ground Floor, B Block Market, South City II, Sohna Road, Gurgaon, Haryana - 122018',
    this.spvEscrowCertificateUrl,
    this.spvTrusteeName = 'Universal Trusteeship Services Limited',
    this.spvTrusteeAddress = 'Premises No. 74, 7th Floor, Sakhar Bhavan, Nariman Point, Mumbai 400 021',
    this.spvTrusteeCertificateUrl,
    this.spvLiquidityPolicy,
    this.spvEscrowAccountName,
    this.spvEscrowAccountType,
    this.spvEscrowDivision,
    this.spvEscrowNote,
    this.spvEscrowSafeguards,
    this.spvTrusteeShortName,
    this.spvTrusteeTagline,
    this.spvTrusteeRegNo,
    this.spvTrusteeBeneficiaries,
    this.spvTrusteeCertificateText,
    this.spvTrusteeRoles,
    this.scheduleAdvisorTitle,
    this.scheduleAdvisorSubtitle,
    this.scheduleAdvisorImage,
    this.scheduleTimeSlots,
    this.scheduleDaysAhead = 0,
  });

  static String _or(String? v, String def) =>
      (v != null && v.trim().isNotEmpty) ? v.trim() : def;
  static List<String> _lines(String? v, List<String> def) {
    if (v == null || v.trim().isEmpty) return def;
    final l = v.split(RegExp(r'[\r\n]+')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return l.isEmpty ? def : l;
  }

  // ── Escrow display values ──
  String get escrowAccountName => _or(spvEscrowAccountName, spvName);
  String get escrowAccountType => _or(spvEscrowAccountType, 'Current / Escrow Account');
  String get escrowDivision => _or(spvEscrowDivision, 'Escrow Division');
  String get escrowNote => _or(spvEscrowNote,
      'Certified: All incoming investor capital is held in this segregated escrow account under $trusteeShortName instructions.');
  List<String> get escrowSafeguards => _lines(spvEscrowSafeguards, [
        'Zero Platform Touch: VikaDrx does not have unilateral withdrawal access to your investment funds.',
        'Dual Authorization: Fund disbursement to the seller requires approval from $spvTrusteeName.',
        '100% Refund Guarantee: If the funding milestone is not achieved, capital is returned directly to the investor bank account.',
      ]);

  // ── Trustee display values ──
  String get trusteeShortName => _or(spvTrusteeShortName, 'Universal Trustee');
  String get trusteeTagline => _or(spvTrusteeTagline, 'SEBI Registered Custodian & Trustee');
  String get trusteeRegNo => _or(spvTrusteeRegNo, 'SEBI Regn. No. IND000000570');
  String get trusteeBeneficiaries => _or(spvTrusteeBeneficiaries, 'All registered unit holders of $title');
  String get trusteeCertificateText => _or(spvTrusteeCertificateText,
      'This is to certify that $spvTrusteeName has been formally appointed as the Independent Trustee for $spvName.');
  List<String> get trusteeRoles => _lines(spvTrusteeRoles, const [
        'Title Custody: Holds legal mortgage/charge on property deed preventing unauthorized resale or debt.',
        'Rental Supervision: Audits monthly tenant lease collections and approves automated dividend payouts.',
        'Exit Enforcement: Oversees secondary trading and institutional liquidity windows to protect minority unit holders.',
      ]);

  // ── Schedule-a-call display values ──
  String get scheduleTitle => _or(scheduleAdvisorTitle, 'Call with advisor');
  String get scheduleSubtitle => _or(scheduleAdvisorSubtitle, 'Know how you can maximise your earnings with VikaDrx.');
  int get scheduleDays => (scheduleDaysAhead > 0 && scheduleDaysAhead <= 30) ? scheduleDaysAhead : 7;
  List<String> get scheduleSlots {
    const def = ['10:00 AM', '11:00 AM', '12:00 PM', '1:00 PM', '2:00 PM', '3:00 PM', '4:00 PM', '5:00 PM', '6:00 PM'];
    if (scheduleTimeSlots == null || scheduleTimeSlots!.trim().isEmpty) return def;
    final l = scheduleTimeSlots!.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    return l.isEmpty ? def : l;
  }

  String? get coverImage => images.isNotEmpty ? images.first.url : null;
  double get effectiveXirr => (targetXirr != null && targetXirr! > 0) ? targetXirr! : (expectedRentalYield + expectedAppreciation);
  int get availableBricks => (totalBricks ?? 0) - (soldBricks ?? 0);
  double get soldPercent => totalBricks != null && totalBricks! > 0
      ? (soldBricks ?? 0) / totalBricks! * 100
      : 0;
  bool get allowsBricks => purchaseMode == 'both' || purchaseMode == 'bricks';
  bool get allowsDirectBuy => purchaseMode == 'both' || purchaseMode == 'direct';
  bool get isDirectBuyOnly => purchaseMode == 'direct';
  bool get isBricksOnly => purchaseMode == 'bricks';

  /// Extracts the 11-character YouTube video ID from youtubeUrl or videos array
  String? get youtubeVideoId {
    if (youtubeUrl == null || youtubeUrl!.trim().isEmpty) return null;
    final id = extractYouTubeId(youtubeUrl!);
    if (id == null) return null;
    if (id == 'GDwvVlXmmjU') {
      return 'xBNULnZNZg0'; // Fallback for deleted sample video
    }
    return id;
  }

  static String? extractYouTubeId(String url) {
    url = url.trim();
    if (url.length == 11 && !url.contains('/') && !url.contains('?') && !url.contains('.')) {
      return url;
    }
    final regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/|youtube\.com\/shorts\/)([a-zA-Z0-9_-]{11})',
      caseSensitive: false,
    );
    final match = regExp.firstMatch(url);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

  String get formattedPrice {
    final n = price.amount;
    if (n == null) return '—';
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹$n';
  }

  factory PropertyModel.fromJson(Map<String, dynamic> j) {
    String? ytUrl = j['youtubeUrl']?.toString();
    if (ytUrl == null || ytUrl.isEmpty) {
      final vids = j['videos'];
      if (vids is List && vids.isNotEmpty) {
        final firstVid = vids.first;
        if (firstVid is Map && firstVid['url'] != null) {
          ytUrl = firstVid['url']?.toString();
        } else if (firstVid is String) {
          ytUrl = firstVid;
        }
      }
    }

    return PropertyModel(
      id: j['_id'] ?? '',
      title: j['title'] ?? '',
      description: j['description'],
      propertyType: j['propertyType'],
      bhk: j['bhk'],
      area: (j['area'] as num?)?.toInt(),
      featured: j['featured'] ?? false,
      investmentEnabled: j['investmentEnabled'] ?? false,
      brickPrice: (j['brickPrice'] as num?)?.toInt(),
      totalBricks: (j['totalBricks'] as num?)?.toInt(),
      soldBricks: (j['soldBricks'] as num?)?.toInt(),
      expectedAppreciation: (j['expectedAppreciation'] as num? ?? 8).toDouble(),
      expectedRentalYield: (j['expectedRentalYield'] as num? ?? 3).toDouble(),
      targetXirr: (j['targetXirr'] as num?)?.toDouble(),
      growthProjections: j['growthProjections']?.toString(),
      location: PropertyLocation.fromJson(j['location'] ?? {}),
      price: PropertyPrice.fromJson(j['price'] ?? {}),
      images: (j['images'] as List? ?? [])
          .map((e) => PropertyImage.fromJson(e))
          .toList(),
      amenities: List<String>.from(j['amenities'] ?? []),
      status: j['status'] ?? 'draft',
      purchaseMode: j['purchaseMode'] ?? 'both',
      youtubeUrl: ytUrl,
      valuationReportUrl: j['valuationReportUrl']?.toString(),
      valuationReportTitle: j['valuationReportTitle']?.toString() ?? 'Certified Valuation & Audit Report',
      valuationReportDate: j['valuationReportDate']?.toString(),
      valuationAuthority: j['valuationAuthority']?.toString(),
      valuationMethodology: j['valuationMethodology']?.toString(),
      valuationSummary: j['valuationSummary']?.toString(),
      reraNumber: j['reraNumber']?.toString(),
      documents: (j['documents'] as List? ?? [])
          .map((e) => PropertyDocument.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .toList(),
      spvName: (j['spvName'] != null && j['spvName'].toString().trim().isNotEmpty)
          ? j['spvName'].toString().trim()
          : 'VIKADRX REALTY SERIES 001 LLP',
      spvEscrowBank: (j['spvEscrowBank'] != null && j['spvEscrowBank'].toString().trim().isNotEmpty)
          ? j['spvEscrowBank'].toString().trim()
          : 'ICICI Bank',
      spvEscrowAccountNo: (j['spvEscrowAccountNo'] != null && j['spvEscrowAccountNo'].toString().trim().isNotEmpty)
          ? j['spvEscrowAccountNo'].toString().trim()
          : '705105000036',
      spvEscrowIfsc: (j['spvEscrowIfsc'] != null && j['spvEscrowIfsc'].toString().trim().isNotEmpty)
          ? j['spvEscrowIfsc'].toString().trim()
          : 'ICIC0007051',
      spvEscrowBranch: (j['spvEscrowBranch'] != null && j['spvEscrowBranch'].toString().trim().isNotEmpty)
          ? j['spvEscrowBranch'].toString().trim()
          : 'ICICI Bank Ltd, Shop No 12,13,14, Ground Floor, B Block Market, South City II, Sohna Road, Gurgaon, Haryana - 122018',
      spvEscrowCertificateUrl: j['spvEscrowCertificateUrl']?.toString(),
      spvTrusteeName: (j['spvTrusteeName'] != null && j['spvTrusteeName'].toString().trim().isNotEmpty)
          ? j['spvTrusteeName'].toString().trim()
          : 'Universal Trusteeship Services Limited',
      spvTrusteeAddress: (j['spvTrusteeAddress'] != null && j['spvTrusteeAddress'].toString().trim().isNotEmpty)
          ? j['spvTrusteeAddress'].toString().trim()
          : 'Premises No. 74, 7th Floor, Sakhar Bhavan, Nariman Point, Mumbai 400 021',
      spvTrusteeCertificateUrl: j['spvTrusteeCertificateUrl']?.toString(),
      spvLiquidityPolicy: j['spvLiquidityPolicy']?.toString(),
      spvEscrowAccountName: j['spvEscrowAccountName']?.toString(),
      spvEscrowAccountType: j['spvEscrowAccountType']?.toString(),
      spvEscrowDivision: j['spvEscrowDivision']?.toString(),
      spvEscrowNote: j['spvEscrowNote']?.toString(),
      spvEscrowSafeguards: j['spvEscrowSafeguards']?.toString(),
      spvTrusteeShortName: j['spvTrusteeShortName']?.toString(),
      spvTrusteeTagline: j['spvTrusteeTagline']?.toString(),
      spvTrusteeRegNo: j['spvTrusteeRegNo']?.toString(),
      spvTrusteeBeneficiaries: j['spvTrusteeBeneficiaries']?.toString(),
      spvTrusteeCertificateText: j['spvTrusteeCertificateText']?.toString(),
      spvTrusteeRoles: j['spvTrusteeRoles']?.toString(),
      scheduleAdvisorTitle: j['scheduleAdvisorTitle']?.toString(),
      scheduleAdvisorSubtitle: j['scheduleAdvisorSubtitle']?.toString(),
      scheduleAdvisorImage: j['scheduleAdvisorImage']?.toString(),
      scheduleTimeSlots: j['scheduleTimeSlots']?.toString(),
      scheduleDaysAhead: (j['scheduleDaysAhead'] as num?)?.toInt() ?? 0,
    );
  }
}

class PropertyLocation {
  final String? address, city, state, pincode;
  PropertyLocation({this.address, this.city, this.state, this.pincode});
  String get display => [
    address,
    city,
    state,
  ].where((e) => e != null && e.isNotEmpty).join(', ');
  factory PropertyLocation.fromJson(Map<String, dynamic> j) => PropertyLocation(
    address: j['address'],
    city: j['city'],
    state: j['state'],
    pincode: j['pincode'],
  );
}

class PropertyPrice {
  final int? amount;
  final String? label;
  PropertyPrice({this.amount, this.label});
  factory PropertyPrice.fromJson(Map<String, dynamic> j) =>
      PropertyPrice(amount: j['amount'], label: j['label']);
}

class PropertyImage {
  final String url;
  PropertyImage({required this.url});
  factory PropertyImage.fromJson(Map<String, dynamic> j) =>
      PropertyImage(url: j['url'] ?? '');
}

class PropertyDocument {
  final String? id;
  final String title;
  final String? type;
  final String url;
  final DateTime? uploadedAt;

  PropertyDocument({
    this.id,
    required this.title,
    this.type,
    required this.url,
    this.uploadedAt,
  });

  factory PropertyDocument.fromJson(Map<String, dynamic> j) {
    return PropertyDocument(
      id: j['_id']?.toString(),
      title: j['title']?.toString() ?? 'Document',
      type: j['type']?.toString() ?? 'Legal Document',
      url: j['url']?.toString() ?? '',
      uploadedAt: j['uploadedAt'] != null ? DateTime.tryParse(j['uploadedAt'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'type': type,
    'url': url,
    'uploadedAt': uploadedAt?.toIso8601String(),
  };
}
