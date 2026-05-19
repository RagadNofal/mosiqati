import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/providers/user_provider.dart';
import 'package:project_assignment_e/screens/details_screen.dart';
import 'package:project_assignment_e/screens/profile_screen.dart';
import 'package:project_assignment_e/screens/services_screen.dart';
import 'package:provider/provider.dart';

// ─────────────────────────────────────────────
//  ThemeProvider  –  defined ONCE here, register in main.dart
// ─────────────────────────────────────────────
class ThemeProvider extends ChangeNotifier {
  bool _isDark = false;
  bool get isDark => _isDark;
  void toggle() { _isDark = !_isDark; notifyListeners(); }
}

// ─────────────────────────────────────────────
//  RatingProvider  –  defined ONCE here, register in main.dart
// ─────────────────────────────────────────────
class RatingProvider extends ChangeNotifier {
  final Map<String, double> _ratings = {};
  double getRating(String id) => _ratings[id] ?? 0.0;
  void setRating(String id, double rating) {
    _ratings[id] = rating;
    notifyListeners();
  }
}

// ─────────────────────────────────────────────
//  HomeScreen
// ─────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  late AnimationController _enterController;
  late AnimationController _pulseController;
  late Animation<double>   _fadeAnim;
  late Animation<Offset>   _slideAnim;
  final PageController     _heroPageCtrl = PageController();
  Timer? _heroTimer;
  int    _currentHeroIndex  = 0;
  String _selectedCategory  = '';

  // ── Light colours ──────────────────────────
  static const Color _bgLight        = Color(0xfffbf6ef);
  static const Color _darkBrownBase  = Color(0xff2b130c);
  static const Color _brownBase      = Color(0xffb86f4b);
  static const Color _lightBrownBase = Color(0xffefe2d8);
  static const Color _oliveBase      = Color(0xff71805a);
  // ── Dark colours ──────────────────────────
  static const Color _bgDark         = Color(0xff1a1008);
  static const Color _surfaceDark    = Color(0xff2c1a0e);
  static const Color _textDark       = Color(0xfffde8d4);
  static const Color _brownDark      = Color(0xffcf8a65);

  final List<Map<String, String>> _heroItems = [
    {"tag":"MUSIC EXPERIENCE","title1":"Find your\nperfect ","title2":"sound",
     "subtitle":"Crafted instruments. Real soul.",
     "image":"https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=900"},
    {"tag":"PREMIUM COLLECTION","title1":"Feel the\nmagic of ","title2":"music",
     "subtitle":"Choose instruments that match your mood.",
     "image":"https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=900"},
    {"tag":"NEW ARRIVALS","title1":"Play your\nown ","title2":"story",
     "subtitle":"Explore guitars, piano, drums and more.",
     "image":"https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=900"},
  ];

  final List<Map<String, String>> _categories = [
    {"emoji":"🪕","label":"Oud",   "key":"oud"},
    {"emoji":"🎸","label":"Guitar","key":"guitar"},
    {"emoji":"🎹","label":"Piano", "key":"piano"},
    {"emoji":"🥁","label":"Drums", "key":"drums"},
    {"emoji":"🎧","label":"Studio","key":"studio"},
  ];

  @override
  void initState() {
    super.initState();
    Provider.of<ProductProvider>(context, listen: false).getProducts();
    _enterController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 900),
        lowerBound: 0.94, upperBound: 1.05)..repeat(reverse: true);
    _fadeAnim  = CurvedAnimation(parent: _enterController, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterController, curve: Curves.easeOutCubic));
    _enterController.forward();
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!_heroPageCtrl.hasClients) return;
      final next = (_currentHeroIndex + 1) % _heroItems.length;
      _heroPageCtrl.animateToPage(next,
          duration: const Duration(milliseconds: 650), curve: Curves.easeInOutCubic);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _enterController.dispose();
    _pulseController.dispose();
    _heroTimer?.cancel();
    _heroPageCtrl.dispose();
    super.dispose();
  }

  void _playTap()     => HapticFeedback.lightImpact();
  void _playSuccess() => HapticFeedback.mediumImpact();

  void _toggleDarkMode(BuildContext ctx) {
    try { Provider.of<ThemeProvider>(ctx, listen: false).toggle(); } catch (_) {}
    _playTap();
  }

  // ── Rating Dialog ──────────────────────────
  void _showRatingDialog(BuildContext ctx, dynamic product) {
    double tempRating = Provider.of<RatingProvider>(ctx, listen: false)
        .getRating(product.id.toString());
    showDialog(
      context: ctx,
      builder: (dCtx) => StatefulBuilder(
        builder: (dCtx, setD) => AlertDialog(
          backgroundColor: _bgLight,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
          title: Text("Rate this product",
              style: TextStyle(color: _darkBrownBase, fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(product.model.toString(),
                  style: const TextStyle(color: _brownBase, fontSize: 16),
                  textAlign: TextAlign.center),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) => GestureDetector(
                  onTap: () { setD(() => tempRating = i + 1.0); _playTap(); },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    child: Icon(
                      i < tempRating ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: Colors.orange,
                      size: i < tempRating ? 40 : 34,
                    ),
                  ),
                )),
              ),
              const SizedBox(height: 12),
              Text(
                tempRating == 0 ? "Tap a star to rate" : "${tempRating.toInt()} / 5 stars",
                style: TextStyle(color: Colors.brown.shade400, fontSize: 14),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: Text("Cancel", style: TextStyle(color: Colors.brown.shade400)),
            ),
            ElevatedButton(
              onPressed: tempRating == 0 ? null : () {
                Provider.of<RatingProvider>(ctx, listen: false)
                    .setRating(product.id.toString(), tempRating);
                _playSuccess();
                Navigator.pop(dCtx);
                ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
                  backgroundColor: _oliveBase,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  content: Text("Rated ${tempRating.toInt()} stars – thank you!",
                      style: const TextStyle(color: Colors.white)),
                ));
              },
              style: ElevatedButton.styleFrom(
                  backgroundColor: _brownBase,
                  foregroundColor: Colors.white,
                  shape: const StadiumBorder()),
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final api = Provider.of<ProductProvider>(context).apidatastatus;
    bool isDark = false;
    try { isDark = Provider.of<ThemeProvider>(context).isDark; } catch (_) {}

    final bgColor    = isDark ? _bgDark       : _bgLight;
    final surfaceCol = isDark ? _surfaceDark  : Colors.white;
    final mainText   = isDark ? _textDark     : _darkBrownBase;
    final brownCol   = isDark ? _brownDark    : _brownBase;
    final lightBrCol = isDark ? _surfaceDark  : _lightBrownBase;

    return Scaffold(
      backgroundColor: bgColor,
      extendBody: true,
      bottomNavigationBar: _buildBottomNav(context, isDark, surfaceCol, mainText, brownCol),
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 115),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, isDark, mainText, brownCol, lightBrCol),
                  const SizedBox(height: 22),
                  _buildHeroCard(bgColor, mainText, brownCol, lightBrCol),
                  const SizedBox(height: 20),
                  _buildSearchBar(context, surfaceCol, brownCol, mainText),
                  const SizedBox(height: 24),
                  _buildSectionHeader("Categories", "View all", mainText),
                  const SizedBox(height: 14),
                  _buildCategoryRow(context, lightBrCol, mainText, brownCol),
                  const SizedBox(height: 26),
                  _buildSectionHeader("Most Popular", "See all", mainText),
                  const SizedBox(height: 14),
                  _buildProductsSection(context, api, surfaceCol, lightBrCol, mainText, brownCol),
                  const SizedBox(height: 22),
                  _buildSoundMoodCard(surfaceCol, lightBrCol, mainText, brownCol),
                  const SizedBox(height: 16),
                  _buildDarkModeToggle(context, isDark, surfaceCol, mainText, brownCol),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────
  Widget _buildHeader(BuildContext ctx, bool isDark, Color mainText, Color brownCol, Color lightBrCol) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: RichText(
            text: TextSpan(children: [
              TextSpan(text: "Welcome to\n",
                  style: TextStyle(color: brownCol.withOpacity(0.7), fontSize: 20)),
              TextSpan(text: "MOSI",
                  style: TextStyle(color: mainText, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
              TextSpan(text: "Q",
                  style: TextStyle(color: brownCol, fontSize: 38, fontWeight: FontWeight.w700)),
              TextSpan(text: "ATI",
                  style: TextStyle(color: mainText, fontSize: 38, fontWeight: FontWeight.w700, letterSpacing: 1.4)),
            ]),
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () => _toggleDarkMode(ctx),
              child: CircleAvatar(
                radius: 22,
                backgroundColor: lightBrCol,
                child: Icon(isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
                    color: mainText, size: 22),
              ),
            ),
            const SizedBox(width: 10),
            GestureDetector(
              onTap: () {
                _playTap();
                Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              },
              child: CircleAvatar(
                radius: 28,
                backgroundColor: lightBrCol,
                child: Icon(Icons.person_outline, color: mainText, size: 28),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ── Hero Card ──────────────────────────────
  Widget _buildHeroCard(Color bgColor, Color mainText, Color brownCol, Color lightBrCol) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 175,
          child: PageView.builder(
            controller: _heroPageCtrl,
            itemCount: _heroItems.length,
            onPageChanged: (i) => setState(() => _currentHeroIndex = i),
            itemBuilder: (ctx, index) {
              final item = _heroItems[index];
              return AnimatedBuilder(
                animation: _heroPageCtrl,
                builder: (ctx, child) {
                  double scale = 1.0;
                  if (_heroPageCtrl.hasClients && _heroPageCtrl.position.haveDimensions) {
                    scale = (1 - ((_heroPageCtrl.page! - index).abs() * 0.07)).clamp(0.93, 1.0);
                  }
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(color: const Color(0xffe7d7ca)),
                    gradient: LinearGradient(colors: [bgColor.withOpacity(0.98), const Color(0xfff0d7c4)]),
                    boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.10), blurRadius: 16, offset: const Offset(0, 7))],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(28),
                    child: Stack(
                      children: [
                        Positioned(
                          right: -25, bottom: 0, top: 0,
                          child: Image.network(item["image"]!, width: 245, fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(Icons.music_note, size: 80, color: Colors.brown.shade200)),
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [bgColor.withOpacity(0.98), bgColor.withOpacity(0.55), Colors.transparent],
                              begin: Alignment.centerLeft, end: Alignment.centerRight,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(18),
                          child: SizedBox(
                            width: 230,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                                  decoration: BoxDecoration(color: lightBrCol, borderRadius: BorderRadius.circular(20)),
                                  child: Text(item["tag"]!, style: TextStyle(color: mainText, fontWeight: FontWeight.bold, fontSize: 11)),
                                ),
                                const SizedBox(height: 14),
                                RichText(
                                  maxLines: 2, overflow: TextOverflow.ellipsis,
                                  text: TextSpan(children: [
                                    TextSpan(text: item["title1"]!,
                                        style: TextStyle(color: mainText, fontSize: 23, height: 1.05, fontWeight: FontWeight.bold)),
                                    TextSpan(text: item["title2"]!,
                                        style: TextStyle(color: brownCol, fontSize: 23, height: 1.05, fontWeight: FontWeight.bold)),
                                  ]),
                                ),
                                const SizedBox(height: 7),
                                Text(item["subtitle"]!, maxLines: 1, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: brownCol.withOpacity(0.7), fontSize: 13)),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 22, bottom: 18,
                          child: ScaleTransition(
                            scale: _pulseController,
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.black.withOpacity(0.45),
                              child: const Icon(Icons.play_arrow, color: Colors.white, size: 34),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_heroItems.length, (i) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentHeroIndex == i ? 22 : 10,
            height: 6,
            decoration: BoxDecoration(
              color: _currentHeroIndex == i ? brownCol : const Color(0xffe5d8ce),
              borderRadius: BorderRadius.circular(20),
            ),
          )),
        ),
      ],
    );
  }

  // ── Search Bar ─────────────────────────────
  Widget _buildSearchBar(BuildContext ctx, Color surface, Color brownCol, Color mainText) {
    return Container(
      height: 58,
      decoration: BoxDecoration(
        color: surface.withOpacity(0.85),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: const Color(0xffeadcd1)),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          Provider.of<ProductProvider>(ctx, listen: false).searchByModel(val.toLowerCase().trim());
          setState(() {});
        },
        style: TextStyle(color: mainText),
        decoration: InputDecoration(
          hintText: "Search instruments...",
          hintStyle: TextStyle(color: Colors.brown.shade300, fontSize: 17),
          prefixIcon: Icon(Icons.search, color: Colors.brown.shade400),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: Icon(Icons.close, color: mainText),
                  onPressed: () {
                    _searchController.clear();
                    Provider.of<ProductProvider>(ctx, listen: false).searchByModel('');
                    setState(() {});
                  })
              : Icon(Icons.tune, color: mainText),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.only(top: 14),
        ),
      ),
    );
  }

  // ── Section Header ─────────────────────────
  Widget _buildSectionHeader(String title, String action, Color mainText) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: TextStyle(color: mainText, fontSize: 23, fontWeight: FontWeight.bold, fontFamily: "serif")),
        Row(children: [
          Text(action, style: const TextStyle(color: _oliveBase, fontSize: 15)),
          const SizedBox(width: 6),
          const Icon(Icons.arrow_forward, color: _oliveBase, size: 19),
        ]),
      ],
    );
  }

  // ── Category Row ───────────────────────────
  Widget _buildCategoryRow(BuildContext ctx, Color lightBrCol, Color mainText, Color brownCol) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _categories.asMap().entries.map((entry) {
          final i   = entry.key;
          final cat = entry.value;
          final isSelected = _selectedCategory == cat["key"];
          return Padding(
            padding: EdgeInsets.only(right: i < _categories.length - 1 ? 12 : 0),
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.88, end: 1),
              duration: const Duration(milliseconds: 550),
              curve: Curves.easeOutBack,
              builder: (_, val, child) => Transform.scale(scale: val, child: child),
              child: GestureDetector(
                onTap: () {
                  _playTap();
                  setState(() {
                    if (_selectedCategory == cat["key"]) {
                      _selectedCategory = '';
                      Provider.of<ProductProvider>(ctx, listen: false).getProducts();
                    } else {
                      _selectedCategory = cat["key"]!;
                      Provider.of<ProductProvider>(ctx, listen: false).filterByCate(cat["key"]!);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  width: 86, height: 92,
                  decoration: BoxDecoration(
                    color: isSelected ? brownCol : lightBrCol.withOpacity(0.65),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                        color: isSelected ? brownCol : const Color(0xffeadcd1),
                        width: isSelected ? 2 : 1),
                    boxShadow: isSelected
                        ? [BoxShadow(color: brownCol.withOpacity(0.3), blurRadius: 10, offset: const Offset(0, 4))]
                        : [],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(cat["emoji"]!, style: const TextStyle(fontSize: 30)),
                      const SizedBox(height: 6),
                      Text(cat["label"]!,
                          style: TextStyle(
                              color: isSelected ? Colors.white : mainText,
                              fontSize: 13, fontWeight: FontWeight.w600)),
                    ],
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Products Section ───────────────────────
  Widget _buildProductsSection(BuildContext ctx, ApiStatus api,
      Color surface, Color lightBrCol, Color mainText, Color brownCol) {
    if (api == ApiStatus.loading) {
      return SizedBox(
        height: 265,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 4,
          itemBuilder: (_, __) => Container(
            width: 190, margin: const EdgeInsets.only(right: 14),
            decoration: BoxDecoration(
              color: surface.withOpacity(0.5),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xffeadcd1)),
            ),
            child: Column(children: [
              Expanded(child: Container(margin: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: lightBrCol.withOpacity(0.5), borderRadius: BorderRadius.circular(20)))),
              Container(margin: const EdgeInsets.fromLTRB(14,8,14,4), height: 14,
                  decoration: BoxDecoration(color: lightBrCol, borderRadius: BorderRadius.circular(8))),
              Container(margin: const EdgeInsets.fromLTRB(14,4,14,12), height: 18, width: 80,
                  decoration: BoxDecoration(color: lightBrCol, borderRadius: BorderRadius.circular(8))),
            ]),
          ),
        ),
      );
    }

    if (api != ApiStatus.completed) {
      return Container(
        height: 80, alignment: Alignment.center,
        child: Text("Unable to load products. Please check your connection.",
            style: TextStyle(color: Colors.brown.shade400), textAlign: TextAlign.center),
      );
    }

    return Consumer<ProductProvider>(
      builder: (ctx, prov, __) {
        if (prov.productList.isEmpty) {
          return Container(
            height: 120, alignment: Alignment.center,
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(Icons.music_off, color: Colors.brown.shade300, size: 40),
              const SizedBox(height: 8),
              Text("No products found", style: TextStyle(color: Colors.brown.shade400)),
            ]),
          );
        }
        return SizedBox(
          height: 285,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: prov.productList.length,
            itemBuilder: (ctx, i) {
              final product = prov.productList[i];
              return SizedBox(
                width: 190,
                child: Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: GestureDetector(
                    onTap: () {
                      _playTap();
                      Navigator.push(ctx, MaterialPageRoute(
                          builder: (_) => ProductDetailScreen(result: product, backColor: lightBrCol)));
                    },
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0.86, end: 1),
                      duration: Duration(milliseconds: 450 + i * 80),
                      curve: Curves.easeOutBack,
                      builder: (_, val, child) => Transform.scale(scale: val, child: child),
                      child: Consumer<RatingProvider>(
                        builder: (ctx, rProv, _) {
                          final userRating = rProv.getRating(product.id.toString());
                          return Container(
                            decoration: BoxDecoration(
                              color: surface.withOpacity(0.88),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: const Color(0xffeadcd1)),
                              boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.08), blurRadius: 16, offset: const Offset(0, 8))],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Stack(children: [
                                    Container(
                                      margin: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(color: lightBrCol, borderRadius: BorderRadius.circular(20)),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.network(product.image.toString(),
                                            width: double.infinity, height: double.infinity, fit: BoxFit.contain,
                                            errorBuilder: (_, __, ___) => Icon(Icons.image_not_supported_outlined,
                                                color: Colors.brown.shade300, size: 42)),
                                      ),
                                    ),
                                    Positioned(right: 16, top: 16,
                                        child: CircleAvatar(radius: 17, backgroundColor: Colors.white,
                                            child: Icon(Icons.favorite_border, color: mainText, size: 20))),
                                    Positioned(
                                      left: 16, top: 16,
                                      child: GestureDetector(
                                        onTap: () => _showRatingDialog(ctx, product),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                              color: Colors.black.withOpacity(0.40), borderRadius: BorderRadius.circular(12)),
                                          child: Row(children: [
                                            const Icon(Icons.star, color: Colors.orange, size: 14),
                                            const SizedBox(width: 3),
                                            Text(userRating > 0 ? "${userRating.toInt()}/5" : "4.8",
                                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                                          ]),
                                        ),
                                      ),
                                    ),
                                    Positioned(left: 16, bottom: 16,
                                        child: CircleAvatar(radius: 17,
                                            backgroundColor: Colors.black.withOpacity(0.35),
                                            child: const Icon(Icons.play_arrow, color: Colors.white, size: 21))),
                                  ]),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 8, 14, 4),
                                  child: Text(product.model.toString(), maxLines: 1, overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: mainText, fontSize: 15, fontWeight: FontWeight.bold)),
                                ),
                                Padding(
                                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                                  child: Row(children: [
                                    Expanded(child: Text("\$${product.price}",
                                        style: TextStyle(color: brownCol, fontSize: 20, fontWeight: FontWeight.bold))),
                                    GestureDetector(
                                      onTap: () => _showRatingDialog(ctx, product),
                                      child: Row(children: [
                                        Icon(userRating > 0 ? Icons.star_rounded : Icons.star_outline_rounded,
                                            color: Colors.orange, size: 17),
                                        const SizedBox(width: 3),
                                        Text(userRating > 0 ? "${userRating.toInt()}/5" : "4.8",
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ]),
                                    ),
                                  ]),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // ── Sound Mood Card ────────────────────────
  Widget _buildSoundMoodCard(Color surface, Color lightBrCol, Color mainText, Color brownCol) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xffeadcd1)),
      ),
      child: Row(children: [
        Container(width: 76, height: 76,
            decoration: BoxDecoration(color: lightBrCol, borderRadius: BorderRadius.circular(22)),
            child: Icon(Icons.graphic_eq, color: brownCol, size: 38)),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text("Sound Mood", style: TextStyle(color: mainText, fontSize: 20, fontWeight: FontWeight.bold, fontFamily: "serif")),
          const SizedBox(height: 5),
          Text("Discover instruments based on your mood and style.", maxLines: 2, overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.brown.shade400, fontSize: 14, height: 1.3)),
        ])),
        CircleAvatar(radius: 21, backgroundColor: _oliveBase.withOpacity(0.18),
            child: const Icon(Icons.arrow_forward, color: _oliveBase)),
      ]),
    );
  }

  // ── Dark Mode Toggle ───────────────────────
  Widget _buildDarkModeToggle(BuildContext ctx, bool isDark, Color surface, Color mainText, Color brownCol) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: BoxDecoration(
        color: surface.withOpacity(0.78),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xffeadcd1)),
      ),
      child: Row(children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: isDark ? const Color(0xff3a2010) : const Color(0xffeff0e4),
          child: Icon(isDark ? Icons.dark_mode : Icons.light_mode_outlined,
              color: isDark ? Colors.amber : _oliveBase, size: 26),
        ),
        const SizedBox(width: 14),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(isDark ? "Dark Mode" : "Light Mode",
              style: TextStyle(color: mainText, fontSize: 17, fontWeight: FontWeight.bold)),
          Text("Tap to switch theme", style: TextStyle(color: Colors.brown.shade400, fontSize: 13)),
        ])),
        Switch.adaptive(value: isDark, activeColor: brownCol, onChanged: (_) => _toggleDarkMode(ctx)),
      ]),
    );
  }

  // ── Bottom Nav ─────────────────────────────
  Widget _buildBottomNav(BuildContext ctx, bool isDark, Color surface, Color mainText, Color brownCol) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(24, 0, 24, 12),
        height: 62,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: surface.withOpacity(0.96),
          borderRadius: BorderRadius.circular(32),
          border: Border.all(color: const Color(0xffeadcd1)),
          boxShadow: [BoxShadow(color: Colors.brown.withOpacity(0.10), blurRadius: 18, offset: const Offset(0, 8))],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined,       "Home",     true,  mainText, () => _playTap()),
            _navItem(Icons.build_outlined,      "Services", false, mainText, () {
              _playTap();
              Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ServicesScreen()));
            }),
            _navItem(Icons.music_note_outlined, "Explore",  false, mainText, () => _playTap()),
            _navItem(Icons.person_outline,      "Profile",  false, mainText, () {
              _playTap();
              Navigator.push(ctx, MaterialPageRoute(builder: (_) => const ProfileScreen()));
            }),
          ],
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active, Color mainText, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: active ? const Color(0xffeff0e4) : Colors.transparent,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: active ? _oliveBase : Colors.brown.shade300, size: 21),
              const SizedBox(height: 2),
              Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: active ? mainText : Colors.brown.shade300, fontSize: 10, height: 1)),
            ],
          ),
        ),
      ),
    );
  }
}