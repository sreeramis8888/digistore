import 'partner_model.dart';
import 'redemption_rules.dart';
import 'coverage_areas.dart';
import 'premium_placement.dart';
import 'location_point.dart';

class OfferModel {
  final String? id;
  final PartnerModel? partnerId;
  final String? title;
  final String? description;
  final List<String>? images;
  final String? category;
  final String? offerTypeCode;
  final Map<String, dynamic>? offerMetadata;
  final String? discountType;
  final double? discountValue;
  final double? originalPrice;
  final double? offerPrice;
  final List<String>? terms;
  final DateTime? validFrom;
  final DateTime? validTo;
  final RedemptionRules? redemptionRules;
  final CoverageAreas? coverageAreas;
  final String? status;
  final bool? isPremium;
  final PremiumPlacement? premiumPlacement;
  final int? totalRedemptions;
  final int? views;
  final bool? isActive;
  final bool? isDealOfDay;
  final String? requiredTier;
  final List<String>? tags;
  final LocationPoint? location;
  final int? shareCount;
  final DateTime? createdAt;

  const OfferModel({
    this.id,
    this.partnerId,
    this.title,
    this.description,
    this.images,
    this.category,
    this.offerTypeCode,
    this.offerMetadata,
    this.discountType,
    this.discountValue,
    this.originalPrice,
    this.offerPrice,
    this.terms,
    this.validFrom,
    this.validTo,
    this.redemptionRules,
    this.coverageAreas,
    this.status,
    this.isPremium,
    this.premiumPlacement,
    this.totalRedemptions,
    this.views,
    this.isActive,
    this.isDealOfDay,
    this.requiredTier,
    this.tags,
    this.location,
    this.shareCount,
    this.createdAt,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['_id'] as String?,
      partnerId: json['partnerId'] != null ? PartnerModel.fromJson(json['partnerId'] as Map<String, dynamic>) : null,
      title: json['title'] as String?,
      description: json['description'] as String?,
      images: json['images'] != null ? List<String>.from(json['images']) : null,
      category: json['category'] as String?,
      offerTypeCode: json['offerTypeCode'] as String?,
      offerMetadata: json['offerMetadata'] as Map<String, dynamic>?,
      discountType: json['discountType'] as String?,
      discountValue: (json['discountValue'] as num?)?.toDouble(),
      originalPrice: (json['originalPrice'] as num?)?.toDouble(),
      offerPrice: (json['offerPrice'] as num?)?.toDouble(),
      terms: json['terms'] != null ? List<String>.from(json['terms']) : null,
      validFrom: json['validFrom'] != null ? DateTime.tryParse(json['validFrom']) : null,
      validTo: json['validTo'] != null ? DateTime.tryParse(json['validTo']) : null,
      redemptionRules: json['redemptionRules'] != null
          ? RedemptionRules.fromJson(json['redemptionRules'] as Map<String, dynamic>)
          : null,
      coverageAreas: json['coverageAreas'] != null
          ? CoverageAreas.fromJson(json['coverageAreas'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
      isPremium: json['isPremium'] as bool?,
      premiumPlacement: json['premiumPlacement'] != null
          ? PremiumPlacement.fromJson(json['premiumPlacement'] as Map<String, dynamic>)
          : null,
      totalRedemptions: json['totalRedemptions'] as int?,
      views: json['views'] as int?,
      isActive: json['isActive'] as bool?,
      isDealOfDay: json['isDealOfDay'] as bool?,
      requiredTier: json['requiredTier'] as String?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      location: json['location'] != null ? LocationPoint.fromJson(json['location'] as Map<String, dynamic>) : null,
      shareCount: json['shareCount'] as int?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}
