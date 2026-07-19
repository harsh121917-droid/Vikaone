import 'package:flutter/material.dart';
import 'package:real_estate/core/theme/app_colors.dart';

// ─── Data Models (move to domain layer later) ────────────────────────────────

class PropertyModel {
  final String title;
  final String location;
  final String price;
  final int beds;
  final int baths;
  final String imageAsset;
  bool isFavorite;

  PropertyModel({
    required this.title,
    required this.location,
    required this.price,
    required this.beds,
    required this.baths,
    required this.imageAsset,
    this.isFavorite = false,
  });
}

class CategoryModel {
  final String label;
  final IconData icon;
  CategoryModel({required this.label, required this.icon});
}

// ─── Mock Data ───────────────────────────────────────────────────────────────

final _categories = [
  CategoryModel(label: 'House', icon: Icons.house_outlined),
  CategoryModel(label: 'Apartment', icon: Icons.apartment_outlined),
  CategoryModel(label: 'Villa', icon: Icons.villa_outlined),
  CategoryModel(label: 'Office', icon: Icons.business_outlined),
  CategoryModel(label: 'Land', icon: Icons.landscape_outlined),
];

final _featured = [
  PropertyModel(
    title: 'Modern Family House',
    location: 'San Francisco, CA',
    price: '\$1,250,000',
    beds: 4,
    baths: 3,
    imageAsset: 'assets/images/hero_house.png',
  ),
  PropertyModel(
    title: 'Luxury Apartment',
    location: 'New York, NY',
    price: '\$850,000',
    beds: 2,
    baths: 2,
    imageAsset: 'assets/images/hero_house.png',
  ),
  PropertyModel(
    title: 'Heritage Villa',
    location: 'Miami, FL',
    price: '\$1,800,000',
    beds: 5,
    baths: 4,
    imageAsset: 'assets/images/hero_house.png',
  ),
];

final _recommended = [
  PropertyModel(
    title: 'Cozy Studio',
    location: 'Austin, TX',
    price: '\$320,000',
    beds: 1,
    baths: 1,
    imageAsset: 'assets/images/hero_house.png',
  ),
  PropertyModel(
    title: 'Penthouse Suite',
    location: 'Chicago, IL',
    price: '\$2,100,000',
    beds: 3,
    baths: 3,
    imageAsset: 'assets/images/hero_house.png',
  ),
  PropertyModel(
    title: 'Garden Townhouse',
    location: 'Seattle, WA',
    price: '\$675,000',
    beds: 3,
    baths: 2,
    imageAsset: 'assets/images/hero_house.png',
  ),
];

// ─── Home Page ───────────────────────────────────────────────────────────────

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedCategory = 0;
  int _selectedTab = 0;
  final _searchController = TextEditingController();

  String _greeting() {
    final h = DateTime.now().hour;
    if (h < 12) return 'Good Morning,';
    if (h < 17) return 'Good Afternoon,';
    return 'Good Evening,';
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _BottomNav(
        selected: _selectedTab,
        onTap: (i) => setState(() => _selectedTab = i),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _HeroHeader(greeting: _greeting()),
            const SizedBox(height: 20),
            _SearchBar(controller: _searchController),
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Browse by Category',
              onSeeAll: () {},
            ),
            const SizedBox(height: 14),
            _CategoryRow(
              categories: _categories,
              selected: _selectedCategory,
              onTap: (i) => setState(() => _selectedCategory = i),
            ),
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Featured Properties',
              onSeeAll: () {},
            ),
            const SizedBox(height: 14),
            _FeaturedList(properties: _featured),
            const SizedBox(height: 28),
            _SectionHeader(
              title: 'Recommended For You',
              onSeeAll: () {},
            ),
            const SizedBox(height: 14),
            _RecommendedList(properties: _recommended),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ─── Hero Header ─────────────────────────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.greeting});
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.40,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Hero image
          Image.asset('assets/images/hero_house.png', fit: BoxFit.cover),
          // Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.6, 1.0],
                colors: [
                  Colors.white.withOpacity(0.85),
                  Colors.white.withOpacity(0.2),
                  AppColors.background,
                ],
              ),
            ),
          ),
          // Top bar + greeting
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // App bar row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Icon(Icons.menu_rounded,
                          color: AppColors.textPrimary, size: 26),
                      Stack(
                        children: [
                          Icon(Icons.notifications_outlined,
                              color: AppColors.textPrimary, size: 26),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const Spacer(),
                  // Greeting
                  Text(
                    greeting,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Find Your Dream Home',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Let's find a perfect space\nfor you to live in.",
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Search Bar ───────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 16),
            const Icon(Icons.search_rounded,
                color: AppColors.inputIcon, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'Search location, city or area',
                  hintStyle: TextStyle(
                    color: AppColors.textHint,
                    fontSize: 14,
                  ),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            // Filter button
            GestureDetector(
              onTap: () {}, // TODO: open filter sheet
              child: Container(
                margin: const EdgeInsets.all(8),
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.accent.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  color: AppColors.accent,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.onSeeAll});
  final String title;
  final VoidCallback onSeeAll;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.2,
            ),
          ),
          GestureDetector(
            onTap: onSeeAll,
            child: const Text(
              'See All',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Category Row ─────────────────────────────────────────────────────────────

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.categories,
    required this.selected,
    required this.onTap,
  });
  final List<CategoryModel> categories;
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 88,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        itemBuilder: (_, i) {
          final active = i == selected;
          return GestureDetector(
            onTap: () => onTap(i),
            child: Container(
              width: 72,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: active
                    ? AppColors.accent.withOpacity(0.10)
                    : AppColors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      active ? AppColors.accent : AppColors.inputBorder,
                  width: 1.2,
                ),
                boxShadow: active
                    ? []
                    : [
                        BoxShadow(
                          color: AppColors.primary.withOpacity(0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    categories[i].icon,
                    color: active ? AppColors.accent : AppColors.inputIcon,
                    size: 26,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    categories[i].label,
                    style: TextStyle(
                      color: active
                          ? AppColors.accent
                          : AppColors.textSecondary,
                      fontSize: 11,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ─── Featured Horizontal List ─────────────────────────────────────────────────

class _FeaturedList extends StatelessWidget {
  const _FeaturedList({required this.properties});
  final List<PropertyModel> properties;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 260,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: properties.length,
        itemBuilder: (_, i) => _FeaturedCard(property: properties[i]),
      ),
    );
  }
}

class _FeaturedCard extends StatefulWidget {
  const _FeaturedCard({required this.property});
  final PropertyModel property;

  @override
  State<_FeaturedCard> createState() => _FeaturedCardState();
}

class _FeaturedCardState extends State<_FeaturedCard> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: navigate to property detail
      child: Container(
        width: 200,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: Image.asset(
                    widget.property.imageAsset,
                    height: 140,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                // Favorite button
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: () => setState(
                        () => widget.property.isFavorite =
                            !widget.property.isFavorite),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: AppColors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        widget.property.isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: widget.property.isFavorite
                            ? Colors.red
                            : AppColors.textSecondary,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.property.title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.location_on_outlined,
                          color: AppColors.inputIcon, size: 12),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text(
                          widget.property.location,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.property.price,
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _PropChip(
                        icon: Icons.bed_outlined,
                        label: '${widget.property.beds} Beds',
                      ),
                      const SizedBox(width: 8),
                      _PropChip(
                        icon: Icons.bathtub_outlined,
                        label: '${widget.property.baths} Baths',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recommended Horizontal List ─────────────────────────────────────────────

class _RecommendedList extends StatelessWidget {
  const _RecommendedList({required this.properties});
  final List<PropertyModel> properties;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        physics: const BouncingScrollPhysics(),
        itemCount: properties.length,
        itemBuilder: (_, i) => _RecommendedCard(property: properties[i]),
      ),
    );
  }
}

class _RecommendedCard extends StatelessWidget {
  const _RecommendedCard({required this.property});
  final PropertyModel property;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {}, // TODO: navigate to property detail
      child: Container(
        width: 260,
        margin: const EdgeInsets.only(right: 14),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.06),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(16),
              ),
              child: Image.asset(
                property.imageAsset,
                width: 100,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            // Info
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      property.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined,
                            color: AppColors.inputIcon, size: 12),
                        const SizedBox(width: 2),
                        Expanded(
                          child: Text(
                            property.location,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      property.price,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    Row(
                      children: [
                        _PropChip(
                          icon: Icons.bed_outlined,
                          label: '${property.beds}',
                        ),
                        const SizedBox(width: 6),
                        _PropChip(
                          icon: Icons.bathtub_outlined,
                          label: '${property.baths}',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Prop Chip ────────────────────────────────────────────────────────────────

class _PropChip extends StatelessWidget {
  const _PropChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.textSecondary, size: 12),
        const SizedBox(width: 3),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// ─── Bottom Navigation ────────────────────────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.selected, required this.onTap});
  final int selected;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    const items = [
      _NavItem(icon: Icons.home_rounded, label: 'Home'),
      _NavItem(icon: Icons.favorite_border_rounded, label: 'Favorites'),
      _NavItem(icon: Icons.person_outline_rounded, label: 'Profile'),
    ];

    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final active = i == selected;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (active)
                    Container(
                      width: 44,
                      height: 44,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(items[i].icon,
                          color: AppColors.white, size: 22),
                    )
                  else
                    Icon(items[i].icon,
                        color: AppColors.textSecondary, size: 24),
                  if (!active) ...[
                    const SizedBox(height: 4),
                    Text(
                      items[i].label,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  const _NavItem({required this.icon, required this.label});
}