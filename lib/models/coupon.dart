import 'package:cloud_firestore/cloud_firestore.dart';

// ── Status ────────────────────────────────────────────────────────────────────
enum CouponStatus { active, expired, notStarted, usageLimitReached, inactive }

// ── Coupon model ─────────────────────────────────────────────────────────────
class Coupon {
  final String  id;
  final String  code;           // always uppercase
  final String  titleEn;
  final String  titleAr;
  final String  descriptionEn;
  final String  descriptionAr;
  final String  discountType;   // 'percentage' | 'fixed'
  final double  discountValue;
  final double  minOrderAmount;
  final double? maxDiscountAmount; // null = no cap
  final DateTime validFrom;
  final DateTime validUntil;
  final bool    isActive;
  final int?    usageLimit;     // null = unlimited
  final int     usedCount;
  final DateTime createdAt;
  final DateTime updatedAt;

  const Coupon({
    required this.id,
    required this.code,
    required this.titleEn,
    required this.titleAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.discountType,
    required this.discountValue,
    required this.minOrderAmount,
    this.maxDiscountAmount,
    required this.validFrom,
    required this.validUntil,
    required this.isActive,
    this.usageLimit,
    required this.usedCount,
    required this.createdAt,
    required this.updatedAt,
  });

  // ── Firestore bridge ──────────────────────────────────────────────────────

  factory Coupon.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    DateTime tsField(String key) {
      final v = d[key];
      if (v is Timestamp) return v.toDate();
      return DateTime.now();
    }

    return Coupon(
      id:                 doc.id,
      code:               (d['code'] as String? ?? '').toUpperCase(),
      titleEn:            d['titleEn']        as String? ?? '',
      titleAr:            d['titleAr']        as String? ?? '',
      descriptionEn:      d['descriptionEn']  as String? ?? '',
      descriptionAr:      d['descriptionAr']  as String? ?? '',
      discountType:       d['discountType']   as String? ?? 'percentage',
      discountValue:      (d['discountValue'] as num? ?? 0).toDouble(),
      minOrderAmount:     (d['minOrderAmount'] as num? ?? 0).toDouble(),
      maxDiscountAmount:  d['maxDiscountAmount'] != null
          ? (d['maxDiscountAmount'] as num).toDouble()
          : null,
      validFrom:          tsField('validFrom'),
      validUntil:         tsField('validUntil'),
      isActive:           d['isActive']  as bool? ?? false,
      usageLimit:         d['usageLimit'] as int?,
      usedCount:          d['usedCount'] as int? ?? 0,
      createdAt:          tsField('createdAt'),
      updatedAt:          tsField('updatedAt'),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'code':               code.toUpperCase(),
    'titleEn':            titleEn,
    'titleAr':            titleAr,
    'descriptionEn':      descriptionEn,
    'descriptionAr':      descriptionAr,
    'discountType':       discountType,
    'discountValue':      discountValue,
    'minOrderAmount':     minOrderAmount,
    'maxDiscountAmount':  maxDiscountAmount,
    'validFrom':          Timestamp.fromDate(validFrom),
    'validUntil':         Timestamp.fromDate(validUntil),
    'isActive':           isActive,
    'usageLimit':         usageLimit,
    'usedCount':          usedCount,
    'createdAt':          Timestamp.fromDate(createdAt),
    'updatedAt':          Timestamp.fromDate(updatedAt),
  };

  Coupon copyWith({
    String?   id,
    String?   code,
    String?   titleEn,
    String?   titleAr,
    String?   descriptionEn,
    String?   descriptionAr,
    String?   discountType,
    double?   discountValue,
    double?   minOrderAmount,
    double?   maxDiscountAmount,
    DateTime? validFrom,
    DateTime? validUntil,
    bool?     isActive,
    int?      usageLimit,
    int?      usedCount,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Coupon(
    id:                 id                ?? this.id,
    code:               code              ?? this.code,
    titleEn:            titleEn           ?? this.titleEn,
    titleAr:            titleAr           ?? this.titleAr,
    descriptionEn:      descriptionEn     ?? this.descriptionEn,
    descriptionAr:      descriptionAr     ?? this.descriptionAr,
    discountType:       discountType      ?? this.discountType,
    discountValue:      discountValue     ?? this.discountValue,
    minOrderAmount:     minOrderAmount    ?? this.minOrderAmount,
    maxDiscountAmount:  maxDiscountAmount ?? this.maxDiscountAmount,
    validFrom:          validFrom         ?? this.validFrom,
    validUntil:         validUntil        ?? this.validUntil,
    isActive:           isActive          ?? this.isActive,
    usageLimit:         usageLimit        ?? this.usageLimit,
    usedCount:          usedCount         ?? this.usedCount,
    createdAt:          createdAt         ?? this.createdAt,
    updatedAt:          updatedAt         ?? this.updatedAt,
  );

  // ── Computed properties ───────────────────────────────────────────────────

  /// Current status based on date, activity flag, and usage.
  CouponStatus get status {
    if (!isActive) return CouponStatus.inactive;
    final now = DateTime.now();
    if (now.isBefore(validFrom))  return CouponStatus.notStarted;
    if (now.isAfter(validUntil))  return CouponStatus.expired;
    if (usageLimit != null && usedCount >= usageLimit!) {
      return CouponStatus.usageLimitReached;
    }
    return CouponStatus.active;
  }

  bool get isCurrentlyValid => status == CouponStatus.active;

  /// Calculate discount amount for a given subtotal.
  /// Returns 0 if the coupon is not valid or subtotal is below minimum.
  double calculateDiscount(double subtotal) {
    if (subtotal < minOrderAmount) return 0.0;
    double discount;
    if (discountType == 'percentage') {
      discount = subtotal * discountValue / 100.0;
      if (maxDiscountAmount != null) {
        discount = discount.clamp(0.0, maxDiscountAmount!);
      }
    } else {
      // fixed
      discount = discountValue;
    }
    // Never exceed the subtotal
    return discount.clamp(0.0, subtotal);
  }

  /// Localised title helper.
  String displayTitle(String lang) =>
      lang == 'ar' ? titleAr : titleEn;
}
