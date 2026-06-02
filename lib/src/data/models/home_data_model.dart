import '../../utils/safe_parser.dart';
import 'loyalty_card.dart';
import 'banner_model.dart';
import 'category_model.dart';
import 'offer_model.dart';
import 'shop_model.dart';
import 'reward_model.dart';
import 'partner_home_data.dart';

class HomeData {
  final LoyaltyCard? loyaltyCard;
  final List<BannerModel>? premiumBanners;
  final List<CategoryModel>? categories;
  // final List<OfferModel>? dealsOfDay;
  final List<OfferModel>? dealOfTheHour;
  final List<OfferModel>? dealOfTheDay;
  final List<OfferModel>? dealOfTheWeek;
  final List<OfferModel>? dealOfTheMonth;
  final List<OfferModel>? nearbyOffers;
  final List<ShopModel>? featuredShops;
  final List<RewardModel>? rewardsPreview;
  final List<OfferModel>? upcomingDeals;

  const HomeData({
    this.loyaltyCard,
    this.premiumBanners,
    this.categories,
    // this.dealsOfDay,
    this.dealOfTheHour,
    this.dealOfTheDay,
    this.dealOfTheWeek,
    this.dealOfTheMonth,
    this.nearbyOffers,
    this.featuredShops,
    this.rewardsPreview,
    this.upcomingDeals,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) {
    final deals = json['deals'] as Map<String, dynamic>?;
    return HomeData(
      loyaltyCard: SafeParser.parseObject(json['loyaltyCard'], LoyaltyCard.fromJson),
      premiumBanners: SafeParser.parseList(
          (json['banners'] as Map<String, dynamic>?)?['all'],
          BannerModel.fromJson),
      categories: SafeParser.parseList(json['categories'], CategoryModel.fromJson),
      // dealsOfDay: SafeParser.parseList(json['dealsOfDay'], OfferModel.fromJson),
      dealOfTheHour: SafeParser.parseList(deals?['deal_of_hour'], OfferModel.fromJson),
      dealOfTheDay: SafeParser.parseList(deals?['deal_of_day'], OfferModel.fromJson),
      dealOfTheWeek: SafeParser.parseList(deals?['deal_of_week'], OfferModel.fromJson),
      dealOfTheMonth: SafeParser.parseList(deals?['deal_of_month'], OfferModel.fromJson),
      nearbyOffers: SafeParser.parseList(json['nearbyOffers'], OfferModel.fromJson),
      featuredShops: SafeParser.parseList(json['featuredShops'], ShopModel.fromJson),
      rewardsPreview: SafeParser.parseList(json['rewardsPreview'], RewardModel.fromJson),
      upcomingDeals: SafeParser.parseList(json['upcomingDeals'], OfferModel.fromJson),
    );
  }
}

sealed class HomeResponseState {
  const HomeResponseState();
}

class CustomerHomeState extends HomeResponseState {
  final HomeData data;
  const CustomerHomeState(this.data);
}

class PartnerHomeState extends HomeResponseState {
  final PartnerHomeData data;
  const PartnerHomeState(this.data);
}
