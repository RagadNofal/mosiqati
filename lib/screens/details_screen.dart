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

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  VideoPlayerController? _videoController;
  bool _videoInitialized = false;
  bool _showVideo = false;

  @override
  void initState() {
    super.initState();
    if (widget.result?.videoUrl != null) {
      _initVideo();
    }
  }

  Future<void> _initVideo() async {
    _videoController = VideoPlayerController.networkUrl(
      Uri.parse(widget.result!.videoUrl!),
    );
    try {
      await _videoController!.initialize();
      if (mounted) setState(() => _videoInitialized = true);
    } catch (_) {}
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }

  void _share() {
    final product = widget.result;
    if (product == null) return;
    Share.share(
      'Check out ${product.name ?? product.model} at MOSIQATI!\n'
      'Price: JOD ${product.price?.toStringAsFixed(2)}\n'
      'Brand: ${product.brand}\n\n'
      '🎵 Jordan\'s premier music store - موسيقاتي',
    );
  }

  void _navigateToCart() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CartScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    final product = widget.result;
    final color = widget.backColor ?? AppColors.primary;
    final productProvider = context.watch<ProductProvider>();
    final cartProvider = context.watch<CartProvider>();
    final isFav = productProvider.isFavorite(product?.id);
    final userRating = productProvider.getRating(product?.id);

    return Scaffold(
      backgroundColor: color,
      body: SafeArea(
        child: Column(
          children: [
            // ─── Top bar ────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
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
                  const Spacer(),
                  IconButton(
                    onPressed: _share,
                    icon: const Icon(Icons.share_rounded, color: Colors.white),
                    tooltip: l.t('share'),
                  ),
                  IconButton(
                    onPressed: () {
                      HapticFeedback.selectionClick();
                      context
                          .read<ProductProvider>()
                          .toggleFavorite(product?.id);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isFav ? l.t('removeFromFav') : l.t('addedToFav'),
                          ),
                          behavior: SnackBarBehavior.floating,
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    icon: Icon(
                      isFav
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: isFav ? Colors.red.shade300 : Colors.white,
                    ),
                  ),
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: _navigateToCart,
                        icon: const Icon(Icons.shopping_cart_rounded,
                            color: Colors.white),
                      ),
                      if (cartProvider.itemCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
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
                ],
              ),
            ),

            // ─── Image / Video ───────────────────────────────────────
            Expanded(
              flex: 4,
              child: _showVideo && _videoInitialized
                  ? _VideoPlayerWidget(controller: _videoController!)
                  : GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ImageViewerScreen(
                              imageUrl: product?.image ?? '',
                              tag: widget.heroTag,
                            ),
                          ),
                        );
                      },
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Hero(
                            tag: widget.heroTag,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 8),
                              child: Image.network(
                                product?.image ?? '',
                                fit: BoxFit.contain,
                                errorBuilder: (_, __, ___) => const Center(
                                  child: Icon(Icons.music_note,
                                      color: Colors.white54, size: 80),
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

            // Video toggle button (if product has video)
            if (product?.videoUrl != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                child: OutlinedButton.icon(
                  onPressed: _videoInitialized
                      ? () => setState(() => _showVideo = !_showVideo)
                      : null,
                  icon: Icon(_showVideo ? Icons.image_rounded : Icons.play_circle_rounded),
                  label: Text(_showVideo ? 'Show Image' : l.t('watchVideo')),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white60),
                    shape: const StadiumBorder(),
                  ),
                ),
              ),

            // ─── Details card ────────────────────────────────────────
            Expanded(
              flex: 5,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(36),
                    topRight: Radius.circular(36),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.15),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Model name + brand
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product?.model ?? '',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                Text(
                                  product?.brand ?? '',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.55),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${l.t('currency')} ${product?.price?.toStringAsFixed(2) ?? ''}',
                              style: TextStyle(
                                color: color,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // ─── Specifications ─────────────────────────────
                      Text(
                        l.t('specifications'),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _SpecsGrid(product: product, l: l, color: color),

                      if (product?.description != null) ...[
                        const SizedBox(height: 16),
                        Text(l.t('description'),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w700)),
                        const SizedBox(height: 6),
                        Text(
                          product!.description!,
                          style: TextStyle(
                            fontSize: 14,
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.7),
                            height: 1.6,
                          ),
                        ),
                      ],

                      // ─── Rating ─────────────────────────────────────
                      const SizedBox(height: 16),
                      Text(l.t('rateProduct'),
                          style: const TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          RatingBar.builder(
                            initialRating: userRating,
                            minRating: 1,
                            direction: Axis.horizontal,
                            itemCount: 5,
                            itemSize: 32,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            itemBuilder: (context, _) => Icon(
                              Icons.star_rounded,
                              color: AppColors.gold,
                            ),
                            onRatingUpdate: (rating) {
                              HapticFeedback.selectionClick();
                              context
                                  .read<ProductProvider>()
                                  .setRating(product?.id, rating);
                            },
                          ),
                          const SizedBox(width: 12),
                          if (userRating > 0)
                            Text(
                              userRating.toStringAsFixed(1),
                              style: const TextStyle(
                                color: AppColors.gold,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // ─── Add to Cart button ──────────────────────────
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            HapticFeedback.mediumImpact();
                            context
                                .read<CartProvider>()
                                .itemAddToCart(product!);
                            final l = AppLocalizations.of(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(
                                        Icons.check_circle_rounded,
                                        color: Colors.white),
                                    const SizedBox(width: 8),
                                    Text(l.t('addedToCart')),
                                  ],
                                ),
                                backgroundColor: Colors.green.shade700,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 2),
                                action: SnackBarAction(
                                  label: l.t('cart'),
                                  textColor: Colors.white,
                                  onPressed: _navigateToCart,
                                ),
                              ),
                            );
                          },
                          icon: const Icon(Icons.add_shopping_cart_rounded),
                          label: Text(l.t('addToCart'),
                              style: const TextStyle(fontSize: 16)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            shape: const StadiumBorder(),
                          ),
                        ),
                      ),
                    ],
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

// ─── Specs Grid ───────────────────────────────────────────────────────────────

class _SpecsGrid extends StatelessWidget {
  final Result? product;
  final AppLocalizations l;
  final Color color;

  const _SpecsGrid({required this.product, required this.l, required this.color});

  @override
  Widget build(BuildContext context) {
    final specs = [
      (l.t('brand'), product?.brand ?? '-', Icons.business_rounded),
      (l.t('color'), product?.colour ?? '-', Icons.palette_rounded),
      (l.t('weight'), product?.weight ?? '-', Icons.monitor_weight_rounded),
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
          .map((s) => Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: color.withValues(alpha: 0.2)),
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
                          Text(s.$1,
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurface
                                      .withValues(alpha: 0.5))),
                          Text(s.$2,
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600),
                              overflow: TextOverflow.ellipsis),
                        ],
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }
}

// ─── Video Player Widget ──────────────────────────────────────────────────────

class _VideoPlayerWidget extends StatefulWidget {
  final VideoPlayerController controller;
  const _VideoPlayerWidget({required this.controller});

  @override
  State<_VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<_VideoPlayerWidget> {
  @override
  void initState() {
    super.initState();
    widget.controller.play();
    widget.controller.addListener(_onVideoUpdated);
  }

  void _onVideoUpdated() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoUpdated);
    widget.controller.pause();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
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
          // Play/Pause overlay
          AnimatedOpacity(
            opacity: isPlaying ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 300),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.4),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(16),
              child: const Icon(Icons.play_arrow_rounded,
                  color: Colors.white, size: 48),
            ),
          ),
          // Progress bar at bottom
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
