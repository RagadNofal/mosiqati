import 'dart:convert';

Product productFromJson(String str) => Product.fromJson(json.decode(str));

class Product {
  bool? status;
  List<Result>? result;

  Product({required this.status, required this.result});

  factory Product.fromJson(Map<String, dynamic> json) => Product(
        status: json["status"],
        result: List<Result>.from(
            json["result"].map((x) => Result.fromJson(x))),
      );
}

class Result {
  String? id;
  String? name;
  String? category;
  String? brand;
  String? model;
  double? price;
  String? colour;
  String? weight;
  int? quantity;
  String? description;
  String? image;
  String? videoUrl;

  Result({
    this.id,
    this.name,
    this.category,
    this.brand,
    this.model,
    this.price,
    this.colour,
    this.weight,
    this.quantity,
    this.description,
    this.image,
    this.videoUrl,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        name: json["name"],
        category: json["category"],
        brand: json["brand"],
        model: json["model"],
        price: (json["price"] as num?)?.toDouble(),
        colour: json["colour"],
        weight: json["weight"],
        quantity: json["quantity"],
        description: json["description"],
        image: json["image"],
        videoUrl: json["videoUrl"],
      );
}
