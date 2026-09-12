import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/models/kyc_model.dart';
import '../../../data/repositories/kyc_repository.dart';

class KycController extends GetxController {
  final KycRepository _repo = Get.find();
  final _picker = ImagePicker();

  final isLoading = false.obs;
  final isSubmitting = false.obs;
  final errorMsg = ''.obs;

  final existingKyc = Rx<KycModel?>(null);
  final kycStatus =
      'not_submitted'.obs; // not_submitted | pending | approved | rejected

  // Form fields
  final fullNameCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final addressCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final stateCtrl = TextEditingController();
  final pincodeCtrl = TextEditingController();
  final panCtrl = TextEditingController();
  final aadhaarCtrl = TextEditingController();
  final bankNameCtrl = TextEditingController();
  final bankAccountCtrl = TextEditingController();
  final bankIfscCtrl = TextEditingController();
  final bankBankNameCtrl = TextEditingController();

  final panImage = Rx<File?>(null);
  final aadhaarFrontImage = Rx<File?>(null);
  final aadhaarBackImage = Rx<File?>(null);

  final selectedDob = ''.obs;

  @override
  void onInit() {
    super.onInit();
    try {
      final cached = AuthService().currentUser?.kycStatus;
      if (cached != null && cached.isNotEmpty && cached != 'not_submitted') {
        kycStatus.value = cached;
      }
    } catch (_) {}
    loadMyKyc();
  }

  @override
  void onClose() {
    fullNameCtrl.dispose();
    dobCtrl.dispose();
    addressCtrl.dispose();
    cityCtrl.dispose();
    stateCtrl.dispose();
    pincodeCtrl.dispose();
    panCtrl.dispose();
    aadhaarCtrl.dispose();
    bankNameCtrl.dispose();
    bankAccountCtrl.dispose();
    bankIfscCtrl.dispose();
    bankBankNameCtrl.dispose();
    super.onClose();
  }

  Future<void> loadMyKyc() async {
    try {
      isLoading.value = true;
      final kyc = await _repo.getMyKyc();
      existingKyc.value = kyc;
      kycStatus.value = kyc?.status ?? 'not_submitted';

      if (kyc != null) {
        fullNameCtrl.text = kyc.fullName;
        dobCtrl.text = kyc.dob.split('T').first;
        addressCtrl.text = kyc.addressLine1;
        cityCtrl.text = kyc.city;
        stateCtrl.text = kyc.state;
        pincodeCtrl.text = kyc.pincode;
        panCtrl.text = kyc.panNumber;
        bankNameCtrl.text = kyc.bankAccountHolderName ?? '';
        bankAccountCtrl.text = kyc.bankAccountNumber ?? '';
        bankIfscCtrl.text = kyc.bankIfscCode ?? '';
        bankBankNameCtrl.text = kyc.bankName ?? '';
      }
    } on DioException catch (_) {
      // 404 / no kyc yet is fine — stays not_submitted
    } catch (e) {
      errorMsg.value = 'Failed to load KYC status';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(Rx<File?> target) async {
    Get.bottomSheet(
      Container(
        color: Get.isDarkMode ? const Color(0xFF0E1626) : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt_outlined, color: Get.isDarkMode ? Colors.white : Colors.black),
              title: Text('Take Photo', style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black)),
              onTap: () async {
                Get.back();
                final picked = await _picker.pickImage(
                  source: ImageSource.camera,
                  imageQuality: 80,
                );
                if (picked != null) target.value = File(picked.path);
              },
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: Get.isDarkMode ? Colors.white : Colors.black),
              title: Text('Choose from Gallery', style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black)),
              onTap: () async {
                Get.back();
                final picked = await _picker.pickImage(
                  source: ImageSource.gallery,
                  imageQuality: 80,
                );
                if (picked != null) target.value = File(picked.path);
              },
            ),
          ],
        ),
      ),
    );
  }

  // UPDATE setDob
  void setDob(DateTime date) {
    selectedDob.value =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    dobCtrl.text =
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> submit() async {
    if (kycStatus.value == 'pending') {
      Get.snackbar(
        'KYC in Review',
        'Your KYC documents are already under review by our admin team',
        backgroundColor: const Color(0xFFF39C12),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (fullNameCtrl.text.trim().isEmpty ||
        dobCtrl.text.trim().isEmpty ||
        addressCtrl.text.trim().isEmpty ||
        cityCtrl.text.trim().isEmpty ||
        stateCtrl.text.trim().isEmpty ||
        pincodeCtrl.text.trim().isEmpty ||
        panCtrl.text.trim().isEmpty ||
        aadhaarCtrl.text.trim().isEmpty) {
      Get.snackbar('Missing fields', 'Please fill all required fields');
      return;
    }

    final panRegex = RegExp(r'^[A-Z]{5}[0-9]{4}[A-Z]{1}$');
    if (!panRegex.hasMatch(panCtrl.text.trim().toUpperCase())) {
      Get.snackbar('Invalid PAN', 'Format should be like ABCDE1234F');
      return;
    }
    if (!RegExp(r'^\d{12}$').hasMatch(aadhaarCtrl.text.trim())) {
      Get.snackbar('Invalid Aadhaar', 'Must be exactly 12 digits');
      return;
    }
    if (panImage.value == null ||
        aadhaarFrontImage.value == null ||
        aadhaarBackImage.value == null) {
      Get.snackbar(
        'Missing documents',
        'Please upload PAN, Aadhaar front and back images',
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final res = await _repo.submitKyc(
        fullName: fullNameCtrl.text.trim(),
        dob: dobCtrl.text.trim(),
        addressLine1: addressCtrl.text.trim(),
        city: cityCtrl.text.trim(),
        state: stateCtrl.text.trim(),
        pincode: pincodeCtrl.text.trim(),
        panNumber: panCtrl.text.trim().toUpperCase(),
        aadhaarNumber: aadhaarCtrl.text.trim(),
        bankAccountHolderName: bankNameCtrl.text.trim(),
        bankAccountNumber: bankAccountCtrl.text.trim(),
        bankIfscCode: bankIfscCtrl.text.trim().toUpperCase(),
        bankName: bankBankNameCtrl.text.trim(),
        panImagePath: panImage.value!.path,
        aadhaarFrontPath: aadhaarFrontImage.value!.path,
        aadhaarBackPath: aadhaarBackImage.value!.path,
      );

      if (res['success'] == true) {
        kycStatus.value = 'pending';
        Get.snackbar(
          'Submitted ✓',
          'Your KYC is under review',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
        );
      } else {
        Get.snackbar(
          'Failed',
          res['message'] ?? 'Submission failed',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Submission failed',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection error. Please try again.',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isSubmitting.value = false;
    }
  }

  Future<void> submitPhotoOnly() async {
    if (kycStatus.value == 'pending') {
      Get.snackbar(
        'KYC in Review',
        'Your KYC documents are already under review by our admin team',
        backgroundColor: const Color(0xFFF39C12),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    if (panImage.value == null && aadhaarFrontImage.value == null) {
      Get.snackbar(
        'Upload Required',
        'Please upload at least your PAN Card or Aadhaar ID photo',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
      return;
    }

    try {
      isSubmitting.value = true;
      final userName = fullNameCtrl.text.trim().isNotEmpty
          ? fullNameCtrl.text.trim()
          : (AuthService().currentUser?.name ?? '');

      final res = await _repo.submitPhotoOnlyKyc(
        fullName: userName,
        panImagePath: panImage.value?.path ?? (aadhaarFrontImage.value?.path ?? ''),
        aadhaarFrontPath: aadhaarFrontImage.value?.path,
        aadhaarBackPath: aadhaarBackImage.value?.path,
      );

      if (res['success'] == true) {
        kycStatus.value = 'pending';
        Get.snackbar(
          'Photo KYC Submitted ✓',
          'Your documents are uploaded and under review by our admin team',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: const Color(0xFFFFFFFF),
          duration: const Duration(seconds: 4),
        );
      } else {
        Get.snackbar(
          'Failed',
          res['message'] ?? 'Submission failed',
          backgroundColor: const Color(0xFFE53E3E),
          colorText: const Color(0xFFFFFFFF),
        );
      }
    } on DioException catch (e) {
      Get.snackbar(
        'Error',
        e.response?.data?['message'] ?? 'Submission failed',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Connection error. Please try again.',
        backgroundColor: const Color(0xFFE53E3E),
        colorText: const Color(0xFFFFFFFF),
      );
    } finally {
      isSubmitting.value = false;
    }
  }
}
