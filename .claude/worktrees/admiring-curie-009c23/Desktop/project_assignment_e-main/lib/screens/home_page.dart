import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/locale_provider.dart';
import 'package:project_assignment_e/providers/notifications_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/providers/sound_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:project_assignment_e/screens/all_products_screen.dart';
import 'package:project_assignment_e/screens/cart_screen.dart';
import 'package:project_assignment_e/screens/details_screen.dart';
import 'package:project_assignment_e/screens/favorites_screen.dart';
import 'package:project_assignment_e/screens/notifications_screen.dart';
import 'package:project_assignment_e/screens/profile_screen.dart';
import 'package:project_assignment_e/screens/services_screen.dart';
import 'package:provider/provider.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';

// ──────────────────────────────────────────────────────────────────────────────
//  Colour Palette  (Raspberry × Plum × Wine × Mint × Gold)
// ──────────────────────────────────────────────────────────────────────────────
class _C {
  // Light mode surfaces
  static const bgLight      = Color(0xFFFAF0EE); // warm blush-cream
  static const surfaceL     = Color(0xFFFFFFFF);
  static const cardL        = Color(0xFFF0E5EB); // soft rose-blush
  // Dark mode surfaces
  static const bgDark       = Color(0xFF0D090A); // near-black
  static const surfaceD     = Color(0xFF1C0F16); // deep wine-black
  static const cardD        = Color(0xFF28141E); // dark plum card

  // Brand
  static const raspberry    = Color(0xFF912F56); // primary action
  static const rose         = Color(0xFFC4587E); // lighter hover
  static const plum         = Color(0xFF521945); // secondary
  static const wine         = Color(0xFF361F27); // dark border/text

  // Accents
  static const gold         = Color(0xFFD4A853); // price / premium
  static const sage         = Color(0xFF3D7A6A); // success / eco

  // Overlays
  static const Color dark45 = Color(0x73000000);
}

// ──────────────────────────────────────────────────────────────────────────────
//  HomeScreen
// ──────────────────────────────────────────────────────────────────────────────
class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  // ── Controllers ─────────────────────────────────────────
  final _searchCtrl   = TextEditingController();
  final _heroPageCtrl = PageController(viewportFraction: 1);
  Timer? _heroTimer;

  late final AnimationController _enterCtrl;
  late final AnimationController _pulseCtrl;
  late final AnimationController _notifCtrl;
  late final Animation<double>   _fadeAnim;
  late final Animation<Offset>   _slideAnim;

  // ── State ───────────────────────────────────────────────
  int    _heroIdx       = 0;
  String _selectedCat   = '';
  bool   _searchFocused = false;
  final Set<String> _addingToCart = {}; // product ids mid-animation

  // ── Hero data (English) ─────────────────────────────────
  static const _heroes = [
    {
      'tag'   : 'MUSIC EXPERIENCE',
      'title1': 'Find your\nperfect ',
      'title2': 'sound',
      'sub'   : 'Crafted instruments. Real soul.',
      'img'   : 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=900',
    },
    {
      'tag'   : 'PREMIUM COLLECTION',
      'title1': 'Feel the\nmagic of ',
      'title2': 'music',
      'sub'   : 'Choose instruments that match your mood.',
      'img'   : 'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=900',
    },
    {
      'tag'   : 'NEW ARRIVALS',
      'title1': 'Play your\nown ',
      'title2': 'story',
      'sub'   : 'Explore guitars, oud, piano & more.',
      'img'   : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=900',
    },
  ];

  // ── Hero data (Arabic) ──────────────────────────────────
  static const _heroesAr = [
    {
      'tag'   : 'تجربة موسيقية',
      'title1': 'اعثر على\n',
      'title2': 'صوتك المثالي',
      'sub'   : 'آلات مصنوعة بعناية. روح حقيقية.',
      'img'   : 'https://images.unsplash.com/photo-1510915361894-db8b60106cb1?w=900',
    },
    {
      'tag'   : 'مجموعة مميزة',
      'title1': 'أحسّ بسحر\n',
      'title2': 'الموسيقى',
      'sub'   : 'اختر آلات تناسب مزاجك وروحك.',
      'img'   : 'https://images.unsplash.com/photo-1520523839897-bd0b52f945a0?w=900',
    },
    {
      'tag'   : 'وصل حديثاً',
      'title1': 'العب\n',
      'title2': 'قصتك الخاصة',
      'sub'   : 'استكشف العود، الغيتار، البيانو والمزيد.',
      'img'   : 'https://images.unsplash.com/photo-1493225457124-a3eb161ffa5f?w=900',
    },
  ];

  // ── Category data ───────────────────────────────────────
  static const _categories = [
    {'emoji': '🪕', 'label': 'Oud',    'key': 'oud',    'color': 0xFFB8602A},
    {'emoji': '🎸', 'label': 'Guitar', 'key': 'guitar', 'color': 0xFF912F56},
    {'emoji': '🎹', 'label': 'Piano',  'key': 'piano',  'color': 0xFF521945},
    {'emoji': '🥁', 'label': 'Drums',  'key': 'drums',  'color': 0xFF2E6D5E},
    {'emoji': '🎧', 'label': 'Studio', 'key': 'studio', 'color': 0xFF1A3B6B},
  ];

  // ── Promo banners ───────────────────────────────────────
  static const _promos = [
    {'label': '10% OFF', 'sub': 'On all Ouds this week', 'icon': '🪕', 'grad': [0xFFB8602A, 0xFF7A3A10]},
    {'label': 'FREE Shipping', 'sub': 'Orders over 200 JOD', 'icon': '🚚', 'grad': [0xFF2E6D5E, 0xFF1A4A3E]},
    {'label': 'NEW Arrivals', 'sub': 'Studio gear just landed', 'icon': '🎧', 'grad': [0xFF521945, 0xFF2D0E28]},
  ];

  // ── Lifecycle ───────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    context.read<ProductProvider>().getProducts();

    _enterCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900),
        lowerBound: 0.93, upperBound: 1.07)
      ..repeat(reverse: true);
    _notifCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 700),
        lowerBound: 0.85, upperBound: 1.0)
      ..repeat(reverse: true);

    _fadeAnim  = CurvedAnimation(parent: _enterCtrl, curve: Curves.easeIn);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _enterCtrl, curve: Curves.easeOutCubic));

    _enterCtrl.forward();
    _heroTimer = Timer.periodic(const Duration(seconds: 4), (_) => _advanceHero());
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _heroPageCtrl.dispose();
    _enterCtrl.dispose();
    _pulseCtrl.dispose();
    _notifCtrl.dispose();
    _heroTimer?.cancel();
    super.dispose();
  }

  // ── Helpers ─────────────────────────────────────────────
  void _advanceHero() {
    if (!_heroPageCtrl.hasClients) return;
    final next = (_heroIdx + 1) % _heroes.length;
    _heroPageCtrl.animateToPage(next,
        duration: const Duration(milliseconds: 700), curve: Curves.easeInOutCubic);
  }

  void _tap()     => HapticFeedback.lightImpact();
  void _success() => HapticFeedback.mediumImpact();

  void _soundTap()     => context.read<SoundProvider>().play(SoundType.click);
  void _soundSuccess() => context.read<SoundProvider>().play(SoundType.cart);

  void _filterBy(String key) {
    _tap();
    setState(() {
      if (_selectedCat == key) {
        _selectedCat = '';
        context.read<ProductProvider>().clearFilter();
      } else {
        _selectedCat = key;
        context.read<ProductProvider>().filterByCate(key);
      }
    });
  }

  Future<void> _addToCart(dynamic product) async {
    _success();
    _soundSuccess();
    setState(() => _addingToCart.add(product.id.toString()));
    context.read<CartProvider>().itemAddToCart(product);
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) setState(() => _addingToCart.remove(product.id.toString()));
  }

  // ── Rating dialog ────────────────────────────────────────
  void _ratingDialog(dynamic product) {
    final prov = context.read<ProductProvider>();
    final l    = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    double tmp  = prov.getRating(product.id);
    final isDark = context.read<ThemeProvider>().isDark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: isDark ? _C.surfaceD : _C.surfaceL,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            // Drag handle
            Container(width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                )),
            const SizedBox(height: 20),
            Text(l.t('rateProduct'),
                style: TextStyle(
                  color: isDark ? Colors.white : _C.wine,
                  fontSize: 20, fontWeight: FontWeight.bold,
                )),
            const SizedBox(height: 6),
            Text(product.displayModel(lang),
                style: const TextStyle(color: _C.raspberry, fontSize: 15)),
            const SizedBox(height: 24),
            // Stars
            Row(mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) => GestureDetector(
                onTap: () { setS(() => tmp = (i + 1).toDouble()); _tap(); },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 5),
                  child: AnimatedScale(
                    scale: i < tmp ? 1.15 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      i < tmp ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: _C.gold,
                      size: i < tmp ? 44 : 36,
                    ),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 12),
            Text(
              tmp == 0 ? l.t('tapToRate') : '${tmp.toInt()} / 5',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: _C.raspberry),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l.t('cancel'), style: const TextStyle(color: _C.raspberry)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: tmp == 0 ? null : () {
                    prov.setRating(product.id, tmp);
                    _success();
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      backgroundColor: _C.sage,
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      content: Row(children: [
                        const Icon(Icons.star_rounded, color: Colors.white, size: 18),
                        const SizedBox(width: 8),
                        Text('Rated ${tmp.toInt()} stars — thank you!',
                            style: const TextStyle(color: Colors.white)),
                      ]),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _C.raspberry,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: Text(l.t('submit'), style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  //  BUILD
  // ──────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final isDark       = context.watch<ThemeProvider>().isDark;
    final cartCount    = context.watch<CartProvider>().itemCount;
    final api          = context.watch<ProductProvider>().apidatastatus;
    final notifCount   = context.watch<NotificationsProvider>().unreadCount;
    final isArabic     = context.watch<LocaleProvider>().isArabic;
    final soundEnabled = context.watch<SoundProvider>().isEnabled;
    final lang         = isArabic ? 'ar' : 'en';
    final isRTL        = isArabic;
    final heroData     = isArabic ? _heroesAr : _heroes;
    final l            = AppLocalizations.of(context);

    final bg      = isDark ? _C.bgDark    : _C.bgLight;
    final surface = isDark ? _C.surfaceD  : _C.surfaceL;
    final card    = isDark ? _C.cardD     : _C.cardL;
    final text    = isDark ? Colors.white : _C.wine;
    final subText = isDark ? Colors.white60 : Colors.grey.shade600;

    return Scaffold(
      backgroundColor: bg,
      extendBody: true,
      bottomNavigationBar: _BottomNav(
        cartCount: cartCount,
        isDark: isDark,
        surface: surface,
        text: text,
        onServices: () {
          _soundTap();
          Navigator.push(context, _slide(
            Scaffold(body: SafeArea(child: const ServicesScreen())),
          ));
        },
        onCart: () {
          _soundTap();
          Navigator.push(context, _slide(const CartPage()));
        },
        onProfile: () {
          _soundTap();
          Navigator.push(context, _slide(const ProfileScreen()));
        },
        onFavorites: () {
          _soundTap();
          Navigator.push(context, _slide(const FavoritesScreen()));
        },
      ),
      body: SafeArea(
        bottom: false,
        child: FadeTransition(
          opacity: _fadeAnim,
          child: SlideTransition(
            position: _slideAnim,
            child: CustomScrollView(
              slivers: [
                // ─────────────────────────────────────────────
                //  1. HEADER
                // ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                    child: Row(children: [
                      // Logo
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          RichText(text: TextSpan(children: [
                            TextSpan(text: 'MOSI',
                                style: TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                            const TextSpan(text: 'Q',
                                style: TextStyle(color: _C.raspberry, fontSize: 32, fontWeight: FontWeight.w800)),
                            TextSpan(text: 'ATI',
                                style: TextStyle(color: text, fontSize: 32, fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                          ])),
                          Text(l.t('tagline'),
                              style: TextStyle(color: subText, fontSize: 13)),
                        ]),
                      ),
                      // ── Top action buttons ────────────────────────
                      // Language toggle (AR / EN)
                      _TopBtn(
                        bg: card,
                        onTap: () {
                          context.read<SoundProvider>().play(SoundType.language);
                          context.read<LocaleProvider>().setLocale(
                            isArabic ? const Locale('en') : const Locale('ar'),
                          );
                        },
                        child: Text(
                          isArabic ? 'EN' : 'AR',
                          style: const TextStyle(
                            color: _C.raspberry,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Theme toggle
                      _TopBtn(
                        bg: card,
                        onTap: () {
                          context.read<SoundProvider>().play(SoundType.theme);
                          context.read<ThemeProvider>().toggle();
                        },
                        child: Icon(
                          isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                          color: isDark ? Colors.amber : _C.plum,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Sound toggle
                      _TopBtn(
                        bg: card,
                        onTap: () => context.read<SoundProvider>().toggle(),
                        child: Icon(
                          soundEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                          color: soundEnabled ? _C.raspberry : Colors.grey,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 6),

                      // Notifications bell
                      GestureDetector(
                        onTap: () {
                          context.read<SoundProvider>().play(SoundType.navigation);
                          Navigator.push(context, _slide(const NotificationsScreen()));
                        },
                        child: Stack(clipBehavior: Clip.none, children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: card,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: notifCount > 0
                                    ? _C.raspberry.withValues(alpha: 0.4)
                                    : Colors.transparent,
                              ),
                            ),
                            child: AnimatedBuilder(
                              animation: _notifCtrl,
                              builder: (_, child) => Transform.rotate(
                                angle: notifCount > 0
                                    ? (_notifCtrl.value - 0.92) * 0.6
                                    : 0,
                                child: child,
                              ),
                              child: Icon(
                                Icons.notifications_outlined,
                                color: notifCount > 0 ? _C.raspberry : text,
                                size: 22,
                              ),
                            ),
                          ),
                          if (notifCount > 0)
                            Positioned(
                              right: -2, top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: _C.raspberry,
                                  shape: BoxShape.circle,
                                ),
                                child: Text('$notifCount',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold)),
                              ),
                            ),
                        ]),
                      ),
                      const SizedBox(width: 8),

                      // Profile avatar
                      GestureDetector(
                        onTap: () {
                          context.read<SoundProvider>().play(SoundType.navigation);
                          Navigator.push(context, _slide(const ProfileScreen()));
                        },
                        child: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [_C.raspberry, _C.plum],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: _C.raspberry.withValues(alpha: 0.35),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(Icons.person_outline,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ]),
                  ),
                ),

                // ─────────────────────────────────────────────
                //  2. HERO CAROUSEL
                // ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Column(mainAxisSize: MainAxisSize.min, children: [
                      SizedBox(
                        height: 185,
                        child: PageView.builder(
                          controller: _heroPageCtrl,
                          itemCount: heroData.length,
                          onPageChanged: (i) => setState(() => _heroIdx = i),
                          itemBuilder: (ctx, i) => _HeroCard(
                            item: heroData[i],
                            isActive: _heroIdx == i,
                            isRTL: isRTL,
                            bg: bg,
                            card: card,
                            text: text,
                            pulseCtrl: _pulseCtrl,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Dot indicators
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        ...List.generate(heroData.length, (i) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          width: _heroIdx == i ? 24 : 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: _heroIdx == i ? _C.raspberry : _C.raspberry.withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(20),
                          ),
                        )),
                      ]),
                    ]),
                  ),
                ),

                // ─────────────────────────────────────────────
                //  3. PROMO BANNERS
                // ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 0, 0),
                    child: SizedBox(
                      height: 80,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _promos.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 12),
                        itemBuilder: (_, i) {
                          final p = _promos[i];
                          final colors = (p['grad'] as List<int>)
                              .map((c) => Color(c))
                              .toList();
                          return GestureDetector(
                            onTap: _tap,
                            child: Container(
                              width: 200,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 12),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: colors,
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Row(children: [
                                Text(p['icon'] as String,
                                    style: const TextStyle(fontSize: 26)),
                                const SizedBox(width: 10),
                                Expanded(child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(p['label'] as String,
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 13)),
                                    Text(p['sub'] as String,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 11)),
                                  ],
                                )),
                              ]),
                            ),
                          );
                        },
                        padding: const EdgeInsets.only(right: 20),
                      ),
                    ),
                  ),
                ),

                // ─────────────────────────────────────────────
                //  4. SEARCH BAR
                // ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                    child: Focus(
                      onFocusChange: (f) => setState(() => _searchFocused = f),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        height: 54,
                        decoration: BoxDecoration(
                          color: surface,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                            color: _searchFocused
                                ? _C.raspberry
                                : _C.raspberry.withValues(alpha: 0.2),
                            width: _searchFocused ? 1.5 : 1,
                          ),
                          boxShadow: _searchFocused
                              ? [BoxShadow(
                              color: _C.raspberry.withValues(alpha: 0.15),
                              blurRadius: 12)]
                              : [],
                        ),
                        child: TextField(
                          controller: _searchCtrl,
                          onChanged: (v) {
                            context.read<ProductProvider>().searchByModel(v.trim());
                            setState(() {});
                          },
                          style: TextStyle(color: text, fontSize: 15),
                          decoration: InputDecoration(
                            hintText: l.t('search'),
                            hintStyle: TextStyle(
                                color: text.withValues(alpha: 0.4), fontSize: 15),
                            prefixIcon: Icon(Icons.search_rounded,
                                color: _searchFocused ? _C.raspberry : text.withValues(alpha: 0.5)),
                            suffixIcon: _searchCtrl.text.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  color: _C.raspberry),
                              onPressed: () {
                                _searchCtrl.clear();
                                context.read<ProductProvider>().clearFilter();
                                setState(() {});
                              },
                            )
                                : Icon(Icons.tune_rounded,
                                color: text.withValues(alpha: 0.4)),
                            border: InputBorder.none,
                            contentPadding:
                            const EdgeInsets.only(top: 15),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // ─────────────────────────────────────────────
                //  5. CATEGORIES
                // ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 0),
                    child: _SectionHeader(
                      title: l.t('byCategory'),
                      action: l.t('viewAll'),
                      text: text,
                      onAction: () => Navigator.push(context, _slide(const AllProductsScreen())),
                    ),
                  ),
                ),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 14, 0, 0),
                    child: SizedBox(
                      height: 96,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: _categories.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 10),
                        padding: const EdgeInsets.only(right: 20),
                        itemBuilder: (_, i) {
                          final cat    = _categories[i];
                          final catKey = cat['key'] as String;
                          final active = _selectedCat == catKey;
                          final color  = Color(cat['color'] as int);
                          return GestureDetector(
                            onTap: () => _filterBy(catKey),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeOutBack,
                              width: 82,
                              decoration: BoxDecoration(
                                color: active
                                    ? color
                                    : color.withValues(alpha: isDark ? 0.15 : 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: active
                                      ? color
                                      : color.withValues(alpha: 0.3),
                                  width: active ? 2 : 1,
                                ),
                                boxShadow: active
                                    ? [BoxShadow(
                                    color: color.withValues(alpha: 0.4),
                                    blurRadius: 10,
                                    offset: const Offset(0, 4))]
                                    : [],
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(cat['emoji'] as String,
                                      style: const TextStyle(fontSize: 28)),
                                  const SizedBox(height: 5),
                                  Text(l.t(catKey),
                                      style: TextStyle(
                                        color: active
                                            ? Colors.white
                                            : (isDark ? Colors.white70 : _C.wine),
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      )),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // ─────────────────────────────────────────────
                //  6. PRODUCTS
                // ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: _SectionHeader(
                      title: l.t('mostPopular'),
                      action: l.t('seeAll'),
                      text: text,
                      onAction: () => Navigator.push(context, _slide(const AllProductsScreen())),
                    ),
                  ),
                ),

                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: _buildProducts(api, surface, card, text, subText, isDark, lang),
                  ),
                ),

                // ─────────────────────────────────────────────
                //  7. SOUND MOOD CARD
                // ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                    child: GestureDetector(
                      onTap: () {
                        _tap();
                        Navigator.push(context, _slide(
                          Scaffold(body: SafeArea(child: const ServicesScreen())),
                        ));
                      },
                      child: Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [_C.plum, _C.raspberry],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(color: _C.raspberry.withValues(alpha: 0.35),
                                blurRadius: 16, offset: const Offset(0, 6)),
                          ],
                        ),
                        child: Row(children: [
                          Container(
                            width: 70, height: 70,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: const Icon(Icons.music_note_rounded,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(width: 16),
                          Expanded(child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(l.t('ourServices'),
                                  style: const TextStyle(color: Colors.white,
                                      fontSize: 20, fontWeight: FontWeight.bold)),
                              const SizedBox(height: 5),
                              Text(l.t('servicesSubtitle'),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(color: Colors.white70, fontSize: 13)),
                            ],
                          )),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(isRTL ? Icons.arrow_back_rounded : Icons.arrow_forward_rounded,
                                color: Colors.white, size: 20),
                          ),
                        ]),
                      ),
                    ),
                  ),
                ),

                // Bottom padding for floating nav
                const SliverToBoxAdapter(
                  child: SizedBox(height: 110),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Products section ─────────────────────────────────────
  Widget _buildProducts(ApiStatus api, Color surface, Color card, Color text,
      Color subText, bool isDark, String lang) {
    if (api == ApiStatus.loading) {
      return SizedBox(
        height: 280,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20, right: 20),
          itemCount: 4,
          itemBuilder: (_, __) => _SkeletonCard(card: card),
        ),
      );
    }

    if (api == ApiStatus.error) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Container(
          height: 100,
          alignment: Alignment.center,
          child: Text('Could not load products. Please try again.',
              style: TextStyle(color: subText), textAlign: TextAlign.center),
        ),
      );
    }

    return Consumer<ProductProvider>(builder: (ctx, prov, __) {
      final products = prov.productList;
      if (products.isEmpty) {
        return SizedBox(
          height: 120,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.music_off_rounded,
                color: _C.raspberry.withValues(alpha: 0.4), size: 40),
            const SizedBox(height: 8),
            Text('No products found',
                style: TextStyle(color: subText)),
          ]),
        );
      }

      return SizedBox(
        height: 295,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.only(left: 20, right: 20),
          itemCount: products.length,
          itemBuilder: (ctx, i) {
            final product   = products[i];
            final isFav     = prov.isFavorite(product.id);
            final rating    = prov.getRating(product.id);
            final isAdding  = _addingToCart.contains(product.id.toString());
            final isNew     = ['07','08','09','10'].contains(product.id);
            final hasVideo  = product.videoUrl != null;

            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: Duration(milliseconds: 400 + i * 90),
              curve: Curves.easeOutBack,
              builder: (_, val, child) =>
                  Opacity(opacity: val.clamp(0, 1),
                      child: Transform.scale(scale: 0.85 + val * 0.15,
                          child: child)),
              child: Padding(
                padding: const EdgeInsets.only(right: 14),
                child: GestureDetector(
                  onTap: () {
                    _tap();
                    Navigator.push(ctx, _slide(ProductDetailScreen(
                      result: product,
                      backColor: Color(
                        _categories.firstWhere(
                              (c) => c['key'] == product.category,
                          orElse: () => {'color': 0xFF912F56},
                        )['color'] as int,
                      ),
                      heroTag: 'home_${product.id}_$i',
                    )));
                  },
                  child: _ProductCard(
                    product: product,
                    surface: surface,
                    card: card,
                    text: text,
                    subText: subText,
                    isFav: isFav,
                    rating: rating,
                    isAdding: isAdding,
                    isNew: isNew,
                    hasVideo: hasVideo,
                    lang: lang,
                    onFav: () {
                      context.read<SoundProvider>().play(SoundType.favorite);
                      context.read<ProductProvider>().toggleFavorite(product.id);
                    },
                    onAddToCart: () => _addToCart(product),
                    onRate: () => _ratingDialog(product),
                  ),
                ),
              ),
            );
          },
        ),
      );
    });
  }

  // ── Page route helper ────────────────────────────────────
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
}

// ──────────────────────────────────────────────────────────────────────────────
//  Hero Card
// ──────────────────────────────────────────────────────────────────────────────
class _HeroCard extends StatelessWidget {
  final Map<String, String> item;
  final bool isActive;
  final bool isRTL;
  final Color bg, card, text;
  final AnimationController pulseCtrl;

  const _HeroCard({
    required this.item,
    required this.isActive,
    required this.isRTL,
    required this.bg,
    required this.card,
    required this.text,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    // Gradient flows from text side → image side
    final gradBegin = isRTL ? Alignment.centerRight : Alignment.centerLeft;
    final gradEnd   = isRTL ? Alignment.centerLeft  : Alignment.centerRight;

    return AnimatedScale(
      scale: isActive ? 1.0 : 0.94,
      duration: const Duration(milliseconds: 400),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _C.raspberry.withValues(alpha: 0.2)),
          gradient: LinearGradient(
            colors: [bg, _C.wine.withValues(alpha: 0.08)],
          ),
          boxShadow: [
            BoxShadow(color: _C.raspberry.withValues(alpha: 0.12),
                blurRadius: 20, offset: const Offset(0, 8)),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(children: [
            // Background image — opposite side to text
            Positioned(
              right: isRTL ? null : -20,
              left:  isRTL ? -20  : null,
              bottom: 0, top: 0,
              child: Image.network(
                item['img']!,
                width: 250,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Icon(Icons.music_note, size: 80,
                        color: _C.raspberry.withValues(alpha: 0.3)),
              ),
            ),
            // Gradient overlay — fades from text side to transparent
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [bg, bg.withValues(alpha: 0.7), Colors.transparent],
                  begin: gradBegin,
                  end: gradEnd,
                  stops: const [0.0, 0.55, 1.0],
                ),
              ),
            ),
            // Content — CrossAxisAlignment.start is direction-aware
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tag chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _C.raspberry.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: _C.raspberry.withValues(alpha: 0.3)),
                    ),
                    child: Text(item['tag']!,
                        style: const TextStyle(
                            color: _C.raspberry,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 0.8)),
                  ),
                  const SizedBox(height: 14),
                  // Title
                  RichText(
                    textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    text: TextSpan(children: [
                      TextSpan(text: item['title1']!,
                          style: TextStyle(color: text, fontSize: 24,
                              height: 1.1, fontWeight: FontWeight.w800)),
                      TextSpan(text: item['title2']!,
                          style: const TextStyle(color: _C.raspberry,
                              fontSize: 24, height: 1.1, fontWeight: FontWeight.w800)),
                    ]),
                  ),
                  const SizedBox(height: 8),
                  Text(item['sub']!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          color: text.withValues(alpha: 0.55), fontSize: 13)),
                ],
              ),
            ),
            // Pulse play button — on the image side
            Positioned(
              right: isRTL ? null : 20,
              left:  isRTL ? 20   : null,
              bottom: 20,
              child: ScaleTransition(
                scale: pulseCtrl,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [_C.raspberry, _C.plum],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: _C.raspberry.withValues(alpha: 0.5),
                          blurRadius: 12, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: const Icon(Icons.play_arrow_rounded,
                      color: Colors.white, size: 28),
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Product Card
// ──────────────────────────────────────────────────────────────────────────────
class _ProductCard extends StatelessWidget {
  final dynamic product;
  final Color surface, card, text, subText;
  final bool isFav, isAdding, isNew, hasVideo;
  final double rating;
  final String lang;
  final VoidCallback onFav, onAddToCart, onRate;

  const _ProductCard({
    required this.product, required this.surface, required this.card,
    required this.text, required this.subText, required this.isFav,
    required this.rating, required this.isAdding, required this.isNew,
    required this.hasVideo, required this.lang,
    required this.onFav, required this.onAddToCart, required this.onRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 185,
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: _C.raspberry.withValues(alpha: 0.15)),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.07),
              blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Image area ───────────────────────────────────
        Expanded(
          child: Stack(children: [
            // Background + image
            Container(
              margin: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: card,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Image.network(
                  product.image?.toString() ?? '',
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => Center(
                    child: Icon(Icons.music_note_rounded,
                        color: _C.raspberry.withValues(alpha: 0.3), size: 40),
                  ),
                ),
              ),
            ),

            // NEW badge
            if (isNew)
              Positioned(left: 16, top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.sage,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Text('NEW',
                      style: TextStyle(color: Colors.white,
                          fontSize: 10, fontWeight: FontWeight.bold,
                          letterSpacing: 0.5)),
                ),
              ),

            // Video badge
            if (hasVideo && !isNew)
              Positioned(left: 16, top: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.shade700,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(Icons.play_circle_filled,
                        color: Colors.white, size: 12),
                    SizedBox(width: 3),
                    Text('VIDEO',
                        style: TextStyle(color: Colors.white, fontSize: 9,
                            fontWeight: FontWeight.bold)),
                  ]),
                ),
              ),

            // Favorite button
            Positioned(right: 16, top: 16,
              child: GestureDetector(
                onTap: onFav,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: isFav
                        ? _C.raspberry.withValues(alpha: 0.15)
                        : Colors.white.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 6),
                    ],
                  ),
                  child: AnimatedScale(
                    scale: isFav ? 1.2 : 1.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      color: isFav ? _C.raspberry : Colors.grey.shade400,
                      size: 18,
                    ),
                  ),
                ),
              ),
            ),

            // Rating badge (tappable)
            Positioned(left: 16, bottom: 16,
              child: GestureDetector(
                onTap: onRate,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _C.dark45,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(rating > 0
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                        color: _C.gold, size: 14),
                    const SizedBox(width: 3),
                    Text(
                      rating > 0 ? '${rating.toInt()}/5' : 'Rate',
                      style: const TextStyle(
                          color: Colors.white, fontSize: 11,
                          fontWeight: FontWeight.w600),
                    ),
                  ]),
                ),
              ),
            ),
          ]),
        ),

        // ── Info area ─────────────────────────────────────
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(product.displayModel(lang),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: text,
                    fontSize: 14,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 2),
            Text(product.displayBrand(lang),
                style: TextStyle(color: subText, fontSize: 11)),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: Text('JOD ${product.price?.toStringAsFixed(0) ?? ''}',
                    style: const TextStyle(
                        color: _C.gold,
                        fontSize: 17,
                        fontWeight: FontWeight.w800)),
              ),
              // Quick Add to Cart
              GestureDetector(
                onTap: onAddToCart,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    color: isAdding ? _C.sage : _C.raspberry,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (isAdding ? _C.sage : _C.raspberry)
                            .withValues(alpha: 0.4),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      isAdding
                          ? Icons.check_rounded
                          : Icons.add_rounded,
                      key: ValueKey(isAdding),
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ]),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Skeleton Card (loading placeholder)
// ──────────────────────────────────────────────────────────────────────────────
class _SkeletonCard extends StatefulWidget {
  final Color card;
  const _SkeletonCard({required this.card});

  @override
  State<_SkeletonCard> createState() => _SkeletonCardState();
}

class _SkeletonCardState extends State<_SkeletonCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, __) => Opacity(
        opacity: 0.4 + _anim.value * 0.4,
        child: Container(
          width: 185,
          margin: const EdgeInsets.only(right: 14),
          decoration: BoxDecoration(
            color: widget.card,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(children: [
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(18),
                ),
              ),
            ),
            for (var h in [14.0, 12.0, 18.0])
              Container(
                margin: EdgeInsets.fromLTRB(12, h == 14 ? 8 : 4, 12, h == 18 ? 12 : 0),
                height: h,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
          ]),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Top icon button helper
// ──────────────────────────────────────────────────────────────────────────────
class _TopBtn extends StatelessWidget {
  final Color bg;
  final VoidCallback onTap;
  final Widget child;

  const _TopBtn({required this.bg, required this.onTap, required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: bg,
          shape: BoxShape.circle,
          border: Border.all(color: _C.raspberry.withValues(alpha: 0.25)),
        ),
        child: child,
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Section Header
// ──────────────────────────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final String title, action;
  final Color text;
  final VoidCallback? onAction;

  const _SectionHeader({
    required this.title,
    required this.action,
    required this.text,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Expanded(
        child: Text(title,
            style: TextStyle(color: text, fontSize: 22,
                fontWeight: FontWeight.bold)),
      ),
      GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          onAction?.call();
        },
        child: Row(children: [
          Text(action, style: const TextStyle(color: _C.rose, fontSize: 14)),
          const SizedBox(width: 4),
          const Icon(Icons.arrow_forward_rounded, color: _C.rose, size: 18),
        ]),
      ),
    ]);
  }
}

// ──────────────────────────────────────────────────────────────────────────────
//  Floating Bottom Navigation Bar
// ──────────────────────────────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final int cartCount;
  final bool isDark;
  final Color surface, text;
  final VoidCallback onServices, onCart, onProfile, onFavorites;

  const _BottomNav({
    required this.cartCount, required this.isDark,
    required this.surface, required this.text,
    required this.onServices, required this.onCart,
    required this.onProfile, required this.onFavorites,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 14),
        height: 65,
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? _C.surfaceD : Colors.white,
          borderRadius: BorderRadius.circular(36),
          border: Border.all(color: _C.raspberry.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.12),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Builder(builder: (ctx) {
          final l = AppLocalizations.of(ctx);
          return Row(children: [
            _NavItem(icon: Icons.home_rounded,
                label: l.t('home'),      active: true,  text: text, onTap: () {}),
            _NavItem(icon: Icons.favorite_rounded,
                label: l.t('favorites'), active: false, text: text, onTap: onFavorites),
            _NavItemCart(count: cartCount, text: text, onTap: onCart),
            _NavItem(icon: Icons.build_rounded,
                label: l.t('services'),  active: false, text: text, onTap: onServices),
            _NavItem(icon: Icons.person_rounded,
                label: l.t('profile'),   active: false, text: text, onTap: onProfile),
          ]);
        }),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool active;
  final Color text;
  final VoidCallback onTap;

  const _NavItem({required this.icon, required this.label,
    required this.active, required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: active ? _C.raspberry.withValues(alpha: 0.1) : Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon,
                color: active ? _C.raspberry : text.withValues(alpha: 0.4),
                size: 22),
            const SizedBox(height: 3),
            Text(label, maxLines: 1,
                style: TextStyle(
                    color: active ? _C.raspberry : text.withValues(alpha: 0.4),
                    fontSize: 10, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}

class _NavItemCart extends StatelessWidget {
  final int count;
  final Color text;
  final VoidCallback onTap;

  const _NavItemCart({required this.count, required this.text,
    required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(28),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Stack(clipBehavior: Clip.none, children: [
              Icon(Icons.shopping_bag_rounded,
                  color: text.withValues(alpha: 0.4), size: 22),
              if (count > 0)
                Positioned(right: -6, top: -6,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                        color: _C.raspberry, shape: BoxShape.circle),
                    child: Text('$count',
                        style: const TextStyle(color: Colors.white,
                            fontSize: 9, fontWeight: FontWeight.bold)),
                  ),
                ),
            ]),
            const SizedBox(height: 3),
            Text(AppLocalizations.of(context).t('cart'), maxLines: 1,
                style: TextStyle(
                    color: text.withValues(alpha: 0.4),
                    fontSize: 10, fontWeight: FontWeight.w600)),
          ]),
        ),
      ),
    );
  }
}
