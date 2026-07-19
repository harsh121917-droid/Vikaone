import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/dreamspace_logo.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

class LoginView extends GetView<AuthController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final emailCtrl    = TextEditingController();
    final passwordCtrl = TextEditingController();
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
              height: size.height * 0.50,
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
                        stops: const [0.0, 0.55, 1.0],
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
                          const Text('Welcome\nBack!',
                            style: TextStyle(color: AppColors.textPrimary, fontSize: 36, fontWeight: FontWeight.w800, height: 1.15, letterSpacing: -0.5)),
                          const SizedBox(height: 4),
                          Container(width: 40, height: 3,
                            decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(2))),
                          const SizedBox(height: 10),
                          const Text('Login to continue your\njourney with us.',
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14, height: 1.5)),
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
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
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
                    AuthTextField(
                      hint: 'Email or Phone Number',
                      prefixIcon: Icons.person_outline_rounded,
                      controller: emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                    ),
                    const SizedBox(height: 14),
                    AuthTextField(
                      hint: 'Password',
                      prefixIcon: Icons.lock_outline_rounded,
                      isPassword: true,
                      controller: passwordCtrl,
                      textInputAction: TextInputAction.done,
                      validator: (v) => (v == null || v.length < 6) ? 'Min 6 chars' : null,
                    ),
                    const SizedBox(height: 10),

                    // Forgot password
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () {}, // TODO: forgot password
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('Forgot Password?', style: TextStyle(color: AppColors.accent, fontSize: 13, fontWeight: FontWeight.w600)),
                            SizedBox(width: 2),
                            Icon(Icons.chevron_right_rounded, color: AppColors.accent, size: 16),
                          ],
                        ),
                      ),
                    ),
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

                    // Login button
                    Obx(() => ElevatedButton(
                      onPressed: controller.isLoading.value
                          ? null
                          : () {
                              if (!formKey.currentState!.validate()) return;
                              controller.login(emailCtrl.text.trim(), passwordCtrl.text);
                            },
                      child: controller.isLoading.value
                          ? const SizedBox(height: 20, width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Login'),
                    )),
                    const SizedBox(height: 24),

                    // Divider
                    Row(children: [
                      const Expanded(child: Divider(color: AppColors.divider)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text('or', style: TextStyle(color: AppColors.textHint, fontSize: 13)),
                      ),
                      const Expanded(child: Divider(color: AppColors.divider)),
                    ]),
                    const SizedBox(height: 20),

                    // Register link
                    Center(
                      child: GestureDetector(
                        onTap: () => Get.toNamed(AppRoutes.register),
                        child: RichText(
                          text: const TextSpan(
                            text: "Don't have an account?  ",
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                            children: [
                              TextSpan(text: 'Register', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w700)),
                              WidgetSpan(child: Icon(Icons.chevron_right_rounded, color: AppColors.accent, size: 16)),
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
