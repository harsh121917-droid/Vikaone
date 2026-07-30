import 'package:dio/dio.dart';
import 'package:real_estate/core/network/api_client.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class GoldRateModel {
  final double buyRate, sellRate, change24h, changePct;
  final String purity;
  final double gstPct;
  final DateTime updatedAt;
  final String source;
  bool get isStale => source != 'goldapi.io';

  const GoldRateModel({
    required this.buyRate,
    required this.sellRate,
    required this.change24h,
    required this.changePct,
    required this.purity,
    required this.gstPct,
    required this.updatedAt,
    this.source = 'goldapi.io',
  });

  factory GoldRateModel.fromJson(Map<String, dynamic> j) => GoldRateModel(
    buyRate: (j['buyRate'] ?? 7309.0) * 1.0,
    sellRate: (j['sellRate'] ?? 7256.0) * 1.0,
    change24h: (j['change24h'] ?? 0) * 1.0,
    changePct: (j['changePct'] ?? 0) * 1.0,
    purity: j['purity'] ?? '24K',
    gstPct: (j['gstPct'] ?? 3.0) * 1.0,
    updatedAt: DateTime.tryParse(j['updatedAt'] ?? '') ?? DateTime.now(),
    source: j['source'] ?? 'goldapi.io',
  );

  String get formattedBuyRate => '₹${buyRate.toStringAsFixed(2)}/g';
  String get formattedSellRate => '₹${sellRate.toStringAsFixed(2)}/g';
  String get formattedChange =>
      '${changePct >= 0 ? '+' : ''}${changePct.toStringAsFixed(2)}%';
  bool get isPositive => changePct >= 0;
}

class GoldBalanceModel {
  final double totalGrams, availableGrams, lockedGrams;
  final double investedAmt, currentValue, gainLoss, gainLossPct;
  final double avgBuyRate, currentBuyRate, currentSellRate;

  const GoldBalanceModel({
    required this.totalGrams,
    required this.availableGrams,
    required this.lockedGrams,
    required this.investedAmt,
    required this.currentValue,
    required this.gainLoss,
    required this.gainLossPct,
    required this.avgBuyRate,
    required this.currentBuyRate,
    required this.currentSellRate,
  });

  factory GoldBalanceModel.fromJson(Map<String, dynamic> j) => GoldBalanceModel(
    totalGrams: (j['totalGrams'] ?? 0) * 1.0,
    availableGrams: (j['availableGrams'] ?? 0) * 1.0,
    lockedGrams: (j['lockedGrams'] ?? 0) * 1.0,
    investedAmt: (j['investedAmt'] ?? 0) * 1.0,
    currentValue: (j['currentValue'] ?? 0) * 1.0,
    gainLoss: (j['gainLoss'] ?? 0) * 1.0,
    gainLossPct: (j['gainLossPct'] ?? 0) * 1.0,
    avgBuyRate: (j['avgBuyRate'] ?? 0) * 1.0,
    currentBuyRate: (j['currentBuyRate'] ?? 0) * 1.0,
    currentSellRate: (j['currentSellRate'] ?? 0) * 1.0,
  );

  String fmt(double n) {
    if (n >= 10000000) return '₹${(n / 10000000).toStringAsFixed(2)}Cr';
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹${n.toStringAsFixed(2)}';
  }

  String get formattedValue => fmt(currentValue);
  String get formattedInvested => fmt(investedAmt);
  String get formattedGain => '${gainLoss >= 0 ? '+' : ''}${fmt(gainLoss)}';
  String get formattedGainPct =>
      '${gainLossPct >= 0 ? '+' : ''}${gainLossPct.toStringAsFixed(2)}%';
  String get formattedGrams => '${totalGrams.toStringAsFixed(4)}g';
  bool get isProfit => gainLoss >= 0;
}

class GoldBuyInitiateResult {
  final Map<String, dynamic> order;
  final String transactionId;
  final double grams, goldValue, gstAmt, totalAmt, ratePerGram;
  final String key;

  const GoldBuyInitiateResult({
    required this.order,
    required this.transactionId,
    required this.grams,
    required this.goldValue,
    required this.gstAmt,
    required this.totalAmt,
    required this.ratePerGram,
    required this.key,
  });

  factory GoldBuyInitiateResult.fromJson(Map<String, dynamic> j) {
    final b = j['breakdown'] as Map<String, dynamic>;
    return GoldBuyInitiateResult(
      order: j['order'] as Map<String, dynamic>,
      transactionId: j['transaction']['id'] as String,
      grams: (b['grams'] ?? 0) * 1.0,
      goldValue: (b['goldValue'] ?? 0) * 1.0,
      gstAmt: (b['gstAmt'] ?? 0) * 1.0,
      totalAmt: (b['totalAmt'] ?? 0) * 1.0,
      ratePerGram: (b['ratePerGram'] ?? 0) * 1.0,
      key: j['key'] as String,
    );
  }
}

class GoldTxnModel {
  final String id, type, status;
  final String? invoiceNo;
  final double grams, ratePerGram, goldValue, gstAmt, totalAmt;
  final String? razorpayPaymentId, note;
  final DateTime createdAt;

  const GoldTxnModel({
    required this.id,
    required this.type,
    required this.status,
    required this.grams,
    required this.ratePerGram,
    required this.goldValue,
    required this.gstAmt,
    required this.totalAmt,
    required this.createdAt,
    this.invoiceNo,
    this.razorpayPaymentId,
    this.note,
  });

  /// Short display label for UI — falls back to a shortened id if the
  /// backend hasn't backfilled invoiceNo for older records.
  String get displayInvoiceNo =>
      invoiceNo ?? 'TX-${id.length >= 8 ? id.substring(id.length - 8).toUpperCase() : id.toUpperCase()}';

  factory GoldTxnModel.fromJson(Map<String, dynamic> j) => GoldTxnModel(
    id: j['id']?.toString() ?? '',
    invoiceNo: j['invoiceNo'] as String?,
    type: j['type'] ?? 'buy',
    status: j['status'] ?? 'pending',
    grams: (j['grams'] ?? 0) * 1.0,
    ratePerGram: (j['ratePerGram'] ?? 0) * 1.0,
    goldValue: (j['goldValue'] ?? 0) * 1.0,
    gstAmt: (j['gstAmt'] ?? 0) * 1.0,
    totalAmt: (j['totalAmt'] ?? 0) * 1.0,
    razorpayPaymentId: j['razorpayPaymentId'],
    note: j['note'],
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

  bool get isSuccess => status == 'success';
  bool get isBuy => type == 'buy' || type == 'sip_buy';
  String get typeLabel => isBuy
      ? 'Gold Purchased'
      : type == 'sell'
      ? 'Gold Sold'
      : 'SIP Buy';
}

// ─── Repository ───────────────────────────────────────────────────────────────
class GoldRepository {
  final _dio = ApiClient.instance;
  static const _base = '/gold';

  // 1. Rate (no auth)
  Future<GoldRateModel> getRate() async {
    final res = await _dio.get('$_base/rate');
    final data = res.data['data'] as Map<String, dynamic>;
    final gold = (data['gold'] ?? {}) as Map<String, dynamic>;
    return GoldRateModel.fromJson({
      ...gold,
      'updatedAt': data['updatedAt'],
      'source': data['source'],
    });
  }

  // 2. Balance
  Future<GoldBalanceModel> getBalance() async {
    final res = await _dio.get('$_base/balance');
    return GoldBalanceModel.fromJson(res.data['data']);
  }

  // 3a. Initiate buy
  Future<GoldBuyInitiateResult> initiateBuy({
    double? amountInRupees,
    double? grams,
  }) async {
    final res = await _dio.post(
      '$_base/buy/initiate',
      data: {
        if (amountInRupees != null) 'amountInRupees': amountInRupees,
        if (grams != null) 'grams': grams,
      },
    );
    return GoldBuyInitiateResult.fromJson(res.data['data']);
  }

  // 3b. Verify buy
  Future<bool> verifyBuy({
    required String orderId,
    required String paymentId,
    required String signature,
    required String transactionId,
  }) async {
    final res = await _dio.post(
      '$_base/buy/verify',
      data: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
        'transactionId': transactionId,
      },
    );
    return res.data['success'] == true;
  }

  // 4. Sell
  Future<Map<String, dynamic>> sellGold({
    required double grams,
    required String bankAccountId,
  }) async {
    final res = await _dio.post(
      '$_base/sell',
      data: {'grams': grams, 'bankAccountId': bankAccountId},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // 5. Transactions
  Future<List<GoldTxnModel>> getTransactions({
    int page = 1,
    String? type,
  }) async {
    final res = await _dio.get(
      '$_base/transactions',
      queryParameters: {'page': page, if (type != null) 'type': type},
    );
    return (res.data['data'] as List)
        .map((e) => GoldTxnModel.fromJson(e))
        .toList();
  }

  /// Downloads the PDF invoice bytes for a transaction.
  Future<List<int>> getTransactionInvoice(String txnId) async {
    final res = await _dio.get<List<int>>(
      '$_base/transactions/$txnId/invoice',
      options: Options(responseType: ResponseType.bytes),
    );
    return res.data!;
  }
}