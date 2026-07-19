import 'package:get/get.dart';
import '../controllers/property_detail_controller.dart';
import '../../../data/repositories/property_repository.dart';
import '../../../data/repositories/investment_repository.dart';

class PropertyDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertyRepository>(() => PropertyRepository());
    Get.lazyPut<InvestmentRepository>(() => InvestmentRepository());
    Get.lazyPut<PropertyDetailController>(() => PropertyDetailController());
  }
}
