import 'package:flutter/cupertino.dart';
import 'package:project_assignment_e/models/product.dart';

class CartProvider extends ChangeNotifier {
  final List<Result> _cartItems = [];
  List<Result> get cartItems => _cartItems;

  int get itemCount => _cartItems.length;

  void itemAddToCart(Result product) {
    _cartItems.add(product);
    notifyListeners();
  }

  void itemRemoveFromCart(Result product) {
    _cartItems.remove(product);
    notifyListeners();
  }

  double getcartTotal() {
    double total = 0;
    for (final item in _cartItems) {
      total += item.price ?? 0;
    }
    return total;
  }

  void clearCart() {
    _cartItems.clear();
    notifyListeners();
  }
}
