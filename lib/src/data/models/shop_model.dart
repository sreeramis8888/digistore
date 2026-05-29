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

  const ShopModel({
    this.id,
    this.businessDetails,
    this.serviceCategories,
    this.coverageAreas,
    this.businessInfo,
    this.isFeatured,
    this.tags,
    this.isOpenNow,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['_id'] as String?,
      businessDetails: SafeParser.parseObject(
        json['businessDetails'],
        BusinessDetails.fromJson,
      ),
      serviceCategories: json['serviceCategories'] != null
          ? List<String>.from(json['serviceCategories'])
          : null,
      coverageAreas: SafeParser.parseObject(
        json['coverageAreas'],
        CoverageAreas.fromJson,
      ),
      businessInfo: SafeParser.parseObject(
        json['businessInfo'],
        BusinessInfo.fromJson,
      ),
      isFeatured: json['isFeatured'] as bool?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isOpenNow: json['isOpenNow'] as bool?,
    );
  }
}
