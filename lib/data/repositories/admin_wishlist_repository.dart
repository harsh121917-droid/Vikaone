import 'package:dio/dio.dart';
import '../../../core/network/api_client.dart';
import '../models/property_model.dart';
import '../models/user_model.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class AdminWishlistStats {
  final int totalSaves, uniqueUsers, last7days;
  final String? topPropertyTitle;
  final int? topPropertyCount;

  const AdminWishlistStats({
    required this.totalSaves,
    required this.uniqueUsers,
    required this.last7days,
    this.topPropertyTitle,
    this.topPropertyCount,
  });

  factory AdminWishlistStats.fromJson(Map<String, dynamic> j) {
    final s = j['stats'] as Map<String, dynamic>;
    final tp = s['topProperty'] as Map<String, dynamic>?;
    return AdminWishlistStats(
      totalSaves: s['totalSaves'] ?? 0,
      uniqueUsers: s['uniqueUsers'] ?? 0,
      last7days: s['last7days'] ?? 0,
      topPropertyTitle: tp?['property']?['title'],
      topPropertyCount: tp?['count'],
    );
  }
}

class PropertyWishlistEntry {
  final String propertyId, propertyTitle, city;
  final int saveCount;
  final int? priceAmount;
  final String? coverImage;
  final List<UserModel> users;

  const PropertyWishlistEntry({
    required this.propertyId,
    required this.propertyTitle,
    required this.city,
    required this.saveCount,
    this.priceAmount,
    this.coverImage,
    required this.users,
  });

  factory PropertyWishlistEntry.fromJson(Map<String, dynamic> j) {
    final p = j['property'] as Map<String, dynamic>;
    return PropertyWishlistEntry(
      propertyId: p['_id'] ?? '',
      propertyTitle: p['title'] ?? '',
      city: p['location']?['city'] ?? 'India',
      saveCount: j['saveCount'] ?? 0,
      priceAmount: p['price']?['amount'],
      coverImage: (p['images'] as List?)?.isNotEmpty == true
          ? p['images'][0]['url']
          : null,
      users: (j['userDetails'] as List? ?? [])
          .map((u) => UserModel.fromJson(u))
          .toList(),
    );
  }

  String get formattedPrice {
    final n = priceAmount;
    if (n == null) return '—';
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹$n';
  }
}

class UserWishlistEntry {
  final UserModel user;
  final int saveCount;
  final List<String> propertyTitles;

  const UserWishlistEntry({
    required this.user,
    required this.saveCount,
    required this.propertyTitles,
  });

  factory UserWishlistEntry.fromJson(Map<String, dynamic> j) =>
      UserWishlistEntry(
        user: UserModel.fromJson(j['user']),
        saveCount: j['saveCount'] ?? 0,
        propertyTitles: (j['propertyDetails'] as List? ?? [])
            .map((p) => p['title']?.toString() ?? '')
            .toList(),
      );
}

// ─── Repository ───────────────────────────────────────────────────────────────
class AdminWishlistRepository {
  final _dio = ApiClient.instance;
  static const _base = '/wishlist/admin';

  Future<AdminWishlistStats> getStats() async {
    final res = await _dio.get('$_base/stats');
    return AdminWishlistStats.fromJson(res.data);
  }

  Future<List<PropertyWishlistEntry>> getByProperty() async {
    final res = await _dio.get('$_base/by-property');
    return (res.data['data'] as List)
        .map((e) => PropertyWishlistEntry.fromJson(e))
        .toList();
  }

  Future<List<UserWishlistEntry>> getByUser() async {
    final res = await _dio.get('$_base/by-user');
    return (res.data['data'] as List)
        .map((e) => UserWishlistEntry.fromJson(e))
        .toList();
  }
}
