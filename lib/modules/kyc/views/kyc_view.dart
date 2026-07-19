import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/kyc_controller.dart';
import '../../../core/theme/app_colors.dart';

class KycView extends GetView<KycController> {
  const KycView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Complete KYC',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Get.back(),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.accent),
          );
        }

        final status = controller.kycStatus.value;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            if (status != 'not_submitted')
              _StatusBanner(status: status, kyc: controller.existingKyc.value),
            if (status != 'approved') ...[
              const SizedBox(height: 20),
              _KycForm(controller: controller),
            ],
          ],
        );
      }),
    );
  }
}

// ─── Status Banner ────────────────────────────────────────────────────────────
class _StatusBanner extends StatelessWidget {
  const _StatusBanner({required this.status, required this.kyc});
  final String status;
  final dynamic kyc;

  @override
  Widget build(BuildContext context) {
    late Color color;
    late IconData icon;
    late String title;
    late String subtitle;

    if (status == 'pending') {
      color = const Color(0xFFF39C12);
      icon = Icons.hourglass_top_rounded;
      title = 'Verification Pending';
      subtitle = 'Your KYC is under review. This usually takes 24-48 hours.';
    } else if (status == 'approved') {
      color = const Color(0xFF2ECC71);
      icon = Icons.verified_rounded;
      title = 'KYC Verified';
      subtitle = "You're all set to invest in property bricks.";
    } else {
      color = const Color(0xFFE53E3E);
      icon = Icons.cancel_rounded;
      title = 'KYC Rejected';
      subtitle =
          kyc?.rejectionReason ?? 'Please review and resubmit your details.';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Form ─────────────────────────────────────────────────────────────────────
class _KycForm extends StatelessWidget {
  const _KycForm({required this.controller});
  final KycController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(
          icon: Icons.person_outline_rounded,
          label: 'Personal Details',
        ),
        _LabeledField(
          label: 'Full Name *',
          controller: controller.fullNameCtrl,
          hint: 'As per PAN card',
        ),
        const SizedBox(height: 12),
        _DobField(controller: controller),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Address Line *',
          controller: controller.addressCtrl,
          hint: 'House no, street, area',
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: 'City *',
                controller: controller.cityCtrl,
                hint: 'Mumbai',
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LabeledField(
                label: 'State *',
                controller: controller.stateCtrl,
                hint: 'Maharashtra',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Pincode *',
          controller: controller.pincodeCtrl,
          hint: '400050',
          keyboardType: TextInputType.number,
          maxLength: 6,
        ),

        const SizedBox(height: 8),
        const _SectionTitle(
          icon: Icons.badge_outlined,
          label: 'PAN Verification',
        ),
        _LabeledField(
          label: 'PAN Number *',
          controller: controller.panCtrl,
          hint: 'ABCDE1234F',
          textCapitalization: TextCapitalization.characters,
          maxLength: 10,
        ),
        const SizedBox(height: 12),
        Obx(
          () => _UploadBox(
            label: 'Upload PAN Card *',
            file: controller.panImage.value,
            onTap: () => controller.pickImage(controller.panImage),
          ),
        ),

        const SizedBox(height: 8),
        const _SectionTitle(
          icon: Icons.fingerprint_rounded,
          label: 'Aadhaar Verification',
        ),
        _LabeledField(
          label: 'Aadhaar Number *',
          controller: controller.aadhaarCtrl,
          hint: '12 digit number',
          keyboardType: TextInputType.number,
          maxLength: 12,
        ),
        const SizedBox(height: 12),
        Obx(
          () => _UploadBox(
            label: 'Aadhaar Front *',
            file: controller.aadhaarFrontImage.value,
            onTap: () => controller.pickImage(controller.aadhaarFrontImage),
          ),
        ),
        const SizedBox(height: 12),
        Obx(
          () => _UploadBox(
            label: 'Aadhaar Back *',
            file: controller.aadhaarBackImage.value,
            onTap: () => controller.pickImage(controller.aadhaarBackImage),
          ),
        ),

        const SizedBox(height: 8),
        const _SectionTitle(
          icon: Icons.account_balance_outlined,
          label: 'Bank Details (for payouts)',
        ),
        _LabeledField(
          label: 'Account Holder Name',
          controller: controller.bankNameCtrl,
          hint: 'As per bank passbook',
        ),
        const SizedBox(height: 12),
        _LabeledField(
          label: 'Account Number',
          controller: controller.bankAccountCtrl,
          hint: '1234567890',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _LabeledField(
                label: 'IFSC Code',
                controller: controller.bankIfscCtrl,
                hint: 'SBIN0001234',
                textCapitalization: TextCapitalization.characters,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _LabeledField(
                label: 'Bank Name',
                controller: controller.bankBankNameCtrl,
                hint: 'SBI',
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.shield_outlined,
                color: AppColors.accent,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Your documents are encrypted and used only for identity verification.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        Obx(
          () => SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.isSubmitting.value
                  ? null
                  : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                minimumSize: const Size(double.infinity, 54),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: controller.isSubmitting.value
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Submit for Verification',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 16),
          const SizedBox(width: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              color: AppColors.accent,
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _LabeledField extends StatelessWidget {
  const _LabeledField({
    required this.label,
    required this.controller,
    this.hint = '',
    this.keyboardType,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
  });
  final String label, hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          maxLength: maxLength,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            hintText: hint,
            counterText: '',
            filled: true,
            fillColor: AppColors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide(color: AppColors.inputBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: AppColors.accent),
            ),
          ),
        ),
      ],
    );
  }
}

class _DobField extends StatelessWidget {
  const _DobField({required this.controller});
  final KycController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth *',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        GestureDetector(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime(2000, 1, 1),
              firstDate: DateTime(1940),
              lastDate: DateTime.now(),
            );
            if (picked != null) controller.setDob(picked);
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.inputBorder),
            ),
            child: Obx(
              () => Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.inputIcon,
                    size: 16,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    controller.selectedDob.value.isEmpty
                        ? 'Select date of birth'
                        : controller.selectedDob.value,
                    style: TextStyle(
                      color: controller.selectedDob.value.isEmpty
                          ? AppColors.textHint
                          : AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _UploadBox extends StatelessWidget {
  const _UploadBox({
    required this.label,
    required this.file,
    required this.onTap,
  });
  final String label;
  final dynamic file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasFile = file != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: hasFile ? 140 : 100,
        width: double.infinity,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasFile ? const Color(0xFF2ECC71) : AppColors.inputBorder,
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: hasFile
            ? ClipRRect(
                borderRadius: BorderRadius.circular(11),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.file(file, fit: BoxFit.cover),
                    Positioned(
                      top: 6,
                      right: 6,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF2ECC71),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.cloud_upload_outlined,
                    color: AppColors.inputIcon,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
