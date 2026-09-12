import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../core/services/auth_service.dart';
import '../../../data/repositories/otp_repository.dart';
import '../../../routes/app_routes.dart';

const _gold = Color(0xFFD4A017);
const _danger = Color(0xFFE05A47);

class _T {
  final Color bg, card, primary, ink, inkMuted, cardBorder, subBg, ctaText;
  const _T({
    required this.bg,
    required this.card,
    required this.primary,
    required this.ink,
    required this.inkMuted,
    required this.cardBorder,
    required this.subBg,
    required this.ctaText,
  });
  factory _T.of(bool dark) => dark
      ? const _T(
          bg: Color(0xFF0A0A0C),
          card: Color(0xFF16161B),
          primary: _gold,
          ink: Color(0xFFF5F5F5),
          inkMuted: Color(0xFF8A8A93),
          cardBorder: Color(0x2ED4A017),
          subBg: Color(0xFF1C1C22),
          ctaText: Color(0xFF3D2B00),
        )
      : const _T(
          bg: Color(0xFFF7F4EE),
          card: Colors.white,
          primary: Color(0xFF0B3D2E),
          ink: Color(0xFF1A2B22),
          inkMuted: Color(0xFF6B7A72),
          cardBorder: Colors.transparent,
          subBg: Color(0xFFF3F1EA),
          ctaText: Colors.white,
        );
}

class ForgotPasswordView extends StatefulWidget {
  const ForgotPasswordView({super.key});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

enum _ForgotStep { email, otpReset }

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  final _otpRepo = OtpRepository();
  final _emailCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  final _confirmPwCtrl = TextEditingController();

  _ForgotStep _step = _ForgotStep.email;
  bool _busy = false;
  String? _error;
  int _cooldown = 0;
  Timer? _timer;
  bool _obscurePassword = true;

  String? _resolvedPhone;
  String? _maskedPhone;

  @override
  void dispose() {
    _timer?.cancel();
    _emailCtrl.dispose();
    _otpCtrl.dispose();
    _pwCtrl.dispose();
    _confirmPwCtrl.dispose();
    super.dispose();
  }

  void _startCooldown() {
    _cooldown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (!mounted) return;
      setState(() {
        if (_cooldown > 0) {
          _cooldown--;
        } else {
          _timer?.cancel();
        }
      });
    });
  }

  Future<void> _sendOtp() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty || !GetUtils.isEmail(email)) {
      setState(() => _error = 'Enter a valid email address.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      final authService = Get.find<AuthService>();
      final res = await authService.initiateForgotPassword(email: email);
      if (res['success'] == true) {
        _resolvedPhone = res['phone']?.toString();
        _maskedPhone = res['maskedPhone']?.toString();
        _startCooldown();
        setState(() {
          _step = _ForgotStep.otpReset;
        });
      } else {
        setState(() => _error = res['message'] ?? 'Failed to send OTP.');
      }
    } catch (e) {
      setState(() {
        _error = _formatError(e);
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  Future<void> _resetPassword() async {
    final otpCode = _otpCtrl.text.trim();
    final newPassword = _pwCtrl.text;
    final confirmPassword = _confirmPwCtrl.text;

    if (_resolvedPhone == null || _resolvedPhone!.isEmpty) {
      setState(() => _error = 'Invalid phone verification state. Start over.');
      return;
    }
    if (otpCode.length < 6) {
      setState(() => _error = 'Enter the 6-digit OTP code.');
      return;
    }
    if (newPassword.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (newPassword != confirmPassword) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
    });

    try {
      // Step 1: Verify OTP and get record ID
      final otpRecordId = await _otpRepo.verifyOtp(
        phone: _resolvedPhone!,
        purpose: 'forgot_password',
        code: otpCode,
      );

      // Step 2: Reset password on backend
      final authService = Get.find<AuthService>();
      final ok = await authService.resetPassword(
        phone: _resolvedPhone!,
        otpRecordId: otpRecordId,
        newPassword: newPassword,
        email: _emailCtrl.text.trim(),
      );

      if (ok) {
        Get.snackbar(
          'Success ✓',
          'Password reset successfully! You can now log in.',
          backgroundColor: const Color(0xFF2ECC71),
          colorText: Colors.white,
        );
        Get.offAllNamed(AppRoutes.login);
      } else {
        setState(() => _error = 'Failed to reset password. Please try again.');
      }
    } catch (e) {
      setState(() {
        _error = _formatError(e);
      });
    } finally {
      setState(() {
        _busy = false;
      });
    }
  }

  String _formatError(dynamic e) {
    if (e is DioException) {
      if (e.response != null && e.response!.data != null) {
        final data = e.response!.data;
        if (data is Map && data.containsKey('message')) {
          return data['message'].toString();
        }
      }
      if (e.type == DioExceptionType.connectionTimeout || e.type == DioExceptionType.receiveTimeout) {
        return "Connection timeout. Please check your internet connection.";
      }
      return "Network connection issue. Please try again.";
    }
    return e.toString().replaceAll('Exception:', '').replaceAll('DioException', '').trim();
  }

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final t = _T.of(dark);

    return Scaffold(
      backgroundColor: t.bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: t.ink),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Forgot Password',
          style: TextStyle(
            color: t.ink,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.card,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: t.cardBorder, width: 1.5),
              boxShadow: dark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  _step == _ForgotStep.email ? Icons.lock_reset_rounded : Icons.shield_outlined,
                  size: 64,
                  color: t.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  _step == _ForgotStep.email ? 'Reset Password' : 'Verify Code',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: t.ink,
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _step == _ForgotStep.email
                      ? 'Enter your registered email address below to receive an OTP on your mobile number.'
                      : 'We have sent a 6-digit OTP code to ${_maskedPhone}.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: t.inkMuted,
                    fontSize: 13,
                    height: 1.45,
                  ),
                ),
                const SizedBox(height: 24),

                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    decoration: BoxDecoration(
                      color: _danger.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _danger.withOpacity(0.2)),
                    ),
                    child: Text(
                      _error!,
                      style: const TextStyle(
                        color: _danger,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                if (_step == _ForgotStep.email) ...[
                  TextField(
                    controller: _emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(color: t.ink, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Registered Email Address',
                      hintStyle: TextStyle(color: t.inkMuted),
                      prefixIcon: Icon(Icons.email_outlined, color: t.inkMuted),
                      filled: true,
                      fillColor: t.subBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _busy ? null : _sendOtp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.primary,
                      foregroundColor: t.ctaText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _busy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: t.ctaText, strokeWidth: 2),
                          )
                        : const Text('Send OTP Code', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ] else ...[
                  // Step 2: OTP & Reset
                  Pinput(
                    length: 6,
                    controller: _otpCtrl,
                    keyboardType: TextInputType.number,
                    defaultPinTheme: PinTheme(
                      width: 44,
                      height: 48,
                      textStyle: TextStyle(
                        fontSize: 18,
                        color: t.ink,
                        fontWeight: FontWeight.w700,
                      ),
                      decoration: BoxDecoration(
                        color: t.subBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _pwCtrl,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: t.ink, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'New Password',
                      hintStyle: TextStyle(color: t.inkMuted),
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: t.inkMuted),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                          color: t.inkMuted,
                          size: 20,
                        ),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                      filled: true,
                      fillColor: t.subBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _confirmPwCtrl,
                    obscureText: _obscurePassword,
                    style: TextStyle(color: t.ink, fontWeight: FontWeight.w600),
                    decoration: InputDecoration(
                      hintText: 'Confirm New Password',
                      hintStyle: TextStyle(color: t.inkMuted),
                      prefixIcon: Icon(Icons.lock_outline_rounded, color: t.inkMuted),
                      filled: true,
                      fillColor: t.subBg,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _busy ? null : _resetPassword,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: t.primary,
                      foregroundColor: t.ctaText,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _busy
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: t.ctaText, strokeWidth: 2),
                          )
                        : const Text('Reset Password', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _cooldown > 0 ? 'Resend OTP in ${_cooldown}s' : "Didn't receive code? ",
                        style: TextStyle(color: t.inkMuted, fontSize: 13),
                      ),
                      if (_cooldown == 0)
                        GestureDetector(
                          onTap: _busy ? null : _sendOtp,
                          child: Text(
                            'Resend',
                            style: TextStyle(
                              color: t.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
