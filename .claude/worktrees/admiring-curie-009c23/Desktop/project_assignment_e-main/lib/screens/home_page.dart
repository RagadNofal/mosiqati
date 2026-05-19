import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/locale_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:project_assignment_e/screens/cart_screen.dart';
import 'package:project_assignment_e/screens/details_screen.dart';
import 'package:project_assignment_e/screens/services_screen.dart';
import 'package:project_assignment_e/screens/settings_screen.dart';
import 'package:project_assignment_e/utils/app_colors.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  final TextEditingController _searchController = TextEditingController();
  String? _activeCategory;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().getProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onNavTap(int index) {
    if (index == _currentIndex) return;
    HapticFeedback.selectionClick();
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final cartProvider = context.watch<CartProvider>();

    final screens = [
      _StoreTab(
        searchController: _searchController,
        activeCategory: _activeCategory,
        onCategorySelected: (cat) => setState(() => _activeCategory = cat),
      ),
      const ServicesScreen(),
      CartScreen(),
      const SettingsScreen(),
    ];

    return Scaffold(
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: screens,
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onNavTap,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.store_rounded),
            label: l.t('home'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.build_rounded),
            label: l.t('services'),
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                const Icon(Icons.shopping_cart_rounded),
                if (cartProvider.itemCount > 0)
                  Positioned(
                    right: -6,
                    top: -6,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${cartProvider.itemCount}',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
              ],
            ),
            label: l.t('cart'),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings_rounded),
            label: l.t('settings'),
          ),
        ],
      ),
    );
  }
}

// ─── Store Tab ────────────────────────────────────────────────────────────────

class _StoreTab extends StatelessWidget {
  final TextEditingController searchController;
  final String? activeCategory;
  final void Function(String?) onCategorySelected;

  const _StoreTab({
    required this.searchController,
    required this.activeCategory,
    required this.onCategorySelected,
  });

  static const _categories = [
    ('guitar', AppColors.catGuitar, Icons.queue_music_rounded),
    ('piano', AppColors.catPiano, Icons.piano_rounded),
    ('drums', AppColors.catDrums, Icons.sensors_rounded),
    ('oud', AppColors.catOud, Icons.music_note_rounded),
    ('studio', AppColors.catStudio, Icons.mic_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final productProvider = context.watch<ProductProvider>();
    final api = productProvider.apidatastatus;

    return CustomScrollView(
      slivers: [
        // ─ App bar
        SliverAppBar(
          pinned: true,
          expandedHeight: 160,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.music_note_rounded,
                                color: AppColors.gold, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Consumer<LocaleProvider>(
                            builder: (_, loc, __) => Text(
                              AppLocalizations(loc.locale).t('appName'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Consumer<ThemeProvider>(
                            builder: (ctx, theme, __) => IconButton(
                              icon: Icon(
                                theme.isDark
                                    ? Icons.light_mode_rounded
                                    : Icons.dark_mode_rounded,
                                color: Colors.white,
                              ),
                              onPressed: theme.toggle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${l.t('hello')}, ${l.t('userName')} 🎵',
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(56),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                controller: searchController,
                onSubmitted: (q) =>
                    context.read<ProductProvider>().searchByModel(q),
                onChanged: (q) {
                  if (q.isEmpty) context.read<ProductProvider>().clearFilter();
                },
                decoration: InputDecoration(
                  hintText: l.t('search'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.clear_rounded),
                    onPressed: () {
                      searchController.clear();
                      context.read<ProductProvider>().clearFilter();
                    },
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ),
          ),
        ),

        // ─ Category chips
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l.t('byCategory'),
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      // "All" chip
                      _CategoryChip(
                        label: l.t('allProducts'),
                        color: AppColors.primary,
                        icon: Icons.grid_view_rounded,
                        isActive: activeCategory == null,
                        onTap: () {
                          onCategorySelected(null);
                          context.read<ProductProvider>().clearFilter();
                        },
                      ),
                      const SizedBox(width: 8),
                      ..._categories.map((c) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: _CategoryChip(
                              label: l.t(c.$1),
                              color: c.$2,
                              icon: c.$3,
                              isActive: activeCategory == c.$1,
                              onTap: () {
                                onCategorySelected(c.$1);
                                context
                                    .read<ProductProvider>()
                                    .filterByCate(c.$1);
                              },
                            ),
                          )),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        // ─ Products header
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Text(
              l.t('mostPopular'),
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w700),
            ),
          ),
        ),

        // ─ Products grid
        if (api == ApiStatus.loading)
          const SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: AppColors.primary),
                  SizedBox(height: 16),
                  Text('Loading instruments...'),
                ],
              ),
            ),
          )
        else if (api == ApiStatus.error)
          SliverFillRemaining(
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline,
                      size: 60, color: Colors.red),
                  const SizedBox(height: 12),
                  Text(l.t('errorLoading')),
                ],
              ),
            ),
          )
        else
          Consumer<ProductProvider>(
            builder: (_, prov, __) {
              final products = prov.productList;
              if (products.isEmpty) {
                return SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.search_off_rounded,
                            size: 60, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(l.t('noProducts')),
                      ],
                    ),
                  ),
                );
              }
              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.78,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final product = products[index];
                      final color = AppColors.cardColors[
                          index % AppColors.cardColors.length];
                      return _ProductCard(
                        product: product,
                        color: color,
                        index: index,
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }
}

// ─── Category Chip ────────────────────────────────────────────────────────────

class _CategoryChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData icon;
  final bool isActive;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.color,
    required this.icon,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: isActive ? color : color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(30),
          boxShadow: isActive
              ? [BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 8, offset: const Offset(0, 3))]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                size: 18,
                color: isActive ? Colors.white : color),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.white : color,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Product Card ─────────────────────────────────────────────────────────────

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final Color color;
  final int index;

  const _ProductCard({
    required this.product,
    required this.color,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final isFav =
        context.watch<ProductProvider>().isFavorite(product.id);

    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(
              result: product,
              backColor: color,
              heroTag: 'product_${product.id}_$index',
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color, color.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.35),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top row: name + favorite
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 4, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      product.model ?? '',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red.shade300 : Colors.white70,
                      size: 20,
                    ),
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context
                          .read<ProductProvider>()
                          .toggleFavorite(product.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFav
                                ? l.t('removeFromFav')
                                : l.t('addedToFav'),
                          ),
                          duration: const Duration(seconds: 1),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // Product image
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Hero(
                  tag: 'product_${product.id}_$index',
                  child: Image.network(
                    product.image ?? '',
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => const Center(
                      child: Icon(Icons.music_note,
                          color: Colors.white54, size: 40),
                    ),
                  ),
                ),
              ),
            ),

            // Price + video badge
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${l.t('currency')} ${product.price?.toStringAsFixed(0) ?? ''}',
                        style: const TextStyle(
                          color: AppColors.goldLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 15,
                        ),
                      ),
                      if ((product.quantity ?? 0) > 0)
                        Text(
                          '${product.quantity} ${l.t('quantity')}',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 11),
                        ),
                    ],
                  ),
                  if (product.videoUrl != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.85),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 2),
                          Text('HD',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
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
