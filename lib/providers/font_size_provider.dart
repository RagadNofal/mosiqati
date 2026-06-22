import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ── Font-size options ─────────────────────────────────────────────────────────
enum AppFontSize { small, medium, large }

/// Persists the user's preferred in-app font scale and exposes it as a
/// [textScaleFactor] that [MosiqatiApp] applies via a [MediaQuery] override.
///
/// scale factors:
///   small  → 0.85   (compact text for dense UIs)
///   medium → 1.00   (system default)
///   large  → 1.20   (easier to read)
class FontSizeProvider extends ChangeNotifier {
  static const _prefKey = 'app_font_size_index';

  AppFontSize _size = AppFontSize.medium;
  bool _loaded = false;

  AppFontSize get size => _size;
  bool get isLoaded => _loaded;

  /// Returns the numeric scale factor for the current size.
  double get scaleFactor {
    switch (_size) {
      case AppFontSize.small:  return 0.85;
      case AppFontSize.medium: return 1.00;
      case AppFontSize.large:  return 1.20;
    }
  }

  FontSizeProvider() {
    _loadFromPrefs();
  }

  Future<void> _loadFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final idx   = prefs.getInt(_prefKey) ?? AppFontSize.medium.index;
      _size   = AppFontSize.values[idx.clamp(0, AppFontSize.values.length - 1)];
      _loaded = true;
      notifyListeners();
    } catch (_) {
      _loaded = true;
    }
  }

  /// Updates the font size and persists the choice immediately.
  Future<void> setSize(AppFontSize newSize) async {
    if (_size == newSize) return;
    _size = newSize;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_prefKey, newSize.index);
    } catch (_) {}
  }
}
