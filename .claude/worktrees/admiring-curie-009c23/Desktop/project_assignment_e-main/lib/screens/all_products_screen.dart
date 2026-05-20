import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:project_assignment_e/screens/details_screen.dart';
import 'package:provider/provider.dart';

class _C {
  static const raspberry = Color(0xFF912F56);
  static const plum      = Color(0xFF521945);
  static const wine      = Color(0xFF361F27);
  static const gold      = Color(0xFFD4A853);
  static const sage      = Color(0xFF3D7A6A);
  static const bgDark    = Color(0xFF0D090A);
  static const surfaceD  = Color(0xFF1C0F16);
  static const cardD     = Color(0xFF28141E);
  static const bgLight   = Color(0xFFFAF0EE);
}

const _kCategories = [
  {'key': '',       'label': 'All',    'emoji': '🎵'},
  {'key': 'oud',    'label': 'Oud',    'emoji': '🪕'},
  {'key': 'guitar', 'label': 'Guitar', 'emoji': '🎸'},
  {'key': 'piano',  'label': 'Piano',  'emoji': '🎹'},
  {'key': 'drums',  'label': 'Drums',  'emoji': '🥁'},
  {'key': 'studio', 'label': 'Studio', 'emoji': '🎧'},
];

class AllProductsScreen extends StatefulWidget {
  final String initialCategory;

  const AllProductsScreen({super.key, this.initialCategory = ''});

  @override
  State<AllProductsScreen> createState() => _AllProductsScreenState();
}

class _AllProductsScreenState extends State<AllProductsScreen> {
  String _selectedCat = '';
  final _searchCtrl = TextEditingController();
  String _searchQuery = '';
  final Set<String> _addingToCart = {};

  @override
  void initState() {
    super.initState();
    _selectedCat = widget.initialCategory;
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _addToCart(dynamic product) async {
    HapticFeedback.mediumImpact();
    setState(() => _addingToCart.add(product.id.toString()));
    context.read<CartProvider>().itemAddToCart(product);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _addingToCart.remove(product.id.toString()));
  }

  List _filteredProducts(List products) {
    return products.where((p) {
      final matchesCat = _selectedCat.isEmpty ||
          (p.category?.toString().toLowerCase() == _selectedCat);
      final q = _searchQuery.toLowerCase();
      final matchesSearch = q.isEmpty ||
          (p.model?.toString().toLowerCase().contains(q) ?? false) ||
          (p.brand?.toString().toLowerCase().contains(q) ?? false) ||
          (p.name?.toString().toLowerCase().contains(q) ?? false);
      return matchesCat && matchesSearch;
    }).toList();
  }

  PageRouteBuilder _slide(Widget page) => PageRouteBuilder(
    pageBuilder: (_, a, __) => page,
    transitionsBuilder: (_, a, __, child) => SlideTransition(
      position: Tween<Offset>(
          begin: const Offset(1, 0), end: Offset.zero)
          .animate(CurvedAnimation(parent: a, curve: Curves.easeOutCubic)),
      child: child,
    ),
    transitionDuration: const Duration(milliseconds: 350),
  );

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context);
    final isDark  = context.watch<ThemeProvider>().isDark;
    final prov    = context.watch<ProductProvider>();

    final bg      = isDark ? _C.bgDark  : _C.bgLight;
    final surface = isDark ? _C.surfaceD : Colors.white;
    final card    = isDark ? _C.cardD   : const Color(0xFFF0E5EB);
    final text    = isDark ? Colors.white : _C.wine;
    final subText = isDark ? Colors.white60 : Colors.grey.shade600;

    final products = _filteredProducts(prov.productList);

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 130,
            backgroundColor: _C.plum,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              title: Text(
                l.t('allProducts'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_C.wine, _C.plum, _C.raspberry],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Icon(Icons.store_rounded,
                        color: Colors.white24, size: 80),
                  ),
                ),
              ),
            ),
          ),

          // ── Search bar ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Container(
                height: 50,
                decoration: BoxDecoration(
                  color: surface,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: _C.raspberry.withValues(alpha: 0.2)),
                ),
                child: TextField(
                  controller: _searchCtrl,
                  onChanged: (v) => setState(() => _searchQuery = v),
                  style: TextStyle(color: text, fontSize: 14),
                  decoration: InputDecoration(
                    hintText: l.t('search'),
                    hintStyle: TextStyle(color: text.withValues(alpha: 0.4), fontSize: 14),
                    prefixIcon: const Icon(Icons.search_rounded,
                        color: _C.raspberry, size: 20),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.close_rounded,
                                color: _C.raspberry, size: 18),
                            onPressed: () {
                              _searchCtrl.clear();
                              setState(() => _searchQuery = '');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.only(top: 14),
                  ),
                ),
              ),
            ),
          ),

          // ── Category chips ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 54,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                itemCount: _kCategories.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final cat    = _kCategories[i];
                  final key    = cat['key']!;
                  final active = _selectedCat == key;
                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _selectedCat = key);
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: active ? _C.raspberry : surface,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active
                              ? _C.raspberry
                              : _C.raspberry.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(cat['emoji']!,
                            style: const TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Text(
                          cat['key']!.isEmpty ? l.t('allProducts') : l.t(cat['key']!),
                          style: TextStyle(
                            color: active ? Colors.white : text,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ]),
                    ),
                  );
                },
              ),
            ),
          ),

          // ── Product count ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Text(
                '${products.length} ${l.t('allProducts').toLowerCase()}',
                style: TextStyle(color: subText, fontSize: 13),
              ),
            ),
          ),

          // ── Grid ────────────────────────────────────────────────────────
          products.isEmpty
              ? SliverFillRemaining(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search_off_rounded,
                            color: _C.raspberry.withValues(alpha: 0.4),
                            size: 56),
                        const SizedBox(height: 16),
                        Text(l.t('noProducts'),
                            style: TextStyle(
                                color: text,
                                fontSize: 18,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                )
              : SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 220,
                      childAspectRatio: 0.65,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 12,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final product  = products[i];
                        final isFav    = prov.isFavorite(product.id);
                        final rating   = prov.getRating(product.id);
                        final isAdding = _addingToCart.contains(
                            product.id.toString());

                        return TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0.0, end: 1.0),
                          duration: Duration(milliseconds: 300 + i * 50),
                          curve: Curves.easeOut,
                          builder: (_, val, child) => Opacity(
                            opacity: val.clamp(0.0, 1.0),
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - val)),
                              child: child,
                            ),
                          ),
                          child: _GridProductCard(
                            product:  product,
                            surface:  surface,
                            card:     card,
                            text:     text,
                            subText:  subText,
                            isFav:    isFav,
                            rating:   rating,
                            isAdding: isAdding,
                            isDark:   isDark,
                            onTap: () {
                              HapticFeedback.lightImpact();
                              Navigator.push(ctx, _slide(ProductDetailScreen(
                                result: product,
                                heroTag: 'all_${product.id}_$i',
                                backColor: _C.raspberry,
                              )));
                            },
                            onFav: () {
                              HapticFeedback.lightImpact();
                              prov.toggleFavorite(product.id);
                            },
                            onAddToCart: () => _addToCart(product),
                          ),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

// ── Grid Product Card ─────────────────────────────────────────────────────────
class _GridProductCard extends StatelessWidget {
  final dynamic product;
  final Color surface, card, text, subText;
  final bool isFav, isAdding, isDark;
  final double rating;
  final VoidCallback onTap, onFav, onAddToCart;

  const _GridProductCard({
    required this.product,
    required this.surface,
    required this.card,
    required this.text,
    required this.subText,
    required this.isFav,
    required this.rating,
    required this.isAdding,
    required this.isDark,
    required this.onTap,
    required this.onFav,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _C.raspberry.withValues(alpha: 0.12)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Image
          Expanded(
            child: Stack(children: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: card,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    product.image?.toString() ?? '',
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Icon(Icons.music_note_rounded,
                          color: _C.raspberry.withValues(alpha: 0.3), size: 32),
                    ),
                  ),
                ),
              ),

              // Favorite
              Positioned(
                right: 12, top: 12,
                child: GestureDetector(
                  onTap: onFav,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: isFav
                          ? _C.raspberry.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.08),
                            blurRadius: 4),
                      ],
                    ),
                    child: AnimatedScale(
                      scale: isFav ? 1.2 : 1.0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                        color: isFav ? _C.raspberry : Colors.grey.shade400,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ),

              // Rating
              if (rating > 0)
                Positioned(
                  left: 12, bottom: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      const Icon(Icons.star_rounded,
                          color: _C.gold, size: 12),
                      const SizedBox(width: 2),
                      Text('${rating.toInt()}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold)),
                    ]),
                  ),
                ),
            ]),
          ),

          // Info
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 6, 10, 10),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
              Text(product.displayModel(Localizations.localeOf(context).languageCode),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      color: text,
                      fontSize: 13,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text(product.displayBrand(Localizations.localeOf(context).languageCode),
                  style: TextStyle(color: subText, fontSize: 11)),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: Text(
                    'JOD ${product.price?.toStringAsFixed(0) ?? ''}',
                    style: const TextStyle(
                        color: _C.gold,
                        fontSize: 15,
                        fontWeight: FontWeight.w800),
                  ),
                ),
                GestureDetector(
                  onTap: onAddToCart,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: isAdding ? _C.sage : _C.raspberry,
                      shape: BoxShape.circle,
                    ),
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        isAdding ? Icons.check_rounded : Icons.add_rounded,
                        key: ValueKey(isAdding),
                        color: Colors.white,
                        size: 17,
                      ),
                    ),
                  ),
                ),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}
