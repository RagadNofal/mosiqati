import 'package:flutter/material.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/auth_provider.dart';
import 'package:project_assignment_e/screens/auth/register_screen.dart';
import 'package:provider/provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey      = GlobalKey<FormState>();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool  _obscurePass  = true;
  bool  _isLoading    = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AppAuthProvider>();
    final ok   = await auth.login(_emailCtrl.text, _passwordCtrl.text);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (ok) {
      // Pop this screen — AuthGate rebuilds and routes to
      // AdminDashboard or HomeScreen automatically.
      Navigator.of(context).popUntil((r) => r.isFirst);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:         Text(auth.errorMessage),
          backgroundColor: Colors.red.shade700,
          behavior:        SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l       = AppLocalizations.of(context);
    final theme   = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('login')),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Icon
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: primary.withValues(alpha: 0.12),
                    child: Icon(Icons.music_note_rounded, size: 44, color: primary),
                  ),
                  const SizedBox(height: 18),

                  Text(l.t('loginTitle'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(l.t('loginSub'),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6))),
                  const SizedBox(height: 28),

                  // Email
                  TextFormField(
                    controller:      _emailCtrl,
                    keyboardType:    TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText:  l.t('email'),
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                    ),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return l.t('fieldRequired');
                      if (!v.contains('@')) return l.t('invalidEmail');
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Password
                  TextFormField(
                    controller:      _passwordCtrl,
                    obscureText:     _obscurePass,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _login(),
                    decoration: InputDecoration(
                      labelText:  l.t('password'),
                      prefixIcon: const Icon(Icons.lock_outline),
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14)),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePass
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined),
                        onPressed: () =>
                            setState(() => _obscurePass = !_obscurePass),
                      ),
                    ),
                    validator: (v) {
                      if (v == null || v.isEmpty) return l.t('fieldRequired');
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login button
                  Semantics(
                    label: l.t('semLoginBtn'),
                    button: true,
                    child: FilledButton(
                      onPressed: _isLoading ? null : _login,
                      style: FilledButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 22,
                              width:  22,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2.5, color: Colors.white))
                          : Text(l.t('signIn'),
                              style: const TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Continue as guest
                  Semantics(
                    label: l.t('semGuestBtn'),
                    button: true,
                    child: OutlinedButton(
                      onPressed: () {
                        context.read<AppAuthProvider>().continueAsGuest();
                        Navigator.of(context).popUntil((r) => r.isFirst);
                      },
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      child: Text(l.t('guestMode')),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Register link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l.t('noAccount'),
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                              builder: (_) => const RegisterScreen()),
                        ),
                        child: Text(l.t('signUp')),
                      ),
                    ],
                  ),

                  // Admin hint
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.admin_panel_settings_outlined,
                            size: 14,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.4)),
                        const SizedBox(width: 4),
                        Text(
                          l.t('adminHint'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.45),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
