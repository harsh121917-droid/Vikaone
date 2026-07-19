import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/core/theme/app_colors.dart';
import 'package:real_estate/data/models/transaction_model.dart';
import 'package:real_estate/data/repositories/transaction_repository.dart';

class TransactionController extends GetxController {
  static TransactionController get to => Get.find();

  final _repo = TransactionRepository();

  final isLoading = false.obs;
  final errorMsg = ''.obs;
  final all = <TransactionModel>[].obs;
  final filtered = <TransactionModel>[].obs;
  final summary = Rxn<TransactionSummary>();
  final activeTab = 0.obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    try {
      isLoading.value = true;
      errorMsg.value = '';
      final r = await _repo.getAll();
      all.value = r.transactions;
      summary.value = r.summary;
      _applyTab();
    } on DioException catch (e) {
      errorMsg.value =
          e.response?.data?['message'] ?? 'Failed to load transactions';
    } finally {
      isLoading.value = false;
    }
  }

  void setTab(int i) {
    activeTab.value = i;
    _applyTab();
  }

  void _applyTab() {
    switch (activeTab.value) {
      case 1:
        filtered.value = all.where((t) => t.isBrick).toList();
        break;
      case 2:
        filtered.value = all.where((t) => t.isSaving).toList();
        break;
      default:
        filtered.value = List.from(all);
    }
  }
}
