import 'package:get/get.dart';
import '../controllers/kyc_controller.dart';
import '../../../data/repositories/kyc_repository.dart';

class KycBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<KycRepository>(() => KycRepository());
    Get.lazyPut<KycController>(() => KycController());
  }
}