import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:project_assignment_e/models/app_user.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db   = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  /// Sign in with email and password.
  Future<UserCredential> signIn(String email, String password) =>
      _auth.signInWithEmailAndPassword(email: email, password: password);

  /// Register a new customer account, then write the user doc.
  Future<UserCredential> registerCustomer({
    required String name,
    required String email,
    required String password,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = AppUser(
      uid:       cred.user!.uid,
      name:      name,
      email:     email,
      role:      UserRole.customer,
      createdAt: DateTime.now(),
    );
    await _db.collection('users').doc(cred.user!.uid).set(user.toFirestore());
    return cred;
  }

  /// Fetch the AppUser document for [uid].
  Future<AppUser?> fetchUser(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    if (!doc.exists) return null;
    return AppUser.fromFirestore(doc);
  }

  /// Create (or overwrite) the Firestore user document.
  /// Used when a user exists in Firebase Auth but the Firestore doc is missing.
  Future<void> createUserDoc(AppUser user) =>
      _db.collection('users').doc(user.uid).set(user.toFirestore());

  /// Update mutable profile fields (name, phone, address) in Firestore.
  Future<void> updateUserProfile({
    required String uid,
    required String name,
    required String phone,
    required String address,
  }) =>
      _db.collection('users').doc(uid).update({
        'name':    name,
        'phone':   phone,
        'address': address,
      });

  /// Sign out.
  Future<void> signOut() => _auth.signOut();
}
