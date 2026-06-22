import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/models/app_user.dart';
import 'package:project_assignment_e/providers/auth_provider.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/font_size_provider.dart';
import 'package:project_assignment_e/providers/locale_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/providers/sound_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:project_assignment_e/screens/auth/login_screen.dart';
import 'package:project_assignment_e/screens/edit_profile_screen.dart';
import 'package:project_assignment_e/screens/favorites_screen.dart';
import 'package:project_assignment_e/screens/orders/my_orders_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─── Colour aliases (matches home_page.dart palette) ─────────────────────────
class _C {
  static const raspberry = Color(0xFF912F56);
  static const rose      = Color(0xFFC4587E);
  static const plum      = Color(0xFF521945);
  static const wine      = Color(0xFF361F27);
  static const bgDark    = Color(0xFF0D090A);
  static const gold      = Color(0xFFD4A853);
  static const sage      = Color(0xFF3D7A6A);
  static const bgLight   = Color(0xFFFAF0EE);
  static const cardD     = Color(0xFF28141E);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset>  _slideAnim;

  // ── Local profile image (Option A — stored in SharedPreferences) ──────────
  String? _localImagePath;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
    _fadeAnim  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.12),
      end:   Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));

    // Load persisted image after first frame (context available then)
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _loadLocalImage());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // ── Load image path from SharedPreferences ────────────────────────────────
  Future<void> _loadLocalImage() async {
    final auth = context.read<AppAuthProvider>();
    if (!auth.isLoggedIn || auth.user == null) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      final path  = prefs.getString('profile_image_${auth.user!.uid}');
      if (path != null && File(path).existsSync()) {
        if (mounted) setState(() => _localImagePath = path);
      }
    } catch (_) {}
  }

  // ── Pick image from gallery ───────────────────────────────────────────────
  Future<void> _pickImage(String uid) async {
    try {
      final picker = ImagePicker();
      final picked = await picker.pickImage(
        source:       ImageSource.gallery,
        imageQuality: 80,
        maxWidth:     512,
      );
      if (picked == null) return;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('profile_image_$uid', picked.path);
      if (mounted) setState(() => _localImagePath = picked.path);
    } catch (_) {
      // Permissions denied or picker cancelled — fail silently.
    }
  }

  @override
  Widget build(BuildContext context) {
    final l             = AppLocalizations.of(context);
    final auth          = context.watch<AppAuthProvider>();
    final isDark        = context.watch<ThemeProvider>().isDark;
    final favCount      = context.watch<ProductProvider>().favorites.length;
    final cartCount     = context.watch<CartProvider>().itemCount;
    final localeProvider   = context.watch<LocaleProvider>();
    final soundProvider    = context.watch<SoundProvider>();
    final fontSizeProvider = context.watch<FontSizeProvider>();

    final bg     = isDark ? _C.bgDark    : _C.bgLight;
    final cardBg = isDark ? _C.cardD     : Colors.white;
    final onCard = isDark ? Colors.white : _C.wine;

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [

              // ── Collapsible header ────────────────────────────────────
              SliverAppBar(
                expandedHeight: 330,
                pinned: true,
                backgroundColor: _C.plum,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded,
                      color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                // Only show edit button for logged-in users (not guests)
                actions: auth.isLoggedIn
                    ? [
                        IconButton(
                          icon: const Icon(Icons.edit_rounded, color: Colors.white),
                          tooltip: l.t('editProfile'),
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => const EditProfileScreen(),
                              ),
                            );
                          },
                        ),
                      ]
                    : [],
                flexibleSpace: FlexibleSpaceBar(
                  collapseMode: CollapseMode.parallax,
                  background: _ProfileHeader(
                    l: l,
                    favCount: favCount,
                    cartCount: cartCount,
                    appUser: auth.user,
                    isGuest: auth.isGuest,
                    localImagePath: _localImagePath,
                    onEditPhoto: auth.isLoggedIn
                        ? () => _pickImage(auth.user!.uid)
                        : null,
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      // ── Achievements (hidden for guests) ─────────────
                      if (auth.isLoggedIn) ...[
                        _SectionTitle(l.t('achievements'), onCard),
                        const SizedBox(height: 12),
                        _AchievementsRow(
                          l: l,
                          cardBg: cardBg,
                          isDark: isDark,
                          favCount: favCount,
                          cartCount: cartCount,
                        ),
                        const SizedBox(height: 24),
                      ],

                      // ── Quick links ─────────────────────────────────
                      _SectionTitle(l.t('quickLinks'), onCard),
                      const SizedBox(height: 12),
                      _QuickLinks(
                        l: l,
                        cardBg: cardBg,
                        isDark: isDark,
                        localeProvider: localeProvider,
                        themeProvider: context.read<ThemeProvider>(),
                        soundProvider: soundProvider,
                        fontSizeProvider: fontSizeProvider,
                        auth: auth,
                      ),
                      const SizedBox(height: 24),

                      // ── Stats card ──────────────────────────────────
                      _StatsCard(
                        l: l,
                        favCount: favCount,
                        cartCount: cartCount,
                        cardBg: cardBg,
                        isDark: isDark,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}

// ─── Profile Header ───────────────────────────────────────────────────────────
class _ProfileHeader extends StatelessWidget {
  final AppLocalizations l;
  final int favCount;
  final int cartCount;
  final AppUser? appUser;
  final bool isGuest;
  final String? localImagePath;
  final VoidCallback? onEditPhoto;

  const _ProfileHeader({
    required this.l,
    required this.favCount,
    required this.cartCount,
    required this.appUser,
    required this.isGuest,
    this.localImagePath,
    this.onEditPhoto,
  });

  @override
  Widget build(BuildContext context) {
    final displayName = appUser?.name.isNotEmpty == true
        ? appUser!.name
        : (isGuest ? l.t('guestUser') : l.t('userName'));

    final roleLabel = appUser == null
        ? l.t('guestUserSub')
        : (appUser!.isAdmin ? l.t('roleAdmin') : l.t('roleCustomer'));

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [_C.wine, _C.plum, _C.raspberry],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 12),

            // Avatar ring + optional camera edit overlay
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [_C.gold, _C.rose],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: _C.raspberry.withValues(alpha: 0.5),
                        blurRadius: 20,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 44,
                    backgroundColor: _C.wine,
                    child: ClipOval(
                      child: _buildAvatarContent(),
                    ),
                  ),
                ),
                // Camera edit button — shown only for logged-in users
                if (onEditPhoto != null)
                  Positioned(
                    right: 0,
                    bottom: 2,
                    child: GestureDetector(
                      onTap: onEditPhoto,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _C.raspberry,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 4),

            // Email (logged-in) / guest sub-label
            if (appUser?.email.isNotEmpty == true) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  appUser!.email,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white60, fontSize: 12),
                ),
              ),
              const SizedBox(height: 6),
            ],

            // Role badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: isGuest
                    ? Colors.white.withValues(alpha: 0.12)
                    : _C.gold.withValues(alpha: 0.25),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isGuest
                      ? Colors.white.withValues(alpha: 0.3)
                      : _C.gold.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGuest
                        ? Icons.person_outline_rounded
                        : (appUser?.isAdmin == true
                            ? Icons.admin_panel_settings_rounded
                            : Icons.verified_user_rounded),
                    size: 12,
                    color: isGuest ? Colors.white60 : _C.gold,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    roleLabel,
                    style: TextStyle(
                      color: isGuest ? Colors.white60 : _C.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Inline stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _HeaderStat(
                  value: favCount.toString(),
                  label: l.t('myFavorites'),
                  icon: Icons.favorite_rounded,
                ),
                _vDivider(),
                _HeaderStat(
                  value: cartCount.toString(),
                  label: l.t('cart'),
                  icon: Icons.shopping_bag_rounded,
                ),
                _vDivider(),
                _HeaderStat(
                  value: '0',
                  label: l.t('myOrders'),
                  icon: Icons.receipt_long_rounded,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Builds the avatar image or fallback icon
  Widget _buildAvatarContent() {
    final hasImage = localImagePath != null && localImagePath!.isNotEmpty;
    if (hasImage) {
      return Image.file(
        File(localImagePath!),
        width: 88,
        height: 88,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _fallbackIcon(),
      );
    }
    return _fallbackIcon();
  }

  Widget _fallbackIcon() => SizedBox(
        width: 88,
        height: 88,
        child: Icon(
          isGuest ? Icons.person_outline_rounded : Icons.person_rounded,
          size: 48,
          color: Colors.white,
        ),
      );

  Widget _vDivider() => Container(
        height: 36,
        width: 1,
        color: Colors.white24,
      );
}

class _HeaderStat extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _HeaderStat({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: _C.gold, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(color: Colors.white60, fontSize: 11),
        ),
      ],
    );
  }
}

// ─── Achievements ─────────────────────────────────────────────────────────────
class _AchievementsRow extends StatelessWidget {
  final AppLocalizations l;
  final Color cardBg;
  final bool isDark;
  final int favCount;
  final int cartCount;

  const _AchievementsRow({
    required this.l,
    required this.cardBg,
    required this.isDark,
    required this.favCount,
    required this.cartCount,
  });

  @override
  Widget build(BuildContext context) {
    final badges = [
      _Badge(
        icon: Icons.favorite_rounded,
        color: _C.raspberry,
        title: l.t('musicLover'),
        desc: l.t('musicLoverDesc'),
        unlocked: favCount > 0,
      ),
      _Badge(
        icon: Icons.shopping_bag_rounded,
        color: _C.gold,
        title: l.t('firstPurchase'),
        desc: l.t('firstPurchaseDesc'),
        unlocked: cartCount > 0,
      ),
      _Badge(
        icon: Icons.play_circle_fill_rounded,
        color: _C.sage,
        title: l.t('soundExplorer'),
        desc: l.t('soundExplorerDesc'),
        unlocked: true,
      ),
    ];

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: badges.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => _BadgeCard(
          badge: badges[i],
          cardBg: cardBg,
          isDark: isDark,
        ),
      ),
    );
  }
}

class _Badge {
  final IconData icon;
  final Color color;
  final String title;
  final String desc;
  final bool unlocked;
  const _Badge({
    required this.icon,
    required this.color,
    required this.title,
    required this.desc,
    required this.unlocked,
  });
}

class _BadgeCard extends StatelessWidget {
  final _Badge badge;
  final Color cardBg;
  final bool isDark;

  const _BadgeCard({
    required this.badge,
    required this.cardBg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final locked = !badge.unlocked;
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: locked
              ? Colors.grey.withValues(alpha: 0.2)
              : badge.color.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: locked
                ? Colors.transparent
                : badge.color.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: locked
                  ? Colors.grey.withValues(alpha: 0.1)
                  : badge.color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              locked ? Icons.lock_outline_rounded : badge.icon,
              color: locked ? Colors.grey : badge.color,
              size: 26,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            badge.title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: locked
                  ? Colors.grey
                  : (isDark ? Colors.white : _C.wine),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Quick Links ──────────────────────────────────────────────────────────────
class _QuickLinks extends StatelessWidget {
  final AppLocalizations l;
  final Color cardBg;
  final bool isDark;
  final LocaleProvider localeProvider;
  final ThemeProvider themeProvider;
  final SoundProvider soundProvider;
  final FontSizeProvider fontSizeProvider;
  final AppAuthProvider auth;

  const _QuickLinks({
    required this.l,
    required this.cardBg,
    required this.isDark,
    required this.localeProvider,
    required this.themeProvider,
    required this.soundProvider,
    required this.fontSizeProvider,
    required this.auth,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          _LinkTile(
            icon: Icons.favorite_rounded,
            color: _C.raspberry,
            label: l.t('myFavorites'),
            trailing: Text(
              '${context.watch<ProductProvider>().favorites.length}',
              style: const TextStyle(
                  color: _C.raspberry, fontWeight: FontWeight.w700),
            ),
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const FavoritesScreen()),
              );
            },
          ),
          _divider(),
          _LinkTile(
            icon: Icons.receipt_long_rounded,
            color: _C.gold,
            label: l.t('myOrders'),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black26,
              size: 20,
            ),
            isDark: isDark,
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (_) => const MyOrdersScreen()),
              );
            },
          ),
          _divider(),
          Semantics(
            label: l.t('semSwitchLang'),
            child: _LinkTile(
              icon: Icons.language_rounded,
              color: _C.sage,
              label: l.t('language'),
              trailing: Text(
                localeProvider.isArabic ? 'AR' : 'EN',
                style: const TextStyle(
                    color: _C.sage, fontWeight: FontWeight.w700),
              ),
              isDark: isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                localeProvider.setLocale(
                  localeProvider.isArabic
                      ? const Locale('en')
                      : const Locale('ar'),
                );
              },
            ),
          ),
          _divider(),
          Semantics(
            label: l.t('semSwitchTheme'),
            child: _LinkTile(
              icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
              color: isDark ? _C.rose : Colors.amber,
              label: l.t('theme'),
              trailing: Switch(
                value: isDark,
                onChanged: (_) {
                  themeProvider.toggle();
                },
                activeThumbColor: Colors.white,
                activeTrackColor: _C.raspberry,
              ),
              isDark: isDark,
              onTap: () => themeProvider.toggle(),
            ),
          ),
          _divider(),
          Semantics(
            label: l.t('semToggleSound'),
            child: _LinkTile(
              icon: soundProvider.isEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
              color: soundProvider.isEnabled ? _C.sage : Colors.grey,
              label: l.t('sound'),
              trailing: Switch(
                value: soundProvider.isEnabled,
                onChanged: (_) => soundProvider.toggle(),
                activeThumbColor: Colors.white,
                activeTrackColor: _C.sage,
              ),
              isDark: isDark,
              onTap: () => soundProvider.toggle(),
            ),
          ),
          _divider(),
          // ── Font Size ────────────────────────────────────
          _LinkTile(
            icon: Icons.text_fields_rounded,
            color: _C.raspberry,
            label: l.t('fontSize'),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _C.raspberry.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                _fontSizeLabel(fontSizeProvider.size, l),
                style: const TextStyle(
                  color: _C.raspberry,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
            ),
            isDark: isDark,
            onTap: () => _showFontSizeDialog(context, l),
          ),
          // ── Admin: go to Admin Dashboard ─────────────────────
          if (auth.isAdmin) ...[
            _divider(),
            _LinkTile(
              icon: Icons.admin_panel_settings_rounded,
              color: _C.gold,
              label: l.t('goToAdminDashboard'),
              trailing: Icon(
                Icons.chevron_right_rounded,
                color: isDark ? Colors.white38 : Colors.black26,
                size: 20,
              ),
              isDark: isDark,
              onTap: () {
                HapticFeedback.lightImpact();
                // Pop back to AuthGate — it shows AdminDashboard for admins
                Navigator.of(context).popUntil((r) => r.isFirst);
              },
            ),
          ],
          // ── Auth tile: logout (logged-in) or login (guest) ──
          _divider(),
          _LinkTile(
            icon: auth.isLoggedIn
                ? Icons.logout_rounded
                : Icons.login_rounded,
            color: auth.isLoggedIn ? const Color(0xFFD32F2F) : _C.sage,
            label: auth.isLoggedIn ? l.t('logout') : l.t('loginOrRegister'),
            trailing: Icon(
              Icons.chevron_right_rounded,
              color: isDark ? Colors.white38 : Colors.black26,
              size: 20,
            ),
            isDark: isDark,
            onTap: () async {
              if (auth.isLoggedIn) {
                HapticFeedback.lightImpact();
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: Text(l.t('logout')),
                    content: Text(l.t('logoutConfirm')),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text(l.t('close')),
                      ),
                      FilledButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFFD32F2F)),
                        child: Text(l.t('logout')),
                      ),
                    ],
                  ),
                );
                if (confirm == true && context.mounted) {
                  await context.read<AppAuthProvider>().signOut();
                  if (context.mounted) {
                    Navigator.of(context).popUntil((r) => r.isFirst);
                  }
                }
              } else {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 56, endIndent: 16);

  /// Returns the localised label for the active font size.
  String _fontSizeLabel(AppFontSize size, AppLocalizations l) {
    switch (size) {
      case AppFontSize.small:  return l.t('fontSmall');
      case AppFontSize.medium: return l.t('fontMedium');
      case AppFontSize.large:  return l.t('fontLarge');
    }
  }

  /// Shows a simple dialog for the user to pick a font size.
  void _showFontSizeDialog(BuildContext context, AppLocalizations l) {
    HapticFeedback.lightImpact();
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          const Icon(Icons.text_fields_rounded, color: _C.raspberry, size: 22),
          const SizedBox(width: 10),
          Text(l.t('fontSizeTitle')),
        ]),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: AppFontSize.values.map((size) {
            final labels = {
              AppFontSize.small:  l.t('fontSmall'),
              AppFontSize.medium: l.t('fontMedium'),
              AppFontSize.large:  l.t('fontLarge'),
            };
            final icons = {
              AppFontSize.small:  Icons.text_decrease_rounded,
              AppFontSize.medium: Icons.text_fields_rounded,
              AppFontSize.large:  Icons.text_increase_rounded,
            };
            final isSelected = fontSizeProvider.size == size;
            return ListTile(
              leading: Icon(icons[size]!, color: _C.raspberry, size: 22),
              title: Text(
                labels[size]!,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.normal,
                ),
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle_rounded,
                      color: _C.raspberry, size: 22)
                  : Icon(Icons.circle_outlined,
                      color: Colors.grey.shade400, size: 22),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              onTap: () {
                fontSizeProvider.setSize(size);
                Navigator.pop(context);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final Widget trailing;
  final bool isDark;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.color,
    required this.label,
    required this.trailing,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: isDark ? Colors.white : _C.wine,
        ),
      ),
      trailing: trailing,
    );
  }
}

// ─── Stats Card ───────────────────────────────────────────────────────────────
class _StatsCard extends StatelessWidget {
  final AppLocalizations l;
  final int favCount;
  final int cartCount;
  final Color cardBg;
  final bool isDark;

  const _StatsCard({
    required this.l,
    required this.favCount,
    required this.cartCount,
    required this.cardBg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_C.plum, _C.raspberry],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: _C.raspberry.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.music_note_rounded, color: _C.gold, size: 22),
              const SizedBox(width: 8),
              Text(
                l.t('appName'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  l.t('appVersion'),
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            l.t('tagline'),
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 13,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MiniStat(
                icon: Icons.category_rounded,
                label: '5 ${l.t('byCategory')}',
              ),
              const SizedBox(width: 16),
              _MiniStat(
                icon: Icons.inventory_2_rounded,
                label: '10+ ${l.t('allProducts')}',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MiniStat({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: _C.gold, size: 16),
        const SizedBox(width: 6),
        Text(label,
            style: const TextStyle(color: Colors.white60, fontSize: 12)),
      ],
    );
  }
}

// ─── Section Title ────────────────────────────────────────────────────────────
class _SectionTitle extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionTitle(this.title, this.color);

  @override
  Widget build(BuildContext context) => Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.5,
          color: color.withValues(alpha: 0.5),
        ),
      );
}
