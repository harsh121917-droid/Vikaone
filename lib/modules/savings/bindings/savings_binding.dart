import 'package:get/get.dart';
import '../controllers/savings_controller.dart';
import '../../../data/repositories/saving_repository.dart';

class SavingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => SavingRepository());
    Get.lazyPut(() => SavingsController());
  }
}
