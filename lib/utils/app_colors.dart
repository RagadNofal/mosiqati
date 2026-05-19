import 'package:flutter/material.dart';

class AppColors {
  // ── Brand palette (raspberry × plum × wine) ──────────────────────────────
  static const Color primary       = Color(0xFF912F56); // raspberry
  static const Color primaryLight  = Color(0xFFC4587E); // rose
  static const Color primaryDark   = Color(0xFF521945); // plum
  static const Color wine          = Color(0xFF361F27);

  // Alias kept for backward-compat with existing widgets
  static const Color primaryLighter = Color(0xFFC4587E);

  // ── Accent ────────────────────────────────────────────────────────────────
  static const Color gold      = Color(0xFFD4A853);
  static const Color goldLight = Color(0xFFE8C76C);
  static const Color sage      = Color(0xFF3D7A6A);
  static const Color sageLight = Color(0xFF6AAF9E);

  // ── Light-mode surfaces ────────────────────────────────────────────────────
  static const Color bgLight      = Color(0xFFFAF0EE);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight    = Color(0xFFF0E5EB);
  static const Color mintAccent   = Color(0xFFEAF2EF);

  // ── Dark-mode surfaces ─────────────────────────────────────────────────────
  static const Color bgDark      = Color(0xFF0D090A);
  static const Color surfaceDark = Color(0xFF1C0F16);
  static const Color cardDark    = Color(0xFF28141E);

  // ── Product-card gradient colours ─────────────────────────────────────────
  static const List<Color> cardColors = [
    Color(0xFF912F56), // raspberry
    Color(0xFF521945), // plum
    Color(0xFF361F27), // wine
    Color(0xFF3D7A6A), // sage
    Color(0xFF7A2C4A), // dark rose
  ];

  // ── Category accent colours ────────────────────────────────────────────────
  static const Color catGuitar = Color(0xFF912F56);
  static const Color catPiano  = Color(0xFF521945);
  static const Color catDrums  = Color(0xFF3D7A6A);
  static const Color catOud    = Color(0xFFD4A853);
  static const Color catStudio = Color(0xFF1A3B5A);

  // ── Text ──────────────────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF361F27);
  static const Color textSecondary = Color(0xFF6B3557);
  static const Color textLight     = Color(0xFFFFFFFF);

  // ── Divider ───────────────────────────────────────────────────────────────
  static const Color divider = Color(0xFFF0D8E0);
}
