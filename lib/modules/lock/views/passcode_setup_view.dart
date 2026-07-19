import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/lock_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../routes/app_routes.dart';

// ════════════════════════════════════════════════════════════════════════════
// PASSCODE SETUP — shown once after login/register
// ════════════════════════════════════════════════════════════════════════════
class PasscodeSetupView extends StatefulWidget {
  const PasscodeSetupView({super.key});
  @override
  State<PasscodeSetupView> createState() => _PasscodeSetupViewState();
}

class _PasscodeSetupViewState extends State<PasscodeSetupView>
    with SingleTickerProviderStateMixin {
  int _phase = 0; // 0=enter, 1=confirm
  String _first = '';
  String _input = '';
  bool _error = false;
  late final AnimationController _shake;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -14.0, end: 14.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 14.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shake, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  void _onKey(String k) {
    if (_input.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _input += k;
      _error = false;
    });
    if (_input.length == 4) _onComplete();
  }

  void _onDelete() {
    if (_input.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _onComplete() async {
    await Future.delayed(const Duration(milliseconds: 180));
    if (_phase == 0) {
      setState(() {
        _first = _input;
        _input = '';
        _phase = 1;
      });
    } else {
      if (_input == _first) {
        HapticFeedback.mediumImpact();
        await LockService.to.savePasscode(_input);
        // After PIN saved — offer biometric if device supports it
        await _offerBiometric();
      } else {
        HapticFeedback.vibrate();
        setState(() {
          _error = true;
          _input = '';
        });
        _shake.forward(from: 0);
      }
    }
  }

  // Ask user if they want to enable biometric after setting PIN
  Future<void> _offerBiometric() async {
    final canBio = await LockService.to.canUseBiometric;
    if (!canBio || !mounted) {
      Get.offAllNamed(AppRoutes.home);
      return;
    }
    // Show biometric offer dialog
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _BiometricOfferDialog(),
    );
    if (result == true) {
      await LockService.to.enableBiometric(true);
    }
    if (mounted) Get.offAllNamed(AppRoutes.home);
  }

  void _skip() => Get.offAllNamed(AppRoutes.home);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060B16),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _skip,
                  child: const Text(
                    'Skip',
                    style: TextStyle(color: Color(0xFF8A95B0), fontSize: 13),
                  ),
                ),
              ),

              const Spacer(),
              // Icon
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [AppColors.accent, AppColors.accentLight],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withOpacity(0.4),
                      blurRadius: 22,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.lock_outline_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),

              Text(
                _phase == 0 ? 'Create PIN' : 'Confirm PIN',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _phase == 0
                    ? 'Set a 4-digit PIN to secure your app'
                    : 'Enter the same PIN again',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF8A95B0), fontSize: 14),
              ),
              const SizedBox(height: 40),

              // Dots
              _PinDots(input: _input, error: _error, shake: _shakeAnim),
              if (_error) ...[
                const SizedBox(height: 12),
                const Text(
                  'PINs do not match. Try again.',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const Spacer(),
              _NumPad(onKey: _onKey, onDelete: _onDelete),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// LOCK SCREEN — shown on every app open/resume when PIN is set
// ════════════════════════════════════════════════════════════════════════════
class LockScreenView extends StatefulWidget {
  const LockScreenView({super.key});
  @override
  State<LockScreenView> createState() => _LockScreenViewState();
}

class _LockScreenViewState extends State<LockScreenView>
    with SingleTickerProviderStateMixin {
  String _input = '';
  bool _error = false;
  bool _canBio = false;
  late final AnimationController _shake;
  late final Animation<double> _shakeAnim;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _shakeAnim = TweenSequence([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: -14.0), weight: 1),
      TweenSequenceItem(tween: Tween(begin: -14.0, end: 14.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 14.0, end: -8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: -8.0, end: 8.0), weight: 2),
      TweenSequenceItem(tween: Tween(begin: 8.0, end: 0.0), weight: 1),
    ]).animate(CurvedAnimation(parent: _shake, curve: Curves.easeInOut));

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final can = await LockService.to.canUseBiometric;
      if (mounted) setState(() => _canBio = can);
      if (LockService.to.biometricEnabled && can) {
        await Future.delayed(const Duration(milliseconds: 300));
        _tryBiometric();
      }
    });
  }

  @override
  void dispose() {
    _shake.dispose();
    super.dispose();
  }

  Future<void> _tryBiometric() async {
    if (!_canBio) return;
    LockService.to.setUnlocking(true);
    final ok = await LockService.to.authenticateWithBiometric();
    if (ok && mounted) {
      _unlock();
    } else {
      LockService.to.setUnlocking(false);
    }
  }

  void _unlock() {
    LockService.to.setUnlocking(false);
    if (mounted) Get.offAllNamed(AppRoutes.home);
  }

  void _onKey(String k) {
    if (_input.length >= 4) return;
    HapticFeedback.selectionClick();
    setState(() {
      _input += k;
      _error = false;
    });
    if (_input.length == 4) _onComplete();
  }

  void _onDelete() {
    if (_input.isEmpty) return;
    HapticFeedback.lightImpact();
    setState(() => _input = _input.substring(0, _input.length - 1));
  }

  Future<void> _onComplete() async {
    await Future.delayed(const Duration(milliseconds: 150));
    if (LockService.to.verifyPasscode(_input)) {
      HapticFeedback.mediumImpact();
      _unlock();
    } else {
      HapticFeedback.vibrate();
      setState(() {
        _error = true;
        _input = '';
      });
      _shake.forward(from: 0);
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false, // can't back out of lock screen
      child: Scaffold(
        backgroundColor: const Color(0xFF060B16),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Column(
              children: [
                const Spacer(),

                // Gold lock
                Container(
                  width: 84,
                  height: 84,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFFFD700).withOpacity(0.4),
                        blurRadius: 28,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lock_rounded,
                    color: Colors.black,
                    size: 40,
                  ),
                ),
                const SizedBox(height: 22),

                const Text(
                  'Bharat SQFT',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _canBio && LockService.to.biometricEnabled
                      ? 'Use fingerprint or enter your PIN'
                      : 'Enter your PIN to continue',
                  style: const TextStyle(
                    color: Color(0xFF8A95B0),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 40),

                // Dots
                _PinDots(input: _input, error: _error, shake: _shakeAnim),
                if (_error) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Incorrect PIN. Try again.',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],

                const Spacer(),
                _NumPad(onKey: _onKey, onDelete: _onDelete),
                const SizedBox(height: 20),

                // Biometric button — show if device supports it regardless of setting
                // (if enabled: prominent; if device has it but user hasn't enabled: show enable option)
                if (_canBio)
                  LockService.to.biometricEnabled
                      ? _BioButton(
                          onTap: _tryBiometric,
                          label: 'Use Fingerprint / Face ID',
                        )
                      : _EnableBioButton(
                          onEnable: () async {
                            await LockService.to.enableBiometric(true);
                            setState(() {});
                            _tryBiometric();
                          },
                        ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Biometric offer dialog (shown after PIN setup) ───────────────────────────
class _BiometricOfferDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Center(
    child: Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF0E1626),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.accent.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 40),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.accent.withOpacity(0.15),
                border: Border.all(color: AppColors.accent.withOpacity(0.4)),
              ),
              child: const Icon(
                Icons.fingerprint_rounded,
                color: AppColors.accent,
                size: 34,
              ),
            ),
            const SizedBox(height: 18),
            const Text(
              'Enable Biometric?',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Use fingerprint or Face ID to unlock the app quickly.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF8A95B0),
                fontSize: 13,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, false),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                        ),
                      ),
                      child: const Center(
                        child: Text(
                          'Skip',
                          style: TextStyle(
                            color: Color(0xFF8A95B0),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context, true),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.accent, AppColors.accentLight],
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.accent.withOpacity(0.4),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Center(
                        child: Text(
                          'Enable',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
}

// ─── Biometric button ─────────────────────────────────────────────────────────
class _BioButton extends StatelessWidget {
  const _BioButton({required this.onTap, required this.label});
  final VoidCallback onTap;
  final String label;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.accent.withOpacity(0.2),
            AppColors.accent.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.accent.withOpacity(0.4)),
        boxShadow: [
          BoxShadow(color: AppColors.accent.withOpacity(0.15), blurRadius: 12),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fingerprint_rounded,
            color: AppColors.accent,
            size: 26,
          ),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    ),
  );
}

class _EnableBioButton extends StatelessWidget {
  const _EnableBioButton({required this.onEnable});
  final VoidCallback onEnable;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onEnable,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.12)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.fingerprint_rounded, color: Color(0xFF8A95B0), size: 20),
          SizedBox(width: 8),
          Text(
            'Enable biometric unlock',
            style: TextStyle(color: Color(0xFF8A95B0), fontSize: 13),
          ),
        ],
      ),
    ),
  );
}

// ─── Shared PIN dots ──────────────────────────────────────────────────────────
class _PinDots extends StatelessWidget {
  const _PinDots({
    required this.input,
    required this.error,
    required this.shake,
  });
  final String input;
  final bool error;
  final Animation<double> shake;
  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: shake,
    builder: (_, __) => Transform.translate(
      offset: Offset(shake.value, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (i) {
          final filled = i < input.length;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 12),
            width: filled ? 20 : 16,
            height: filled ? 20 : 16,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: error
                  ? Colors.red
                  : filled
                  ? AppColors.accent
                  : Colors.white.withOpacity(0.15),
              border: Border.all(
                color: error
                    ? Colors.red
                    : filled
                    ? AppColors.accent
                    : Colors.white.withOpacity(0.3),
              ),
              boxShadow: filled && !error
                  ? [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.6),
                        blurRadius: 10,
                      ),
                    ]
                  : null,
            ),
          );
        }),
      ),
    ),
  );
}

// ─── Numpad ───────────────────────────────────────────────────────────────────
class _NumPad extends StatelessWidget {
  const _NumPad({required this.onKey, required this.onDelete});
  final ValueChanged<String> onKey;
  final VoidCallback onDelete;
  @override
  Widget build(BuildContext context) {
    const rows = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', 'del'],
    ];
    return Column(
      children: rows
          .map(
            (row) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: row.map((k) {
                  if (k.isEmpty) return const SizedBox(width: 84, height: 72);
                  final isDel = k == 'del';
                  return GestureDetector(
                    onTap: () => isDel ? onDelete() : onKey(k),
                    child: Container(
                      width: 84,
                      height: 72,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      decoration: BoxDecoration(
                        color: isDel
                            ? Colors.transparent
                            : Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(18),
                        border: isDel
                            ? null
                            : Border.all(color: Colors.white.withOpacity(0.1)),
                        boxShadow: isDel
                            ? null
                            : [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.25),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                      ),
                      child: Center(
                        child: isDel
                            ? const Icon(
                                Icons.backspace_outlined,
                                color: Color(0xFF8A95B0),
                                size: 22,
                              )
                            : Text(
                                k,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          )
          .toList(),
    );
  }
}
