import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:project_assignment_e/models/app_user.dart';
import 'package:project_assignment_e/services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AppAuthProvider extends ChangeNotifier {
  final _service = AuthService();

  AuthStatus _status    = AuthStatus.initial;
  AppUser?   _user;
  String     _errorMessage = '';
  bool       _isGuest   = false;  // true when user chose "Continue as Guest"

  AuthStatus get status       => _status;
  AppUser?   get user         => _user;
  bool       get isAdmin      => _user?.isAdmin ?? false;
  bool       get isLoggedIn   => _user != null;
  bool       get isGuest      => _isGuest && _user == null;
  String     get errorMessage => _errorMessage;

  AppAuthProvider() {
    _service.authStateChanges.listen(_onAuthStateChanged);
  }

  Future<void> _onAuthStateChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      _user   = null;
      // Keep _isGuest flag if user was already in guest mode.
      // Only reset it explicitly via signOut().
      _status = AuthStatus.unauthenticated;
    } else {
      _isGuest = false;           // Real login → clear guest flag
      _status  = AuthStatus.loading;
      notifyListeners();
      _user = await _service.fetchUser(firebaseUser.uid);
      if (_user == null) {
        // Firestore user doc missing — create it automatically as customer.
        try {
          final appUser = AppUser(
            uid:       firebaseUser.uid,
            name:      firebaseUser.displayName ?? '',
            email:     firebaseUser.email ?? '',
            role:      UserRole.customer,
            createdAt: DateTime.now(),
          );
          await _service.createUserDoc(appUser);
          _user = appUser;
        } catch (_) {}
      }
      _status = _user != null
          ? AuthStatus.authenticated
          : AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  // ── Guest mode ────────────────────────────────────────────────────────────

  /// User chose to browse without logging in.
  void continueAsGuest() {
    _isGuest = true;
    _user    = null;
    _status  = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Auth actions ──────────────────────────────────────────────────────────

  /// Sign in. Returns true on success.
  Future<bool> login(String email, String password) async {
    _status       = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      await _service.signIn(email.trim(), password);
      // _onAuthStateChanged fires and sets status + user.
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyMessage(e.code);
      _status       = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Register a new customer. Returns true on success.
  Future<bool> register(String name, String email, String password) async {
    _status       = AuthStatus.loading;
    _errorMessage = '';
    notifyListeners();
    try {
      await _service.registerCustomer(
          name: name.trim(), email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = _friendlyMessage(e.code);
      _status       = AuthStatus.error;
      notifyListeners();
      return false;
    }
  }

  /// Update the user's name, phone, and address in Firestore and refresh local state.
  Future<void> updateProfile({
    required String name,
    required String phone,
    required String address,
  }) async {
    if (_user == null) return;
    await _service.updateUserProfile(
      uid:     _user!.uid,
      name:    name.trim(),
      phone:   phone.trim(),
      address: address.trim(),
    );
    _user = _user!.copyWith(
      name:    name.trim(),
      phone:   phone.trim(),
      address: address.trim(),
    );
    notifyListeners();
  }

  /// Sign out — clears guest flag so WelcomeScreen is shown next.
  Future<void> signOut() async {
    await _service.signOut();
    _user    = null;
    _isGuest = false;         // Clear guest flag → WelcomeScreen shows
    _status  = AuthStatus.unauthenticated;
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _friendlyMessage(String code) {
    switch (code) {
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Invalid email or password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password must be at least 6 characters.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'network-request-failed':
        return 'No internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
