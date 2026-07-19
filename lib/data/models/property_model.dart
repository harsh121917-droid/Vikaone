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
  });

  String? get coverImage => images.isNotEmpty ? images.first.url : null;
  int get availableBricks => (totalBricks ?? 0) - (soldBricks ?? 0);
  double get soldPercent => totalBricks != null && totalBricks! > 0
      ? (soldBricks ?? 0) / totalBricks! * 100
      : 0;

  String get formattedPrice {
    final n = price.amount;
    if (n == null) return '—';
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹$n';
  }

  factory PropertyModel.fromJson(Map<String, dynamic> j) => PropertyModel(
    id: j['_id'] ?? '',
    title: j['title'] ?? '',
    description: j['description'],
    propertyType: j['propertyType'],
    bhk: j['bhk'],
    area: j['area'],
    featured: j['featured'] ?? false,
    investmentEnabled: j['investmentEnabled'] ?? false,
    brickPrice: j['brickPrice'],
    totalBricks: j['totalBricks'],
    soldBricks: j['soldBricks'],
    expectedAppreciation: (j['expectedAppreciation'] ?? 8).toDouble(),
    expectedRentalYield: (j['expectedRentalYield'] ?? 3).toDouble(),
    location: PropertyLocation.fromJson(j['location'] ?? {}),
    price: PropertyPrice.fromJson(j['price'] ?? {}),
    images: (j['images'] as List? ?? [])
        .map((e) => PropertyImage.fromJson(e))
        .toList(),
    amenities: List<String>.from(j['amenities'] ?? []),
    status: j['status'] ?? 'draft',
  );
}

class PropertyLocation {
  final String? address, city, state, pincode;
  PropertyLocation({this.address, this.city, this.state, this.pincode});
  String get display => [
    address,
    city,
    state,
  ].where((e) => e != null && e!.isNotEmpty).join(', ');
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
