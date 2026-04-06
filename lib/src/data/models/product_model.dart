class ProductCategory {
  final String? id;
  final String? category;
  final String? subcategory;

  const ProductCategory({
    this.id,
    this.category,
    this.subcategory,
  });

  factory ProductCategory.fromJson(Map<String, dynamic> json) {
    return ProductCategory(
      id: json['_id'] as String?,
      category: json['category'] as String?,
      subcategory: json['subcategory'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'category': category,
      'subcategory': subcategory,
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
  final ProductCategory? category;
  final List<String>? tags;
  final bool? isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const ProductModel({
    this.id,
    this.partnerId,
    this.title,
    this.description,
    this.images,
    this.price,
    this.category,
    this.tags,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] as String?,
      partnerId: json['partnerId'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      price: (json['price'] as num?)?.toDouble(),
      category: json['category'] != null
          ? ProductCategory.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'partnerId': partnerId,
      'title': title,
      'description': description,
      'images': images,
      'price': price,
      'category': category?.toJson(),
      'tags': tags,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
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
      data: json['data'] != null
          ? (json['data'] as List)
              .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}
