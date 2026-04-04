class CategoryModel {
  final String? id;
  final String? name;
  final String? slug;

  const CategoryModel({
    this.id,
    this.name,
    this.slug,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      slug: json['slug'] as String?,
    );
  }
}
