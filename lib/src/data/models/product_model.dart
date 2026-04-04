class ProductModel {
  final String? id;
  final String? title;
  final List<String>? images;
  final double? price;
  final DateTime? createdAt;

  const ProductModel({
    this.id,
    this.title,
    this.images,
    this.price,
    this.createdAt,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      price: (json['price'] as num?)?.toDouble(),
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
