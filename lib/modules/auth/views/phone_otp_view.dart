import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:pinput/pinput.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/repositories/otp_repository.dart';
import '../controllers/auth_controller.dart';

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
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

/// Handles both "register" and "login" via phone + OTP, in one screen.
/// For register, [name] must be provided by the caller (collected on the
/// register form before navigating here) since the backend requires it.
class PhoneOtpView extends StatefulWidget {
  const PhoneOtpView({
    super.key,
    required this.purpose,
    this.name,
    this.email,
    this.password,
    this.phoneNumber,
    this.referralCode,
  });
  final String purpose; // "register" | "login"
  final String? name;
  final String? email;
  final String? password;
  final String? phoneNumber;
  final String? referralCode;

  @override
  State<PhoneOtpView> createState() => _PhoneOtpViewState();
}

class _PhoneOtpViewState extends State<PhoneOtpView> {
  final _repo = OtpRepository();
  final _phoneCtrl = TextEditingController();
  final _otpCtrl = TextEditingController();
  final _pinFocus = FocusNode();

  bool _codeSent = false;
  bool _sending = false;
  bool _verifying = false;
  String? _error;
  int _cooldown = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    if (widget.phoneNumber != null && widget.phoneNumber!.isNotEmpty) {
      _phoneCtrl.text = widget.phoneNumber!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _sendOtp();
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _phoneCtrl.dispose();
    _otpCtrl.dispose();
    _pinFocus.dispose();
    super.dispose();
  }

  bool get _isRegister => widget.purpose == 'register';
  String get _phone => _phoneCtrl.text.trim();
  bool get _phoneValid => RegExp(r'^[6-9]\d{9}$').hasMatch(_phone);

  void _startCooldown() {
    _cooldown = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (_cooldown <= 1) {
        t.cancel();
        setState(() => _cooldown = 0);
      } else {
        setState(() => _cooldown--);
      }
    });
  }

  Future<void> _sendOtp() async {
    if (!_phoneValid) {
      setState(() => _error = 'Enter a valid 10-digit mobile number');
      return;
    }
    setState(() {
      _sending = true;
      _error = null;
    });
    try {
      await _repo.sendOtp(phone: _phone, purpose: widget.purpose);
      setState(() => _codeSent = true);
      _startCooldown();
      HapticFeedback.mediumImpact();
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      setState(() => _sending = false);
    }
  }

  Future<void> _verifyAndContinue() async {
    if (_otpCtrl.text.trim().length != 6) return;
    setState(() {
      _verifying = true;
      _error = null;
    });
    try {
      final otpRecordId = await _repo.verifyOtp(
        phone: _phone,
        purpose: widget.purpose,
        code: _otpCtrl.text.trim(),
      );
      final auth = Get.find<AuthController>();
      final ok = _isRegister
          ? (widget.password != null && widget.password!.isNotEmpty
              ? await auth.register(
                  name: widget.name ?? '',
                  email: widget.email ?? '',
                  password: widget.password!,
                  phone: _phone,
                  otpRecordId: otpRecordId,
                  referralCode: widget.referralCode,
                )
              : await auth.registerWithOtp(
                  name: widget.name ?? '',
                  phone: _phone,
                  otpRecordId: otpRecordId,
                  email: widget.email,
                  referralCode: widget.referralCode,
                ))
          : await auth.loginWithOtp(phone: _phone, otpRecordId: otpRecordId);

      if (!ok) {
        setState(
          () => _error = auth.errorMsg.value.isNotEmpty
              ? auth.errorMsg.value
              : 'Something went wrong',
        );
      }
      // On success, AuthController._afterAuth() already navigates away.
    } catch (e) {
      setState(() => _error = _friendlyError(e));
    } finally {
      if (mounted) setState(() => _verifying = false);
    }
  }

  String _friendlyError(Object e) {
    final s = e.toString();
    final match = RegExp(r'"message":"([^"]+)"').firstMatch(s);
    return match?.group(1) ?? 'Something went wrong. Please try again.';
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final t = _T.of(dark);

      return Scaffold(
        backgroundColor: t.bg,
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Get.back(),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: t.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.cardBorder),
                    ),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: t.ink,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(height: 28),
                Text(
                  _isRegister ? 'Verify Your Number' : 'Login with OTP',
                  style: TextStyle(
                    color: t.primary,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _codeSent
                      ? 'Enter the 6-digit code sent to +91 $_phone'
                      : (_isRegister
                            ? 'We\'ll text you a code to verify your number'
                            : 'Enter your registered mobile number to continue'),
                  style: TextStyle(
                    color: t.inkMuted,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                if (!_codeSent) ...[
                  Text(
                    'Mobile Number',
                    style: TextStyle(
                      color: t.inkMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: t.subBg,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: t.cardBorder),
                    ),
                    child: Row(
                      children: [
                        Text(
                          '+91',
                          style: TextStyle(
                            color: t.ink,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Container(
                          width: 1,
                          height: 24,
                          color: t.inkMuted.withOpacity(0.2),
                          margin: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                        Expanded(
                          child: TextField(
                            controller: _phoneCtrl,
                            keyboardType: TextInputType.phone,
                            maxLength: 10,
                            style: TextStyle(
                              color: t.ink,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              counterText: '',
                              isDense: true,
                              contentPadding: EdgeInsets.symmetric(
                                vertical: 16,
                              ),
                            ),
                            onChanged: (_) => setState(() => _error = null),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _error!,
                      style: const TextStyle(color: _danger, fontSize: 12),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: 'Send OTP',
                    loading: _sending,
                    enabled: _phoneValid,
                    onTap: _sendOtp,
                  ),
                ] else ...[
                  Center(
                    child: Pinput(
                      length: 6,
                      controller: _otpCtrl,
                      focusNode: _pinFocus,
                      autofocus: true,
                      keyboardType: TextInputType.number,
                      onCompleted: (_) => _verifyAndContinue(),
                      onChanged: (_) => setState(() => _error = null),
                      defaultPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: TextStyle(
                          color: t.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: BoxDecoration(
                          color: t.subBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: t.cardBorder),
                        ),
                      ),
                      focusedPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: TextStyle(
                          color: t.ink,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: BoxDecoration(
                          color: t.subBg,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _gold, width: 1.6),
                          boxShadow: [
                            BoxShadow(
                              color: _gold.withOpacity(0.25),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                      ),
                      submittedPinTheme: PinTheme(
                        width: 48,
                        height: 56,
                        textStyle: TextStyle(
                          color: t.primary,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                        decoration: BoxDecoration(
                          color: _gold.withOpacity(0.10),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: _gold),
                        ),
                      ),
                    ),
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: 14),
                    Center(
                      child: Text(
                        _error!,
                        style: const TextStyle(color: _danger, fontSize: 12),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  _PrimaryButton(
                    label: 'Verify & Continue',
                    loading: _verifying,
                    enabled: _otpCtrl.text.trim().length == 6,
                    onTap: _verifyAndContinue,
                  ),
                  const SizedBox(height: 18),
                  Center(
                    child: _cooldown > 0
                        ? Text(
                            'Resend code in ${_cooldown}s',
                            style: TextStyle(color: t.inkMuted, fontSize: 12),
                          )
                        : GestureDetector(
                            onTap: () {
                              _otpCtrl.clear();
                              _sendOtp();
                            },
                            child: const Text(
                              'Resend OTP',
                              style: TextStyle(
                                color: _gold,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _codeSent = false;
                          _otpCtrl.clear();
                          _error = null;
                        });
                      },
                      child: Text(
                        'Change number',
                        style: TextStyle(color: t.inkMuted, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
    });
  }
}

class _PrimaryButton extends StatelessWidget {
  const _PrimaryButton({
    required this.label,
    required this.loading,
    required this.enabled,
    required this.onTap,
  });
  final String label;
  final bool loading, enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final active = enabled && !loading;
    return GestureDetector(
      onTap: active ? onTap : null,
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: active
              ? const LinearGradient(colors: [_gold, _goldLight])
              : null,
          color: active ? null : _gold.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          boxShadow: active
              ? [
                  BoxShadow(
                    color: _gold.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ]
              : null,
        ),
        child: Center(
          child: loading
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  label,
                  style: TextStyle(
                    color: active ? const Color(0xFF3D2B00) : Colors.white38,
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                  ),
                ),
        ),
      ),
    );
  }
}
