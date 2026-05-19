import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/models/product.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/screens/cart_screen.dart';
import 'package:project_assignment_e/screens/home_page.dart';
import 'package:provider/provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Result? result;
  final Color? backColor;

  const ProductDetailScreen({
    Key? key,
    this.result,
    this.backColor,
  }) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  // Light colours
  static const Color _bgLight = Color(0xfffbf6ef);
  static const Color _darkBrownBase = Color(0xff2b130c);
  static const Color _brownBase = Color(0xffb86f4b);
  static const Color _lightBrownBase = Color(0xffefe2d8);
  static const Color _olive = Color(0xff71805a);

  // Dark colours
  static const Color _bgDark = Color(0xff1a1008);
  static const Color _surfaceDark = Color(0xff2c1a0e);
  static const Color _textDark = Color(0xfffde8d4);
  static const Color _brownDark = Color(0xffcf8a65);

  int _quantity = 1;
  double _tempRating = 0;
  bool _addedAnimation = false;

  late AnimationController _addToCartController;
  late Animation<double> _addToCartScale;
  late AnimationController _enterController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _enterController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _fadeAnim = CurvedAnimation(
      parent: _enterController,
      curve: Curves.easeIn,
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _enterController,
        curve: Curves.easeOutCubic,
      ),
    );

    _addToCartController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 180),
      lowerBound: 0.92,
      upperBound: 1.0,
    );

    _addToCartScale = _addToCartController;
  }

  @override
  void dispose() {
    _enterController.dispose();
    _addToCartController.dispose();
    super.dispose();
  }

  void _tapSound() => HapticFeedback.lightImpact();
  void _successSound() => HapticFeedback.mediumImpact();

  void _toggleDarkMode(BuildContext ctx) {
    Provider.of<ThemeProvider>(ctx, listen: false).toggle();
    _tapSound();
  }

  Future<void> _handleAddToCart(Result product) async {
    _tapSound();

    await _addToCartController.reverse();
    await _addToCartController.forward();

    final cart = Provider.of<CartProvider>(context, listen: false);

    for (int i = 0; i < _quantity; i++) {
      cart.itemAddToCart(product);
    }

    _successSound();

    setState(() => _addedAnimation = true);

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() => _addedAnimation = false);
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: _olive,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        content: Row(
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                _quantity > 1
                    ? "$_quantity items added to cart!"
                    : "Added to cart successfully!",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CartScreen()),
                );
              },
              child: const Text(
                "View",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showRatingDialog(
    Result product,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
  ) {
    final ratingProv = Provider.of<RatingProvider>(context, listen: false);
    _tempRating = ratingProv.getRating(product.id.toString());

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setD) => AlertDialog(
          backgroundColor: surfaceCol,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          title: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: lightBrCol,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: brownCol,
                  size: 36,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                "Rate this Product",
                style: TextStyle(
                  color: mainText,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                product.model.toString(),
                style: TextStyle(color: brownCol, fontSize: 15),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 22),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  5,
                  (i) => GestureDetector(
                    onTap: () {
                      setD(() => _tempRating = i + 1.0);
                      _tapSound();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      child: Icon(
                        i < _tempRating
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.orange,
                        size: i < _tempRating ? 44 : 36,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  _tempRating == 0
                      ? "Tap a star to rate"
                      : _ratingLabel(_tempRating.toInt()),
                  key: ValueKey(_tempRating),
                  style: TextStyle(
                    color: _tempRating == 0
                        ? isDark
                            ? _textDark.withOpacity(0.55)
                            : Colors.brown.shade300
                        : _olive,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: isDark
                      ? _textDark.withOpacity(0.75)
                      : Colors.brown.shade400,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: _tempRating == 0
                  ? null
                  : () {
                      ratingProv.setRating(
                        product.id.toString(),
                        _tempRating,
                      );

                      _successSound();
                      Navigator.pop(ctx);

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: _olive,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                          content: Row(
                            children: [
                              const Icon(Icons.star, color: Colors.white),
                              const SizedBox(width: 8),
                              Text(
                                "Thanks! You rated it ${_tempRating.toInt()} stars ★",
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: brownCol,
                foregroundColor: Colors.white,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 28,
                  vertical: 12,
                ),
              ),
              child: const Text(
                "Submit Rating",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _ratingLabel(int r) {
    const labels = [
      "",
      "Poor ★",
      "Fair ★★",
      "Good ★★★",
      "Very Good ★★★★",
      "Excellent ★★★★★"
    ];

    return r >= 1 && r <= 5 ? labels[r] : "";
  }

  void _showImageZoom(String url, Color lightBrCol, Color brownCol) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(16),
        child: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: InteractiveViewer(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Image.network(
                url,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => Container(
                  height: 300,
                  color: lightBrCol,
                  child: Icon(
                    Icons.image_not_supported_outlined,
                    size: 80,
                    color: brownCol,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.result;

    final isDark = Provider.of<ThemeProvider>(context).isDark;

    final bgColor = isDark ? _bgDark : _bgLight;
    final surfaceCol = isDark ? _surfaceDark : Colors.white;
    final mainText = isDark ? _textDark : _darkBrownBase;
    final brownCol = isDark ? _brownDark : _brownBase;
    final lightBrCol = isDark ? const Color(0xff3a2010) : _lightBrownBase;
    final boxCol = isDark ? const Color(0xff24150b) : const Color(0xfffffbf5);
    final borderCol =
        isDark ? Colors.white.withOpacity(0.08) : const Color(0xffeadcd1);

    if (product == null) {
      return Scaffold(
        backgroundColor: bgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_off,
                size: 64,
                color: isDark
                    ? _textDark.withOpacity(0.45)
                    : Colors.brown.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                "No product details available",
                style: TextStyle(
                  color: mainText,
                  fontSize: 18,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.only(bottom: 110),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildTopBar(
                        context,
                        product,
                        isDark,
                        surfaceCol,
                        mainText,
                        brownCol,
                        lightBrCol,
                      ),
                      const SizedBox(height: 18),
                      _buildImageSection(
                        product,
                        isDark,
                        lightBrCol,
                        brownCol,
                        borderCol,
                      ),
                      const SizedBox(height: 24),
                      _buildInfoCard(
                        product,
                        isDark,
                        surfaceCol,
                        mainText,
                        brownCol,
                        lightBrCol,
                        boxCol,
                        borderCol,
                      ),
                    ],
                  ),
                ),
                _buildBottomBar(
                  product,
                  isDark,
                  surfaceCol,
                  brownCol,
                  borderCol,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(
    BuildContext ctx,
    Result product,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _circleBtn(
            Icons.arrow_back,
            surfaceCol: surfaceCol,
            mainText: mainText,
            onTap: () {
              _tapSound();
              Navigator.pop(ctx);
            },
          ),
          Row(
            children: [
              _circleBtn(
                isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                surfaceCol: lightBrCol,
                mainText: mainText,
                onTap: () => _toggleDarkMode(ctx),
              ),
              const SizedBox(width: 10),
              _circleBtn(
                Icons.share_outlined,
                surfaceCol: surfaceCol,
                mainText: mainText,
                onTap: _tapSound,
              ),
              const SizedBox(width: 10),
              Consumer<ProductProvider>(
                builder: (ctx, prov, _) => _circleBtn(
                  prov.isfavorite ? Icons.favorite : Icons.favorite_border,
                  surfaceCol: surfaceCol,
                  mainText: mainText,
                  iconColor: prov.isfavorite ? Colors.red : mainText,
                  onTap: () {
                    _tapSound();
                    Provider.of<ProductProvider>(ctx, listen: false)
                        .makeFavorite();
                  },
                ),
              ),
              const SizedBox(width: 10),
              Stack(
                children: [
                  _circleBtn(
                    Icons.shopping_bag_outlined,
                    surfaceCol: surfaceCol,
                    mainText: mainText,
                    onTap: () {
                      _tapSound();
                      Navigator.push(
                        ctx,
                        MaterialPageRoute(builder: (_) => const CartScreen()),
                      );
                    },
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Consumer<CartProvider>(
                      builder: (_, cart, __) => cart.cartItems.isEmpty
                          ? const SizedBox.shrink()
                          : CircleAvatar(
                              radius: 10,
                              backgroundColor: Colors.deepOrange.shade400,
                              child: Text(
                                cart.cartItems.length.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(
    Result product,
    bool isDark,
    Color lightBrCol,
    Color brownCol,
    Color borderCol,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          color: lightBrCol,
          borderRadius: BorderRadius.circular(34),
          border: Border.all(color: borderCol),
        ),
        child: Stack(
          children: [
            GestureDetector(
              onTap: () => _showImageZoom(
                product.image.toString(),
                lightBrCol,
                brownCol,
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(26),
                  child: Hero(
                    tag: "product_image_${product.id}",
                    child: Image.network(
                      product.image.toString(),
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.image_not_supported_outlined,
                        size: 80,
                        color: isDark
                            ? _textDark.withOpacity(0.45)
                            : Colors.brown.shade300,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.80),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  "PREMIUM",
                  style: TextStyle(
                    color: brownCol,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 20,
              top: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.zoom_in, color: Colors.white, size: 16),
                    SizedBox(width: 4),
                    Text(
                      "Zoom",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 20,
              bottom: 20,
              child: CircleAvatar(
                radius: 26,
                backgroundColor: Colors.black.withOpacity(0.38),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 30,
                ),
              ),
            ),
            Positioned(
              right: 20,
              bottom: 20,
              child: GestureDetector(
                onTap: () {
                  final isDark = Provider.of<ThemeProvider>(
                    context,
                    listen: false,
                  ).isDark;

                  final surfaceCol = isDark ? _surfaceDark : Colors.white;
                  final mainText = isDark ? _textDark : _darkBrownBase;
                  final brown = isDark ? _brownDark : _brownBase;
                  final light = isDark
                      ? const Color(0xff3a2010)
                      : _lightBrownBase;

                  _showRatingDialog(
                    product,
                    isDark,
                    surfaceCol,
                    mainText,
                    brown,
                    light,
                  );
                },
                child: Consumer<RatingProvider>(
                  builder: (_, rProv, __) {
                    final r = rProv.getRating(product.id.toString());

                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.38),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            color: Colors.orange,
                            size: 18,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            r > 0 ? "${r.toInt()}/5" : "Rate",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    Result product,
    bool isDark,
    Color surfaceCol,
    Color mainText,
    Color brownCol,
    Color lightBrCol,
    Color boxCol,
    Color borderCol,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 18),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: surfaceCol.withOpacity(0.88),
        borderRadius: BorderRadius.circular(34),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            product.model.toString(),
            style: TextStyle(
              color: mainText,
              fontSize: 28,
              fontWeight: FontWeight.bold,
              fontFamily: "serif",
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () => _showRatingDialog(
              product,
              isDark,
              surfaceCol,
              mainText,
              brownCol,
              lightBrCol,
            ),
            child: Consumer<RatingProvider>(
              builder: (_, rProv, __) {
                final r = rProv.getRating(product.id.toString());

                return Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        i < (r > 0 ? r : 4.8).ceil()
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: Colors.orange,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      r > 0 ? "${r.toInt()}.0  (Your rating)" : "4.8  (Tap to rate)",
                      style: TextStyle(
                        color: r > 0
                            ? _olive
                            : isDark
                                ? _textDark.withOpacity(0.65)
                                : Colors.grey.shade600,
                        fontSize: 15,
                        fontWeight:
                            r > 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Crafted instruments. Real soul.",
            style: TextStyle(
              color: isDark
                  ? _textDark.withOpacity(0.70)
                  : Colors.brown.shade400,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _infoBox(
                  "Brand",
                  product.brand.toString(),
                  Icons.verified_outlined,
                  isDark,
                  boxCol,
                  mainText,
                  borderCol,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoBox(
                  "Color",
                  product.colour.toString(),
                  Icons.palette_outlined,
                  isDark,
                  boxCol,
                  mainText,
                  borderCol,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _infoBox(
                  "Weight",
                  product.weight.toString(),
                  Icons.scale_outlined,
                  isDark,
                  boxCol,
                  mainText,
                  borderCol,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoBox(
                  "Category",
                  product.category.toString(),
                  Icons.music_note_outlined,
                  isDark,
                  boxCol,
                  mainText,
                  borderCol,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Text(
            "Description",
            style: TextStyle(
              color: mainText,
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "A beautifully crafted musical instrument designed for rich tone, elegant style, "
            "and a premium playing experience. Built with care for both beginners and professional musicians.",
            style: TextStyle(
              color: isDark
                  ? _textDark.withOpacity(0.70)
                  : Colors.brown.shade400,
              fontSize: 15,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                "Quantity",
                style: TextStyle(
                  color: isDark
                      ? _textDark.withOpacity(0.70)
                      : Colors.brown.shade400,
                  fontSize: 16,
                ),
              ),
              const Spacer(),
              _buildQuantitySelector(
                lightBrCol,
                mainText,
                borderCol,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total Price",
                style: TextStyle(
                  color: isDark
                      ? _textDark.withOpacity(0.70)
                      : Colors.brown.shade400,
                  fontSize: 17,
                ),
              ),
              Text(
                "\$${((double.tryParse(product.price.toString()) ?? 0) * _quantity).toStringAsFixed(2)}",
                style: TextStyle(
                  color: brownCol,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySelector(
    Color lightBrCol,
    Color mainText,
    Color borderCol,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: lightBrCol,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Row(
        children: [
          _qtyBtn(
            Icons.remove,
            mainText,
            () {
              if (_quantity > 1) {
                _tapSound();
                setState(() => _quantity--);
              }
            },
          ),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: child,
            ),
            child: Text(
              "$_quantity",
              key: ValueKey(_quantity),
              style: TextStyle(
                color: mainText,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          _qtyBtn(
            Icons.add,
            mainText,
            () {
              _tapSound();
              setState(() => _quantity++);
            },
          ),
        ],
      ),
    );
  }

  Widget _qtyBtn(
    IconData icon,
    Color mainText,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        child: Icon(
          icon,
          color: mainText,
          size: 22,
        ),
      ),
    );
  }

  Widget _buildBottomBar(
    Result product,
    bool isDark,
    Color surfaceCol,
    Color brownCol,
    Color borderCol,
  ) {
    return Positioned(
      left: 18,
      right: 18,
      bottom: 16,
      child: ScaleTransition(
        scale: _addToCartScale,
        child: Container(
          height: 70,
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: surfaceCol.withOpacity(0.96),
            borderRadius: BorderRadius.circular(38),
            border: Border.all(color: borderCol),
            boxShadow: [
              BoxShadow(
                color: Colors.brown.withOpacity(isDark ? 0.18 : 0.14),
                blurRadius: 22,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _handleAddToCart(product),
            icon: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _addedAnimation
                    ? Icons.check_circle_outline
                    : Icons.shopping_bag_outlined,
                key: ValueKey(_addedAnimation),
                color: Colors.white,
              ),
            ),
            label: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _addedAnimation ? "Added!" : "Add to Cart",
                key: ValueKey(_addedAnimation),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: _addedAnimation ? _olive : brownCol,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: const StadiumBorder(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _circleBtn(
    IconData icon, {
    required VoidCallback onTap,
    required Color surfaceCol,
    required Color mainText,
    Color? iconColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 24,
        backgroundColor: surfaceCol.withOpacity(0.90),
        child: Icon(
          icon,
          color: iconColor ?? mainText,
          size: 22,
        ),
      ),
    );
  }

  Widget _infoBox(
    String title,
    String value,
    IconData icon,
    bool isDark,
    Color boxCol,
    Color mainText,
    Color borderCol,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: boxCol,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderCol),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.circle,
            color: Colors.transparent,
            size: 0,
          ),
          Icon(icon, color: _olive, size: 22),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: isDark
                  ? _textDark.withOpacity(0.55)
                  : Colors.brown.shade300,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: mainText,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}