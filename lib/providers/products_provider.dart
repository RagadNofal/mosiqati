import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:project_assignment_e/models/firestore_product.dart';
import 'package:project_assignment_e/models/product.dart';
import 'package:project_assignment_e/services/firestore_service.dart';
import 'package:project_assignment_e/services/products_services.dart';

enum ApiStatus { loading, initial, completed, error }

class ProductProvider extends ChangeNotifier {
  List<Result> _productList  = [];
  List<Result> _filteredList = [];
  bool   _isFiltered  = false;
  String _filterCat   = '';
  String _searchQuery = '';

  final Set<String>           _favoriteIds = {};
  final Map<String, double>   _ratings     = {};
  String?                     _currentUid;

  StreamSubscription<List<FirestoreProduct>>? _subscription;

  ApiStatus _apiDataStatus = ApiStatus.initial;
  ApiStatus get apidatastatus => _apiDataStatus;

  List<Result> get productList =>
      _isFiltered ? _filteredList : _productList;

  /// Always returns the full, unfiltered product list.
  /// Use this instead of [productList] when you need all products regardless
  /// of any active home-page category filter.
  List<Result> get allProducts => List.unmodifiable(_productList);

  Set<String> get favorites => Set.unmodifiable(_favoriteIds);

  bool isFavorite(String? id) => id != null && _favoriteIds.contains(id);

  double getRating(String? id) => id != null ? (_ratings[id] ?? 0.0) : 0.0;

  // ── Load products ─────────────────────────────────────────────────────────
  /// Streams available products from Firestore.
  /// Falls back to bundled static JSON when Firestore returns an empty list
  /// or encounters an error.
  void getProducts() {
    _apiDataStatus = ApiStatus.loading;
    notifyListeners();

    _subscription?.cancel();
    _subscription = FirestoreService()
        .streamAvailableProducts()
        .listen(
      (firestoreList) async {
        if (firestoreList.isNotEmpty) {
          _productList = firestoreList.map((p) => p.toResult()).toList();
        } else {
          // Firestore has no available products — use bundled JSON.
          try {
            _productList = await ProductServices().fetchProducts();
          } catch (_) {
            _productList = [];
          }
        }
        _apiDataStatus = ApiStatus.completed;
        _reapply();
        notifyListeners();
      },
      onError: (_) async {
        // Firestore unavailable — use bundled JSON.
        try {
          _productList = await ProductServices().fetchProducts();
          _apiDataStatus = ApiStatus.completed;
        } catch (__) {
          _apiDataStatus = ApiStatus.error;
        }
        _reapply();
        notifyListeners();
      },
    );
  }

  /// Re-apply active category/search filter after the product list refreshes.
  void _reapply() {
    if (!_isFiltered) return;
    List<Result> base = _productList;
    if (_filterCat.isNotEmpty) {
      base = base
          .where((e) =>
              e.category?.toLowerCase() == _filterCat.toLowerCase())
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      base = base
          .where((e) =>
              (e.model?.toLowerCase().contains(q) ?? false) ||
              (e.name?.toLowerCase().contains(q) ?? false) ||
              (e.brand?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    _filteredList = base;
  }

  // ── Filtering ─────────────────────────────────────────────────────────────

  void filterByCate(String categoryName) {
    _isFiltered   = true;
    _filterCat    = categoryName;
    _searchQuery  = '';
    _filteredList = _productList
        .where((e) =>
            e.category?.toLowerCase() == categoryName.toLowerCase())
        .toList();
    notifyListeners();
  }

  void clearFilter() {
    _isFiltered   = false;
    _filterCat    = '';
    _searchQuery  = '';
    _filteredList = [];
    notifyListeners();
  }

  void searchByModel(String query) {
    _searchQuery = query;
    if (query.isEmpty) {
      if (_filterCat.isNotEmpty) {
        filterByCate(_filterCat);
      } else {
        clearFilter();
      }
      return;
    }
    _isFiltered = true;
    final q    = query.toLowerCase();
    final base = _filterCat.isNotEmpty
        ? _productList
            .where((e) =>
                e.category?.toLowerCase() == _filterCat.toLowerCase())
            .toList()
        : _productList;
    _filteredList = base
        .where((e) =>
            (e.model?.toLowerCase().contains(q) ?? false) ||
            (e.name?.toLowerCase().contains(q) ?? false) ||
            (e.brand?.toLowerCase().contains(q) ?? false))
        .toList();
    notifyListeners();
  }

  // ── Auth-uid binding ──────────────────────────────────────────────────────

  /// Called when the logged-in user changes.
  /// [uid] is non-null for a real user, null for guest / logged-out.
  /// Guard prevents redundant reloads when auth fires multiple events.
  void setCurrentUid(String? uid) {
    if (_currentUid == uid) return;
    _currentUid = uid;
    if (uid != null) {
      _loadFavoritesFromFirestore(uid);
    } else {
      _favoriteIds.clear();
      notifyListeners();
    }
  }

  Future<void> _loadFavoritesFromFirestore(String uid) async {
    try {
      final ids = await FirestoreService().loadFavorites(uid);
      if (_currentUid != uid) return; // uid changed while request was in-flight
      _favoriteIds
        ..clear()
        ..addAll(ids);
      notifyListeners();
    } catch (_) {
      // Silently swallow — favorites just won't be pre-loaded.
    }
  }

  // ── Favourites & ratings ──────────────────────────────────────────────────

  void toggleFavorite(String? id) {
    if (id == null) return;
    final adding = !_favoriteIds.contains(id);
    if (adding) {
      _favoriteIds.add(id);
    } else {
      _favoriteIds.remove(id);
    }
    notifyListeners();
    // Fire-and-forget Firestore sync for logged-in users.
    if (_currentUid != null) {
      if (adding) {
        FirestoreService().addFavorite(_currentUid!, id);
      } else {
        FirestoreService().removeFavorite(_currentUid!, id);
      }
    }
  }

  void setRating(String? id, double rating) {
    if (id == null) return;
    _ratings[id] = rating;
    notifyListeners();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
