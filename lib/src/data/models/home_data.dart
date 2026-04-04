import 'loyalty_card.dart';
import 'banner_model.dart';
import 'category_model.dart';
import 'offer_model.dart';
import 'featured_shop.dart';
import 'reward_model.dart';

class HomeData {
  final LoyaltyCard? loyaltyCard;
  final List<BannerModel>? premiumBanners;
  final List<CategoryModel>? categories;
  final List<OfferModel>? dealsOfDay;
  final List<OfferModel>? dealOfTheHour;
  final List<OfferModel>? dealOfTheDay;
  final List<OfferModel>? dealOfTheMonth;
  final List<OfferModel>? nearbyOffers;
  final List<FeaturedShop>? featuredShops;
  final List<RewardModel>? rewardsPreview;
  final List<OfferModel>? upcomingDeals;

  const HomeData({
    this.loyaltyCard,
    this.premiumBanners,
    this.categories,
    this.dealsOfDay,
    this.dealOfTheHour,
    this.dealOfTheDay,
    this.dealOfTheMonth,
    this.nearbyOffers,
    this.featuredShops,
    this.rewardsPreview,
    this.upcomingDeals,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    return HomeData(
      loyaltyCard: json['loyaltyCard'] != null ? LoyaltyCard.fromJson(json['loyaltyCard'] as Map<String, dynamic>) : null,
      premiumBanners: json['premiumBanners'] != null
          ? (json['premiumBanners'] as List).map((e) => BannerModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      categories: json['categories'] != null
          ? (json['categories'] as List).map((e) => CategoryModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      dealsOfDay: json['dealsOfDay'] != null
          ? (json['dealsOfDay'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      dealOfTheHour: json['dealOfTheHour'] != null
          ? (json['dealOfTheHour'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      dealOfTheDay: json['dealOfTheDay'] != null
          ? (json['dealOfTheDay'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      dealOfTheMonth: json['dealOfTheMonth'] != null
          ? (json['dealOfTheMonth'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      nearbyOffers: json['nearbyOffers'] != null
          ? (json['nearbyOffers'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      featuredShops: json['featuredShops'] != null
          ? (json['featuredShops'] as List).map((e) => FeaturedShop.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      rewardsPreview: json['rewardsPreview'] != null
          ? (json['rewardsPreview'] as List).map((e) => RewardModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
      upcomingDeals: json['upcomingDeals'] != null
          ? (json['upcomingDeals'] as List).map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList()
          : null,
    );
  }
}
