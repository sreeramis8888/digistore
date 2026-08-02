import 'package:setgo/src/utils/safe_parser.dart';

import 'business_details.dart';
import 'business_info.dart';
import 'coverage_areas.dart';

class ShopModel {
  final String? id;
  final BusinessDetails? businessDetails;
  final List<String>? serviceCategories;
  final CoverageAreas? coverageAreas;
  final BusinessInfo? businessInfo;
  final bool? isFeatured;
  final List<String>? tags;
  final bool? isOpenNow;
  final double? distance;
  final String? roadDistance;
  final double? roadDuration;

  const ShopModel({
    this.id,
    this.businessDetails,
    this.serviceCategories,
    this.coverageAreas,
    this.businessInfo,
    this.isFeatured,
    this.tags,
    this.isOpenNow,
    this.distance,
    this.roadDistance,
    this.roadDuration,
  });

  ShopModel copyWith({
    String? id,
    BusinessDetails? businessDetails,
    List<String>? serviceCategories,
    CoverageAreas? coverageAreas,
    BusinessInfo? businessInfo,
    bool? isFeatured,
    List<String>? tags,
    bool? isOpenNow,
    double? distance,
    String? roadDistance,
    double? roadDuration,
  }) {
    return ShopModel(
      id: id ?? this.id,
      businessDetails: businessDetails ?? this.businessDetails,
      serviceCategories: serviceCategories ?? this.serviceCategories,
      coverageAreas: coverageAreas ?? this.coverageAreas,
      businessInfo: businessInfo ?? this.businessInfo,
      isFeatured: isFeatured ?? this.isFeatured,
      tags: tags ?? this.tags,
      isOpenNow: isOpenNow ?? this.isOpenNow,
      distance: distance ?? this.distance,
      roadDistance: roadDistance ?? this.roadDistance,
      roadDuration: roadDuration ?? this.roadDuration,
    );
  }

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    var bDetails = SafeParser.parseObject(
      json['businessDetails'],
      BusinessDetails.fromJson,
    );
    if (bDetails == null && json['name'] != null) {
      bDetails = BusinessDetails(businessName: json['name'] as String?);
    }

    var bInfo = SafeParser.parseObject(
      json['businessInfo'],
      BusinessInfo.fromJson,
    );
    if (bInfo == null && (json['logo'] != null || json['cover'] != null)) {
      bInfo = BusinessInfo(
        businessLogo: json['logo'] as String?,
        coverImage: json['cover'] as String?,
      );
    }

    return ShopModel(
      id: json['_id'] as String?,
      businessDetails: bDetails,
      serviceCategories: json['serviceCategories'] != null
          ? List<String>.from(json['serviceCategories'])
          : null,
      coverageAreas: SafeParser.parseObject(
        json['coverageAreas'],
        CoverageAreas.fromJson,
      ),
      businessInfo: bInfo,
      isFeatured: json['isFeatured'] as bool?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isOpenNow: json['isOpenNow'] as bool?,
      distance: json['distance'] != null ? (json['distance'] as num).toDouble() : null,
    );
  }
}
