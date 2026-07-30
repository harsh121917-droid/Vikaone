import 'package:real_estate/core/network/api_client.dart';

class GoldSchemeModel {
  final String id, name, description;
  final int durationMonths, bonusMonths;
  final double minAmount, maxAmount;
  final bool active;

  const GoldSchemeModel({
    required this.id,
    required this.name,
    required this.description,
    required this.durationMonths,
    required this.bonusMonths,
    required this.minAmount,
    required this.maxAmount,
    required this.active,
  });

  factory GoldSchemeModel.fromJson(Map<String, dynamic> j) => GoldSchemeModel(
    id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
    name: j['name'] ?? '',
    description: j['description'] ?? '',
    durationMonths: (j['durationMonths'] ?? 0) as int,
    bonusMonths: (j['bonusMonths'] ?? 0) as int,
    minAmount: (j['minAmount'] ?? 0) * 1.0,
    maxAmount: (j['maxAmount'] ?? 0) * 1.0,
    active: j['active'] ?? true,
  );
}

class SchemePaymentModel {
  final int installmentNo;
  final double amount, ratePerGram, grams;
  final bool isBonus;
  final DateTime paidAt;

  const SchemePaymentModel({
    required this.installmentNo,
    required this.amount,
    required this.ratePerGram,
    required this.grams,
    required this.isBonus,
    required this.paidAt,
  });

  factory SchemePaymentModel.fromJson(Map<String, dynamic> j) =>
      SchemePaymentModel(
        installmentNo: (j['installmentNo'] ?? 0) as int,
        amount: (j['amount'] ?? 0) * 1.0,
        ratePerGram: (j['ratePerGram'] ?? 0) * 1.0,
        grams: (j['grams'] ?? 0) * 1.0,
        isBonus: j['isBonus'] ?? false,
        paidAt: DateTime.tryParse(j['paidAt'] ?? '') ?? DateTime.now(),
      );
}

class SchemeEnrollmentModel {
  final String id, schemeName, status;
  final double monthlyAmount, totalGoldGrams, totalInvested;
  final int durationMonths, bonusMonths, installmentsPaid;
  final DateTime startedAt;
  final DateTime? completedAt, nextDueAt;
  final List<SchemePaymentModel> payments;

  const SchemeEnrollmentModel({
    required this.id,
    required this.schemeName,
    required this.status,
    required this.monthlyAmount,
    required this.totalGoldGrams,
    required this.totalInvested,
    required this.durationMonths,
    required this.bonusMonths,
    required this.installmentsPaid,
    required this.startedAt,
    required this.payments,
    this.completedAt,
    this.nextDueAt,
  });

  double get progressPct => durationMonths == 0
      ? 0
      : (installmentsPaid / durationMonths * 100).clamp(0, 100);
  bool get isMatured => installmentsPaid >= durationMonths;

  factory SchemeEnrollmentModel.fromJson(Map<String, dynamic> j) =>
      SchemeEnrollmentModel(
        id: j['_id']?.toString() ?? j['id']?.toString() ?? '',
        schemeName: j['schemeName'] ?? '',
        status: j['status'] ?? 'active',
        monthlyAmount: (j['monthlyAmount'] ?? 0) * 1.0,
        totalGoldGrams: (j['totalGoldGrams'] ?? 0) * 1.0,
        totalInvested: (j['totalInvested'] ?? 0) * 1.0,
        durationMonths: (j['durationMonths'] ?? 0) as int,
        bonusMonths: (j['bonusMonths'] ?? 0) as int,
        installmentsPaid: (j['installmentsPaid'] ?? 0) as int,
        startedAt: DateTime.tryParse(j['startedAt'] ?? '') ?? DateTime.now(),
        completedAt: j['completedAt'] != null
            ? DateTime.tryParse(j['completedAt'])
            : null,
        nextDueAt: j['nextDueAt'] != null
            ? DateTime.tryParse(j['nextDueAt'])
            : null,
        payments: (j['payments'] as List? ?? [])
            .map((e) => SchemePaymentModel.fromJson(e))
            .toList(),
      );
}

class SchemeRepository {
  final _dio = ApiClient.instance;
  static const _base = '/schemes';

  Future<List<GoldSchemeModel>> getSchemes() async {
    final res = await _dio.get(_base);
    return (res.data['data'] as List)
        .map((e) => GoldSchemeModel.fromJson(e))
        .toList();
  }

  Future<SchemeEnrollmentModel> enroll({
    required String schemeId,
    required double monthlyAmount,
  }) async {
    final res = await _dio.post(
      '$_base/$schemeId/enroll',
      data: {'monthlyAmount': monthlyAmount},
    );
    return SchemeEnrollmentModel.fromJson(res.data['data']);
  }

  Future<SchemeEnrollmentModel> payNextInstallment(String enrollmentId) async {
    final res = await _dio.post('$_base/enrollments/$enrollmentId/pay');
    return SchemeEnrollmentModel.fromJson(res.data['data']);
  }

  Future<List<SchemeEnrollmentModel>> getMyEnrollments() async {
    final res = await _dio.get('$_base/my');
    return (res.data['data'] as List)
        .map((e) => SchemeEnrollmentModel.fromJson(e))
        .toList();
  }

  Future<SchemeEnrollmentModel> getEnrollmentDetail(String id) async {
    final res = await _dio.get('$_base/my/$id');
    return SchemeEnrollmentModel.fromJson(res.data['data']);
  }

  Future<void> cancelEnrollment(String id) async {
    await _dio.post('$_base/my/$id/cancel');
  }
}
