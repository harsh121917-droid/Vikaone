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
    this.documents = const [],
    this.spvName = 'VIKAONE REALTY SERIES 001 LLP',
    this.spvEscrowBank = 'ICICI Bank',
    this.spvEscrowAccountNo = '705105000036',
    this.spvEscrowIfsc = 'ICIC0007051',
    this.spvEscrowBranch = 'ICICI Bank Ltd, Shop No 12,13,14, Ground Floor, B Block Market, South City II, Sohna Road, Gurgaon, Haryana - 122018',
    this.spvEscrowCertificateUrl,
    this.spvTrusteeName = 'Universal Trusteeship Services Limited',
    this.spvTrusteeAddress = 'Premises No. 74, 7th Floor, Sakhar Bhavan, Nariman Point, Mumbai 400 021',
    this.spvTrusteeCertificateUrl,
    this.spvLiquidityPolicy,
  });

  String? get coverImage => images.isNotEmpty ? images.first.url : null;
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
      valuationReportTitle: j['valuationReportTitle']?.toString() ?? 'Valuation & Audit Report',
      documents: (j['documents'] as List? ?? [])
          .map((e) => PropertyDocument.fromJson(e is Map<String, dynamic> ? e : Map<String, dynamic>.from(e as Map)))
          .toList(),
      spvName: (j['spvName'] != null && j['spvName'].toString().trim().isNotEmpty)
          ? j['spvName'].toString().trim()
          : 'VIKAONE REALTY SERIES 001 LLP',
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
