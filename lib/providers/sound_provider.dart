import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundType { click, navigation, favorite, cart, notification, theme, language }

class SoundProvider extends ChangeNotifier {
  static const _key = 'soundEnabled';

  bool _enabled = true;
  bool get isEnabled => _enabled;

  SoundProvider() {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _enabled = prefs.getBool(_key) ?? true;
    notifyListeners();
  }

  Future<void> toggle() async {
    _enabled = !_enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_key, _enabled);
    notifyListeners();
    // Always do haptic on toggle so user feels the change regardless
    HapticFeedback.mediumImpact();
  }

  void play(SoundType type) {
    if (!_enabled) return;
    switch (type) {
      case SoundType.click:
      case SoundType.navigation:
      case SoundType.language:
        HapticFeedback.lightImpact();
      case SoundType.favorite:
      case SoundType.cart:
      case SoundType.notification:
        HapticFeedback.mediumImpact();
      case SoundType.theme:
        HapticFeedback.selectionClick();
    }
  }
}
