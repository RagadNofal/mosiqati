import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:project_assignment_e/firebase_options.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/auth_provider.dart';
import 'package:project_assignment_e/providers/cart_provider.dart';
import 'package:project_assignment_e/providers/locale_provider.dart';
import 'package:project_assignment_e/providers/notifications_provider.dart';
import 'package:project_assignment_e/providers/products_provider.dart';
import 'package:project_assignment_e/providers/sound_provider.dart';
import 'package:project_assignment_e/providers/font_size_provider.dart';
import 'package:project_assignment_e/providers/theme_provider.dart';
import 'package:project_assignment_e/screens/admin/admin_dashboard.dart';
import 'package:project_assignment_e/screens/auth/welcome_screen.dart';
import 'package:project_assignment_e/screens/home_page.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    MultiProvider(
      providers: [
        // Auth must be first so all other providers/screens can read it.
        ChangeNotifierProvider(create: (_) => AppAuthProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LocaleProvider()),
        ChangeNotifierProvider(create: (_) => NotificationsProvider()),
        ChangeNotifierProvider(create: (_) => SoundProvider()),
        ChangeNotifierProvider(create: (_) => FontSizeProvider()),
      ],
      child: const _AuthSync(child: MosiqatiApp()),
    ),
  );
}

class MosiqatiApp extends StatelessWidget {
  const MosiqatiApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider    = context.watch<ThemeProvider>();
    final localeProvider   = context.watch<LocaleProvider>();
    final fontSizeProvider = context.watch<FontSizeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MOSIQATI | موسيقاتي',

      theme:     themeProvider.lightTheme,
      darkTheme: themeProvider.darkTheme,
      themeMode: themeProvider.isDark ? ThemeMode.dark : ThemeMode.light,

      locale: localeProvider.locale,
      supportedLocales: const [Locale('en'), Locale('ar')],
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Apply the user-selected font scale without blocking system accessibility.
      // System textScaler from MediaQuery is replaced with the user's choice so
      // that both in-app and OS-level scaling work together rather than fighting.
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(
          textScaler: TextScaler.linear(fontSizeProvider.scaleFactor),
        ),
        child: child!,
      ),

      home: const AuthGate(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AuthGate — routes to the correct first screen based on auth state.
// ─────────────────────────────────────────────────────────────────────────────
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();

    switch (auth.status) {
      // Firebase auth state not yet resolved → neutral splash.
      case AuthStatus.initial:
      case AuthStatus.loading:
        return const _SplashScreen();

      case AuthStatus.authenticated:
        // Admin  → Admin Dashboard.
        // Customer → Home.
        return auth.isAdmin ? const AdminDashboard() : const HomeScreen();

      case AuthStatus.unauthenticated:
      case AuthStatus.error:
        // Guest pressed "Continue as Guest" → Home.
        // Truly unauthenticated → Welcome.
        return auth.isGuest ? const HomeScreen() : const WelcomeScreen();
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
//  AuthSync — listens to AppAuthProvider and syncs uid into
//  ProductProvider (favorites) and CartProvider (cart) whenever the
//  logged-in user changes.  Sits just below MultiProvider so it has full
//  access to every provider.
// ─────────────────────────────────────────────────────────────────────────────
class _AuthSync extends StatefulWidget {
  final Widget child;
  const _AuthSync({required this.child});

  @override
  State<_AuthSync> createState() => _AuthSyncState();
}

class _AuthSyncState extends State<_AuthSync> {
  late final AppAuthProvider _auth;

  @override
  void initState() {
    super.initState();
    _auth = context.read<AppAuthProvider>();
    _auth.addListener(_onAuthChanged);
    // Handle any already-resolved auth state on the first frame.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _onAuthChanged());
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChanged);
    super.dispose();
  }

  void _onAuthChanged() {
    if (!mounted) return;
    final uid      = _auth.user?.uid;
    final products = context.read<ProductProvider>().allProducts;
    context.read<ProductProvider>().setCurrentUid(uid);
    context.read<CartProvider>().setCurrentUid(uid, products);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

// ─────────────────────────────────────────────────────────────────────────────
//  Splash shown while Firebase resolves the auth state on startup.
// ─────────────────────────────────────────────────────────────────────────────
class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF361F27), // _C.wine from brand palette
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.music_note_rounded, color: Colors.white, size: 64),
            SizedBox(height: 24),
            CircularProgressIndicator(color: Color(0xFFD4A853)), // gold
          ],
        ),
      ),
    );
  }
}
