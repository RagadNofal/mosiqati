import 'package:flutter/cupertino.dart';
import 'package:project_assignment_e/models/coupon.dart';
import 'package:project_assignment_e/models/product.dart';
import 'package:project_assignment_e/services/coupon_service.dart';
import 'package:project_assignment_e/services/firestore_service.dart';

// ── Cart entry (one line-item) ─────────────────────────────────────────────────
class CartEntry {
  final Result product;
  int quantity;
  CartEntry({required this.product, required this.quantity});
}

// ── CartProvider ───────────────────────────────────────────────────────────────
class CartProvider extends ChangeNotifier {
  final List<CartEntry> _entries = [];
  String? _currentUid;

  List<CartEntry> get cartItems => List.unmodifiable(_entries);

  // ── Applied coupon ─────────────────────────────────────────────────────────
  Coupon? _appliedCoupon;
  Coupon? get appliedCoupon => _appliedCoupon;

  double get discountAmount =>
      _appliedCoupon?.calculateDiscount(subtotal) ?? 0.0;

  /// Total quantity across all entries — used for the cart badge.
  int get itemCount => _entries.fold(0, (sum, e) => sum + e.quantity);

  // ── Add / increment ────────────────────────────────────────────────────────

  /// Adds [product] to the cart with quantity 1, or increments an existing
  /// entry by 1. Silently ignored when out of stock or already at the stock
  /// limit.
  void itemAddToCart(Result product) {
    final stock = product.quantity ?? 0;
    if (stock <= 0) return;
    final idx = _entries.indexWhere((e) => e.product.id == product.id);
    if (idx >= 0) {
      if (_entries[idx].quantity < stock) {
        _entries[idx].quantity++;
        _syncUpsert(_entries[idx]);
        notifyListeners();
      }
    } else {
      _entries.add(CartEntry(product: product, quantity: 1));
      _syncUpsert(_entries.last);
      notifyListeners();
    }
  }

  /// How many units of [productId] are currently in the cart (0 if absent).
  int quantityInCart(String? productId) {
    if (productId == null) return 0;
    final idx = _entries.indexWhere((e) => e.product.id == productId);
    return idx >= 0 ? _entries[idx].quantity : 0;
  }

  /// Increments quantity for [productId], capped at the product's stock.
  void addQuantity(String productId) {
    final idx = _entries.indexWhere((e) => e.product.id == productId);
    if (idx < 0) return;
    final entry = _entries[idx];
    if (entry.quantity < (entry.product.quantity ?? 0)) {
      entry.quantity++;
      _syncUpsert(entry);
      notifyListeners();
    }
  }

  /// Decrements quantity for [productId]; removes the entry at 0.
  /// Clears any applied coupon when the cart becomes empty.
  void removeQuantity(String productId) {
    final idx = _entries.indexWhere((e) => e.product.id == productId);
    if (idx < 0) return;
    if (_entries[idx].quantity > 1) {
      _entries[idx].quantity--;
      _syncUpsert(_entries[idx]);
    } else {
      _syncRemove(_entries[idx].product.id);
      _entries.removeAt(idx);
    }
    if (_entries.isEmpty) _appliedCoupon = null;
    notifyListeners();
  }

  /// Removes [entry] entirely (e.g. swipe-to-dismiss).
  /// Clears any applied coupon when the cart becomes empty.
  void itemRemoveFromCart(CartEntry entry) {
    _syncRemove(entry.product.id);
    _entries.remove(entry);
    if (_entries.isEmpty) _appliedCoupon = null;
    notifyListeners();
  }

  // ── Totals ─────────────────────────────────────────────────────────────────

  double get subtotal => _entries.fold(
      0.0, (sum, e) => sum + ((e.product.price ?? 0) * e.quantity));

  /// Legacy getter kept for backward compatibility.
  double getcartTotal() => subtotal - discountAmount;

  void clearCart() {
    _syncClear();  // Also wipes the Firestore cart after checkout.
    _entries.clear();
    _appliedCoupon = null;
    notifyListeners();
  }

  /// productId → quantity for the Firestore checkout transaction.
  /// Only includes Firestore-backed products; static JSON products are skipped.
  Map<String, int> get checkoutItems => {
        for (final e in _entries)
          if (e.product.isFirestoreBacked && e.product.id != null)
            e.product.id!: e.quantity,
      };

  // ── Auth-uid binding & Firestore persistence ──────────────────────────────

  /// Called when the logged-in user changes.
  /// [uid] is non-null for a real user, null for guest / logged-out.
  /// [allProducts] is the current product list used to match live stock.
  void setCurrentUid(String? uid, List<Result> allProducts) {
    if (_currentUid == uid) return;
    _currentUid = uid;
    if (uid != null) {
      _loadCartFromFirestore(uid, allProducts);
    } else {
      // Clear in-memory only — keep Firestore cart so it restores on next login.
      _entries.clear();
      _appliedCoupon = null;
      notifyListeners();
    }
  }

  Future<void> _loadCartFromFirestore(
      String uid, List<Result> products) async {
    try {
      final docs = await FirestoreService().loadCart(uid);
      if (_currentUid != uid) return; // uid changed while loading
      _entries.clear();
      for (final data in docs) {
        final productId = data['productId'] as String?;
        if (productId == null) continue;
        final qty = (data['quantity'] as num?)?.toInt() ?? 1;
        // Prefer live product (fresh stock count); fall back to stored snapshot.
        Result? product = products.cast<Result?>().firstWhere(
          (p) => p?.id == productId,
          orElse: () => null,
        );
        product ??= _resultFromCartData(data);
        if (product == null) continue;
        final stock   = product.quantity ?? qty;
        final safeQty = qty > stock ? stock : qty;
        if (safeQty > 0) {
          _entries.add(CartEntry(product: product, quantity: safeQty));
        }
      }
      notifyListeners();
    } catch (_) {
      // Silently swallow — cart just stays empty.
    }
  }

  /// Reconstructs a [Result] from a Firestore cart document when the live
  /// product list does not yet contain this product.
  Result? _resultFromCartData(Map<String, dynamic> data) {
    final productId = data['productId'] as String?;
    if (productId == null) return null;
    return Result(
      id:               productId,
      name:             data['name']             as String?,
      nameAr:           data['nameAr']           as String?,
      model:            data['model']            as String?,
      modelAr:          data['modelAr']          as String?,
      brand:            data['brand']            as String?,
      brandAr:          data['brandAr']          as String?,
      price:            (data['price']       as num?)?.toDouble(),
      image:            data['image']            as String?,
      category:         data['category']         as String?,
      quantity:         (data['maxQuantity'] as num?)?.toInt(),
      isFirestoreBacked: (data['isFirestoreBacked'] as bool?) ?? false,
    );
  }

  // ── Firestore sync helpers (fire-and-forget) ──────────────────────────────

  void _syncUpsert(CartEntry entry) {
    final uid = _currentUid;
    final id  = entry.product.id;
    if (uid == null || id == null) return;
    final p = entry.product;
    FirestoreService().upsertCartItem(uid, id, {
      'quantity':          entry.quantity,
      'name':              p.name,
      'nameAr':            p.nameAr,
      'model':             p.model,
      'modelAr':           p.modelAr,
      'brand':             p.brand,
      'brandAr':           p.brandAr,
      'price':             p.price,
      'image':             p.image,
      'category':          p.category,
      'maxQuantity':       p.quantity,
      'isFirestoreBacked': p.isFirestoreBacked,
    });
  }

  void _syncRemove(String? productId) {
    if (_currentUid == null || productId == null) return;
    FirestoreService().removeCartItem(_currentUid!, productId);
  }

  void _syncClear() {
    if (_currentUid == null) return;
    FirestoreService().clearUserCart(_currentUid!);
  }

  // ── Coupon logic ───────────────────────────────────────────────────────────

  /// Tries to apply a coupon by [code].
  /// Returns null on success; returns a localisation error key on failure.
  Future<String?> applyCoupon(String code) async {
    if (code.trim().isEmpty) return 'couponNotFound';
    if (_entries.isEmpty) return 'couponCartEmpty';
    try {
      final service = CouponService();
      final coupon  = await service.findByCode(code.trim());
      if (coupon == null) return 'couponNotFound';
      final errorKey = service.validateCoupon(coupon, subtotal);
      if (errorKey != null) return errorKey;
      _appliedCoupon = coupon;
      notifyListeners();
      return null; // success
    } catch (_) {
      return 'couponNotFound';
    }
  }

  void removeCoupon() {
    _appliedCoupon = null;
    notifyListeners();
  }
}
