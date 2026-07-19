class SavingModel {
  final String id;
  final String type; // "daily" | "monthly"
  final int targetAmount;
  final int amountPerCycle;
  final int savedAmount;
  final int? estimatedCyclesToGoal;
  final bool isActive;
  final bool firstPaymentDone; // ← new
  final String? razorpayOrderId; // ← new
  final String? razorpayPaymentId; // ← new
  final DateTime? lastCycleDate;
  final List<SavingCycle> cycles;
  final SavingProperty? targetProperty;
  final DateTime createdAt;

  SavingModel({
    required this.id,
    required this.type,
    required this.targetAmount,
    required this.amountPerCycle,
    required this.savedAmount,
    this.estimatedCyclesToGoal,
    required this.isActive,
    required this.firstPaymentDone,
    this.razorpayOrderId,
    this.razorpayPaymentId,
    this.lastCycleDate,
    required this.cycles,
    this.targetProperty,
    required this.createdAt,
  });

  String get formattedSaved {
    if (savedAmount >= 10000000)
      return '₹${(savedAmount / 10000000).toStringAsFixed(2)}Cr';
    if (savedAmount >= 100000)
      return '₹${(savedAmount / 100000).toStringAsFixed(1)}L';
    return '₹${_fmt(savedAmount)}';
  }

  String get formattedTarget {
    if (targetAmount >= 10000000)
      return '₹${(targetAmount / 10000000).toStringAsFixed(2)}Cr';
    if (targetAmount >= 100000)
      return '₹${(targetAmount / 100000).toStringAsFixed(1)}L';
    return '₹${_fmt(targetAmount)}';
  }

  String get formattedPerCycle {
    final label = type == 'daily' ? '/day' : '/month';
    return '₹${_fmt(amountPerCycle)}$label';
  }

  double get progressPercent =>
      targetAmount > 0 ? (savedAmount / targetAmount).clamp(0.0, 1.0) : 0;

  bool get goalReached => savedAmount >= targetAmount;

  String _fmt(int n) => n.toString().replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (m) => '${m[1]},',
  );

  factory SavingModel.fromJson(Map<String, dynamic> j) => SavingModel(
    id: j['_id'] ?? '',
    type: j['type'] ?? 'daily',
    targetAmount: (j['targetAmount'] ?? 0) as int,
    amountPerCycle: (j['amountPerCycle'] ?? 0) as int,
    savedAmount: (j['savedAmount'] ?? 0) as int,
    estimatedCyclesToGoal: j['estimatedCyclesToGoal'] as int?,
    isActive: j['isActive'] ?? true,
    firstPaymentDone: j['firstPaymentDone'] ?? false, // ← new
    razorpayOrderId: j['razorpayOrderId'] as String?, // ← new
    razorpayPaymentId: j['razorpayPaymentId'] as String?, // ← new
    lastCycleDate: j['lastCycleDate'] != null
        ? DateTime.tryParse(j['lastCycleDate'])
        : null,
    cycles: (j['cycles'] as List? ?? [])
        .map((e) => SavingCycle.fromJson(e))
        .toList(),
    targetProperty: j['targetProperty'] != null
        ? SavingProperty.fromJson(j['targetProperty'])
        : null,
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );
}

class SavingCycle {
  final DateTime date;
  final int amount;
  final String note;

  SavingCycle({required this.date, required this.amount, required this.note});

  factory SavingCycle.fromJson(Map<String, dynamic> j) => SavingCycle(
    date: DateTime.tryParse(j['date'] ?? '') ?? DateTime.now(),
    amount: (j['amount'] ?? 0) as int,
    note: j['note'] ?? '',
  );
}

class SavingProperty {
  final String id;
  final String title;
  final int? brickPrice;
  final String? coverImage;

  SavingProperty({
    required this.id,
    required this.title,
    this.brickPrice,
    this.coverImage,
  });

  factory SavingProperty.fromJson(Map<String, dynamic> j) => SavingProperty(
    id: j['_id'] ?? '',
    title: j['title'] ?? '',
    brickPrice: j['brickPrice'] as int?,
    coverImage: (j['images'] as List?)?.isNotEmpty == true
        ? j['images'][0]['url']
        : null,
  );
}

class SavingSummary {
  final int totalSaved;
  final int totalTarget;
  final int activePlans;

  SavingSummary({
    required this.totalSaved,
    required this.totalTarget,
    required this.activePlans,
  });

  factory SavingSummary.fromJson(Map<String, dynamic> j) => SavingSummary(
    totalSaved: (j['totalSaved'] ?? 0) as int,
    totalTarget: (j['totalTarget'] ?? 0) as int,
    activePlans: (j['activePlans'] ?? 0) as int,
  );
}
