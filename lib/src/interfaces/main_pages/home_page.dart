import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../components/home/home_app_bar.dart';
import '../components/home/home_search_bar.dart';
import '../components/cards/loyalty_reward_card.dart';
import '../components/home/category_list.dart';
import '../components/home/deals_carousel.dart';
import '../components/home/banner_section.dart';
import '../components/cards/deal_card.dart';
import '../components/home/featured_shops_list.dart';
import '../components/home/rewards_carousel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenSize.responsivePadding(45)),
            const HomeAppBar(),
            SizedBox(height: screenSize.responsivePadding(10)),
            const HomeSearchBar(),
            SizedBox(height: screenSize.responsivePadding(10)),
            const LoyaltyRewardCard(),
            SizedBox(height: screenSize.responsivePadding(10)),
            const CategoryList(),
            SizedBox(height: screenSize.responsivePadding(10)),
            
            DealsCarousel(
              title: 'Deal of the Hour',
              deals: [
                DealCard(
                  title: 'Fresh Bakes Deal',
                  subtitle: 'Buy one bun Get one free',
                  shopName: 'HomeGoods',
                  badgeText: 'BUY 1\nGET 1',
                  avatarColor: kPrimaryLightColor,
                ),
                DealCard(
                  title: 'Special Salon Offer',
                  subtitle: 'Try any haircut Get 30% off',
                  shopName: 'Glow Saloon',
                  badgeText: '30%\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
                DealCard(
                  title: 'Weekend Groceries',
                  subtitle: '50% off on all fresh fruits',
                  shopName: 'FreshMarket',
                  badgeText: '50%\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
              ],
            ),
            SizedBox(height: screenSize.responsivePadding(10)),
            
            const FeaturedShopsList(),
            SizedBox(height: screenSize.responsivePadding(20)),
            
            DealsCarousel(
              title: 'Deal of the Day',
              deals: [
                DealCard(
                  title: 'Big Grocery Savings',
                  subtitle: 'Shop for ₹500 minimum and Save ₹100',
                  shopName: 'DailyMart',
                  badgeText: '₹100\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
                DealCard(
                  title: 'Beverage Bonanza',
                  subtitle: 'Mix and match 3 drinks > Get 20% off',
                  shopName: 'Drinkdrop',
                  badgeText: '20%\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
                DealCard(
                  title: 'Meat Deal',
                  subtitle: 'Save up to 10% on your orders today',
                  shopName: 'DailyMart',
                  badgeText: '10%\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
              ],
            ),
            SizedBox(height: screenSize.responsivePadding(20)),
            
            const BannerSection(),
            SizedBox(height: screenSize.responsivePadding(20)),
            
            DealsCarousel(
              title: 'Deal of the Week',
              deals: [
                DealCard(
                  title: 'Fresh Bakes Deal',
                  subtitle: 'Buy one bun Get one free',
                  shopName: 'HomeGoods',
                  badgeText: 'BUY 1\nGET 1',
                  avatarColor: kPrimaryLightColor,
                ),
                DealCard(
                  title: 'Big Grocery Savings',
                  subtitle: 'Shop for ₹500 minimum and Save ₹100',
                  shopName: 'DailyMart',
                  badgeText: '₹100\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
                DealCard(
                  title: 'Special Salon Offer',
                  subtitle: 'Try any haircut Get 30% off',
                  shopName: 'Glow Saloon',
                  badgeText: '30%\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
              ],
            ),
            SizedBox(height: screenSize.responsivePadding(20)),
            
            const RewardsCarousel(),
            SizedBox(height: screenSize.responsivePadding(20)),
            
            // Deal of the Month
            DealsCarousel(
              title: 'Deal of the Month',
              deals: [
                DealCard(
                  title: 'Special Salon Offer',
                  subtitle: 'Try any haircut Get 30% off',
                  shopName: 'Glow Saloon',
                  badgeText: '30%\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
                DealCard(
                  title: 'Big Grocery Savings',
                  subtitle: 'Shop for ₹500 minimum and Save ₹100',
                  shopName: 'DailyMart',
                  badgeText: '₹100\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
                DealCard(
                  title: 'Beverage Bonanza',
                  subtitle: 'Mix and match 3 drinks > Get 20% off',
                  shopName: 'Drinkdrop',
                  badgeText: '20%\nOFF',
                  avatarColor: kPrimaryLightColor,
                ),
              ],
            ),
            SizedBox(height: screenSize.responsivePadding(40)),
          ],
        ),
      ),
    );
  }
}
