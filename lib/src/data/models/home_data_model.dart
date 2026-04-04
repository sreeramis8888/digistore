// class HomeDataModel {
//   final bool success;
//   final HomeData? data;
//   final String? message;

//   const HomeDataModel({
//     required this.success,
//     this.data,
//     this.message,
//   });

//   factory HomeDataModel.fromJson(Map<String, dynamic> json) {
//     return HomeDataModel(
//       success: json['success'] as bool? ?? false,
//       data: json['data'] != null ? HomeData.fromJson(json['data'] as Map<String, dynamic>) : null,
//       message: json['message'] as String?,
//     );
//   }
// }

// class HomeData {
//   final LoyaltyCard? loyaltyCard;
//   final List<BannerModel>? premiumBanners;
//   final List<CategoryModel>? categories;
//   final List<OfferModel>? dealsOfDay;
//   final List<OfferModel>? dealOfTheHour;
//   final List<OfferModel>? dealOfTheDay;
//   final List<OfferModel>? dealOfTheMonth;
//   final List<OfferModel>? nearbyOffers;
//   final List<FeaturedShop>? featuredShops;
//   final List<RewardModel>? rewardsPreview;
//   final List<OfferModel>? upcomingDeals;

//   const HomeData({
//     this.loyaltyCard,
//     this.premiumBanners,
//     this.categories,
//     this.dealsOfDay,
//     this.dealOfTheHour,
//     this.dealOfTheDay,
//     this.dealOfTheMonth,
//     this.nearbyOffers,
//     this.featuredShops,
//     this.rewardsPreview,
//     this.upcomingDeals,
//   });

//   factory HomeData.fromJson(Map<String, dynamic> json) {
//     return HomeData(
//       loyaltyCard: json['loyaltyCard'] != null ? LoyaltyCard.fromJson(json['loyaltyCard'] as Map<String, dynamic>) : null,
//       premiumBanners: json['premiumBanners'] != null
//           ? (json['premiumBanners'] as List).map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       categories: json['categories'] != null
//           ? (json['categories'] as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       dealsOfDay: json['dealsOfDay'] != null
//           ? (json['dealsOfDay'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       dealOfTheHour: json['dealOfTheHour'] != null
//           ? (json['dealOfTheHour'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       dealOfTheDay: json['dealOfTheDay'] != null
//           ? (json['dealOfTheDay'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       dealOfTheMonth: json['dealOfTheMonth'] != null
//           ? (json['dealOfTheMonth'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       nearbyOffers: json['nearbyOffers'] != null
//           ? (json['nearbyOffers'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       featuredShops: json['featuredShops'] != null
//           ? (json['featuredShops'] as List).map((e) => FeaturedShop.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       rewardsPreview: json['rewardsPreview'] != null
//           ? (json['rewardsPreview'] as List).map((e) => RewardModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//       upcomingDeals: json['upcomingDeals'] != null
//           ? (json['upcomingDeals'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
//           : null,
//     );
//   }
// }

// class LoyaltyCard {
//   final String? name;
//   final int? pointsBalance;
//   final int? totalPointsEarned;
//   final String? tier;
//   final List<String>? tierBenefits;

//   const LoyaltyCard({
//     this.name,
//     this.pointsBalance,
//     this.totalPointsEarned,
//     this.tier,
//     this.tierBenefits,
//   });

//   factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
//     return LoyaltyCard(
//       name: json['name'] as String?,
//       pointsBalance: json['pointsBalance'] as int?,
//       totalPointsEarned: json['totalPointsEarned'] as int?,
//       tier: json['tier'] as String?,
//       tierBenefits: json['tierBenefits'] != null ? List<String>.from(json['tierBenefits']) : null,
//     );
//   }
// }

// class BannerModel {
//   final String? id;
//   final String? title;
//   final String? image;
//   final String? type;
//   final String? linkType;
//   final String? linkId;
//   final String? externalUrl;
//   final int? sortOrder;
//   final bool? isActive;

//   const BannerModel({
//     this.id,
//     this.title,
//     this.image,
//     this.type,
//     this.linkType,
//     this.linkId,
//     this.externalUrl,
//     this.sortOrder,
//     this.isActive,
//   });

//   factory BannerModel.fromJson(Map<String, dynamic> json) {
//     return BannerModel(
//       id: json['_id'] as String?,
//       title: json['title'] as String?,
//       image: json['image'] as String?,
//       type: json['type'] as String?,
//       linkType: json['linkType'] as String?,
//       linkId: json['linkId'] as String?,
//       externalUrl: json['externalUrl'] as String?,
//       sortOrder: json['sortOrder'] as int?,
//       isActive: json['isActive'] as bool?,
//     );
//   }
// }

// class CategoryModel {
//   final String? id;
//   final String? name;
//   final String? slug;

//   const CategoryModel({
//     this.id,
//     this.name,
//     this.slug,
//   });

//   factory CategoryModel.fromJson(Map<String, dynamic> json) {
//     return CategoryModel(
//       id: json['_id'] as String?,
//       name: json['name'] as String?,
//       slug: json['slug'] as String?,
//     );
//   }
// }

// class OfferModel {
//   final String? id;
//   final PartnerModel? partnerId;
//   final String? title;
//   final String? description;
//   final List<String>? images;
//   final String? category;
//   final String? offerTypeCode;
//   final Map<String, dynamic>? offerMetadata;
//   final String? discountType;
//   final double? discountValue;
//   final double? originalPrice;
//   final double? offerPrice;
//   final List<String>? terms;
//   final DateTime? validFrom;
//   final DateTime? validTo;
//   final RedemptionRules? redemptionRules;
//   final CoverageAreas? coverageAreas;
//   final String? status;
//   final bool? isPremium;
//   final PremiumPlacement? premiumPlacement;
//   final int? totalRedemptions;
//   final int? views;
//   final bool? isActive;
//   final bool? isDealOfDay;
//   final String? requiredTier;
//   final List<String>? tags;
//   final LocationPoint? location;
//   final int? shareCount;

//   const OfferModel({
//     this.id,
//     this.partnerId,
//     this.title,
//     this.description,
//     this.images,
//     this.category,
//     this.offerTypeCode,
//     this.offerMetadata,
//     this.discountType,
//     this.discountValue,
//     this.originalPrice,
//     this.offerPrice,
//     this.terms,
//     this.validFrom,
//     this.validTo,
//     this.redemptionRules,
//     this.coverageAreas,
//     this.status,
//     this.isPremium,
//     this.premiumPlacement,
//     this.totalRedemptions,
//     this.views,
//     this.isActive,
//     this.isDealOfDay,
//     this.requiredTier,
//     this.tags,
//     this.location,
//     this.shareCount,
//   });

//   factory OfferModel.fromJson(Map<String, dynamic> json) {
//     return OfferModel(
//       id: json['_id'] as String?,
//       partnerId: json['partnerId'] != null ? PartnerModel.fromJson(json['partnerId'] as Map<String, dynamic>) : null,
//       title: json['title'] as String?,
//       description: json['description'] as String?,
//       images: json['images'] != null ? List<String>.from(json['images']) : null,
//       category: json['category'] as String?,
//       offerTypeCode: json['offerTypeCode'] as String?,
//       offerMetadata: json['offerMetadata'] as Map<String, dynamic>?,
//       discountType: json['discountType'] as String?,
//       discountValue: (json['discountValue'] as num?)?.toDouble(),
//       originalPrice: (json['originalPrice'] as num?)?.toDouble(),
//       offerPrice: (json['offerPrice'] as num?)?.toDouble(),
//       terms: json['terms'] != null ? List<String>.from(json['terms']) : null,
//       validFrom: json['validFrom'] != null ? DateTime.tryParse(json['validFrom']) : null,
//       validTo: json['validTo'] != null ? DateTime.tryParse(json['validTo']) : null,
//       redemptionRules: json['redemptionRules'] != null
//           ? RedemptionRules.fromJson(json['redemptionRules'] as Map<String, dynamic>)
//           : null,
//       coverageAreas: json['coverageAreas'] != null
//           ? CoverageAreas.fromJson(json['coverageAreas'] as Map<String, dynamic>)
//           : null,
//       status: json['status'] as String?,
//       isPremium: json['isPremium'] as bool?,
//       premiumPlacement: json['premiumPlacement'] != null
//           ? PremiumPlacement.fromJson(json['premiumPlacement'] as Map<String, dynamic>)
//           : null,
//       totalRedemptions: json['totalRedemptions'] as int?,
//       views: json['views'] as int?,
//       isActive: json['isActive'] as bool?,
//       isDealOfDay: json['isDealOfDay'] as bool?,
//       requiredTier: json['requiredTier'] as String?,
//       tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
//       location: json['location'] != null ? LocationPoint.fromJson(json['location'] as Map<String, dynamic>) : null,
//       shareCount: json['shareCount'] as int?,
//     );
//   }
// }

// class PartnerModel {
//   final String? id;
//   final BusinessDetails? businessDetails;
//   final BusinessInfo? businessInfo;

//   const PartnerModel({
//     this.id,
//     this.businessDetails,
//     this.businessInfo,
//   });

//   factory PartnerModel.fromJson(Map<String, dynamic> json) {
//     return PartnerModel(
//       id: json['_id'] as String?,
//       businessDetails: json['businessDetails'] != null
//           ? BusinessDetails.fromJson(json['businessDetails'] as Map<String, dynamic>)
//           : null,
//       businessInfo:
//           json['businessInfo'] != null ? BusinessInfo.fromJson(json['businessInfo'] as Map<String, dynamic>) : null,
//     );
//   }
// }

// class BusinessDetails {
//   final String? businessName;
//   final String? businessType;
//   final String? address;
//   final String? pincode;

//   const BusinessDetails({
//     this.businessName,
//     this.businessType,
//     this.address,
//     this.pincode,
//   });

//   factory BusinessDetails.fromJson(Map<String, dynamic> json) {
//     return BusinessDetails(
//       businessName: json['businessName'] as String?,
//       businessType: json['businessType'] as String?,
//       address: json['address'] as String?,
//       pincode: json['pincode'] as String?,
//     );
//   }
// }

// class BusinessInfo {
//   final String? businessLogo;
//   final List<String>? businessImages;
//   final String? description;
//   final List<String>? specialties;
//   final double? rating;
//   final int? reviewCount;
//   final String? contactPhone;
//   final String? tagline;
//   final String? coverImage;
//   final Map<String, dynamic>? operatingHours;

//   const BusinessInfo({
//     this.businessLogo,
//     this.businessImages,
//     this.description,
//     this.specialties,
//     this.rating,
//     this.reviewCount,
//     this.contactPhone,
//     this.tagline,
//     this.coverImage,
//     this.operatingHours,
//   });

//   factory BusinessInfo.fromJson(Map<String, dynamic> json) {
//     return BusinessInfo(
//       businessLogo: json['businessLogo'] as String?,
//       businessImages: json['businessImages'] != null ? List<String>.from(json['businessImages']) : null,
//       description: json['description'] as String?,
//       specialties: json['specialties'] != null ? List<String>.from(json['specialties']) : null,
//       rating: (json['rating'] as num?)?.toDouble(),
//       reviewCount: json['reviewCount'] as int?,
//       contactPhone: json['contactPhone'] as String?,
//       tagline: json['tagline'] as String?,
//       coverImage: json['coverImage'] as String?,
//       operatingHours: json['operatingHours'] as Map<String, dynamic>?,
//     );
//   }
// }

// class RedemptionRules {
//   final int? maxTotalRedemptions;
//   final int? maxPerUser;
//   final double? minPurchaseAmount;
//   final List<String>? applicableDays;

//   const RedemptionRules({
//     this.maxTotalRedemptions,
//     this.maxPerUser,
//     this.minPurchaseAmount,
//     this.applicableDays,
//   });

//   factory RedemptionRules.fromJson(Map<String, dynamic> json) {
//     return RedemptionRules(
//       maxTotalRedemptions: json['maxTotalRedemptions'] as int?,
//       maxPerUser: json['maxPerUser'] as int?,
//       minPurchaseAmount: (json['minPurchaseAmount'] as num?)?.toDouble(),
//       applicableDays: json['applicableDays'] != null ? List<String>.from(json['applicableDays']) : null,
//     );
//   }
// }

// class CoverageAreas {
//   final List<String>? districts;
//   final List<String>? localBodies;

//   const CoverageAreas({
//     this.districts,
//     this.localBodies,
//   });

//   factory CoverageAreas.fromJson(Map<String, dynamic> json) {
//     return CoverageAreas(
//       districts: json['districts'] != null ? List<String>.from(json['districts']) : null,
//       localBodies: json['localBodies'] != null ? List<String>.from(json['localBodies']) : null,
//     );
//   }
// }

// class PremiumPlacement {
//   final String? position;
//   final DateTime? startDate;
//   final DateTime? endDate;

//   const PremiumPlacement({
//     this.position,
//     this.startDate,
//     this.endDate,
//   });

//   factory PremiumPlacement.fromJson(Map<String, dynamic> json) {
//     return PremiumPlacement(
//       position: json['position'] as String?,
//       startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
//       endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
//     );
//   }
// }

// class LocationPoint {
//   final String? type;
//   final List<double>? coordinates;

//   const LocationPoint({
//     this.type,
//     this.coordinates,
//   });

//   factory LocationPoint.fromJson(Map<String, dynamic> json) {
//     return LocationPoint(
//       type: json['type'] as String?,
//       coordinates: (json['coordinates'] as List?)?.map((e) => (e as num).toDouble()).toList(),
//     );
//   }
// }

// class FeaturedShop {
//   final String? id;
//   final BusinessDetails? businessDetails;
//   final BusinessInfo? businessInfo;
//   final List<String>? serviceCategories;
//   final bool? isFeatured;
//   final bool? isOpenNow;

//   const FeaturedShop({
//     this.id,
//     this.businessDetails,
//     this.businessInfo,
//     this.serviceCategories,
//     this.isFeatured,
//     this.isOpenNow,
//   });

//   factory FeaturedShop.fromJson(Map<String, dynamic> json) {
//     return FeaturedShop(
//       id: json['_id'] as String?,
//       businessDetails: json['businessDetails'] != null
//           ? BusinessDetails.fromJson(json['businessDetails'] as Map<String, dynamic>)
//           : null,
//       businessInfo:
//           json['businessInfo'] != null ? BusinessInfo.fromJson(json['businessInfo'] as Map<String, dynamic>) : null,
//       serviceCategories: json['serviceCategories'] != null ? List<String>.from(json['serviceCategories']) : null,
//       isFeatured: json['isFeatured'] as bool?,
//       isOpenNow: json['isOpenNow'] as bool?,
//     );
//   }
// }

// class RewardModel {
//   final String? id;
//   final String? title;
//   final String? description;
//   final String? image;
//   final int? pointsCost;
//   final String? category;
//   final double? value;
//   final String? valueType;
//   final List<String>? terms;
//   final int? stock;
//   final int? maxPerUser;
//   final bool? isActive;
//   final String? requiredTier;

//   const RewardModel({
//     this.id,
//     this.title,
//     this.description,
//     this.image,
//     this.pointsCost,
//     this.category,
//     this.value,
//     this.valueType,
//     this.terms,
//     this.stock,
//     this.maxPerUser,
//     this.isActive,
//     this.requiredTier,
//   });

//   factory RewardModel.fromJson(Map<String, dynamic> json) {
//     return RewardModel(
//       id: json['_id'] as String?,
//       title: json['title'] as String?,
//       description: json['description'] as String?,
//       image: json['image'] as String?,
//       pointsCost: json['pointsCost'] as int?,
//       category: json['category'] as String?,
//       value: (json['value'] as num?)?.toDouble(),
//       valueType: json['valueType'] as String?,
//       terms: json['terms'] != null ? List<String>.from(json['terms']) : null,
//       stock: json['stock'] as int?,
//       maxPerUser: json['maxPerUser'] as int?,
//       isActive: json['isActive'] as bool?,
//       requiredTier: json['requiredTier'] as String?,
//     );
//   }
// }
