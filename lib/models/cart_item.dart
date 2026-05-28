import 'package:project_assignment_e/models/product.dart';

/// A cart entry: one product + how many units the customer wants.
class CartItem {
  final Result product;
  final int quantity;
  /// Maximum units the customer may add (comes from Firestore stock).
  /// -1 means unlimited (for demo/JSON products).
  final int maxQuantity;

  const CartItem({
    required this.product,
    required this.quantity,
    this.maxQuantity = -1,
  });

  double get totalPrice => (product.price ?? 0) * quantity;

  CartItem copyWith({int? quantity, int? maxQuantity}) => CartItem(
        product:     product,
        quantity:    quantity     ?? this.quantity,
        maxQuantity: maxQuantity  ?? this.maxQuantity,
      );

  /// True if this product came from Firestore (id is a Firestore document id,
  /// which is a random 20-char string, not the short '01'-'10' JSON ids).
  bool get isFirestoreProduct =>
      (product.id?.length ?? 0) > 4;
}
