import 'package:flutter/material.dart';

/// Smart product image widget that applies priority:
///   1. imageUrl starts with "http" → Image.network (error → placeholder)
///   2. imageUrl non-empty          → Image.asset   (error → placeholder)
///   3. null / empty                → placeholder icon
class ProductImageWidget extends StatelessWidget {
  final String? imageUrl;
  final BoxFit  fit;
  final double  iconSize;
  final Color?  iconColor;

  const ProductImageWidget({
    super.key,
    required this.imageUrl,
    this.fit       = BoxFit.contain,
    this.iconSize  = 40,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final img   = imageUrl ?? '';
    final color = iconColor ?? const Color(0xFF912F56);
    final placeholder = Center(
      child: Icon(
        Icons.music_note_rounded,
        color: color.withValues(alpha: 0.3),
        size:  iconSize,
      ),
    );

    if (img.isEmpty) return placeholder;

    if (img.startsWith('http')) {
      return Image.network(
        img,
        fit:    fit,
        width:  double.infinity,
        height: double.infinity,
        errorBuilder: (_, __, ___) => placeholder,
      );
    }

    // Local asset path
    return Image.asset(
      img,
      fit:    fit,
      width:  double.infinity,
      height: double.infinity,
      errorBuilder: (_, __, ___) => placeholder,
    );
  }
}
