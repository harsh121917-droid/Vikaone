import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import '../../../data/repositories/admin_wishlist_repository.dart';

class AdminWishlistView extends StatefulWidget {
  const AdminWishlistView({super.key});
  @override
  State<AdminWishlistView> createState() => _AdminWishlistViewState();
}

class _AdminWishlistViewState extends State<AdminWishlistView>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  final _repo = AdminWishlistRepository();

  final _stats = Rx<AdminWishlistStats?>(null);
  final _byProp = <PropertyWishlistEntry>[].obs;
  final _byUser = <UserWishlistEntry>[].obs;
  final _loading = true.obs;
  final _error = ''.obs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      _loading.value = true;
      _error.value = '';
      final results = await Future.wait([
        _repo.getStats(),
        _repo.getByProperty(),
        _repo.getByUser(),
      ]);
      _stats.value = results[0] as AdminWishlistStats;
      _byProp.value = results[1] as List<PropertyWishlistEntry>;
      _byUser.value = results[2] as List<UserWishlistEntry>;
    } catch (e) {
      _error.value = 'Failed to load: $e';
    } finally {
      _loading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? const Color(0xFF060B16) : const Color(0xFFECF0FF);
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final card = dark ? const Color(0xFF0E1626) : Colors.white;

      return Scaffold(
        backgroundColor: bg,
        body: Column(
          children: [
            // ── Header ───────────────────────────────────────────────────────
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
                child: Row(
                  children: [
                    _NavBtn(
                      icon: Icons.arrow_back_rounded,
                      dark: dark,
                      onTap: () => Get.back(),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Wishlist Analytics',
                            style: TextStyle(
                              color: tp,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                          Text(
                            'Admin — who saved what',
                            style: TextStyle(color: ts, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                    _NavBtn(
                      icon: Icons.refresh_rounded,
                      dark: dark,
                      onTap: _load,
                    ),
                  ],
                ),
              ),
            ),

            // ── Stats strip ──────────────────────────────────────────────────
            Obx(
              () => _stats.value == null
                  ? const SizedBox.shrink()
                  : Padding(
                      padding: const EdgeInsets.fromLTRB(22, 0, 22, 16),
                      child: _StatsStrip(stats: _stats.value!, dark: dark),
                    ),
            ),

            // ── Tabs ─────────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22),
              child: Container(
                height: 48,
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: dark
                        ? const Color(0xFF1A2B45)
                        : const Color(0xFFE2E6F0),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                      spreadRadius: -2,
                    ),
                  ],
                ),
                child: TabBar(
                  controller: _tabs,
                  indicator: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.accent, AppColors.accentLight],
                    ),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.accent.withOpacity(0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelColor: Colors.white,
                  unselectedLabelColor: ts,
                  labelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'By Property'),
                    Tab(text: 'By User'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // ── Content ──────────────────────────────────────────────────────
            Expanded(
              child: Obx(() {
                if (_loading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.accent,
                      strokeWidth: 2,
                    ),
                  );
                }
                if (_error.value.isNotEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: AppColors.error,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _error.value,
                          style: TextStyle(color: ts, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        _GoldBtn(label: 'Retry', onTap: _load),
                      ],
                    ),
                  );
                }
                return TabBarView(
                  controller: _tabs,
                  children: [
                    // By Property
                    _byProp.isEmpty
                        ? _EmptyList(label: 'No wishlist data', dark: dark)
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppColors.accent,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(22, 0, 22, 60),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _byProp.length,
                              itemBuilder: (_, i) => _PropertyEntry(
                                entry: _byProp[i],
                                index: i,
                                dark: dark,
                              ),
                            ),
                          ),
                    // By User
                    _byUser.isEmpty
                        ? _EmptyList(label: 'No wishlist data', dark: dark)
                        : RefreshIndicator(
                            onRefresh: _load,
                            color: AppColors.accent,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(22, 0, 22, 60),
                              physics: const BouncingScrollPhysics(),
                              itemCount: _byUser.length,
                              itemBuilder: (_, i) => _UserEntry(
                                entry: _byUser[i],
                                index: i,
                                dark: dark,
                              ),
                            ),
                          ),
                  ],
                );
              }),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Stats Strip ──────────────────────────────────────────────────────────────
class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.stats, required this.dark});
  final AdminWishlistStats stats;
  final bool dark;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
    decoration: BoxDecoration(
      gradient: dark
          ? const LinearGradient(
              colors: [Color(0xFF0E1626), Color(0xFF182238)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            )
          : const LinearGradient(
              colors: [Color(0xFF1C2D50), Color(0xFF253868)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: AppColors.accent.withOpacity(0.2)),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(dark ? 0.45 : 0.18),
          blurRadius: 20,
          offset: const Offset(0, 8),
          spreadRadius: -3,
        ),
        BoxShadow(color: AppColors.accent.withOpacity(0.08), blurRadius: 16),
      ],
    ),
    child: Row(
      children: [
        Expanded(
          child: _SC(
            label: 'Total Saves',
            value: '${stats.totalSaves}',
            icon: Icons.favorite_rounded,
            color: Colors.red,
          ),
        ),
        _Div(),
        Expanded(
          child: _SC(
            label: 'Unique Users',
            value: '${stats.uniqueUsers}',
            icon: Icons.people_outline_rounded,
            color: const Color(0xFF3B82F6),
          ),
        ),
        _Div(),
        Expanded(
          child: _SC(
            label: 'Last 7 Days',
            value: '+${stats.last7days}',
            icon: Icons.trending_up_rounded,
            color: const Color(0xFF2ecc71),
          ),
        ),
      ],
    ),
  );
}

class _SC extends StatelessWidget {
  const _SC({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });
  final String label, value;
  final IconData icon;
  final Color color;
  @override
  Widget build(BuildContext context) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(height: 5),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w900,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label,
        style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 9),
      ),
    ],
  );
}

class _Div extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, height: 32, color: Colors.white.withOpacity(0.12));
}

// ─── Property Entry ───────────────────────────────────────────────────────────
class _PropertyEntry extends StatefulWidget {
  const _PropertyEntry({
    required this.entry,
    required this.index,
    required this.dark,
  });
  final PropertyWishlistEntry entry;
  final int index;
  final bool dark;
  @override
  State<_PropertyEntry> createState() => _PropertyEntryState();
}

class _PropertyEntryState extends State<_PropertyEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _f;
  late final Animation<Offset> _s;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _f = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _s = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

    return FadeTransition(
      opacity: _f,
      child: SlideTransition(
        position: _s,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.35 : 0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
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
          child: Column(
            children: [
              // Main row
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Image or placeholder
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: e.coverImage != null
                              ? Image.network(
                                  e.coverImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => _ph(dark),
                                )
                              : _ph(dark),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.propertyTitle,
                              style: TextStyle(
                                color: tp,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Row(
                              children: [
                                Icon(
                                  Icons.location_on_outlined,
                                  color: ts,
                                  size: 11,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  e.city,
                                  style: TextStyle(color: ts, fontSize: 11),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  e.formattedPrice,
                                  style: const TextStyle(
                                    color: AppColors.accent,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      // Save count badge
                      Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(dark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.red.withOpacity(0.35),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.red.withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.favorite_rounded,
                                  color: Colors.red,
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${e.saveCount}',
                                  style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: ts,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Expanded user list
              if (_expanded) ...[
                Divider(height: 1, color: border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved by ${e.saveCount} user${e.saveCount != 1 ? "s" : ""}',
                        style: TextStyle(
                          color: ts,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      ...e.users.map(
                        (u) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Row(
                            children: [
                              Container(
                                width: 34,
                                height: 34,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    colors: [
                                      AppColors.accent,
                                      AppColors.accentLight,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.accent.withOpacity(0.35),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Center(
                                  child: Text(
                                    u.name.isNotEmpty
                                        ? u.name[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      u.name,
                                      style: TextStyle(
                                        color: tp,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    Text(
                                      u.email,
                                      style: TextStyle(color: ts, fontSize: 11),
                                    ),
                                  ],
                                ),
                              ),
                              if (u.phone != null)
                                Text(
                                  u.phone!,
                                  style: TextStyle(color: ts, fontSize: 11),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _ph(bool dark) => Container(
    color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0F2F8),
    child: Icon(
      Icons.home_outlined,
      color: dark ? const Color(0xFF4A5C7A) : AppColors.inputIcon,
      size: 24,
    ),
  );
}

// ─── User Entry ───────────────────────────────────────────────────────────────
class _UserEntry extends StatefulWidget {
  const _UserEntry({
    required this.entry,
    required this.index,
    required this.dark,
  });
  final UserWishlistEntry entry;
  final int index;
  final bool dark;
  @override
  State<_UserEntry> createState() => _UserEntryState();
}

class _UserEntryState extends State<_UserEntry>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  late final Animation<double> _f;
  late final Animation<Offset> _s;
  bool _expanded = false;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _f = CurvedAnimation(parent: _c, curve: Curves.easeOut);
    _s = Tween(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOutCubic));
    Future.delayed(Duration(milliseconds: 60 * widget.index), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.entry;
    final dark = widget.dark;
    final cardBg = dark ? const Color(0xFF0E1626) : Colors.white;
    final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
    final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
    final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0);

    return FadeTransition(
      opacity: _f,
      child: SlideTransition(
        position: _s,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: border),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(dark ? 0.35 : 0.07),
                blurRadius: 14,
                offset: const Offset(0, 6),
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
          child: Column(
            children: [
              GestureDetector(
                onTap: () => setState(() => _expanded = !_expanded),
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppColors.accent, AppColors.accentLight],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.accent.withOpacity(0.4),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            e.user.name.isNotEmpty
                                ? e.user.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              e.user.name,
                              style: TextStyle(
                                color: tp,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              e.user.email,
                              style: TextStyle(color: ts, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            if (e.user.phone != null)
                              Text(
                                e.user.phone!,
                                style: TextStyle(color: ts, fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          // Save count
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 5,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(
                                0xFF3B82F6,
                              ).withOpacity(dark ? 0.2 : 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(
                                  0xFF3B82F6,
                                ).withOpacity(0.35),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF3B82F6,
                                  ).withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(
                                  Icons.bookmark_rounded,
                                  color: Color(0xFF3B82F6),
                                  size: 12,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${e.saveCount}',
                                  style: const TextStyle(
                                    color: Color(0xFF3B82F6),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Icon(
                            _expanded
                                ? Icons.keyboard_arrow_up_rounded
                                : Icons.keyboard_arrow_down_rounded,
                            color: ts,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (_expanded && e.propertyTitles.isNotEmpty) ...[
                Divider(height: 1, color: border),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Saved properties',
                        style: TextStyle(
                          color: ts,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...e.propertyTitles.map(
                        (title) => Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: Row(
                            children: [
                              Container(
                                width: 6,
                                height: 6,
                                decoration: const BoxDecoration(
                                  color: AppColors.accent,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  title,
                                  style: TextStyle(color: tp, fontSize: 12),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Helpers ──────────────────────────────────────────────────────────────────
class _NavBtn extends StatelessWidget {
  const _NavBtn({required this.icon, required this.dark, required this.onTap});
  final IconData icon;
  final bool dark;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () {
      HapticFeedback.lightImpact();
      onTap();
    },
    child: Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF0E1626) : Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(
          color: dark ? const Color(0xFF1A2B45) : const Color(0xFFE2E6F0),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(dark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        icon,
        color: dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340),
        size: 20,
      ),
    ),
  );
}

class _GoldBtn extends StatelessWidget {
  const _GoldBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _EmptyList extends StatelessWidget {
  const _EmptyList({required this.label, required this.dark});
  final String label;
  final bool dark;
  @override
  Widget build(BuildContext context) => Center(
    child: Text(
      label,
      style: TextStyle(
        color: dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280),
        fontSize: 14,
      ),
    ),
  );
}
