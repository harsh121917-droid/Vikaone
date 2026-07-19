import 'package:get/get.dart';

class MainShellController extends GetxController {
  final tabIndex = 0.obs;

  void changeTab(int i) => tabIndex.value = i;
}