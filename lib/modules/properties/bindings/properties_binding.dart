import 'package:get/get.dart';
import '../controllers/properties_controller.dart';
import '../../../data/repositories/property_repository.dart';

class PropertiesBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PropertyRepository>(() => PropertyRepository());
    Get.lazyPut<PropertiesController>(() => PropertiesController());
  }
}
