import 'package:real_estate/core/network/api_client.dart';

// ─── Models ───────────────────────────────────────────────────────────────────
class WalletModel {
  final double balance, lockedBalance, availableBalance, pendingCredit;
  final double totalAdded, totalWithdrawn;
  final List<WalletTxnModel> transactions;

  const WalletModel({
    required this.balance,
    required this.lockedBalance,
    required this.availableBalance,
    required this.pendingCredit,
    required this.totalAdded,
    required this.totalWithdrawn,
    required this.transactions,
  });

  factory WalletModel.fromJson(Map<String, dynamic> j) => WalletModel(
    balance: (j['balance'] ?? 0) * 1.0,
    lockedBalance: (j['lockedBalance'] ?? 0) * 1.0,
    availableBalance: (j['availableBalance'] ?? 0) * 1.0,
    pendingCredit: (j['pendingCredit'] ?? 0) * 1.0,
    totalAdded: (j['totalAdded'] ?? 0) * 1.0,
    totalWithdrawn: (j['totalWithdrawn'] ?? 0) * 1.0,
    transactions: (j['transactions'] as List? ?? [])
        .map((e) => WalletTxnModel.fromJson(e))
        .toList(),
  );

  String fmt(double n) {
    if (n >= 100000) return '₹${(n / 100000).toStringAsFixed(1)}L';
    return '₹${n.toStringAsFixed(2)}';
  }

  String get fmtAvailable => fmt(availableBalance);
  String get fmtBalance => fmt(balance);
  String get fmtLocked => fmt(lockedBalance);
}

class WalletTxnModel {
  final String id, type, status, note;
  final double amount, balanceBefore, balanceAfter;
  final DateTime createdAt;
  final String? razorpayPaymentId;

  const WalletTxnModel({
    required this.id,
    required this.type,
    required this.status,
    required this.note,
    required this.amount,
    required this.balanceBefore,
    required this.balanceAfter,
    required this.createdAt,
    this.razorpayPaymentId,
  });

  factory WalletTxnModel.fromJson(Map<String, dynamic> j) => WalletTxnModel(
    id: j['_id']?.toString() ?? '',
    type: j['type'] ?? 'add',
    status: j['status'] ?? 'pending',
    note: j['note'] ?? '',
    amount: (j['amount'] ?? 0) * 1.0,
    balanceBefore: (j['balanceBefore'] ?? 0) * 1.0,
    balanceAfter: (j['balanceAfter'] ?? 0) * 1.0,
    razorpayPaymentId: j['razorpayPaymentId'],
    createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
  );

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

  bool get isCredit => type == 'add' || type == 'drx_deposit' || type == 'brick_yield' || type == 'deposit' || type == 'manual_credit';
  bool get isSuccess => status == 'success';
}

class BankAccountModel {
  final String id, accountHolder, accountNumber, ifsc, bankName, accountType;
  final bool isDefault, isVerified;

  const BankAccountModel({
    required this.id,
    required this.accountHolder,
    required this.accountNumber,
    required this.ifsc,
    required this.bankName,
    required this.accountType,
    required this.isDefault,
    required this.isVerified,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> j) => BankAccountModel(
    id: j['_id']?.toString() ?? '',
    accountHolder: j['accountHolder'] ?? '',
    accountNumber: j['accountNumber'] ?? '',
    ifsc: j['ifsc'] ?? '',
    bankName: j['bankName'] ?? '',
    accountType: j['accountType'] ?? 'savings',
    isDefault: j['isDefault'] ?? false,
    isVerified: j['isVerified'] ?? false,
  );

  String get maskedAcc =>
      '••••${accountNumber.length > 4 ? accountNumber.substring(accountNumber.length - 4) : accountNumber}';
}

// ─── Repository ───────────────────────────────────────────────────────────────
class WalletRepository {
  final _dio = ApiClient.instance;
  static const _w = '/wallet';
  static const _b = '/bank';

  // Wallet
  Future<WalletModel> getWallet() async {
    final res = await _dio.get(_w);
    return WalletModel.fromJson(res.data['data']);
  }

  Future<Map<String, dynamic>> initiateAdd(double amount) async {
    final res = await _dio.post('$_w/add/initiate', data: {'amount': amount});
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<bool> verifyAdd({
    required String orderId,
    required String paymentId,
    required String signature,
    required double amount,
  }) async {
    final res = await _dio.post(
      '$_w/add/verify',
      data: {
        'razorpayOrderId': orderId,
        'razorpayPaymentId': paymentId,
        'razorpaySignature': signature,
        'amount': amount,
      },
    );
    return res.data['success'] == true;
  }

  Future<Map<String, dynamic>> buyGoldFromWallet({
    double? amount,
    double? grams,
  }) async {
    final res = await _dio.post(
      '$_w/buy-gold',
      data: {
        if (amount != null) 'amountInRupees': amount,
        if (grams != null) 'grams': grams,
      },
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> sellGoldToWallet(double grams) async {
    final res = await _dio.post('$_w/sell-gold', data: {'grams': grams});
    return res.data['data'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> initiateWithdraw(
    double amount,
    String bankAccountId,
  ) async {
    final res = await _dio.post(
      '$_w/withdraw/initiate',
      data: {'amount': amount, 'bankAccountId': bankAccountId},
    );
    return res.data['data'] as Map<String, dynamic>;
  }

  // Bank accounts
  Future<List<BankAccountModel>> getBankAccounts() async {
    final res = await _dio.get(_b);
    return (res.data['data'] as List)
        .map((e) => BankAccountModel.fromJson(e))
        .toList();
  }

  Future<BankAccountModel> addBankAccount({
    required String accountHolder,
    required String accountNumber,
    required String ifsc,
    required String bankName,
    required String accountType,
  }) async {
    final res = await _dio.post(
      _b,
      data: {
        'accountHolder': accountHolder,
        'accountNumber': accountNumber,
        'ifsc': ifsc,
        'bankName': bankName,
        'accountType': accountType,
      },
    );
    return BankAccountModel.fromJson(res.data['data']);
  }

  Future<void> setDefaultBank(String id) async =>
      await _dio.put('$_b/$id/default');

  Future<void> deleteBank(String id) async => await _dio.delete('$_b/$id');
}
