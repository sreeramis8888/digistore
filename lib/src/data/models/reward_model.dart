import 'package:setgo/src/utils/safe_parser.dart';

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
  final bool? isAffordable;
  final bool? isAccessible;
  final int? totalRedeemed;

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
    this.isAffordable,
    this.isAccessible,
    this.totalRedeemed,
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
      isAffordable: json['isAffordable'] as bool?,
      isAccessible: json['isAccessible'] as bool?,
      totalRedeemed: json['totalRedeemed'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'description': description,
      'image': image,
      'pointsCost': pointsCost,
      'category': category,
      'value': value,
      'valueType': valueType,
      'terms': terms,
      'stock': stock,
      'maxPerUser': maxPerUser,
      'isActive': isActive,
      'requiredTier': requiredTier,
      'isAffordable': isAffordable,
      'isAccessible': isAccessible,
      'totalRedeemed': totalRedeemed,
    };
  }
}

class PaginatedRewards {
  final List<RewardModel> rewards;
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginatedRewards({
    required this.rewards,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginatedRewards.fromJson(Map<String, dynamic> json) {
    return PaginatedRewards(
      rewards: SafeParser.parseList(json['data'], RewardModel.fromJson) ?? [],
      page: json['pagination']?['page'] as int? ?? 1,
      limit: json['pagination']?['limit'] as int? ?? 10,
      total: json['pagination']?['total'] as int? ?? 0,
      pages: json['pagination']?['pages'] as int? ?? 1,
    );
  }
}
