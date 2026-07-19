import 'property_model.dart';

class InvestmentModel {
  final String id;
  final int bricks;
  final int pricePerBrick;
  final int totalAmount;
  final double? ownershipPercent;
  final String status;
  final PropertyModel? property;
  final DateTime createdAt;

  InvestmentModel({
    required this.id, required this.bricks, required this.pricePerBrick,
    required this.totalAmount, this.ownershipPercent, required this.status,
    this.property, required this.createdAt,
  });

  String get formattedTotal {
    if (totalAmount >= 10000000) return '₹${(totalAmount / 10000000).toStringAsFixed(2)}Cr';
    if (totalAmount >= 100000) return '₹${(totalAmount / 100000).toStringAsFixed(1)}L';
    return '₹$totalAmount';
  }

  factory InvestmentModel.fromJson(Map<String, dynamic> j) => InvestmentModel(
    id: j['_id'] ?? '', bricks: j['bricks'] ?? 0,
    pricePerBrick: j['pricePerBrick'] ?? 0, totalAmount: j['totalAmount'] ?? 0,
    ownershipPercent: (j['ownershipPercent'] as num?)?.toDouble(),
    status: j['status'] ?? 'pending',
    property: j['property'] != null ? PropertyModel.fromJson(j['property']) : null,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );
}
