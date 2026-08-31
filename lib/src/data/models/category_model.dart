class CategoryModel {
  final String? id;
  final String? name;
  final String? slug;
  final String? iconUrl;
  final List<String>? subcategories;

  const CategoryModel({
    this.id,
    this.name,
    this.slug,
    this.iconUrl,
    this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    List<String>? parsedSubcategories;
    if (json['subcategories'] is List) {
      parsedSubcategories = (json['subcategories'] as List)
          .map((e) {
            if (e is Map && e['name'] != null) return e['name'].toString();
            return e.toString();
          })
          .where((s) => s.trim().isNotEmpty)
          .toList();
    }
    return CategoryModel(
      id: (json['_id'] ?? json['id']) as String?,
      name: (json['name'] ?? json['category']) as String?,
      slug: json['slug'] as String?,
      iconUrl: json['iconUrl'] as String?,
      subcategories: parsedSubcategories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'slug': slug,
      'iconUrl': iconUrl,
      'subcategories': subcategories,
    };
  }
}
