import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../properties/views/properties_view.dart';
import '../../investments/views/investments_view.dart';
import '../views/home_view.dart';
import '../../profile/views/profile_view.dart';
import '../../savings/views/savings_view.dart';
import '../controllers/main_shell_controller.dart';

class MainShellView extends GetView<MainShellController> {
  const MainShellView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: controller.scaffoldKey,
      drawer: const _AppDrawer(),
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: const [
            HomeView(),
            PropertiesView(),
            InvestmentsView(),
            SavingsView(),
            ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Obx(
          () => _GlassNav(
            selected: controller.tabIndex.value,
            onTap: controller.changeTab,
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Items â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _NI {
  final IconData icon;
  final String label;
  const _NI(this.icon, this.label);
}

const _items = [
  _NI(Icons.home_rounded, 'Home'),
  _NI(Icons.apartment_outlined, 'Explore'),
  _NI(Icons.account_balance_wallet_outlined, 'Bricks'),
  _NI(Icons.savings_outlined, 'Savings'),
  _NI(Icons.person_outline_rounded, 'Profile'),
];

// â”€â”€â”€ Glass Nav Bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _GlassNav extends StatelessWidget {
  const _GlassNav({required this.selected, required this.onTap});
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final dark = ThemeController.to.isDark.value;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: 74,
            decoration: BoxDecoration(
              // Glass gradient
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [
                        Colors.white.withOpacity(0.06),
                        Colors.white.withOpacity(0.02),
                        const Color(0xFF0E1626).withOpacity(0.85),
                      ]
                    : [
                        const Color(0xFF1A2340),
                        const Color(0xFF1F2D50),
                        const Color(0xFF1A2340),
                      ],
              ),
              borderRadius: BorderRadius.circular(36),
              // Glass edge â€” top-left bright, bottom-right dark
              border: Border.all(
                color: dark
                    ? Colors.white.withOpacity(0.10)
                    : AppColors.accent.withOpacity(0.25),
                width: 1.2,
              ),
              boxShadow: [
                // Deep lift shadow
                BoxShadow(
                  color: Colors.black.withOpacity(dark ? 0.55 : 0.22),
                  blurRadius: 32,
                  spreadRadius: -4,
                  offset: const Offset(0, 16),
                ),
                // Accent glow
                BoxShadow(
                  color: AppColors.accent.withOpacity(dark ? 0.12 : 0.08),
                  blurRadius: 24,
                  offset: const Offset(0, 10),
                ),
                // Top shine (glass specular)
                BoxShadow(
                  color: Colors.white.withOpacity(dark ? 0.04 : 0.20),
                  blurRadius: 1,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: List.generate(
                _items.length,
                (i) => Expanded(
                  child: _GlassBtn(
                    item: _items[i],
                    active: i == selected,
                    dark: dark,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      onTap(i);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ Individual Glass 3D Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _GlassBtn extends StatefulWidget {
  const _GlassBtn({
    required this.item,
    required this.active,
    required this.dark,
    required this.onTap,
  });
  final _NI item;
  final bool active, dark;
  final VoidCallback onTap;
  @override
  State<_GlassBtn> createState() => _GlassBtnState();
}

class _GlassBtnState extends State<_GlassBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );
  }

  @override
  void didUpdateWidget(covariant _GlassBtn old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      // Spring bounce on activation
      _ctrl.forward(from: 0).then((_) => _ctrl.reverse());
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final active = widget.active;
    final dark = widget.dark;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        height: 74,
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // â”€â”€ 3D Glass Button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                AnimatedContainer(
                  duration: const Duration(milliseconds: 280),
                  curve: Curves.easeOutCubic,
                  width: active ? 50 : 40,
                  height: active ? 50 : 40,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // 3D base shadow layer (appears as extruded bottom)
                      if (active)
                        Positioned(
                          left: 3,
                          top: 5,
                          child: Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.accent.withOpacity(0.45),
                            ),
                          ),
                        ),

                      // Main button face
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 280),
                        curve: Curves.easeOutCubic,
                        width: active ? 50 : 40,
                        height: active ? 50 : 40,
                        decoration: active
                            ? BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    AppColors.accentLight,
                                    AppColors.accent,
                                  ],
                                ),
                                boxShadow: [
                                  // Main glow
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(
                                      dark ? 0.65 : 0.50,
                                    ),
                                    blurRadius: 20,
                                    offset: const Offset(0, 6),
                                  ),
                                  // Tight shadow
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              )
                            : BoxDecoration(
                                shape: BoxShape.circle,
                                // Inactive: subtle glass pill
                                color: Colors.white.withOpacity(
                                  dark ? 0.05 : 0.12,
                                ),
                                border: Border.all(
                                  color: Colors.white.withOpacity(
                                    dark ? 0.08 : 0.20,
                                  ),
                                  width: 1,
                                ),
                              ),
                        child: Stack(
                          children: [
                            // Specular highlight (top-left shine on glass)
                            if (active)
                              Positioned(
                                top: 5,
                                left: 7,
                                width: 18,
                                height: 8,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.35),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            Center(
                              child: Icon(
                                widget.item.icon,
                                color: active
                                    ? Colors.white
                                    : Colors.white.withOpacity(
                                        dark ? 0.38 : 0.50,
                                      ),
                                size: active ? 23 : 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 4),

                // â”€â”€ Label â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 220),
                  style: TextStyle(
                    color: active
                        ? AppColors.accent
                        : Colors.white.withOpacity(dark ? 0.35 : 0.50),
                    fontSize: active ? 9.5 : 9,
                    fontWeight: active ? FontWeight.w800 : FontWeight.w400,
                    letterSpacing: active ? 0.3 : 0,
                  ),
                  child: Text(widget.item.label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// â”€â”€â”€ 3D Drawer â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
class _AppDrawer extends StatelessWidget {
  const _AppDrawer();

  @override
  Widget build(BuildContext context) {
    final shell = Get.find<MainShellController>();
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      return Drawer(
        backgroundColor: Colors.transparent,
        child: ClipRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
            child: Container(
              color: dark
                  ? const Color(0xFF060B16).withOpacity(0.96)
                  : const Color(0xFF0A1228).withOpacity(0.96),
              child: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Logo
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
                      child: Row(
                        children: [
                          Container(
                            width: 52,
                            height: 52,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFB8860B), Color(0xFFFFD700)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFFD700,
                                  ).withOpacity(0.5),
                                  blurRadius: 16,
                                  offset: const Offset(0, 8),
                                ),
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.3),
                                  blurRadius: 4,
                                  offset: const Offset(2, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.home_work_rounded,
                              color: Colors.black,
                              size: 26,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bharat SQFT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              Text(
                                'Real Assets. Real Returns.',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.5),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.accent.withOpacity(0.4),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    Expanded(
                      child: ListView(
                        padding: EdgeInsets.zero,
                        children: [
                          _DrawerTile(
                            icon: Icons.home_rounded,
                            label: 'Home',
                            onTap: () {
                              shell.changeTab(0);
                              Get.back();
                            },
                          ),
                          _DrawerTile(
                            icon: Icons.apartment_outlined,
                            label: 'Properties',
                            onTap: () {
                              shell.changeTab(1);
                              Get.back();
                            },
                          ),
                          _DrawerTile(
                            icon: Icons.grid_view_rounded,
                            label: 'My Bricks',
                            onTap: () {
                              shell.changeTab(2);
                              Get.back();
                            },
                          ),
                          _DrawerTile(
                            icon: Icons.savings_outlined,
                            label: 'Savings',
                            onTap: () {
                              shell.changeTab(3);
                              Get.back();
                            },
                          ),
                          _DrawerTile(
                            icon: Icons.person_outline_rounded,
                            label: 'Profile',
                            onTap: () {
                              shell.changeTab(4);
                              Get.back();
                            },
                          ),
                        ],
                      ),
                    ),

                    Container(
                      height: 1,
                      margin: const EdgeInsets.symmetric(horizontal: 24),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.accent.withOpacity(0.3),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'v0.1.0',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.3),
                              fontSize: 12,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2ecc71).withOpacity(0.15),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFF2ecc71).withOpacity(0.3),
                              ),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(
                                color: Color(0xFF2ecc71),
                                fontSize: 10,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _DrawerTile extends StatefulWidget {
  const _DrawerTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  State<_DrawerTile> createState() => _DrawerTileState();
}

class _DrawerTileState extends State<_DrawerTile> {
  bool _pressed = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() => _pressed = true);
        HapticFeedback.lightImpact();
      },
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        decoration: BoxDecoration(
          color: _pressed
              ? AppColors.accent.withOpacity(0.15)
              : Colors.white.withOpacity(0.04),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _pressed
                ? AppColors.accent.withOpacity(0.4)
                : Colors.transparent,
          ),
          boxShadow: _pressed
              ? [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.accent.withOpacity(_pressed ? 0.3 : 0.15),
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppColors.accent.withOpacity(0.3)),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Icon(widget.icon, color: AppColors.accent, size: 18),
            ),
            const SizedBox(width: 14),
            Text(
              widget.label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
