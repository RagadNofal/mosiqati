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

// ──────────────────────────────────────────────────────────────────────────────
//  Arabic translation tables  (built-in, no API changes needed)
// ──────────────────────────────────────────────────────────────────────────────

/// Per-product Arabic names — keyed by product id.
const _arNames = <String, String>{
  '01': 'غيتار كهربائي ياماها OC112',
  '02': 'غيتار كهربائي إيبانيز IB212O',
  '03': 'فيندر ستراتوكاستر',
  '04': 'بيانو عمودي ياماها',
  '05': 'بيانو غراند ياماها C3XPE',
  '06': 'طبول إلكترونية رولاند VAD506',
  '07': 'عود عربي - احترافي',
  '08': 'عود تركي - للحفلات',
  '09': 'واجهة صوتية Focusrite Scarlett 2i2',
  '10': 'مونيتور استوديو رولاند RM-5',
};

/// Per-product Arabic descriptions — keyed by product id.
const _arDescriptions = <String, String>{
  '01':
      'غيتار كهربائي متعدد الاستخدامات من ياماها بصوت دافئ ورنان. '
      'مثالي للمبتدئين والمحترفين في موسيقى الروك والبلوز والجاز. '
      'يأتي مع حقيبة نقل وحزام.',
  '02':
      'غيتار إيبانيز احترافي بميكروفونات هامبكر قوية وتصميم أنيق. '
      'مثالي لموسيقى الروك والميتال بعنقه السريع وجسمه الغني بالرنين.',
  '03':
      'فيندر ستراتوكاستر الأسطوري — آلة خالدة يستخدمها أعظم عازفي الغيتار في التاريخ. '
      'يتميز بثلاثة ميكروفونات أحادية الملف لصوت ساطع في أي أسلوب موسيقي.',
  '04':
      'بيانو عمودي فاخر من ياماها بصوت غني ورنان ولمسة مستجيبة. '
      'يتميز بلوح صوتي من خشب التنوب الصلب ونظام الصمت الفريد من ياماها — '
      'مثالي للتدريب المنزلي والاستوديو.',
  '05':
      'بيانو غراند ياماها على مستوى الحفلات مع نظام SH2 الصامت المتقدم. '
      'صوت وملمس واستجابة من الدرجة العالمية الأولى — '
      'مصمم للمسرح الاحترافي والموسيقي الجاد.',
  '06':
      'طقم طبول إلكترونية رائد من رولاند يجمع بين الإحساس الأكوستيكي والدقة الرقمية. '
      'رؤوس شبكية وصنجات واقعية وأكثر من 700 صوت مدمج — '
      'العزف بأي مستوى صوت دون التنازل عن التعبير.',
  '07':
      'عود عربي احترافي مصنوع يدوياً بصدى متفوق وحرفية تقليدية أصيلة. '
      'مصنوع من خشب الجوز والأرز المختار — '
      'مثالي لعروض المقامات الكلاسيكية والاندماج الحديث.',
  '08':
      'عود تركي فاخر بصوت مشرق ونافذ مثالي للحفلات الاحترافية والتسجيلات الاستوديوية. '
      'سطح من خشب التنوب، ظهر وجوانب من الماهوغاني، بمقياس 58.5 سم.',
  '09':
      'واجهة الصوت USB الأكثر مبيعاً في العالم. '
      'مقدمات صوت Focusrite بلورية مع 56 ديسيبل من الكسب، '
      'ووضع Air لصوت المحول الكلاسيكي، وزمن استجابة فائق — '
      'المعيار الذهبي للاستوديو المنزلي.',
  '10':
      'مونيتور استوديو مرجعي باستجابة تردد مسطحة للمزج والإتقان الدقيق. '
      'مكبر 5 بوصة، تصميم ثنائي التضخيم، ونقطة استماع واسعة — '
      'اسمع موسيقاك كما هي تماماً.',
};

/// Common colour translations (lowercase English key → Arabic value).
const _arColours = <String, String>{
  'red':            'أحمر',
  'black':          'أسود',
  'white':          'أبيض',
  'blue':           'أزرق',
  'green':          'أخضر',
  'brown':          'بني',
  'gold':           'ذهبي',
  'silver':         'فضي',
  'cherry':         'كرزي',
  'natural':        'طبيعي',
  'sunburst':       'غروب الشمس',
  'polished ebony': 'آبنوس مصقول',
  'silver & black': 'فضي وأسود',
  'walnut brown':   'بني جوزي',
  'mahogany':       'ماهوغاني',
  'matte black':    'أسود مطفأ',
};

/// Brand translations (lowercase English key → Arabic value).
/// Most international brands keep their English spelling.
const _arBrands = <String, String>{
  'mosiqati': 'موسيقاتي',
};

/// Category key translations — matches keys used in AppLocalizations.
const _arCategories = <String, String>{
  'guitar':      'قيثارة',
  'piano':       'بيانو',
  'drums':       'طبول',
  'oud':         'عود',
  'studio':      'استوديو',
  'studiotools': 'أدوات الاستوديو',
};

// ──────────────────────────────────────────────────────────────────────────────
//  Result (single product)
// ──────────────────────────────────────────────────────────────────────────────
class Result {
  String? id;
  String? name;
  String? category;
  String? brand;
  String? model;
  double? price;
  String? colour;
  String? weight;
  int?    quantity;
  String? description;
  String? image;
  String? videoUrl;

  // Optional Arabic overrides from JSON.
  // If the API later adds these fields they will be used automatically.
  String? nameAr;
  String? descriptionAr;
  String? modelAr;
  String? brandAr;
  String? colourAr;

  /// True when this product was loaded from Firestore (not static JSON).
  /// Used to decide whether to run the stock-deduction transaction at checkout.
  bool isFirestoreBacked;

  // Extended fields (used by Firestore-backed products).
  List<String>? images;
  String? dimensions;
  String? materialEn;
  String? materialAr;
  String? warrantyEn;
  String? warrantyAr;
  String? modelNumber;
  String? originCountryEn;
  String? originCountryAr;
  String? conditionEn;
  String? conditionAr;
  String? specificationsEn;
  String? specificationsAr;
  String? featuresEn;
  String? featuresAr;

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
    this.nameAr,
    this.descriptionAr,
    this.modelAr,
    this.brandAr,
    this.colourAr,
    this.isFirestoreBacked = false,
    // Extended fields
    this.images,
    this.dimensions,
    this.materialEn,
    this.materialAr,
    this.warrantyEn,
    this.warrantyAr,
    this.modelNumber,
    this.originCountryEn,
    this.originCountryAr,
    this.conditionEn,
    this.conditionAr,
    this.specificationsEn,
    this.specificationsAr,
    this.featuresEn,
    this.featuresAr,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id:          json["id"]?.toString(),
        name:        json["name"]?.toString(),
        category:    json["category"]?.toString(),
        brand:       json["brand"]?.toString(),
        model:       json["model"]?.toString(),
        price:       (json["price"] as num?)?.toDouble(),
        colour:      json["colour"]?.toString(),
        weight:      json["weight"]?.toString(),
        quantity:    json["quantity"] as int?,
        description: json["description"]?.toString(),
        image:       json["image"]?.toString(),
        videoUrl:    json["videoUrl"]?.toString(),
        // Arabic overrides from JSON (gracefully ignored if absent)
        nameAr:        json["nameAr"]?.toString(),
        descriptionAr: json["descriptionAr"]?.toString(),
        modelAr:       json["modelAr"]?.toString(),
        brandAr:       json["brandAr"]?.toString(),
        colourAr:      json["colourAr"]?.toString(),
      );

  // ── Localization helpers ─────────────────────────────────────────────────────
  //
  // Usage in any widget:
  //   final lang = Localizations.localeOf(context).languageCode; // 'en' or 'ar'
  //   Text(product.displayName(lang))
  //
  // ────────────────────────────────────────────────────────────────────────────

  /// Localized product name.
  String displayName(String lang) {
    if (lang != 'ar') return name ?? '';
    return nameAr ?? _arNames[id] ?? name ?? '';
  }

  /// Localized product description.
  String displayDescription(String lang) {
    if (lang != 'ar') return description ?? '';
    return descriptionAr ?? _arDescriptions[id] ?? description ?? '';
  }

  /// Localized brand name.
  String displayBrand(String lang) {
    if (lang != 'ar') return brand ?? '';
    if (brandAr != null) return brandAr!;
    return _arBrands[(brand ?? '').toLowerCase()] ?? brand ?? '';
  }

  /// Localized model — model codes are the same in both languages.
  String displayModel(String lang) {
    if (lang != 'ar') return model ?? '';
    return modelAr ?? model ?? '';
  }

  /// Localized colour.
  String displayColour(String lang) {
    if (lang != 'ar') return colour ?? '';
    if (colourAr != null) return colourAr!;
    return _arColours[(colour ?? '').toLowerCase()] ?? colour ?? '';
  }

  /// Localized category label.
  String displayCategory(String lang) {
    if (lang != 'ar') return category ?? '';
    return _arCategories[(category ?? '').toLowerCase()] ?? category ?? '';
  }

  /// Convenience: returns all localised display fields as a single map.
  Map<String, String> toLocalized(String lang) => {
    'name':        displayName(lang),
    'description': displayDescription(lang),
    'brand':       displayBrand(lang),
    'model':       displayModel(lang),
    'colour':      displayColour(lang),
    'category':    displayCategory(lang),
  };
}
