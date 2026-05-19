import 'package:flutter/cupertino.dart';
import 'package:project_assignment_e/models/product.dart';
import 'package:project_assignment_e/services/products_services.dart';

enum ApiStatus { loading, initial, completed, error }

class ProductProvider extends ChangeNotifier {
  List<Result> _productList = [];
  List<Result> _filteredList = [];
  bool _isFiltered = false;

  final Set<String> _favoriteIds = {};
  final Map<String, double> _ratings = {};

  ApiStatus _apiDataStatus = ApiStatus.initial;
  ApiStatus get apidatastatus => _apiDataStatus;

  List<Result> get productList =>
      _isFiltered ? _filteredList : _productList;

  bool isFavorite(String? id) => id != null && _favoriteIds.contains(id);

  double getRating(String? id) => id != null ? (_ratings[id] ?? 0.0) : 0.0;

  void getProducts() async {
    _apiDataStatus = ApiStatus.loading;
    notifyListeners();

    try {
      _productList = await ProductServices().fetchProducts();
      _apiDataStatus = ApiStatus.completed;
    } catch (_) {
      _apiDataStatus = ApiStatus.error;
    }
    notifyListeners();
  }

  void filterByCate(String categoryName) {
    _isFiltered = true;
    _filteredList = _productList
        .where((e) => e.category == categoryName.toLowerCase())
        .toList();
    notifyListeners();
  }

  void clearFilter() {
    _isFiltered = false;
    _filteredList = [];
    notifyListeners();
  }

  void searchByModel(String query) {
    if (query.isEmpty) {
      clearFilter();
      return;
    }
    _isFiltered = true;
    final q = query.toLowerCase();
    _filteredList = _productList
        .where((e) =>
            (e.model?.toLowerCase().contains(q) ?? false) ||
            (e.name?.toLowerCase().contains(q) ?? false) ||
            (e.brand?.toLowerCase().contains(q) ?? false))
        .toList();
    notifyListeners();
  }

  void toggleFavorite(String? id) {
    if (id == null) return;
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }

  void setRating(String? id, double rating) {
    if (id == null) return;
    _ratings[id] = rating;
    notifyListeners();
  }
}
