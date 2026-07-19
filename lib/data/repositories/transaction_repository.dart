import 'package:real_estate/core/network/api_client.dart';
import 'package:real_estate/data/models/transaction_model.dart';

class TransactionResult {
  final List<TransactionModel> transactions;
  final TransactionSummary summary;
  const TransactionResult({required this.transactions, required this.summary});
}

class TransactionRepository {
  final _dio = ApiClient.instance;
  static const _base = '/transactions';

  Future<TransactionResult> getAll() async {
    final res = await _dio.get(_base);
    return TransactionResult(
      transactions: (res.data['data'] as List)
          .map((e) => TransactionModel.fromJson(e))
          .toList(),
      summary: TransactionSummary.fromJson(res.data['summary'] ?? {}),
    );
  }

  Future<TransactionModel> getById(String id) async {
    final res = await _dio.get('$_base/$id');
    return TransactionModel.fromJson(res.data['data']);
  }
}
