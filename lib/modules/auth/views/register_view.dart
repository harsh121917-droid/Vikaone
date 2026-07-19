import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/dreamspace_logo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class RegisterView extends GetView<AuthController> {
  const RegisterView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey           = GlobalKey<FormState>();
    final nameCtrl          = TextEditingController();
    final emailCtrl         = TextEditingController();
    final phoneCtrl         = TextEditingController();
    final passwordCtrl      = TextEditingController();
    final confirmPassCtrl   = TextEditingController();
    final agreedToTerms     = false.obs;
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Section ──────────────────────────────────────────────
            SizedBox(
              height: size.height * 0.34,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset('assets/images/hero_house.png', fit: BoxFit.cover),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.6, 1.0],
                        colors: [Colors.transparent, Colors.white.withOpacity(0.0), AppColors.background],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DreamSpaceLogo(),
                          const Spacer(),
                          const Text('Create Your\nAccount',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 30, fontWeight: FontWeight.w800, height: 1.2, letterSpacing: -0.5)),
                          const SizedBox(height: 6),
                          const Text('Join us and start your journey\nto find the perfect property.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.5)),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // ── Form Card ─────────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [BoxShadow(color: AppColors.primary.withOpacity(0.06), blurRadius: 32, offset: const Offset(0, 8))],
              ),
              child: Form(
                key: formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Create Account',
                      style: TextStyle(color: AppColors.textPrimary, fontSize: 20, fontWeight: FontWeight.w700, letterSpacing: -0.3)),
                    const SizedBox(height: 4),
                    const Text('Please fill in the details below to get started.',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4)),
                    const SizedBox(height: 20),

                    AuthTextField(hint: 'Full Name', prefixIcon: Icons.person_outline_rounded,
                      controller: nameCtrl, validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                    const SizedBox(height: 12),
                    AuthTextField(hint: 'Email Address', prefixIcon: Icons.mail_outline_rounded,
                      controller: emailCtrl, keyboardType: TextInputType.emailAddress,
                      validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (!v.contains('@')) return 'Invalid email'; return null; }),
                    const SizedBox(height: 12),
                    AuthTextField(hint: 'Phone Number', prefixIcon: Icons.phone_outlined,
                      controller: phoneCtrl, keyboardType: TextInputType.phone,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null),
                    const SizedBox(height: 12),
                    AuthTextField(hint: 'Password', prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true, controller: passwordCtrl,
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null),
                    const SizedBox(height: 12),
                    AuthTextField(hint: 'Confirm Password', prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true, controller: confirmPassCtrl, textInputAction: TextInputAction.done,
                      validator: (v) { if (v == null || v.isEmpty) return 'Required'; if (v != passwordCtrl.text) return 'Passwords do not match'; return null; }),
                    const SizedBox(height: 16),

                    // Terms checkbox
                    Obx(() => GestureDetector(
                      onTap: () => agreedToTerms.value = !agreedToTerms.value,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(width: 20, height: 20,
                            child: Checkbox(
                              value: agreedToTerms.value,
                              onChanged: (v) => agreedToTerms.value = v ?? false,
                              activeColor: AppColors.primary,
                              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                text: 'I agree to the ',
                                style: const TextStyle(color: AppColors.textSecondary, fontSize: 13, height: 1.4),
                                children: [
                                  TextSpan(text: 'Terms & Conditions',
                                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                                    recognizer: TapGestureRecognizer()..onTap = () {}),
                                  const TextSpan(text: ' and '),
                                  TextSpan(text: 'Privacy Policy',
                                    style: const TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600),
                                    recognizer: TapGestureRecognizer()..onTap = () {}),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    )),
                    const SizedBox(height: 16),

                    // Error message
                    Obx(() => controller.errorMsg.value.isNotEmpty
                        ? Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            margin: const EdgeInsets.only(bottom: 12),
                            decoration: BoxDecoration(
                              color: AppColors.error.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: AppColors.error.withOpacity(0.3)),
                            ),
                            child: Text(controller.errorMsg.value,
                              style: const TextStyle(color: AppColors.error, fontSize: 13)),
                          )
                        : const SizedBox.shrink()),

                    // Register button
                    Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (!formKey.currentState!.validate()) return;
                              if (!agreedToTerms.value) {
                                Get.snackbar('Required', 'Please agree to Terms & Conditions',
                                  backgroundColor: AppColors.error, colorText: Colors.white);
                                return;
                              }
                              controller.register(
                                name:     nameCtrl.text.trim(),
                                email:    emailCtrl.text.trim(),
                                password: passwordCtrl.text,
                                phone:    phoneCtrl.text.trim(),
                              );
                            },
                      child: controller.isLoading.value
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Register'),
                    )),
                    const SizedBox(height: 20),

                    // Login link
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.login),
                        child: RichText(
                          text: const TextSpan(
                            text: 'Already have an account?  ',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            children: [
                              TextSpan(text: 'Login', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
