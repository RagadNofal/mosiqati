import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_assignment_e/models/coupon.dart';
import 'package:project_assignment_e/models/firestore_product.dart';
import 'package:project_assignment_e/services/coupon_service.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _products =>
      _db.collection('products');
  CollectionReference<Map<String, dynamic>> get _orders =>
      _db.collection('orders');

  // ── Product streams ────────────────────────────────────────────────────────

  /// All products (admin view) — sorted client-side by createdAt descending.
  Stream<List<FirestoreProduct>> streamAllProducts() => _products
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(FirestoreProduct.fromFirestore).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  /// Only available products (customer view).
  Stream<List<FirestoreProduct>> streamAvailableProducts() => _products
      .where('isAvailable', isEqualTo: true)
      .snapshots()
      .map((snap) {
        final list = snap.docs.map(FirestoreProduct.fromFirestore).toList();
        list.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return list;
      });

  // ── Single-document reads ──────────────────────────────────────────────────

  Future<FirestoreProduct?> getProduct(String id) async {
    final doc = await _products.doc(id).get();
    if (!doc.exists) return null;
    return FirestoreProduct.fromFirestore(doc);
  }

  // ── Product writes ────────────────────────────────────────────────────────

  Future<DocumentReference> addProduct(FirestoreProduct product) =>
      _products.add(product.toFirestore());

  Future<void> updateProduct(FirestoreProduct product) =>
      _products.doc(product.id).update({
        ...product.toFirestore(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

  Future<void> disableProduct(String id) => _products.doc(id).update({
        'isAvailable': false,
        'updatedAt':   FieldValue.serverTimestamp(),
      });

  Future<void> enableProduct(String id) => _products.doc(id).update({
        'isAvailable': true,
        'updatedAt':   FieldValue.serverTimestamp(),
      });

  Future<void> deleteProduct(String id) => _products.doc(id).delete();

  // ── Checkout transaction ──────────────────────────────────────────────────

  /// Atomically:
  ///   1. Re-validates stock for each product.
  ///   2. Re-validates the coupon (if any) inside the transaction.
  ///   3. Deducts stock.
  ///   4. Increments coupon usedCount (if coupon applied).
  ///   5. Saves the order to the `orders` collection.
  ///
  /// [items] is a map of productId → quantityToBuy.
  /// Throws [CheckoutException] on validation failure.
  Future<void> checkout(
    Map<String, int> items, {
    String  userId         = '',
    double  subtotal       = 0,
    double  discountAmount = 0,
    double  finalTotal     = 0,
    Coupon? coupon,
  }) async {
    await _db.runTransaction((tx) async {
      // ── 1. Read all product documents first ──────────────────────────────
      final refs  = items.keys.map((id) => _products.doc(id)).toList();
      final snaps = await Future.wait(refs.map(tx.get));

      // ── 2. Optionally read the coupon document for re-validation ─────────
      DocumentSnapshot<Map<String, dynamic>>? couponSnap;
      DocumentReference<Map<String, dynamic>>? couponRef;
      if (coupon != null) {
        couponRef  = _db.collection('coupons').doc(coupon.id);
        couponSnap = await tx.get(couponRef);
      }

      // ── 3. Validate stock ─────────────────────────────────────────────────
      for (int i = 0; i < refs.length; i++) {
        final snap    = snaps[i];
        final id      = refs[i].id;
        final wantQty = items[id]!;

        if (!snap.exists) {
          throw CheckoutException('Product $id no longer exists.');
        }
        final product = FirestoreProduct.fromFirestore(snap);
        if (!product.isAvailable) {
          throw CheckoutException(
              '"${product.nameEn}" is no longer available.');
        }
        if (product.quantity < wantQty) {
          throw CheckoutException(
              'Only ${product.quantity} unit(s) left for "${product.nameEn}".');
        }
      }

      // ── 4. Re-validate coupon (inside transaction) ───────────────────────
      if (coupon != null && couponSnap != null && couponRef != null) {
        if (!couponSnap.exists) {
          throw CheckoutException('couponNotFound');
        }
        final liveCoupon = Coupon.fromFirestore(couponSnap);
        final err = CouponService().validateCoupon(liveCoupon, subtotal);
        if (err != null) {
          throw CheckoutException(err);
        }
      }

      // ── 5. Deduct stock ───────────────────────────────────────────────────
      for (int i = 0; i < refs.length; i++) {
        final snap    = snaps[i];
        final id      = refs[i].id;
        final wantQty = items[id]!;
        final current = (snap.data()!['quantity'] as int?) ?? 0;
        tx.update(refs[i], {
          'quantity':  current - wantQty,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // ── 6. Increment coupon usedCount ─────────────────────────────────────
      if (coupon != null && couponRef != null) {
        tx.update(couponRef, {
          'usedCount': FieldValue.increment(1),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      // ── 7. Save order ─────────────────────────────────────────────────────
      final orderRef = _orders.doc();
      tx.set(orderRef, {
        'userId':         userId,
        'items':          items.map((k, v) => MapEntry(k, v)),
        'subtotal':       subtotal,
        'couponCode':     coupon?.code,
        'discountAmount': discountAmount,
        'total':          finalTotal,
        'status':         'pending',
        'createdAt':      FieldValue.serverTimestamp(),
      });
    });
  }
}

/// Thrown when a checkout transaction fails due to stock or coupon issues.
class CheckoutException implements Exception {
  final String message;
  const CheckoutException(this.message);
  @override
  String toString() => message;
}
