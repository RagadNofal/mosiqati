import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:project_assignment_e/models/product.dart';

/// A product stored in Firestore.
/// Bridges with the existing [Result] class via [toResult()].
class FirestoreProduct {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double price;
  final int quantity;
  /// Primary network URL (legacy / single-image path)
  final String imageUrl;
  /// Local asset path e.g. "assets/images/guitar.jpg" or empty string
  final String imageAsset;
  /// Multiple image URLs — preferred over imageUrl when non-empty.
  final List<String> images;
  final String category;
  final bool isAvailable;

  // ── Extended product fields ────────────────────────────────────────────────
  final String brandEn;
  final String brandAr;
  final String colorEn;
  final String colorAr;
  final String weight;
  final String dimensions;
  final String materialEn;
  final String materialAr;
  final String warrantyEn;
  final String warrantyAr;
  final String modelNumber;
  final String originCountryEn;
  final String originCountryAr;
  final String conditionEn;
  final String conditionAr;
  final String specificationsEn;
  final String specificationsAr;
  final String featuresEn;
  final String featuresAr;

  // ── Timestamps ────────────────────────────────────────────────────────────
  final DateTime createdAt;
  final DateTime updatedAt;

  FirestoreProduct({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.price,
    required this.quantity,
    required this.imageUrl,
    required this.imageAsset,
    this.images = const [],
    required this.category,
    required this.isAvailable,
    this.brandEn = '',
    this.brandAr = '',
    this.colorEn = '',
    this.colorAr = '',
    this.weight = '',
    this.dimensions = '',
    this.materialEn = '',
    this.materialAr = '',
    this.warrantyEn = '',
    this.warrantyAr = '',
    this.modelNumber = '',
    this.originCountryEn = '',
    this.originCountryAr = '',
    this.conditionEn = '',
    this.conditionAr = '',
    this.specificationsEn = '',
    this.specificationsAr = '',
    this.featuresEn = '',
    this.featuresAr = '',
    required this.createdAt,
    required this.updatedAt,
  });

  bool get isOutOfStock => quantity <= 0;
  bool get isLowStock   => quantity > 0 && quantity <= 5;

  /// All images: images list → imageUrl → imageAsset.
  List<String> get allImages {
    if (images.isNotEmpty) return images;
    final single = imageUrl.isNotEmpty ? imageUrl : imageAsset;
    return single.isNotEmpty ? [single] : const [];
  }

  /// Primary display image.
  String get displayImage {
    if (images.isNotEmpty) return images.first;
    if (imageUrl.isNotEmpty) return imageUrl;
    return imageAsset;
  }

  factory FirestoreProduct.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;

    // Parse images list stored as List<dynamic> in Firestore
    final rawImages = d['images'];
    final List<String> imageList = rawImages is List
        ? rawImages.map((e) => e.toString()).where((s) => s.isNotEmpty).toList()
        : [];

    return FirestoreProduct(
      id:            doc.id,
      nameEn:        d['nameEn']        as String? ?? '',
      nameAr:        d['nameAr']        as String? ?? '',
      descriptionEn: d['descriptionEn'] as String? ?? '',
      descriptionAr: d['descriptionAr'] as String? ?? '',
      price:         (d['price']        as num?)?.toDouble() ?? 0.0,
      quantity:      d['quantity']      as int?    ?? 0,
      imageUrl:      d['imageUrl']      as String? ?? '',
      imageAsset:    d['imageAsset']    as String? ?? '',
      images:        imageList,
      category:      d['category']      as String? ?? '',
      isAvailable:   d['isAvailable']   as bool?   ?? true,
      brandEn:       d['brandEn']       as String? ?? '',
      brandAr:       d['brandAr']       as String? ?? '',
      colorEn:       d['colorEn']       as String? ?? '',
      colorAr:       d['colorAr']       as String? ?? '',
      weight:        d['weight']        as String? ?? '',
      dimensions:    d['dimensions']    as String? ?? '',
      materialEn:    d['materialEn']    as String? ?? '',
      materialAr:    d['materialAr']    as String? ?? '',
      warrantyEn:    d['warrantyEn']    as String? ?? '',
      warrantyAr:    d['warrantyAr']    as String? ?? '',
      modelNumber:   d['modelNumber']   as String? ?? '',
      originCountryEn: d['originCountryEn'] as String? ?? '',
      originCountryAr: d['originCountryAr'] as String? ?? '',
      conditionEn:   d['conditionEn']   as String? ?? '',
      conditionAr:   d['conditionAr']   as String? ?? '',
      specificationsEn: d['specificationsEn'] as String? ?? '',
      specificationsAr: d['specificationsAr'] as String? ?? '',
      featuresEn:    d['featuresEn']    as String? ?? '',
      featuresAr:    d['featuresAr']    as String? ?? '',
      createdAt:     (d['createdAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt:     (d['updatedAt']    as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'nameEn':        nameEn,
        'nameAr':        nameAr,
        'descriptionEn': descriptionEn,
        'descriptionAr': descriptionAr,
        'price':         price,
        'quantity':      quantity,
        'imageUrl':      imageUrl,
        'imageAsset':    imageAsset,
        'images':        images,
        'category':      category,
        'isAvailable':   isAvailable,
        'brandEn':       brandEn,
        'brandAr':       brandAr,
        'colorEn':       colorEn,
        'colorAr':       colorAr,
        'weight':        weight,
        'dimensions':    dimensions,
        'materialEn':    materialEn,
        'materialAr':    materialAr,
        'warrantyEn':    warrantyEn,
        'warrantyAr':    warrantyAr,
        'modelNumber':   modelNumber,
        'originCountryEn': originCountryEn,
        'originCountryAr': originCountryAr,
        'conditionEn':   conditionEn,
        'conditionAr':   conditionAr,
        'specificationsEn': specificationsEn,
        'specificationsAr': specificationsAr,
        'featuresEn':    featuresEn,
        'featuresAr':    featuresAr,
        'createdAt':     Timestamp.fromDate(createdAt),
        'updatedAt':     Timestamp.fromDate(updatedAt),
      };

  FirestoreProduct copyWith({
    String?       nameEn,
    String?       nameAr,
    String?       descriptionEn,
    String?       descriptionAr,
    double?       price,
    int?          quantity,
    String?       imageUrl,
    String?       imageAsset,
    List<String>? images,
    String?       category,
    bool?         isAvailable,
    String?       brandEn,
    String?       brandAr,
    String?       colorEn,
    String?       colorAr,
    String?       weight,
    String?       dimensions,
    String?       materialEn,
    String?       materialAr,
    String?       warrantyEn,
    String?       warrantyAr,
    String?       modelNumber,
    String?       originCountryEn,
    String?       originCountryAr,
    String?       conditionEn,
    String?       conditionAr,
    String?       specificationsEn,
    String?       specificationsAr,
    String?       featuresEn,
    String?       featuresAr,
    DateTime?     updatedAt,
  }) =>
      FirestoreProduct(
        id:            id,
        nameEn:        nameEn        ?? this.nameEn,
        nameAr:        nameAr        ?? this.nameAr,
        descriptionEn: descriptionEn ?? this.descriptionEn,
        descriptionAr: descriptionAr ?? this.descriptionAr,
        price:         price         ?? this.price,
        quantity:      quantity      ?? this.quantity,
        imageUrl:      imageUrl      ?? this.imageUrl,
        imageAsset:    imageAsset    ?? this.imageAsset,
        images:        images        ?? this.images,
        category:      category      ?? this.category,
        isAvailable:   isAvailable   ?? this.isAvailable,
        brandEn:       brandEn       ?? this.brandEn,
        brandAr:       brandAr       ?? this.brandAr,
        colorEn:       colorEn       ?? this.colorEn,
        colorAr:       colorAr       ?? this.colorAr,
        weight:        weight        ?? this.weight,
        dimensions:    dimensions    ?? this.dimensions,
        materialEn:    materialEn    ?? this.materialEn,
        materialAr:    materialAr    ?? this.materialAr,
        warrantyEn:    warrantyEn    ?? this.warrantyEn,
        warrantyAr:    warrantyAr    ?? this.warrantyAr,
        modelNumber:   modelNumber   ?? this.modelNumber,
        originCountryEn: originCountryEn ?? this.originCountryEn,
        originCountryAr: originCountryAr ?? this.originCountryAr,
        conditionEn:   conditionEn   ?? this.conditionEn,
        conditionAr:   conditionAr   ?? this.conditionAr,
        specificationsEn: specificationsEn ?? this.specificationsEn,
        specificationsAr: specificationsAr ?? this.specificationsAr,
        featuresEn:    featuresEn    ?? this.featuresEn,
        featuresAr:    featuresAr    ?? this.featuresAr,
        createdAt:     createdAt,
        updatedAt:     updatedAt     ?? DateTime.now(),
      );

  /// Convert to the existing [Result] model so all current screens work unchanged.
  Result toResult() => Result(
        id:            id,
        name:          nameEn,
        nameAr:        nameAr.isNotEmpty ? nameAr : null,
        category:      category,
        brand:         brandEn,
        brandAr:       brandAr.isNotEmpty ? brandAr : null,
        model:         nameEn,
        modelAr:       nameAr.isNotEmpty ? nameAr : null,
        price:         price,
        colour:        colorEn,
        colourAr:      colorAr.isNotEmpty ? colorAr : null,
        weight:        weight.isNotEmpty ? weight : null,
        quantity:      quantity,
        description:   descriptionEn.isNotEmpty ? descriptionEn : null,
        descriptionAr: descriptionAr.isNotEmpty ? descriptionAr : null,
        image:         displayImage,
        images:        allImages.isNotEmpty ? allImages : null,
        videoUrl:      null,
        dimensions:    dimensions.isNotEmpty ? dimensions : null,
        materialEn:    materialEn.isNotEmpty ? materialEn : null,
        materialAr:    materialAr.isNotEmpty ? materialAr : null,
        warrantyEn:    warrantyEn.isNotEmpty ? warrantyEn : null,
        warrantyAr:    warrantyAr.isNotEmpty ? warrantyAr : null,
        modelNumber:   modelNumber.isNotEmpty ? modelNumber : null,
        originCountryEn: originCountryEn.isNotEmpty ? originCountryEn : null,
        originCountryAr: originCountryAr.isNotEmpty ? originCountryAr : null,
        conditionEn:   conditionEn.isNotEmpty ? conditionEn : null,
        conditionAr:   conditionAr.isNotEmpty ? conditionAr : null,
        specificationsEn: specificationsEn.isNotEmpty ? specificationsEn : null,
        specificationsAr: specificationsAr.isNotEmpty ? specificationsAr : null,
        featuresEn:    featuresEn.isNotEmpty ? featuresEn : null,
        featuresAr:    featuresAr.isNotEmpty ? featuresAr : null,
      );
}
