import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum SoundType {
  click,
  navigation,
  favorite,
  cart,
  notification,
  theme,
  language,
  couponSuccess,
  couponError,
  emptyCart,
  emptyFavorites,
}

enum InstrumentSound { guitar, piano, drums, oud }

class SoundProvider extends ChangeNotifier {
  static const _key = 'soundEnabled';

  bool _enabled = true;
  bool get isEnabled => _enabled;

  /// Single player instance — fire-and-forget for short UI sounds.
  final AudioPlayer _player = AudioPlayer();

  SoundProvider() {
    _load();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
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
    // Always give haptic on toggle so the user feels the change either way.
    HapticFeedback.mediumImpact();
  }

  // ── Asset mapping ──────────────────────────────────────────────────────────

  /// Returns the asset path (relative to the `assets/` folder) for [type],
  /// or null when no dedicated audio file is mapped.
  static String? _assetFor(SoundType type) {
    switch (type) {
      case SoundType.cart:
        return 'audio/freesound_crunchpixstudio-add-408457.mp3';
      case SoundType.couponSuccess:
        return 'audio/soundshelfstudio-ui-success-chime-513565.mp3';
      case SoundType.emptyCart:
      case SoundType.emptyFavorites:
        return 'audio/kakaist-crow-sfx-318131.mp3';
      case SoundType.click:
      case SoundType.navigation:
      case SoundType.language:
      case SoundType.favorite:
      case SoundType.notification:
      case SoundType.theme:
      case SoundType.couponError:
        return 'audio/soundreality-interface-button-154180.mp3';
    }
  }

  /// Returns the asset path for an instrument sound.
  /// The guitar audio file is ONLY used here — never for generic UI actions.
  static String? _assetForInstrument(InstrumentSound instrument) {
    switch (instrument) {
      case InstrumentSound.guitar:
        return 'audio/farran_ez-soft-indie-guitar-sample-456142.mp3';
      case InstrumentSound.piano:
        return 'audio/11325622-piano-chords-239967.mp3';
      case InstrumentSound.drums:
        return 'audio/freesound_community-war-drum-loop-103870.mp3';
      case InstrumentSound.oud:
        // No dedicated oud file — haptic feedback only.
        return null;
    }
  }

  // ── Haptic helpers ─────────────────────────────────────────────────────────

  static void _hapticFor(SoundType type) {
    switch (type) {
      case SoundType.click:
      case SoundType.navigation:
      case SoundType.language:
        HapticFeedback.lightImpact();
      case SoundType.favorite:
      case SoundType.cart:
      case SoundType.notification:
      case SoundType.couponSuccess:
      case SoundType.emptyCart:
      case SoundType.emptyFavorites:
        HapticFeedback.mediumImpact();
      case SoundType.theme:
        HapticFeedback.selectionClick();
      case SoundType.couponError:
        HapticFeedback.heavyImpact();
    }
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Plays haptic + audio for [type].
  /// Respects the sound on/off setting; silently no-ops when off.
  /// Catches any asset or platform error so the app never crashes.
  Future<void> play(SoundType type) async {
    if (!_enabled) return;
    _hapticFor(type);
    final asset = _assetFor(type);
    if (asset != null) {
      try {
        await _player.play(AssetSource(asset));
      } catch (_) {
        // Missing asset or unsupported platform — safe fallback, no crash.
      }
    }
  }

  /// Plays haptic + audio for the given [instrument].
  /// The guitar audio file is used exclusively here — never for UI actions.
  Future<void> playInstrument(InstrumentSound instrument) async {
    if (!_enabled) return;
    switch (instrument) {
      case InstrumentSound.guitar:
      case InstrumentSound.oud:
        HapticFeedback.lightImpact();
      case InstrumentSound.piano:
        HapticFeedback.selectionClick();
      case InstrumentSound.drums:
        HapticFeedback.heavyImpact();
    }
    final asset = _assetForInstrument(instrument);
    if (asset != null) {
      try {
        await _player.play(AssetSource(asset));
      } catch (_) {
        // Safe fallback.
      }
    }
  }
}
