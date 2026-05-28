import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_assignment_e/models/coupon.dart';

class CouponService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _coupons =>
      _db.collection('coupons');

  // ── Streams ────────────────────────────────────────────────────────────────

  /// Stream all coupons for admin view, sorted by createdAt descending.
  Stream<List<Coupon>> streamAllCoupons() => _coupons
      .snapshots()
      .map((snap) {
        final list = snap.docs
            .map((d) => Coupon.fromFirestore(d))
            .toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  // ── Single reads ───────────────────────────────────────────────────────────

  /// Find a coupon by its code (case-insensitive).
  /// Returns null if not found.
  Future<Coupon?> findByCode(String code) async {
    final upper = code.trim().toUpperCase();
    final snap  = await _coupons
        .where('code', isEqualTo: upper)
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    return Coupon.fromFirestore(snap.docs.first);
  }

  // ── Validation ─────────────────────────────────────────────────────────────

  /// Validates a coupon against a given subtotal.
  /// Returns a localisation key string on error, or null when valid.
  String? validateCoupon(Coupon coupon, double subtotal) {
    switch (coupon.status) {
      case CouponStatus.inactive:
        return 'couponInactive';
      case CouponStatus.notStarted:
        return 'couponNotStarted';
      case CouponStatus.expired:
        return 'couponExpired';
      case CouponStatus.usageLimitReached:
        return 'couponUsageLimitReached';
      case CouponStatus.active:
        break;
    }
    if (subtotal < coupon.minOrderAmount) {
      return 'couponMinOrderError';
    }
    return null; // valid
  }

  // ── Writes ─────────────────────────────────────────────────────────────────

  Future<DocumentReference> addCoupon(Coupon coupon) =>
      _coupons.add({
        ...coupon.toFirestore(),
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> updateCoupon(Coupon coupon) =>
      _coupons.doc(coupon.id).update({
        ...coupon.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> toggleActive(String id, bool currentValue) =>
      _coupons.doc(id).update({
        'isActive':  !currentValue,
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> deleteCoupon(String id) => _coupons.doc(id).delete();
}
