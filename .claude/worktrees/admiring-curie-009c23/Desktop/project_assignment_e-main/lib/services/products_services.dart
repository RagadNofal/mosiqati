import 'package:flutter/services.dart';
import 'package:project_assignment_e/models/product.dart';

class ProductServices {
  Future<List<Result>> fetchProducts() async {
    final String response =
        await rootBundle.loadString('assets/get-products.json');
    final product = productFromJson(response);
    return product.result!;
  }
}
