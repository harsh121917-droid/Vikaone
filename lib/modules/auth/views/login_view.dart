import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:pinput/pinput.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/repositories/otp_repository.dart';
import '../../../routes/app_routes.dart';
import '../controllers/auth_controller.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/dreamspace_logo.dart';

enum _LoginStep { credentials, otp }

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _formKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();

  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _otpRepo = OtpRepository();
  final _storage = GetStorage();

  _LoginStep _step = _LoginStep.credentials;
  bool _busy = false;
  String? _errorMsg;
  int _cooldownSeconds = 0;
  Timer? _cooldownTimer;

  @override
  void initState() {
    super.initState();
    final lastPhone = _storage.read<String>('last_login_phone');
    if (lastPhone != null && lastPhone.isNotEmpty) {
      _phoneCtrl.text = lastPhone;
    }
  }

  @override
  void dispose() {
    _cooldownTimer?.cancel();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    setState(() => _cooldownSeconds = 30);
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 1) {
        timer.cancel();
        if (mounted) setState(() => _cooldownSeconds = 0);
      } else {
        if (mounted) setState(() => _cooldownSeconds--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final phone = _phoneCtrl.text.trim();

    setState(() {
      _busy = true;
      _errorMsg = null;
    });

    try {
      await _otpRepo.sendOtp(phone: phone, purpose: 'login');
      _storage.write('last_login_phone', phone);
      _startCooldown();
      HapticFeedback.mediumImpact();
      if (mounted) {
        setState(() {
          _step = _LoginStep.otp;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = _extractErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _resendOtp() async {
    if (_cooldownSeconds > 0 || _busy) return;
    _otpCtrl.clear();
    setState(() {
      _busy = true;
      _errorMsg = null;
    });

    try {
      final phone = _phoneCtrl.text.trim();
      await _otpRepo.sendOtp(phone: phone, purpose: 'login');
      _startCooldown();
      Get.snackbar(
        'OTP Resent',
        'A new OTP has been sent to your mobile number.',
        backgroundColor: AppColors.primary,
        colorText: AppColors.white,
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = _extractErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  Future<void> _verifyAndLogin() async {
    final otpCode = _otpCtrl.text.trim();
    if (otpCode.length != 6) {
      setState(() => _errorMsg = 'Please enter a valid 6-digit OTP');
      return;
    }

    final phone = _phoneCtrl.text.trim();

    setState(() {
      _busy = true;
      _errorMsg = null;
    });

    try {
      final otpRecordId = await _otpRepo.verifyOtp(
        phone: phone,
        purpose: 'login',
        code: otpCode,
      );

      final authCtrl = Get.find<AuthController>();
      final ok = await authCtrl.loginWithOtp(
        phone: phone,
        otpRecordId: otpRecordId,
      );

      if (ok) {
        _storage.write('last_login_phone', phone);
      } else if (mounted) {
        setState(() {
          _errorMsg = authCtrl.errorMsg.value.isNotEmpty
              ? authCtrl.errorMsg.value
              : 'Login failed. Please check your mobile number.';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMsg = _extractErrorMessage(e);
        });
      }
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  String _extractErrorMessage(Object e) {
    if (e is DioException) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return 'Connection timeout. Please check your internet connection.';
      }
      return 'Network issue. Please try again.';
    }
    return e
        .toString()
        .replaceAll('Exception:', '')
        .replaceAll('DioException', '')
        .trim();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        physics: const ClampingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            // ── Hero Section ──────────────────────────────────────────────
            SizedBox(
              height: size.height * 0.44,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/hero_house.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.0, 0.55, 1.0],
                        colors: [
                          Colors.transparent,
                          Colors.white.withValues(alpha: 0.0),
                          AppColors.background
                        ],
                      ),
                    ),
                  ),
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 24, vertical: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const DreamSpaceLogo(),
                          const Spacer(),
                          Text(
                            _step == _LoginStep.credentials
                                ? 'Welcome\nBack!'
                                : 'Verify\nOTP',
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 34,
                              fontWeight: FontWeight.w800,
                              height: 1.15,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            width: 40,
                            height: 3,
                            decoration: BoxDecoration(
                              color: AppColors.accent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _step == _LoginStep.credentials
                                ? 'Enter your registered mobile number to login'
                                : 'OTP sent to ${_phoneCtrl.text.trim()}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 16),
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
              padding: const EdgeInsets.fromLTRB(24, 26, 24, 28),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.06),
                    blurRadius: 32,
                    offset: const Offset(0, 8),
                  )
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: _step == _LoginStep.credentials
                    ? _buildCredentialsStep()
                    : _buildOtpStep(),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Step 1: Simple Mobile Number Only Entry ─────────────────────────────
  Widget _buildCredentialsStep() {
    return Form(
      key: _formKey,
      child: Column(
        key: const ValueKey('credentials_step'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Mobile OTP Login',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'We will send a 6-digit verification code to your phone',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),

          // Mobile Number Field
          AuthTextField(
            hint: '10-Digit Mobile Number',
            prefixIcon: Icons.phone_android_rounded,
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.done,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            validator: (v) {
              if (v == null || v.trim().isEmpty) {
                return 'Please enter your registered mobile number';
              }
              final clean = v.trim().replaceAll(RegExp(r'[^0-9]'), '');
              if (clean.length != 10) {
                return 'Please enter a valid 10-digit mobile number';
              }
              return null;
            },
          ),
          const SizedBox(height: 18),

          // Error Message Display
          if (_errorMsg != null && _errorMsg!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Text(
                _errorMsg!,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ],

          // Send OTP Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _busy ? null : _sendOtp,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Get OTP',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 18, color: Colors.white),
                      ],
                    ),
            ),
          ),
          const SizedBox(height: 24),

          // Divider
          Row(
            children: [
              const Expanded(child: Divider(color: AppColors.divider)),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  'or',
                  style: TextStyle(color: AppColors.textHint, fontSize: 13),
                ),
              ),
              const Expanded(child: Divider(color: AppColors.divider)),
            ],
          ),
          const SizedBox(height: 20),

          // Register Link
          Center(
            child: GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.register),
              child: RichText(
                text: const TextSpan(
                  text: "New to Payvika?  ",
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                  children: [
                    TextSpan(
                      text: 'Create Account',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    WidgetSpan(
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.accent,
                        size: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Step 2: 6-Digit OTP Verification Entry ─────────────────────────────
  Widget _buildOtpStep() {
    final defaultPinTheme = PinTheme(
      width: 46,
      height: 52,
      textStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.accent, width: 1.8),
      ),
    );

    final submittedPinTheme = defaultPinTheme.copyWith(
      decoration: defaultPinTheme.decoration!.copyWith(
        border: Border.all(color: AppColors.primary, width: 1.4),
      ),
    );

    return Form(
      key: _otpFormKey,
      child: Column(
        key: const ValueKey('otp_step'),
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                color: AppColors.textPrimary,
                onPressed: () {
                  setState(() {
                    _step = _LoginStep.credentials;
                    _otpCtrl.clear();
                    _errorMsg = null;
                  });
                },
              ),
              const Expanded(
                child: Text(
                  'Enter 6-Digit OTP',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Pinput Widget
          Pinput(
            length: 6,
            controller: _otpCtrl,
            autofocus: true,
            keyboardType: TextInputType.number,
            defaultPinTheme: defaultPinTheme,
            focusedPinTheme: focusedPinTheme,
            submittedPinTheme: submittedPinTheme,
            onCompleted: (_) => _verifyAndLogin(),
            onChanged: (_) {
              if (_errorMsg != null) setState(() => _errorMsg = null);
            },
          ),
          const SizedBox(height: 20),

          // Error Message
          if (_errorMsg != null && _errorMsg!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
              ),
              child: Text(
                _errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error, fontSize: 13),
              ),
            ),
          ],

          // Verify & Login Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: _busy ? null : _verifyAndLogin,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _busy
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Verify & Login',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 18),

          // Resend OTP & Edit Details Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () {
                  setState(() {
                    _step = _LoginStep.credentials;
                    _otpCtrl.clear();
                    _errorMsg = null;
                  });
                },
                child: const Text(
                  'Change Number',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _cooldownSeconds == 0 && !_busy ? _resendOtp : null,
                child: Text(
                  _cooldownSeconds > 0
                      ? 'Resend in ${_cooldownSeconds}s'
                      : 'Resend OTP',
                  style: TextStyle(
                    color: _cooldownSeconds > 0
                        ? AppColors.textHint
                        : AppColors.accent,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
