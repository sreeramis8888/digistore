import 'business_details.dart';
import 'business_info.dart';

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
      businessDetails: json['businessDetails'] != null
          ? BusinessDetails.fromJson(json['businessDetails'] as Map<String, dynamic>)
          : null,
      serviceCategories: json['serviceCategories'] != null
          ? List<String>.from(json['serviceCategories'])
          : null,
      coverageAreas: json['coverageAreas'] != null
          ? CoverageAreas.fromJson(json['coverageAreas'] as Map<String, dynamic>)
          : null,
      businessInfo: json['businessInfo'] != null
          ? BusinessInfo.fromJson(json['businessInfo'] as Map<String, dynamic>)
          : null,
      isFeatured: json['isFeatured'] as bool?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isOpenNow: json['isOpenNow'] as bool?,
    );
  }
}

class CoverageAreas {
  final List<String>? districts;
  final List<String>? cities;

  const CoverageAreas({this.districts, this.cities});

  factory CoverageAreas.fromJson(Map<String, dynamic> json) {
    return CoverageAreas(
      districts: json['districts'] != null ? List<String>.from(json['districts']) : null,
      cities: json['cities'] != null ? List<String>.from(json['cities']) : null,
    );
  }
}
