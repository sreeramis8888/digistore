import 'package:digistore/src/interfaces/animations/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../components/home/home_app_bar.dart';
import '../components/home/home_search_bar.dart';
import '../components/rewards/loyalty_reward_card.dart';
import '../components/home/category_list.dart';
import '../components/home/deals_carousel.dart';
import '../components/home/banner_section.dart';
import '../components/offers/deal_card.dart';
import '../components/home/featured_shops_list.dart';
import '../components/home/rewards_carousel.dart';
import '../components/shimmers/home_shimmer.dart';
import '../../data/utils/global_variables.dart';

import '../../data/providers/home_provider.dart';
import '../../data/models/home_data.dart';
import 'partner/partner_home.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final homeDataAsync = ref.watch(homeDataProvider);

    if (GlobalVariables.isPartner) {
      return const PartnerHomePage();
    }

    return Scaffold(
      backgroundColor: kWhite,
      body: Column(
        children: [
          SizedBox(height: screenSize.responsivePadding(45)),
          const HomeAppBar().fadeIn(),
          SizedBox(height: screenSize.responsivePadding(16)),
          const HomeSearchBar().fadeSlideInFromBottom(delayMilliseconds: 100),
          Expanded(
            child: homeDataAsync.when(
              data: (state) {
                if (state == null) {
                  return const Center(child: Text('No data available'));
                }
                if (state is CustomerHomeState) {
                  return _buildContent(context, ref, state.data, screenSize);
                }
                return const Center(child: Text('Invalid state'));
              },
              loading: () => const HomeShimmer(isPartner: false),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    WidgetRef ref,
    HomeData? data,
    ScreenSizeData screenSize,
  ) {
    if (data == null) {
      return const Center(child: Text('No data available'));
    }

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: screenSize.responsivePadding(16)),
          LoyaltyRewardCard(loyaltyCard: data.loyaltyCard),
          SizedBox(height: screenSize.responsivePadding(16)),
          CategoryList(categories: data.categories),
          SizedBox(height: screenSize.responsivePadding(16)),
          if (data.dealOfTheHour != null && data.dealOfTheHour!.isNotEmpty) ...[
            DealsCarousel(
              title: 'Deal of the Hour',
              deals: data.dealOfTheHour!
                  .map((offer) => DealCard.fromOffer(offer))
                  .toList(),
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
          ],
          FeaturedShopsList(shops: data.featuredShops),
          SizedBox(height: screenSize.responsivePadding(16)),
          if (data.dealOfTheDay != null && data.dealOfTheDay!.isNotEmpty) ...[
            DealsCarousel(
              title: 'Deal of the Day',
              deals: data.dealOfTheDay!
                  .map((offer) => DealCard.fromOffer(offer))
                  .toList(),
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
          ],
          if (data.dealsOfDay != null && data.dealsOfDay!.isNotEmpty) ...[
            DealsCarousel(
              title: 'Specials for You',
              deals: data.dealsOfDay!
                  .map((offer) => DealCard.fromOffer(offer))
                  .toList(),
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
          ],
          BannerSection(banners: data.premiumBanners),
          SizedBox(height: screenSize.responsivePadding(16)),
          if (data.dealOfTheMonth != null &&
              data.dealOfTheMonth!.isNotEmpty) ...[
            DealsCarousel(
              title: 'Deal of the Month',
              deals: data.dealOfTheMonth!
                  .map((offer) => DealCard.fromOffer(offer))
                  .toList(),
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
          ],
          RewardsCarousel(rewards: data.rewardsPreview),
          SizedBox(height: screenSize.responsivePadding(40)),
        ],
      ),
    );
  }
}
