import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/models/investment_model.dart';
import '../../../data/models/grouped_investment.dart';
import '../../../data/repositories/investment_repository.dart';

class InvestmentsController extends GetxController {
  final InvestmentRepository _repo = Get.find();

  final isLoading = false.obs;
  final investments = <InvestmentModel>[].obs; // raw transactions (for totals)
  final groupedHoldings = <GroupedInvestment>[].obs; // merged by property
  final errorMsg = ''.obs;

  int get totalInvested => investments.fold(0, (sum, i) => sum + i.totalAmount);
  int get totalBricks => investments.fold(0, (sum, i) => sum + i.bricks);
  int get propertyCount => groupedHoldings.length;

  @override
  void onInit() {
    super.onInit();
    loadInvestments();
  }

  Future<void> loadInvestments() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final list = await _repo.getMyInvestments();
      investments.value = list;
      groupedHoldings.value = GroupedInvestment.fromList(list);
    } on DioException catch (e) {
      errorMsg.value = e.response?.data?['message'] ?? 'Failed to load';
    } finally {
      isLoading.value = false;
    }
  }
}
