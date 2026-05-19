import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  UserModel  –  holds all user data
// ─────────────────────────────────────────────
class UserModel {
  String name;
  String email;
  String phone;
  String location;
  String avatarUrl;
  int    orders;
  int    favorites;
  double rating;
  String memberSince;
  String language;

  UserModel({
    required this.name,
    required this.email,
    this.phone       = "",
    this.location    = "",
    this.avatarUrl   = "",
    this.orders      = 0,
    this.favorites   = 0,
    this.rating      = 0.0,
    this.memberSince = "",
    this.language    = "English",
  });
}

// ─────────────────────────────────────────────
//  UserProvider  –  ChangeNotifier
// ─────────────────────────────────────────────
class UserProvider extends ChangeNotifier {
  // ── Simulated "logged-in" user ─────────────
  // In a real app this would come from Firebase Auth / SharedPreferences / API
  UserModel _user = UserModel(
    name        : "Ahmad Al-Khalidi",
    email       : "ahmad@mosiqati.jo",
    phone       : "+962 79 123 4567",
    location    : "Amman, Jordan",
    avatarUrl   : "",           // empty = show initials avatar
    orders      : 5,
    favorites   : 3,
    rating      : 4.7,
    memberSince : "Jan 2024",
    language    : "English",
  );

  UserModel get user => _user;

  bool _isLoggedIn = true;
  bool get isLoggedIn => _isLoggedIn;

  // ── Update individual fields ───────────────
  void updateName(String name) {
    _user.name = name.trim();
    notifyListeners();
  }

  void updateEmail(String email) {
    _user.email = email.trim();
    notifyListeners();
  }

  void updatePhone(String phone) {
    _user.phone = phone.trim();
    notifyListeners();
  }

  void updateLocation(String location) {
    _user.location = location.trim();
    notifyListeners();
  }

  void updateLanguage(String lang) {
    _user.language = lang;
    notifyListeners();
  }

  void updateAvatar(String url) {
    _user.avatarUrl = url;
    notifyListeners();
  }

  // ── Increment order count (call after checkout) ──
  void addOrder() {
    _user.orders++;
    notifyListeners();
  }

  // ── Logout ────────────────────────────────
  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // ── Login (simulate) ──────────────────────
  void login({required String name, required String email}) {
    _user = UserModel(
      name        : name,
      email       : email,
      memberSince : _currentMonth(),
    );
    _isLoggedIn = true;
    notifyListeners();
  }

  String _currentMonth() {
    final months = [
      "Jan","Feb","Mar","Apr","May","Jun",
      "Jul","Aug","Sep","Oct","Nov","Dec"
    ];
    final now = DateTime.now();
    return "${months[now.month - 1]} ${now.year}";
  }

  // ── User initials (for avatar fallback) ───
  String get initials {
    final parts = _user.name.trim().split(' ');
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return _user.name.isNotEmpty ? _user.name[0].toUpperCase() : "?";
  }
}