import 'business_details.dart';
import 'business_info.dart';
import 'shop_model.dart';

class FeaturedShop {
  final String? id;
  final BusinessDetails? businessDetails;
  final BusinessInfo? businessInfo;
  final List<String>? serviceCategories;
  final bool? isFeatured;
  final bool? isOpenNow;

  const FeaturedShop({
    this.id,
    this.businessDetails,
    this.businessInfo,
    this.serviceCategories,
    this.isFeatured,
    this.isOpenNow,
  });

  factory FeaturedShop.fromJson(Map<String, dynamic> json) {
    return FeaturedShop(
      id: json['_id'] as String?,
      businessDetails: json['businessDetails'] != null
          ? BusinessDetails.fromJson(json['businessDetails'] as Map<String, dynamic>)
          : null,
      businessInfo:
          json['businessInfo'] != null ? BusinessInfo.fromJson(json['businessInfo'] as Map<String, dynamic>) : null,
      serviceCategories: json['serviceCategories'] != null ? List<String>.from(json['serviceCategories']) : null,
      isFeatured: json['isFeatured'] as bool?,
      isOpenNow: json['isOpenNow'] as bool?,
    );
  }

  ShopModel toShopModel() {
    return ShopModel(
      id: id,
      businessDetails: businessDetails,
      businessInfo: businessInfo,
      serviceCategories: serviceCategories,
      isFeatured: isFeatured,
      isOpenNow: isOpenNow,
    );
  }
}
