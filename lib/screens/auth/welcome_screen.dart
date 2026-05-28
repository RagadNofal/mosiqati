import 'package:flutter/material.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/auth_provider.dart';
import 'package:project_assignment_e/screens/auth/login_screen.dart';
import 'package:project_assignment_e/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';

/// First screen the user sees.  Offers three choices:
///   1. Continue as Guest  → HomeScreen (browse only, no checkout)
///   2. Login              → LoginScreen (customer OR admin — same form)
///   3. Create Account     → RegisterScreen (customers only)
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // Brand palette
  static const _raspberry = Color(0xFF912F56);
  static const _plum      = Color(0xFF521945);
  static const _wine      = Color(0xFF361F27);
  static const _gold      = Color(0xFFD4A853);
  static const _sage      = Color(0xFF3D7A6A);

  @override
  Widget build(BuildContext context) {
    final l    = AppLocalizations.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [_wine, _plum, _raspberry],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: size.height - MediaQuery.of(context).padding.top),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    const SizedBox(height: 48),

                    // ── Branding ──────────────────────────────────────────
                    Container(
                      width: 90,
                      height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.music_note_rounded,
                          color: Colors.white,
                          size: 48,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      l.t('appName'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      l.t('tagline'),
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.75),
                        fontSize: 15,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const Spacer(),

                    // ── Action cards ─────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [

                          // Guest button
                          _WelcomeButton(
                            icon:    Icons.person_outline_rounded,
                            label:   l.t('guestMode'),
                            sublabel: l.t('guestModeSub'),
                            bgColor: Colors.white.withValues(alpha: 0.12),
                            borderColor: Colors.white.withValues(alpha: 0.3),
                            textColor: Colors.white,
                            onTap: () =>
                                context.read<AppAuthProvider>().continueAsGuest(),
                          ),
                          const SizedBox(height: 14),

                          // Login button
                          _WelcomeButton(
                            icon:    Icons.login_rounded,
                            label:   l.t('login'),
                            sublabel: l.t('loginSub'),
                            bgColor: Colors.white,
                            borderColor: Colors.white,
                            textColor: _raspberry,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const LoginScreen()),
                            ),
                          ),
                          const SizedBox(height: 14),

                          // Register button
                          _WelcomeButton(
                            icon:    Icons.person_add_outlined,
                            label:   l.t('register'),
                            sublabel: l.t('registerSub'),
                            bgColor: _sage.withValues(alpha: 0.85),
                            borderColor: _sage,
                            textColor: Colors.white,
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(
                                  builder: (_) => const RegisterScreen()),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 28),

                    // Admin hint
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 28),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.admin_panel_settings_outlined,
                              color: _gold, size: 16),
                          const SizedBox(width: 6),
                          Text(
                            l.t('adminHint'),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.65),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _WelcomeButton extends StatelessWidget {
  final IconData  icon;
  final String    label;
  final String    sublabel;
  final Color     bgColor;
  final Color     borderColor;
  final Color     textColor;
  final VoidCallback onTap;

  const _WelcomeButton({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.bgColor,
    required this.borderColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color:        bgColor,
          borderRadius: BorderRadius.circular(16),
          border:       Border.all(color: borderColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(icon, color: textColor, size: 26),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                        color:      textColor,
                        fontSize:   16,
                        fontWeight: FontWeight.w700,
                      )),
                  const SizedBox(height: 2),
                  Text(sublabel,
                      style: TextStyle(
                        color:    textColor.withValues(alpha: 0.65),
                        fontSize: 12,
                      )),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: textColor.withValues(alpha: 0.5), size: 16),
          ],
        ),
      ),
    );
  }
}
