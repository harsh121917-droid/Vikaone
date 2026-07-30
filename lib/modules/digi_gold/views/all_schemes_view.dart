import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:real_estate/data/repositories/scheme_repository.dart';
import '../../../core/theme/controllers/theme_controller.dart';
import 'gold_schemes_view.dart' show EnrollSchemeSheet;

const _gold = Color(0xFFD4A017);
const _goldLight = Color(0xFFFFD700);
const _ink = Color(0xFF060B16);
const _inkCard = Color(0xFF0E1626);

class AllSchemesView extends StatefulWidget {
  const AllSchemesView({super.key, this.onEnrolled});
  final VoidCallback? onEnrolled;

  @override
  State<AllSchemesView> createState() => _AllSchemesViewState();
}

class _AllSchemesViewState extends State<AllSchemesView> {
  final _repo = SchemeRepository();
  List<GoldSchemeModel>? _schemes;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final schemes = await _repo.getSchemes();
      setState(() {
        _schemes = schemes;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _error = 'Could not load schemes';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final dark = ThemeController.to.isDark.value;
      final bg = dark ? _ink : const Color(0xFFF5F0E8);
      final cardBg = dark ? _inkCard : Colors.white;
      final tp = dark ? const Color(0xFFEDF0FF) : const Color(0xFF1A2340);
      final ts = dark ? const Color(0xFF8A95B0) : const Color(0xFF6B7280);
      final border = dark ? const Color(0xFF1A2B45) : const Color(0xFFE8DFC8);

      return Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: cardBg,
          elevation: 0,
          leading: GestureDetector(
            onTap: () => Get.back(),
            child: Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: dark ? const Color(0xFF1A2B45) : const Color(0xFFF0EDE4),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.arrow_back_rounded, color: tp, size: 20),
            ),
          ),
          title: Text(
            'All Gold Schemes',
            style: TextStyle(
              color: tp,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator(color: _gold))
            : _error != null
            ? Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_error!, style: TextStyle(color: ts)),
                    const SizedBox(height: 10),
                    TextButton(onPressed: _load, child: const Text('Retry')),
                  ],
                ),
              )
            : (_schemes ?? []).isEmpty
            ? Center(
                child: Text(
                  'No schemes available right now',
                  style: TextStyle(color: ts),
                ),
              )
            : RefreshIndicator(
                onRefresh: _load,
                color: _gold,
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  itemCount: _schemes!.length,
                  itemBuilder: (_, i) => _FullSchemeCard(
                    scheme: _schemes![i],
                    dark: dark,
                    tp: tp,
                    ts: ts,
                    cardBg: cardBg,
                    border: border,
                    onEnrolled: () {
                      _load();
                      widget.onEnrolled?.call();
                    },
                  ),
                ),
              ),
      );
    });
  }
}

class _FullSchemeCard extends StatelessWidget {
  const _FullSchemeCard({
    required this.scheme,
    required this.dark,
    required this.tp,
    required this.ts,
    required this.cardBg,
    required this.border,
    required this.onEnrolled,
  });
  final GoldSchemeModel scheme;
  final bool dark;
  final Color tp, ts, cardBg, border;
  final VoidCallback onEnrolled;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF3D2B00), Color(0xFF6B4A00)],
        ),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _gold.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _gold.withOpacity(0.5)),
                ),
                child: Text(
                  '${scheme.durationMonths}+${scheme.bonusMonths}',
                  style: const TextStyle(
                    color: _gold,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.workspace_premium_rounded,
                color: _gold,
                size: 20,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            scheme.name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (scheme.description.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              scheme.description,
              style: const TextStyle(color: Colors.white60, fontSize: 12),
            ),
          ],
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _Info('Duration', '${scheme.durationMonths} months'),
              ),
              Expanded(
                child: _Info('Bonus', '${scheme.bonusMonths} month free'),
              ),
              Expanded(
                child: _Info(
                  'Min/month',
                  '₹${scheme.minAmount.toStringAsFixed(0)}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          GestureDetector(
            onTap: () => Get.bottomSheet(
              EnrollSchemeSheet(
                scheme: scheme,
                dark: dark,
                onEnrolled: onEnrolled,
              ),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            ),
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [_gold, _goldLight]),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Start This Scheme',
                  style: TextStyle(
                    color: Color(0xFF3D2B00),
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Info extends StatelessWidget {
  const _Info(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(color: Colors.white54, fontSize: 10)),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
        ),
      ),
    ],
  );
}
