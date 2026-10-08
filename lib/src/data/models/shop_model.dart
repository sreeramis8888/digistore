import 'package:setgo/src/utils/safe_parser.dart';

import '../utils/name_case.dart';
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
      bDetails = BusinessDetails(
        businessName: NameCase.maybe(json['name']?.toString()),
      );
    }

    var bInfo = SafeParser.parseObject(
      json['businessInfo'],
      BusinessInfo.fromJson,
    );
    if (bInfo == null &&
        (json['logo'] != null ||
            json['cover'] != null ||
            json['bannerVideoUrl'] != null)) {
      bInfo = BusinessInfo(
        businessLogo: json['logo'] as String?,
        coverImage: json['cover'] as String?,
        bannerVideoUrl: json['bannerVideoUrl'] as String?,
      );
    } else if (bInfo != null) {
      // Some payloads put bannerVideoUrl on the shop root, not inside businessInfo.
      final rootBanner = json['bannerVideoUrl'] as String?;
      if ((bInfo.bannerVideoUrl == null || bInfo.bannerVideoUrl!.isEmpty) &&
          rootBanner != null &&
          rootBanner.trim().isNotEmpty) {
        bInfo = BusinessInfo(
          businessLogo: bInfo.businessLogo,
          coverImage: bInfo.coverImage,
          businessImages: bInfo.businessImages,
          description: bInfo.description,
          tagline: bInfo.tagline,
          specialties: bInfo.specialties,
          yearsOfExperience: bInfo.yearsOfExperience,
          rating: bInfo.rating,
          totalReviews: bInfo.totalReviews,
          contactPhone: bInfo.contactPhone,
          otpPhone: bInfo.otpPhone,
          whatsappNumber: bInfo.whatsappNumber,
          websiteUrl: bInfo.websiteUrl,
          operatingHours: bInfo.operatingHours,
          socialLinks: bInfo.socialLinks,
          videoUrl: bInfo.videoUrl,
          bannerVideoUrl: rootBanner,
          achievements: bInfo.achievements,
          faqs: bInfo.faqs,
          branches: bInfo.branches,
          ownerName: bInfo.ownerName,
          email: bInfo.email,
        );
      }
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
      distance: json['distance'] != null
          ? (json['distance'] as num).toDouble()
          : null,
    );
  }
}
