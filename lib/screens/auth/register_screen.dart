import 'package:flutter/material.dart';
import 'package:project_assignment_e/l10n/app_localizations.dart';
import 'package:project_assignment_e/providers/auth_provider.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey        = GlobalKey<FormState>();
  final _nameCtrl       = TextEditingController();
  final _emailCtrl      = TextEditingController();
  final _passwordCtrl   = TextEditingController();
  final _confirmCtrl    = TextEditingController();
  bool  _obscurePass    = true;
  bool  _obscureConfirm = true;
  bool  _isLoading      = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final auth = context.read<AppAuthProvider>();
    final ok   = await auth.register(
      _nameCtrl.text,
      _emailCtrl.text,
      _passwordCtrl.text,
    );

    if (mounted) {
      setState(() => _isLoading = false);
      if (!ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage),
            backgroundColor: Colors.red.shade700,
          ),
        );
      } else {
        // AuthGate will redirect automatically once auth state fires.
        Navigator.of(context).popUntil((r) => r.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l     = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.t('register')),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: primary.withOpacity(0.12),
                  child: Icon(Icons.person_add_outlined, size: 40, color: primary),
                ),
                const SizedBox(height: 16),

                Text(
                  l.t('registerTitle'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  l.t('registerSub'),
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 28),

                // Full name
                TextFormField(
                  controller: _nameCtrl,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText:  l.t('name'),
                    prefixIcon: const Icon(Icons.person_outline),
                    border:     OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (v) => (v == null || v.trim().isEmpty) ? l.t('fieldRequired') : null,
                ),
                const SizedBox(height: 14),

                // Email
                TextFormField(
                  controller:   _emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText:  l.t('email'),
                    prefixIcon: const Icon(Icons.email_outlined),
                    border:     OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
                  controller:  _passwordCtrl,
                  obscureText: _obscurePass,
                  textInputAction: TextInputAction.next,
                  decoration: InputDecoration(
                    labelText:  l.t('password'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    border:     OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePass ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscurePass = !_obscurePass),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.t('fieldRequired');
                    if (v.length < 6) return l.t('weakPassword');
                    return null;
                  },
                ),
                const SizedBox(height: 14),

                // Confirm password
                TextFormField(
                  controller:  _confirmCtrl,
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _register(),
                  decoration: InputDecoration(
                    labelText:  l.t('confirmPassword'),
                    prefixIcon: const Icon(Icons.lock_outline),
                    border:     OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                      onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return l.t('fieldRequired');
                    if (v != _passwordCtrl.text) return l.t('passwordMismatch');
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                FilledButton(
                  onPressed: _isLoading ? null : _register,
                  style: FilledButton.styleFrom(
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 22, width: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                        )
                      : Text(l.t('signUp'), style: const TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(l.t('alreadyHaveAccount'), style: theme.textTheme.bodyMedium),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l.t('signIn')),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
