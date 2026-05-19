import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:project_assignment_e/screens/details_screen.dart';
import 'package:provider/provider.dart';

// ── Palette ───────────────────────────────────────────────────────────────────
class _C {
  static const raspberry = Color(0xFF912F56);
  static const plum      = Color(0xFF521945);
  static const wine      = Color(0xFF361F27);
  static const bgDark    = Color(0xFF0D090A);
  static const cardD     = Color(0xFF28141E);
  static const bgLight   = Color(0xFFFAF0EE);
  static const gold      = Color(0xFFD4A853);
  static const sage      = Color(0xFF3D7A6A);
}

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l        = AppLocalizations.of(context);
    final isDark   = context.watch<ThemeProvider>().isDark;
    final prodProv = context.watch<ProductProvider>();
    final favIds   = prodProv.favorites;
    final products = prodProv.productList
        .where((p) => favIds.contains(p.id))
        .toList();

    final bg      = isDark ? _C.bgDark  : _C.bgLight;
    final cardBg  = isDark ? _C.cardD   : Colors.white;
    final textCol = isDark ? Colors.white : _C.wine;
    final subCol  = isDark ? Colors.white54 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App bar ─────────────────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            expandedHeight: 120,
            backgroundColor: _C.raspberry,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              title: Row(
                children: [
                  Text(
                    l.t('favourites'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (products.isNotEmpty) ...[
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${products.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [_C.plum, _C.raspberry],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
          ),

          // ── Content ──────────────────────────────────────────────────────
          if (products.isEmpty)
            SliverFillRemaining(
              child: _EmptyFavorites(
                l: l,
                isDark: isDark,
                textCol: textCol,
                subCol: subCol,
                onBrowse: () => Navigator.pop(context),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              sliver: SliverGrid(
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.72,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, i) {
                    final product = products[i];
                    final delay = i * 0.08;
                    return FadeTransition(
                      opacity: CurvedAnimation(
                        parent: _ctrl,
                        curve: Interval(
                            delay.clamp(0.0, 0.6),
                            (delay + 0.5).clamp(0.0, 1.0),
                            curve: Curves.easeOut),
                      ),
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.15),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: _ctrl,
                          curve: Interval(
                              delay.clamp(0.0, 0.6),
                              (delay + 0.5).clamp(0.0, 1.0),
                              curve: Curves.easeOutCubic),
                        )),
                        child: _FavCard(
                          product: product,
                          heroTag: 'fav_${product.id}_$i',
                          cardBg: cardBg,
                          textCol: textCol,
                          subCol: subCol,
                          isDark: isDark,
                          l: l,
                          onUnfav: () {
                            HapticFeedback.mediumImpact();
                            context
                                .read<ProductProvider>()
                                .toggleFavorite(product.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(l.t('removeFavourite')),
                                behavior: SnackBarBehavior.floating,
                                backgroundColor: _C.raspberry,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          onTap: () {
                            final colors = [
                              _C.raspberry, _C.plum, _C.sage,
                            ];
                            Navigator.push(
                              context,
                              PageRouteBuilder(
                                transitionDuration:
                                    const Duration(milliseconds: 400),
                                pageBuilder: (_, __, ___) =>
                                    ProductDetailScreen(
                                  result: product,
                                  backColor: colors[i % colors.length],
                                  heroTag: 'fav_${product.id}_$i',
                                ),
                                transitionsBuilder: (_, a, __, child) =>
                                    FadeTransition(opacity: a, child: child),
                              ),
                            );
                          },
                          onAddToCart: () {
                            HapticFeedback.mediumImpact();
                            context.read<CartProvider>().itemAddToCart(product);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Text(l.t('addedToCart')),
                                ]),
                                backgroundColor: _C.sage,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                        ),
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

// ── Favourite Card ────────────────────────────────────────────────────────────
class _FavCard extends StatelessWidget {
  final dynamic product;
  final String heroTag;
  final Color cardBg, textCol, subCol;
  final bool isDark;
  final AppLocalizations l;
  final VoidCallback onUnfav;
  final VoidCallback onTap;
  final VoidCallback onAddToCart;

  const _FavCard({
    required this.product,
    required this.heroTag,
    required this.cardBg,
    required this.textCol,
    required this.subCol,
    required this.isDark,
    required this.l,
    required this.onUnfav,
    required this.onTap,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.07),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                children: [
                  Hero(
                    tag: heroTag,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(20)),
                      child: Container(
                        width: double.infinity,
                        color: isDark
                            ? _C.raspberry.withValues(alpha: 0.08)
                            : _C.raspberry.withValues(alpha: 0.04),
                        child: Image.network(
                          product.image ?? '',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) => const Center(
                            child: Icon(Icons.music_note_rounded,
                                color: _C.raspberry, size: 40),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Unfav button
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onUnfav,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.9),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: _C.raspberry.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ],
                        ),
                        child: const Icon(Icons.favorite_rounded,
                            color: _C.raspberry, size: 16),
                      ),
                    ),
                  ),

                  // Category badge
                  if (product.category != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _C.raspberry.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          product.category!.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.model ?? product.name ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: textCol,
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    product.brand ?? '',
                    style: TextStyle(color: subCol, fontSize: 11),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${l.t('currency')} ${product.price?.toStringAsFixed(0) ?? ''}',
                        style: const TextStyle(
                          color: _C.gold,
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      GestureDetector(
                        onTap: onAddToCart,
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: _C.raspberry,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
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

// ── Empty State ───────────────────────────────────────────────────────────────
class _EmptyFavorites extends StatelessWidget {
  final AppLocalizations l;
  final bool isDark;
  final Color textCol, subCol;
  final VoidCallback onBrowse;

  const _EmptyFavorites({
    required this.l,
    required this.isDark,
    required this.textCol,
    required this.subCol,
    required this.onBrowse,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                color: _C.raspberry.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.favorite_border_rounded,
                size: 54,
                color: _C.raspberry,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l.t('noFavourites'),
              style: TextStyle(
                color: textCol,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l.t('noFavouritesSub'),
              textAlign: TextAlign.center,
              style: TextStyle(color: subCol, fontSize: 14, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton.icon(
              onPressed: onBrowse,
              icon: const Icon(Icons.store_rounded),
              label: Text(l.t('browseStore')),
              style: ElevatedButton.styleFrom(
                backgroundColor: _C.raspberry,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                    horizontal: 28, vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
