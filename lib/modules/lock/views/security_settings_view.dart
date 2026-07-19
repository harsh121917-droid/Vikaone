import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/services/lock_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../routes/app_routes.dart';

class SecuritySettingsView extends StatefulWidget {
  const SecuritySettingsView({super.key});
  @override
  State<SecuritySettingsView> createState() => _SecuritySettingsViewState();
}

class _SecuritySettingsViewState extends State<SecuritySettingsView> {
  bool _canBiometric = false;

  @override
  void initState() {
    super.initState();
    LockService.to.canUseBiometric.then(
      (v) => setState(() => _canBiometric = v),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFECF0FF);
      final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);
      final lock = LockService.to;

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: border),
              ),
              child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
            ),
          ),
          title: Text(
            'Security',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            // Status card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: LockService.to.pinActive.value
                    ? LinearGradient(
                        colors: [
                          const Color(0xFF2ecc71).withOpacity(dark ? 0.2 : 0.1),
                          const Color(
                            0xFF27ae60,
                          ).withOpacity(dark ? 0.1 : 0.05),
                        ],
                      )
                    : null,
                color: LockService.to.pinActive.value ? null : cardBg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: LockService.to.pinActive.value
                      ? const Color(0xFF2ecc71).withOpacity(0.35)
                      : border,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: LockService.to.pinActive.value
                          ? const Color(0xFF2ecc71).withOpacity(0.15)
                          : AppColors.accent.withOpacity(0.1),
                      border: Border.all(
                        color: LockService.to.pinActive.value
                            ? const Color(0xFF2ecc71).withOpacity(0.4)
                            : AppColors.accent.withOpacity(0.3),
                      ),
                    ),
                    child: Icon(
                      LockService.to.pinActive.value
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      color: LockService.to.pinActive.value
                          ? const Color(0xFF2ecc71)
                          : AppColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          LockService.to.pinActive.value
                              ? 'PIN Lock Active'
                              : 'No PIN Set',
                          style: TextStyle(
                            color: tp,
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        Text(
                          LockService.to.pinActive.value
                              ? 'Your app is secured with a PIN'
                              : 'Set up a PIN for extra security',
                          style: TextStyle(color: ts, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Options
            _SettingTile(
              icon: Icons.dialpad_rounded,
              label: LockService.to.pinActive.value
                  ? 'Change PIN'
                  : 'Set Up PIN',
              subtitle: LockService.to.pinActive.value
                  ? 'Update your 4-digit PIN'
                  : 'Create a 4-digit PIN',
              color: AppColors.accent,
              dark: dark,
              onTap: () => Get.toNamed(AppRoutes.passcodeSetup),
            ),
            const SizedBox(height: 10),

            if (_canBiometric && LockService.to.pinActive.value) ...[
              _SettingTile(
                icon: Icons.fingerprint_rounded,
                label: 'Biometric Unlock',
                subtitle: lock.biometricEnabled
                    ? 'Fingerprint/Face ID is enabled'
                    : 'Use fingerprint or Face ID',
                color: const Color(0xFF3B82F6),
                dark: dark,
                trailing: Switch(
                  value: lock.biometricEnabled,
                  onChanged: (v) async {
                    HapticFeedback.lightImpact();
                    await LockService.to.enableBiometric(v);
                    setState(() {});
                  },
                  activeColor: AppColors.accent,
                ),
              ),
              const SizedBox(height: 10),
            ],

            if (LockService.to.pinActive.value) ...[
              _SettingTile(
                icon: Icons.no_encryption_outlined,
                label: 'Disable PIN Lock',
                subtitle: 'Remove PIN protection',
                color: Colors.red,
                dark: dark,
                onTap: () => _confirmDisable(context),
              ),
            ],
          ],
        ),
      );
    });
  }

  void _confirmDisable(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    final bg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);

    Get.dialog(
      Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(22),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 40),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red.withOpacity(0.1),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Icon(
                    Icons.no_encryption_outlined,
                    color: Colors.red,
                    size: 26,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  'Disable PIN Lock?',
                  style: TextStyle(
                    color: tp,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Anyone with access to your device\nwill be able to open the app.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: ts, fontSize: 13, height: 1.4),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Get.back(),
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: dark
                                ? const Color(0xFF1A2B45)
                                : const Color(0xFFF0F4FF),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                color: ts,
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
                        onTap: () {
                          Get.back();
                          LockService.to.disableLock();
                          setState(() {});
                          Get.snackbar(
                            'Disabled',
                            'PIN lock removed',
                            backgroundColor: AppColors.accent,
                            colorText: Colors.white,
                          );
                        },
                        child: Container(
                          height: 46,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.red.withOpacity(0.4),
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Disable',
                              style: TextStyle(
                                color: Colors.red,
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
      ),
      barrierDismissible: true,
      barrierColor: Colors.black54,
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.dark,
    this.onTap,
    this.trailing,
  });
  final IconData icon;
  final String label, subtitle;
  final Color color;
  final bool dark;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(dark ? 0.15 : 0.07)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 5),
              spreadRadius: -2,
            ),
            if (!dark)
              BoxShadow(
                color: Colors.white.withOpacity(0.8),
                blurRadius: 3,
                offset: const Offset(-1, -1),
              ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: color.withOpacity(dark ? 0.18 : 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withOpacity(0.25)),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: tp,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(subtitle, style: TextStyle(color: ts, fontSize: 12)),
                ],
              ),
            ),
            trailing ??
                (onTap != null
                    ? Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color.withOpacity(dark ? 0.15 : 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: color,
                          size: 13,
                        ),
                      )
                    : const SizedBox()),
          ],
        ),
      ),
    );
  }
}
