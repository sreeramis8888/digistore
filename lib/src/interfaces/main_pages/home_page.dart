import 'package:setgo/src/interfaces/animations/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../components/home/home_app_bar.dart';
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
import '../../data/models/home_data_model.dart';
import 'partner/partner_home.dart';
import 'offer_pages/active_deals_page.dart';

import '../../data/constants/style_constants.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
  }

  void _navigateToDealsGrid(BuildContext context, String dealType, String dealTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ActiveDealsPage(
          dealType: dealType,
          dealTitle: dealTitle,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final homeDataAsync = ref.watch(homeDataProvider);

    if (GlobalVariables.isPartner) {
      return const PartnerHomePage();
    }

    return Scaffold(
      backgroundColor: kWhite,
      body: RefreshIndicator(
        color: kPrimaryColor,
        onRefresh: () => ref.refresh(homeDataProvider.future),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.responsivePadding(45)),
              const HomeAppBar().fadeIn(),
              SizedBox(height: screenSize.responsivePadding(16)),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16),
                ),
                child: Container(
                  height: screenSize.responsivePadding(54),
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(20),
                  ),
                  decoration: BoxDecoration(
                    color: kField,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search,
                        color: Color(0xFF7D848D),
                        size: 24,
                      ),
                      SizedBox(width: screenSize.responsivePadding(12)),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          focusNode: _searchFocusNode,
                          onTapOutside: (event) => _searchFocusNode.unfocus(),
                          onChanged: _onSearchChanged,
                          style: kSmallerTitleL.copyWith(color: kBlack),
                          decoration: InputDecoration(
                            hintText: "Search for 'services'",
                            hintStyle: kSmallerTitleL.copyWith(
                              color: kBlack.withOpacity(.5),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                    ],
                  ),
                ).fadeSlideInFromBottom(delayMilliseconds: 100),
              ),
              homeDataAsync.when(
                data: (state) {
                  if (state == null) {
                    return const Center(child: Text('No data available'));
                  }
                  if (state is CustomerHomeState) {
                    return _buildContent(context, ref, state.data, screenSize);
                  }
                  return const Center(child: Text('Invalid state'));
                },
                loading: () => const HomeShimmer(),
                error: (err, stack) => Center(child: Text('No Data Available')),
              ),
            ],
          ),
        ),
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

    final q = _searchQuery.trim();

    final categories = data.categories
        ?.where(
          (c) => q.isEmpty || (c.name?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final dealOfTheHour = data.dealOfTheHour
        ?.where(
          (o) => q.isEmpty || (o.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final dealOfTheDay = data.dealOfTheDay
        ?.where(
          (o) => q.isEmpty || (o.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final dealOfTheWeek = data.dealOfTheWeek
        ?.where(
          (o) => q.isEmpty || (o.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    // final dealsOfDay = data.dealsOfDay
    //     ?.where(
    //       (o) => q.isEmpty || (o.title?.toLowerCase().contains(q) ?? false),
    //     )
    //     .toList();
    final dealOfTheMonth = data.dealOfTheMonth
        ?.where(
          (o) => q.isEmpty || (o.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final featuredShops = data.featuredShops
        ?.where(
          (s) =>
              q.isEmpty ||
              (s.businessDetails?.businessName?.toLowerCase().contains(q) ??
                  false),
        )
        .toList();
    final rewardsPreview = data.rewardsPreview
        ?.where(
          (r) => q.isEmpty || (r.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.responsivePadding(16)),
        LoyaltyRewardCard(loyaltyCard: data.loyaltyCard),
        SizedBox(height: screenSize.responsivePadding(16)),
        if (categories != null && categories.isNotEmpty) ...[
          CategoryList(categories: categories),
          SizedBox(height: screenSize.responsivePadding(16)),
        ],
        if (dealOfTheHour != null && dealOfTheHour.isNotEmpty) ...[
          DealsCarousel(
            title: 'Deal of the Hour',
            deals: dealOfTheHour
                .map((offer) => DealCard.fromOffer(offer))
                .toList(),
            onViewAllTap: () => _navigateToDealsGrid(context, 'deal_of_hour', 'Deal of the Hour'),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
        ],
        if (featuredShops != null && featuredShops.isNotEmpty) ...[
          FeaturedShopsList(shops: featuredShops),
          SizedBox(height: screenSize.responsivePadding(16)),
        ],
        if (dealOfTheDay != null && dealOfTheDay.isNotEmpty) ...[
          DealsCarousel(
            title: 'Deal of the Day',
            deals: dealOfTheDay
                .map((offer) => DealCard.fromOffer(offer))
                .toList(),
            onViewAllTap: () => _navigateToDealsGrid(context, 'deal_of_day', 'Deal of the Day'),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
        ],
        if (dealOfTheWeek != null && dealOfTheWeek.isNotEmpty) ...[
          DealsCarousel(
            title: 'Deal of the Week',
            deals: dealOfTheWeek
                .map((offer) => DealCard.fromOffer(offer))
                .toList(),
            onViewAllTap: () => _navigateToDealsGrid(context, 'deal_of_week', 'Deal of the Week'),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
        ],
        // if (dealsOfDay != null && dealsOfDay.isNotEmpty) ...[
        //   DealsCarousel(
        //     title: 'Specials for You',
        //     deals: dealsOfDay
        //         .map((offer) => DealCard.fromOffer(offer))
        //         .toList(),
        //   ),
        //   SizedBox(height: screenSize.responsivePadding(16)),
        // ],
        if (data.premiumBanners != null && data.premiumBanners!.isNotEmpty) ...[
          BannerSection(banners: data.premiumBanners),
          SizedBox(height: screenSize.responsivePadding(16)),
        ],
        if (dealOfTheMonth != null && dealOfTheMonth.isNotEmpty) ...[
          DealsCarousel(
            title: 'Deal of the Month',
            deals: dealOfTheMonth
                .map((offer) => DealCard.fromOffer(offer))
                .toList(),
            onViewAllTap: () => _navigateToDealsGrid(context, 'deal_of_month', 'Deal of the Month'),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
        ],
        if (rewardsPreview != null && rewardsPreview.isNotEmpty)
          RewardsCarousel(rewards: rewardsPreview),
        SizedBox(height: screenSize.responsivePadding(40)),
      ],
    );
  }
}
