import 'package:setgo/src/utils/safe_parser.dart';

class ProductCategory {
  final String? id;
  final String? category;
  final String? subcategory;
  final List<String>? subcategories;
  final String? iconUrl;

  const ProductCategory({
    this.id,
    this.category,
    this.subcategory,
    this.subcategories,
    this.iconUrl,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    final subs = json['subcategories'] is List
        ? (json['subcategories'] as List)
            .map((e) => e.toString())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];
    final single = json['subcategory']?.toString();
    return ProductCategory(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      category: json['category'] as String?,
      subcategory: (single != null && single.isNotEmpty)
          ? single
          : (subs.isNotEmpty ? subs.first : null),
      subcategories: subs.isNotEmpty ? subs : null,
      iconUrl: json['iconUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
      'subcategory': subcategory,
      'subcategories': subcategories,
      'iconUrl': iconUrl,
    };
  }
}

class ProductSpec {
  final String key;
  final String value;

  const ProductSpec({required this.key, required this.value});

  factory ProductSpec.fromJson(Map<String, dynamic> json) {
    return ProductSpec(
      key: json['key']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'key': key, 'value': value};
}

class ProductVariantAttribute {
  final String name;
  final String value;

  const ProductVariantAttribute({required this.name, required this.value});

  factory ProductVariantAttribute.fromJson(Map<String, dynamic> json) {
    return ProductVariantAttribute(
      name: json['name']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'name': name, 'value': value};
}

class ProductVariant {
  final String? id;
  final String? name;
  final String? sku;
  final double? price;
  final double? offerPrice;
  final bool inStock;
  final List<ProductVariantAttribute> attributes;

  const ProductVariant({
    this.id,
    this.name,
    this.sku,
    this.price,
    this.offerPrice,
    this.inStock = true,
    this.attributes = const [],
  });

  double get effectivePrice {
    if (offerPrice != null && offerPrice! > 0 && offerPrice! < (price ?? double.infinity)) {
      return offerPrice!;
    }
    return price ?? 0;
  }

  factory ProductVariant.fromJson(Map<String, dynamic> json) {
    final attrs = json['attributes'] is List
        ? (json['attributes'] as List)
            .whereType<Map>()
            .map((e) => ProductVariantAttribute.fromJson(
                  Map<String, dynamic>.from(e),
                ))
            .toList()
        : <ProductVariantAttribute>[];
    return ProductVariant(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      name: json['name']?.toString(),
      sku: json['sku']?.toString(),
      price: (json['price'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      inStock: json['inStock'] as bool? ?? true,
      attributes: attrs,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'sku': sku,
      'price': price,
      'offerPrice': offerPrice,
      'inStock': inStock,
      'attributes': attributes.map((e) => e.toJson()).toList(),
    };
  }
}

class ProductModel {
  final String? id;
  final String? partnerId;
  final String? title;
  final String? description;
  final List<String>? images;
  final double? price;
  final bool hasOffer;
  final String? offerType;
  final double? offerValue;
  final double? offerPrice;
  final double? effectivePrice;
  final bool inStock;
  final String? sku;
  final String? brand;
  final String? unit;
  final String? weight;
  final List<ProductSpec> specifications;
  final bool hasVariants;
  final List<ProductVariant> variants;
  final ProductCategory? category;
  final List<String>? tags;
  final bool? isActive;
  final int views;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? partnerObj;
  final List<dynamic>? branchLocations;
  final bool? isFavorited;

  const ProductModel({
    this.id,
    this.partnerId,
    this.title,
    this.description,
    this.images,
    this.price,
    this.hasOffer = false,
    this.offerType,
    this.offerValue,
    this.offerPrice,
    this.effectivePrice,
    this.inStock = true,
    this.sku,
    this.brand,
    this.unit,
    this.weight,
    this.specifications = const [],
    this.hasVariants = false,
    this.variants = const [],
    this.category,
    this.tags,
    this.isActive,
    this.views = 0,
    this.createdAt,
    this.updatedAt,
    this.partnerObj,
    this.branchLocations,
    this.isFavorited,
  });

  /// Best display price: effectivePrice → offerPrice → price.
  double? get displayPrice {
    if (effectivePrice != null && effectivePrice! > 0) return effectivePrice;
    if (hasOffer && offerPrice != null && offerPrice! > 0) return offerPrice;
    return price;
  }

  bool get showStrikeThrough {
    final base = price ?? 0;
    final sale = displayPrice ?? 0;
    return hasOffer && base > 0 && sale > 0 && sale < base;
  }

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final specs = json['specifications'] is List
        ? (json['specifications'] as List)
            .whereType<Map>()
            .map((e) => ProductSpec.fromJson(Map<String, dynamic>.from(e)))
            .where((s) => s.key.isNotEmpty || s.value.isNotEmpty)
            .toList()
        : <ProductSpec>[];

    final variants = json['variants'] is List
        ? (json['variants'] as List)
            .whereType<Map>()
            .map((e) => ProductVariant.fromJson(Map<String, dynamic>.from(e)))
            .toList()
        : <ProductVariant>[];

    final views = (json['viewCount'] as num?)?.toInt() ??
        (json['views'] as num?)?.toInt() ??
        0;

    return ProductModel(
      id: json['_id']?.toString() ?? json['id']?.toString(),
      partnerId: json['partnerId'] is Map
          ? (json['partnerId']['_id']?.toString() ??
              json['partnerId']['id']?.toString())
          : json['partnerId']?.toString(),
      title: json['title'] as String? ?? json['name'] as String?,
      description: json['description'] as String?,
      images: json['images'] != null
          ? List<String>.from(
              (json['images'] as List).map((e) => e.toString()),
            )
          : null,
      price: (json['price'] as num?)?.toDouble(),
      hasOffer: json['hasOffer'] as bool? ?? false,
      offerType: json['offerType']?.toString(),
      offerValue: (json['offerValue'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      effectivePrice: (json['effectivePrice'] as num?)?.toDouble(),
      inStock: json['inStock'] as bool? ?? true,
      sku: json['sku']?.toString(),
      brand: json['brand']?.toString(),
      unit: json['unit']?.toString(),
      weight: json['weight']?.toString(),
      specifications: specs,
      hasVariants: json['hasVariants'] as bool? ?? variants.isNotEmpty,
      variants: variants,
      category: json['category'] is String
          ? ProductCategory(id: json['category'] as String)
          : SafeParser.parseObject(
              json['category'],
              ProductCategory.fromJson,
            ),
      tags: json['tags'] != null
          ? List<String>.from(
              (json['tags'] as List).map((e) => e.toString()),
            )
          : null,
      isActive: json['isActive'] as bool?,
      views: views,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())?.toLocal()
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())?.toLocal()
          : null,
      partnerObj: json['partner'] is Map
          ? Map<String, dynamic>.from(json['partner'] as Map)
          : json['partnerId'] is Map
              ? Map<String, dynamic>.from(json['partnerId'] as Map)
              : null,
      branchLocations: json['branchLocations'] as List<dynamic>?,
      isFavorited:
          json['isFavorited'] as bool? ?? json['isFavorite'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'partnerId': partnerObj ?? partnerId,
      'title': title,
      'description': description,
      'images': images,
      'price': price,
      'hasOffer': hasOffer,
      'offerType': offerType,
      'offerValue': offerValue,
      'offerPrice': offerPrice,
      'effectivePrice': effectivePrice,
      'inStock': inStock,
      'sku': sku,
      'brand': brand,
      'unit': unit,
      'weight': weight,
      'specifications': specifications.map((e) => e.toJson()).toList(),
      'hasVariants': hasVariants,
      'variants': variants.map((e) => e.toJson()).toList(),
      'category': category?.toJson(),
      'tags': tags,
      'isActive': isActive,
      'views': views,
      'viewCount': views,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'partner': partnerObj,
      'branchLocations': branchLocations,
      'isFavorited': isFavorited,
      'isFavorite': isFavorited,
    };
  }
}

class PaginationModel {
  final int page;
  final int limit;
  final int total;
  final int pages;

  const PaginationModel({
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as int? ?? 1,
      limit: json['limit'] as int? ?? 20,
      total: json['total'] as int? ?? 0,
      pages: json['pages'] as int? ?? 1,
    );
  }

  PaginationModel copyWith({int? page, int? limit, int? total, int? pages}) {
    return PaginationModel(
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      pages: pages ?? this.pages,
    );
  }
}

class ProductResponse {
  final bool success;
  final List<ProductModel> data;
  final PaginationModel? pagination;

  const ProductResponse({
    required this.success,
    required this.data,
    this.pagination,
  });

  factory ProductResponse.fromJson(Map<String, dynamic> json) {
    return ProductResponse(
      success: json['success'] as bool? ?? false,
      data: SafeParser.parseList(json['data'], ProductModel.fromJson) ?? [],
      pagination: SafeParser.parseObject(
        json['pagination'],
        PaginationModel.fromJson,
      ),
    );
  }
}
