class CategoryModel {
  final String? id;
  final String? name;
  final String? slug;
  final String? iconUrl;

  const CategoryModel({
    this.id,
    this.name,
    this.slug,
    this.iconUrl,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['_id'] ?? json['id']) as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
      iconUrl: json['iconUrl'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'iconUrl': iconUrl,
    };
  }
}
