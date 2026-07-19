import 'package:get/get.dart';
import '../controllers/investments_controller.dart';
import '../../../data/repositories/investment_repository.dart';

class InvestmentsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvestmentRepository>(() => InvestmentRepository());
    Get.lazyPut<InvestmentsController>(() => InvestmentsController());
  }
}
