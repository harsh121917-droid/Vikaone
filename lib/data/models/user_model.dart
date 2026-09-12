class UserLocationModel {
  final double? latitude;
  final double? longitude;
  final String? city;
  final String? state;
  final String? country;
  final String? address;
  final String? pincode;
  final DateTime? capturedAt;

  UserLocationModel({
    this.latitude,
    this.longitude,
    this.city,
    this.state,
    this.country,
    this.address,
    this.pincode,
    this.capturedAt,
  });

  factory UserLocationModel.fromJson(Map<String, dynamic> j) => UserLocationModel(
        latitude: (j['latitude'] as num?)?.toDouble(),
        longitude: (j['longitude'] as num?)?.toDouble(),
        city: j['city']?.toString(),
        state: j['state']?.toString(),
        country: j['country']?.toString(),
        address: j['address']?.toString(),
        pincode: j['pincode']?.toString(),
        capturedAt: j['capturedAt'] != null ? DateTime.tryParse(j['capturedAt'].toString()) : null,
      );

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'city': city,
        'state': state,
        'country': country,
        'address': address,
        'pincode': pincode,
        'capturedAt': capturedAt?.toIso8601String(),
      };
}

class UserModel {
  final String id;
  final String name;
  final String email;
  final String? phone;
  final String role;
  final String? avatar;
  final String? profilePicture;
  final String? referralCode;
  final double referralBalance;
  final String kycStatus;
  final UserLocationModel? location;

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    required this.role,
    this.avatar,
    this.profilePicture,
    this.referralCode,
    this.referralBalance = 0.0,
    this.kycStatus = 'not_submitted',
    this.location,
  });

  bool get hasLocation =>
      location != null && location!.latitude != null && location!.longitude != null;

  String? get avatarUrl {
    if (profilePicture != null && profilePicture!.trim().isNotEmpty) {
      return profilePicture!.trim();
    }
    if (avatar != null && avatar!.trim().isNotEmpty) {
      return avatar!.trim();
    }
    return null;
  }

  factory UserModel.fromJson(Map<String, dynamic> j) => UserModel(
    id: j['_id'] ?? j['id'] ?? '',
    name: j['name'] ?? '',
    email: j['email'] ?? '',
    phone: j['phone'],
    role: j['role'] ?? 'user',
    avatar: j['avatar']?.toString(),
    profilePicture: j['profilePicture']?.toString(),
    referralCode: j['referralCode'],
    referralBalance: (j['referralBalance'] as num?)?.toDouble() ?? 0.0,
    kycStatus: j['kycStatus']?.toString() ?? 'not_submitted',
    location: j['location'] != null && j['location'] is Map<String, dynamic>
        ? UserLocationModel.fromJson(j['location'] as Map<String, dynamic>)
        : null,
  );

  Map<String, dynamic> toJson() => {
    '_id': id,
    'name': name,
    'email': email,
    'phone': phone,
    'role': role,
    if (avatar != null) 'avatar': avatar,
    if (profilePicture != null) 'profilePicture': profilePicture,
    'referralCode': referralCode,
    'referralBalance': referralBalance,
    'kycStatus': kycStatus,
    if (location != null) 'location': location!.toJson(),
  };
}
