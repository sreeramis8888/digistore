class RewardModel {
  final String? id;
  final String? title;
  final String? description;
  final String? image;
  final int? pointsCost;
  final String? category;
  final double? value;
  final String? valueType;
  final List<String>? terms;
  final int? stock;
  final int? maxPerUser;
  final bool? isActive;
  final String? requiredTier;

  const RewardModel({
    this.id,
    this.title,
    this.description,
    this.image,
    this.pointsCost,
    this.category,
    this.value,
    this.valueType,
    this.terms,
    this.stock,
    this.maxPerUser,
    this.isActive,
    this.requiredTier,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      pointsCost: json['pointsCost'] as int?,
      category: json['category'] as String?,
      value: (json['value'] as num?)?.toDouble(),
      valueType: json['valueType'] as String?,
      terms: json['terms'] != null ? List<String>.from(json['terms']) : null,
      stock: json['stock'] as int?,
      maxPerUser: json['maxPerUser'] as int?,
      isActive: json['isActive'] as bool?,
      requiredTier: json['requiredTier'] as String?,
    );
  }
}
