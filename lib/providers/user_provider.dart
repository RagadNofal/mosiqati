import 'package:flutter/material.dart';

// ─────────────────────────────────────────────
//  UserModel
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
//  UserProvider
// ─────────────────────────────────────────────
class UserProvider extends ChangeNotifier {
  UserModel _user = UserModel(
    name        : "Ahmad Al-Khalidi",
    email       : "ahmad@mosiqati.jo",
    phone       : "+962 79 123 4567",
    location    : "Amman, Jordan",
    avatarUrl   : "",
    orders      : 5,
    favorites   : 3,
    rating      : 4.7,
    memberSince : "Jan 2024",
    language    : "English",
  );

  UserModel get user      => _user;
  bool      _isLoggedIn   = true;
  bool      get isLoggedIn=> _isLoggedIn;

  void updateName    (String v) { _user.name      = v.trim(); notifyListeners(); }
  void updateEmail   (String v) { _user.email     = v.trim(); notifyListeners(); }
  void updatePhone   (String v) { _user.phone     = v.trim(); notifyListeners(); }
  void updateLocation(String v) { _user.location  = v.trim(); notifyListeners(); }
  void updateLanguage(String v) { _user.language  = v;        notifyListeners(); }
  void updateAvatar  (String v) { _user.avatarUrl = v;        notifyListeners(); }
  void addOrder()               { _user.orders++;             notifyListeners(); }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  void login({required String name, required String email}) {
    _user = UserModel(name: name, email: email, memberSince: _month());
    _isLoggedIn = true;
    notifyListeners();
  }

  String _month() {
    const m = ["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"];
    final n = DateTime.now();
    return "${m[n.month - 1]} ${n.year}";
  }

  String get initials {
    final p = _user.name.trim().split(' ');
    if (p.length >= 2) return "${p[0][0]}${p[1][0]}".toUpperCase();
    return _user.name.isNotEmpty ? _user.name[0].toUpperCase() : "?";
  }
}