import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../components/home/home_app_bar.dart';
import '../components/home/home_search_bar.dart';
import '../components/home/loyalty_reward_card.dart';
import '../components/home/category_list.dart';
import '../components/home/deals_section.dart';
import '../components/home/featured_shops_list.dart';
import '../components/home/rewards_carousel.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeAppBar(),
              SizedBox(height: screenSize.responsivePadding(10)),
              const HomeSearchBar(),
              const LoyaltyRewardCard(),
              SizedBox(height: screenSize.responsivePadding(10)),
              const CategoryList(),
              SizedBox(height: screenSize.responsivePadding(10)),
              const DealsSection(),
              SizedBox(height: screenSize.responsivePadding(10)),
              const FeaturedShopsList(),
              SizedBox(height: screenSize.responsivePadding(20)),
              const RewardsCarousel(),
              SizedBox(height: screenSize.responsivePadding(40)), // Bottom padding
            ],
          ),
        ),
      ),
    );
  }
}
