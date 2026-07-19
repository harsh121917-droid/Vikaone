import 'investment_model.dart';
import 'property_model.dart';

/// Represents all investments a user made into a single property,
/// merged into one summary (total bricks, total amount, transaction count).
class GroupedInvestment {
  final PropertyModel? property;
  final int bricks;
  final int totalAmount;
  final int transactionCount;
  final DateTime latestDate;
  final List<InvestmentModel> transactions;

  GroupedInvestment({
    required this.property,
    required this.bricks,
    required this.totalAmount,
    required this.transactionCount,
    required this.latestDate,
    required this.transactions,
  });

  double get ownershipPercent {
    final total = property?.totalBricks;
    if (total == null || total == 0) return 0;
    return bricks / total * 100;
  }

  int get avgPricePerBrick => bricks > 0 ? (totalAmount / bricks).round() : 0;

  String get formattedTotal {
    if (totalAmount >= 10000000)
      return '₹${(totalAmount / 10000000).toStringAsFixed(2)}Cr';
    if (totalAmount >= 100000)
      return '₹${(totalAmount / 100000).toStringAsFixed(1)}L';
    return '₹$totalAmount';
  }

  /// Groups a flat list of investment transactions by property._id.
  static List<GroupedInvestment> fromList(List<InvestmentModel> investments) {
    final Map<String, List<InvestmentModel>> byProperty = {};

    for (final inv in investments) {
      final pid = inv.property?.id ?? 'unknown';
      byProperty.putIfAbsent(pid, () => []).add(inv);
    }

    return byProperty.entries.map((entry) {
      final txs = entry.value;
      final bricks = txs.fold<int>(0, (s, t) => s + t.bricks);
      final totalAmount = txs.fold<int>(0, (s, t) => s + t.totalAmount);
      final latestDate = txs
          .map((t) => t.createdAt)
          .reduce((a, b) => a.isAfter(b) ? a : b);

      return GroupedInvestment(
        property: txs.first.property,
        bricks: bricks,
        totalAmount: totalAmount,
        transactionCount: txs.length,
        latestDate: latestDate,
        transactions: txs,
      );
    }).toList()..sort((a, b) => b.latestDate.compareTo(a.latestDate));
  }
}
