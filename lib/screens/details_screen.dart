import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/models/product.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/screens/cart_screen.dart';
import 'package:project_assignment_e/screens/image_viewer_screen.dart';
import 'package:project_assignment_e/utils/app_colors.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:video_player/video_player.dart';

class ProductDetailScreen extends StatefulWidget {
  final Result? result;
  final Color? backColor;
  final String heroTag;

  const ProductDetailScreen({
    super.key,
    this.result,
    this.backColor,
    required this.heroTag,
  });

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with SingleTickerProviderStateMixin {
  VideoPlayerController? _videoCtrl;
  bool _videoReady = false;
  bool _showVideo  = false;

  late final AnimationController _slideCtrl;
  late final Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    )..forward();
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 1),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));

    if (widget.result?.videoUrl != null) _initVideo();
  }

  Future<void> _initVideo() async {
    _videoCtrl = VideoPlayerController.networkUrl(
      Uri.parse(widget.result!.videoUrl!),
    );
    try {
      await _videoCtrl!.initialize();
      if (mounted) setState(() => _videoReady = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _videoCtrl?.dispose();
    _slideCtrl.dispose();
    super.dispose();
  }

  Color get _accent => widget.backColor ?? AppColors.primary;

  void _share() {
    final p = widget.result;
    if (p == null) return;
    Share.share(
      'Check out ${p.name ?? p.model} at MOSIQATI!\n'
      'Price: JOD ${p.price?.toStringAsFixed(2)}\n'
      'Brand: ${p.brand}\n\n'
      '🎵 موسيقاتي — Jordan\'s premier music store',
    );
  }

  void _goToCart() => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const CartPage()),
      );

  @override
  Widget build(BuildContext context) {
    final l          = AppLocalizations.of(context);
    final lang       = Localizations.localeOf(context).languageCode;
    final p          = widget.result;
    final prodProv   = context.watch<ProductProvider>();
    final cartProv   = context.watch<CartProvider>();
    final isFav      = prodProv.isFavorite(p?.id);
    final userRating = prodProv.getRating(p?.id);

    return Scaffold(
      backgroundColor: _accent,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top bar ───────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      HapticFeedback.lightImpact();
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                  ),
                  Expanded(
                    child: Text(
                      p?.displayBrand(lang) ?? '',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: _share,
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    tooltip: l.t('share'),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      prodProv.toggleFavorite(p?.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(children: [
                            Icon(
                              isFav
                                  ? Icons.heart_broken_rounded
                                  : Icons.favorite_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(isFav
                                ? l.t('removeFromFav')
                                : l.t('addedToFav')),
                          ]),
                          backgroundColor:
                              isFav ? Colors.grey.shade700 : _accent,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        isFav
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFav ? Colors.red.shade300 : Colors.white,
                        key: ValueKey(isFav),
                      ),
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: _goToCart,
                        icon: const Icon(Icons.shopping_cart_rounded,
                            color: Colors.white),
                      ),
                      if (cartProv.itemCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                                color: Colors.red, shape: BoxShape.circle),
                            child: Text(
                              '${cartProv.itemCount}',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ─── Product image / video ─────────────────────────────────────
            Expanded(
              flex: 4,
              child: _showVideo && _videoReady
                  ? _VideoWidget(ctrl: _videoCtrl!)
                  : GestureDetector(
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ImageViewerScreen(
                            imageUrl: p?.image ?? '',
                            tag: widget.heroTag,
                          ),
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Hero(
                            tag: widget.heroTag,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              child: Image.network(
                                p?.image ?? '',
                                fit: BoxFit.contain,
                                loadingBuilder: (_, child, progress) {
                                  if (progress == null) return child;
                                  return const Center(
                                    child: CircularProgressIndicator(
                                        color: Colors.white54),
                                  );
                                },
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.music_note_rounded,
                                      color: Colors.white38, size: 80),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 16,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.45),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.zoom_in_rounded,
                                      color: Colors.white, size: 14),
                                  const SizedBox(width: 4),
                                  Text(l.t('tapToZoom'),
                                      style: const TextStyle(
                                          color: Colors.white, fontSize: 11)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),

            // Video toggle
            if (p?.videoUrl != null)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: OutlinedButton.icon(
                  onPressed: _videoReady
                      ? () => setState(() => _showVideo = !_showVideo)
                      : null,
                  icon: Icon(_showVideo
                      ? Icons.image_rounded
                      : Icons.play_circle_fill_rounded),
                  label: Text(
                    _showVideo ? l.t('showImage') : l.t('watchVideo'),
                    style: const TextStyle(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white60),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                  ),
                ),
              ),

            // ─── Details sheet ─────────────────────────────────────────────
            SlideTransition(
              position: _slideAnim,
              child: Flexible(
                flex: 6,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft:  Radius.circular(36),
                      topRight: Radius.circular(36),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, -6),
                      ),
                    ],
                  ),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Drag handle
                        Center(
                          child: Container(
                            width: 40,
                            height: 4,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),

                        // Model + Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    p?.displayModel(lang) ?? '',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    p?.displayBrand(lang) ?? '',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface
                                          .withValues(alpha: 0.5),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: _accent.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${l.t('currency')} ${p?.price?.toStringAsFixed(2) ?? ''}',
                                    style: TextStyle(
                                      color: _accent,
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                if ((p?.quantity ?? 0) > 0)
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 6, right: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Container(
                                          width: 7,
                                          height: 7,
                                          decoration: const BoxDecoration(
                                            color: AppColors.sage,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${p!.quantity} ${l.t('quantity')}',
                                          style: const TextStyle(
                                              color: AppColors.sage,
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),
                        _GradientDivider(color: _accent),
                        const SizedBox(height: 16),

                        // Specs
                        Text(
                          l.t('specifications'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 10),
                        _SpecsGrid(product: p, l: l, color: _accent, lang: lang),

                        // Description
                        if (p?.description != null) ...[
                          const SizedBox(height: 20),
                          _GradientDivider(color: _accent),
                          const SizedBox(height: 16),
                          Text(l.t('description'),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 8),
                          Text(
                            p!.displayDescription(lang),
                            style: TextStyle(
                              fontSize: 14,
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurface
                                  .withValues(alpha: 0.7),
                              height: 1.65,
                            ),
                          ),
                        ],

                        // Rating
                        const SizedBox(height: 20),
                        _GradientDivider(color: _accent),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Text(l.t('rateProduct'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            const Spacer(),
                            if (userRating > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.gold.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.star_rounded,
                                        color: AppColors.gold, size: 16),
                                    const SizedBox(width: 4),
                                    Text(
                                      userRating.toStringAsFixed(1),
                                      style: const TextStyle(
                                        color: AppColors.gold,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        RatingBar.builder(
                          initialRating: userRating,
                          minRating: 1,
                          direction: Axis.horizontal,
                          itemCount: 5,
                          itemSize: 34,
                          itemPadding:
                              const EdgeInsets.symmetric(horizontal: 2),
                          itemBuilder: (_, __) => const Icon(
                            Icons.star_rounded,
                            color: AppColors.gold,
                          ),
                          onRatingUpdate: (rating) {
                            HapticFeedback.selectionClick();
                            prodProv.setRating(p?.id, rating);
                          },
                        ),

                        const SizedBox(height: 24),

                        // Add to cart
                        SizedBox(
                          width: double.infinity,
                          height: 54,
                          child: ElevatedButton.icon(
                            onPressed: p == null
                                ? null
                                : () {
                                    HapticFeedback.mediumImpact();
                                    cartProv.itemAddToCart(p);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Row(children: [
                                          const Icon(
                                              Icons.check_circle_rounded,
                                              color: Colors.white,
                                              size: 18),
                                          const SizedBox(width: 8),
                                          Text(l.t('addedToCart')),
                                        ]),
                                        backgroundColor: AppColors.sage,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12)),
                                        duration:
                                            const Duration(seconds: 2),
                                        action: SnackBarAction(
                                          label: l.t('cart'),
                                          textColor: Colors.white,
                                          onPressed: _goToCart,
                                        ),
                                      ),
                                    );
                                  },
                            icon: const Icon(
                                Icons.add_shopping_cart_rounded,
                                size: 20),
                            label: Text(l.t('addToCart'),
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _accent,
                              foregroundColor: Colors.white,
                              shape: const StadiumBorder(),
                              elevation: 4,
                              shadowColor: _accent.withValues(alpha: 0.4),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Specs Grid ────────────────────────────────────────────────────────────────
class _SpecsGrid extends StatelessWidget {
  final Result? product;
  final AppLocalizations l;
  final Color color;
  final String lang;

  const _SpecsGrid(
      {required this.product, required this.l, required this.color, required this.lang});

  @override
  Widget build(BuildContext context) {
    final specs = [
      (l.t('brand'),    product?.displayBrand(lang) ?? '-',  Icons.business_rounded),
      (l.t('color'),    product?.displayColour(lang) ?? '-', Icons.palette_rounded),
      (l.t('weight'),   product?.weight ?? '-', Icons.monitor_weight_rounded),
      (l.t('quantity'), '${product?.quantity ?? 0}', Icons.inventory_2_rounded),
    ];

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2.8,
      children: specs
          .map(
            (s) => Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: color.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(s.$3, size: 18, color: color),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          s.$1,
                          style: TextStyle(
                            fontSize: 10,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                        ),
                        Text(
                          s.$2,
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.w600),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Gradient Divider ──────────────────────────────────────────────────────────
class _GradientDivider extends StatelessWidget {
  final Color color;
  const _GradientDivider({required this.color});

  @override
  Widget build(BuildContext context) => Container(
        height: 1,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              color.withValues(alpha: 0),
              color.withValues(alpha: 0.25),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      );
}

// ── Video Player Widget ───────────────────────────────────────────────────────
class _VideoWidget extends StatefulWidget {
  final VideoPlayerController ctrl;
  const _VideoWidget({required this.ctrl});

  @override
  State<_VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<_VideoWidget> {
  @override
  void initState() {
    super.initState();
    widget.ctrl.addListener(_rebuild);
  }

  void _rebuild() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.ctrl.removeListener(_rebuild);
    widget.ctrl.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl      = widget.ctrl;
    final isPlaying = ctrl.value.isPlaying;

    return GestureDetector(
      onTap: () => isPlaying ? ctrl.pause() : ctrl.play(),
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: ctrl.value.aspectRatio,
            child: VideoPlayer(ctrl),
          ),
          AnimatedOpacity(
            opacity: isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 48),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: VideoProgressIndicator(
              ctrl,
              allowScrubbing: true,
              colors: const VideoProgressColors(
                playedColor: AppColors.gold,
                bufferedColor: Colors.white30,
                backgroundColor: Colors.white10,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
