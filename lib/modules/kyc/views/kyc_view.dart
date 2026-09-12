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
              const SizedBox(height: 16),
              _QuickPhotoKycCard(controller: controller),
              const SizedBox(height: 14),
              _ManualFormDisclosure(controller: controller),
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

        Obx(() {
          final bool isPending = controller.kycStatus.value == 'pending';
          final bool isDisabled = controller.isSubmitting.value || isPending;

          return SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isDisabled ? null : controller.submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: isPending ? const Color(0xFF1E2A38) : AppColors.accent,
                disabledBackgroundColor: isPending ? const Color(0xFF1E2A38) : AppColors.accent.withValues(alpha: 0.5),
                disabledForegroundColor: isPending ? const Color(0xFFB0BEC5) : Colors.white70,
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
                  : isPending
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.hourglass_top_rounded, size: 18, color: Color(0xFFF39C12)),
                            SizedBox(width: 8),
                            Text(
                              'KYC Under Review — in Progress',
                              style: TextStyle(
                                color: Color(0xFFF39C12),
                                fontWeight: FontWeight.w700,
                                fontSize: 13.5,
                              ),
                            ),
                          ],
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
          );
        }),
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

// ─── Quick Photo KYC Section ──────────────────────────────────────────────────
class _QuickPhotoKycCard extends StatelessWidget {
  const _QuickPhotoKycCard({required this.controller});
  final KycController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0D1E16), Color(0xFF14291F)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFD4A017).withValues(alpha: 0.35),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF042116).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFD4A017).withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFD4A017).withValues(alpha: 0.3),
                      ),
                    ),
                    child: const Icon(
                      Icons.camera_alt_rounded,
                      color: Color(0xFFD4A017),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Quick Photo KYC',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.2,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Upload document photos only',
                        style: TextStyle(
                          color: Color(0xFF9EBAAA),
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3.5),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFD4A017), Color(0xFFF3C343)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '⚡ FASTEST',
                  style: TextStyle(
                    color: Color(0xFF3D2B00),
                    fontSize: 9.5,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            'Simply upload a clear photo of your PAN Card and Aadhaar / Identity proof. Our admin team will verify and activate your account immediately.',
            style: TextStyle(
              color: Color(0xFFD0DCD5),
              fontSize: 12,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 18),

          // Upload 1: PAN Card Photo
          Obx(
            () => _PhotoUploadTile(
              title: '1. PAN Card Photo *',
              subtitle: 'Front side showing name & photo',
              icon: Icons.badge_outlined,
              file: controller.panImage.value,
              onTap: () => controller.pickImage(controller.panImage),
            ),
          ),
          const SizedBox(height: 12),

          // Upload 2: Aadhaar Front Photo
          Obx(
            () => _PhotoUploadTile(
              title: '2. Aadhaar / ID Front Photo *',
              subtitle: 'Front side showing photo & details',
              icon: Icons.fingerprint_rounded,
              file: controller.aadhaarFrontImage.value,
              onTap: () => controller.pickImage(controller.aadhaarFrontImage),
            ),
          ),
          const SizedBox(height: 12),

          // Upload 3: Aadhaar Back Photo (Optional)
          Obx(
            () => _PhotoUploadTile(
              title: '3. Aadhaar Back Photo (Optional)',
              subtitle: 'Back side showing address details',
              icon: Icons.flip_to_back_rounded,
              file: controller.aadhaarBackImage.value,
              onTap: () => controller.pickImage(controller.aadhaarBackImage),
            ),
          ),
          const SizedBox(height: 18),

          // Security reassurance banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              children: const [
                Icon(
                  Icons.shield_outlined,
                  color: Color(0xFFD4A017),
                  size: 16,
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Bank-grade encrypted upload • Reviewed by Payvika admin',
                    style: TextStyle(
                      color: Color(0xFF9EBAAA),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Submit button
          Obx(() {
            final bool isPending = controller.kycStatus.value == 'pending';
            final bool isDisabled = controller.isSubmitting.value || isPending;

            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isDisabled ? null : controller.submitPhotoOnly,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPending ? const Color(0xFF1E2A38) : const Color(0xFFD4A017),
                  foregroundColor: isPending ? const Color(0xFFB0BEC5) : const Color(0xFF231600),
                  disabledBackgroundColor: isPending ? const Color(0xFF1E2A38) : const Color(0xFFD4A017).withValues(alpha: 0.5),
                  disabledForegroundColor: isPending ? const Color(0xFFB0BEC5) : const Color(0xFF231600).withValues(alpha: 0.6),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: controller.isSubmitting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Color(0xFF231600),
                          strokeWidth: 2,
                        ),
                      )
                    : isPending
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.hourglass_top_rounded, size: 18, color: Color(0xFFF39C12)),
                              SizedBox(width: 8),
                              Text(
                                'KYC In Review — in Progress',
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFFF39C12),
                                ),
                              ),
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_rounded, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Submit Photo KYC Now',
                                style: TextStyle(
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _PhotoUploadTile extends StatelessWidget {
  const _PhotoUploadTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.file,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final dynamic file;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final bool hasFile = file != null;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: hasFile
                ? const Color(0xFF2ECC71).withValues(alpha: 0.8)
                : Colors.white.withValues(alpha: 0.15),
            width: hasFile ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            if (hasFile)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.file(
                  file,
                  width: 54,
                  height: 54,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFD4A017).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: const Color(0xFFD4A017), size: 22),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasFile ? '✓ Photo selected (Tap to change)' : subtitle,
                    style: TextStyle(
                      color: hasFile
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFF9EBAAA),
                      fontSize: 11,
                      fontWeight: hasFile ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: hasFile
                    ? const Color(0xFF2ECC71).withValues(alpha: 0.15)
                    : const Color(0xFFD4A017).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: hasFile
                      ? const Color(0xFF2ECC71).withValues(alpha: 0.4)
                      : const Color(0xFFD4A017).withValues(alpha: 0.3),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    hasFile ? Icons.check_circle : Icons.camera_alt_outlined,
                    color: hasFile
                        ? const Color(0xFF2ECC71)
                        : const Color(0xFFD4A017),
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    hasFile ? 'Change' : 'Upload',
                    style: TextStyle(
                      color: hasFile
                          ? const Color(0xFF2ECC71)
                          : const Color(0xFFD4A017),
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ManualFormDisclosure extends StatefulWidget {
  const _ManualFormDisclosure({required this.controller});
  final KycController controller;

  @override
  State<_ManualFormDisclosure> createState() => _ManualFormDisclosureState();
}

class _ManualFormDisclosureState extends State<_ManualFormDisclosure> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.surfaceVariant),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.edit_note_rounded, color: AppColors.accent, size: 22),
            title: const Text(
              'Or enter complete form details manually',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
            subtitle: const Text(
              'Address, full PAN & bank account details',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
            trailing: Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.accent,
            ),
            onTap: () => setState(() => _isExpanded = !_isExpanded),
          ),
          if (_isExpanded)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: _KycForm(controller: widget.controller),
            ),
        ],
      ),
    );
  }
}
