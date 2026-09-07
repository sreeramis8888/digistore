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
  final List<String>? images;
  final DateTime? expiresAt;

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
    this.images,
    this.expiresAt,
  });

  factory RewardModel.fromJson(Map<String, dynamic> json) {
    return RewardModel(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      image: json['image'] as String?,
      pointsCost: json['pointsCost'] as int?,
      category: json['category'] as String?,
      value: (json['value'] as num? ??
              json['discountValue'] as num? ??
              json['discount'] as num? ??
              json['discountPercent'] as num? ??
              json['discountAmount'] as num?)?.toDouble(),
      valueType: (json['valueType'] as String? ??
                  json['discountType'] as String?),
      terms: _parseTerms(
        json['terms'] ??
            json['termsAndConditions'] ??
            json['terms_and_conditions'] ??
            json['conditions'] ??
            json['rules'],
      ),
      stock: json['stock'] as int?,
      maxPerUser: json['maxPerUser'] as int?,
      isActive: json['isActive'] as bool?,
      requiredTier: json['requiredTier'] as String?,
      isAffordable: json['isAffordable'] as bool?,
      isAccessible: json['isAccessible'] as bool?,
      totalRedeemed: json['totalRedeemed'] as int?,
      images: json['images'] != null
          ? List<String>.from(json['images'] as List)
          : json['gallery'] != null
              ? List<String>.from(json['gallery'] as List)
              : json['galleryImages'] != null
                  ? List<String>.from(json['galleryImages'] as List)
                  : null,
      expiresAt: json['expiresAt'] != null
          ? DateTime.tryParse(json['expiresAt'].toString())?.toLocal()
          : json['validUntil'] != null
              ? DateTime.tryParse(json['validUntil'].toString())?.toLocal()
              : json['validTo'] != null
                  ? DateTime.tryParse(json['validTo'].toString())?.toLocal()
                  : json['expiryDate'] != null
                      ? DateTime.tryParse(json['expiryDate'].toString())?.toLocal()
                      : json['endDate'] != null
                          ? DateTime.tryParse(json['endDate'].toString())?.toLocal()
                          : null,
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
      'images': images,
      'expiresAt': expiresAt?.toIso8601String(),
    };
  }

  static List<String>? _parseTerms(dynamic rawTerms) {
    if (rawTerms == null) return null;
    if (rawTerms is List) {
      final list = rawTerms
          .map((e) => e is Map ? (e['text'] ?? e['title'] ?? e['term'] ?? e.values.first).toString() : e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList();
      return list.isNotEmpty ? list : null;
    } else if (rawTerms is String && rawTerms.trim().isNotEmpty) {
      final list = rawTerms
          .split(RegExp(r'[\r\n]+'))
          .map((s) => s.replaceAll(RegExp(r'^\s*[\d\.\-\*•]+\s*'), '').trim())
          .where((s) => s.isNotEmpty)
          .toList();
      return list.isNotEmpty ? list : null;
    }
    return null;
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
