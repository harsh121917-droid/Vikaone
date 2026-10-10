import 'package:get/get.dart';
import '../../../data/repositories/business_repository.dart';
import '../controllers/business_controller.dart';

class BusinessBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BusinessRepository>(() => BusinessRepository());
    Get.lazyPut<BusinessController>(() => BusinessController());
  }
}
