class TransactionModel {
  final String id;
  final String type; // brick_purchase | daily_saving | monthly_saving
  final String category; // Investment | Savings
  final String title;
  final String subtitle;
  final int amount;
  final String status; // success | pending | failed
  final String? razorpayPaymentId;
  final String? razorpayOrderId;
  final String? coverImage;
  final String? city;
  final String? propertyId;
  final String? savingId;
  final int? bricks;
  final int? pricePerBrick;
  final String? note;
  final DateTime createdAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.category,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.razorpayPaymentId,
    this.razorpayOrderId,
    this.coverImage,
    this.city,
    this.propertyId,
    this.savingId,
    this.bricks,
    this.pricePerBrick,
    this.note,
  });

  bool get isSuccess => status == 'success' || status == 'verified';
  bool get isPending => status == 'pending';
  bool get isFailed => status == 'failed';
  bool get isBrick => type == 'brick_purchase';
  bool get isSaving => type == 'daily_saving' || type == 'monthly_saving';
  bool get isWallet => category == 'Wallet' || type == 'add' || type == 'drx_deposit' || type == 'drx_withdraw' || type == 'withdraw' || type == 'deposit' || type == 'brick_buy' || type == 'brick_yield' || type == 'manual_credit' || type == 'manual_debit';
  bool get isCredit => subtitle.startsWith('+') || type == 'add' || type == 'drx_deposit' || type == 'deposit' || type == 'brick_yield' || type == 'manual_credit';

  String get formattedAmount {
    final n = amount;
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }

  String get formattedDate {
    final d = createdAt;
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${months[d.month - 1]} ${d.year}';
  }

  String get formattedTime {
    final h = createdAt.hour.toString().padLeft(2, '0');
    final m = createdAt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  factory TransactionModel.fromJson(Map<String, dynamic> j) => TransactionModel(
    id: j['id']?.toString() ?? j['_id']?.toString() ?? '',
    type: j['type'] ?? 'brick_purchase',
    category: j['category'] ?? 'Investment',
    title: j['title'] ?? '',
    subtitle: j['subtitle'] ?? '',
    amount: ((j['amount'] ?? 0) as num).toInt(),
    status: j['status'] ?? 'pending',
    razorpayPaymentId: j['razorpayPaymentId'],
    razorpayOrderId: j['razorpayOrderId'],
    coverImage: j['coverImage'],
    city: j['city'],
    propertyId: j['propertyId']?.toString(),
    savingId: j['savingId']?.toString(),
    bricks: (j['bricks'] != null ? (j['bricks'] as num).toInt() : null),
    pricePerBrick: (j['pricePerBrick'] != null ? (j['pricePerBrick'] as num).toInt() : null),
    note: j['note'],
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class TransactionSummary {
  final int totalTransactions, totalInvested, totalSaved, totalSpent;
  const TransactionSummary({
    required this.totalTransactions,
    required this.totalInvested,
    required this.totalSaved,
    required this.totalSpent,
  });
  factory TransactionSummary.fromJson(Map<String, dynamic> j) =>
      TransactionSummary(
        totalTransactions: j['totalTransactions'] ?? 0,
        totalInvested: j['totalInvested'] ?? 0,
        totalSaved: j['totalSaved'] ?? 0,
        totalSpent: j['totalSpent'] ?? 0,
      );
  String fmt(int n) {
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(1)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹${n.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},')}';
  }
}
