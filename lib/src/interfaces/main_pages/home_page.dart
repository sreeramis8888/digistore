import 'dart:async';
import 'package:setgo/src/interfaces/animations/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../../data/services/connectivity_service.dart';
import '../components/home/home_hero_section.dart';
import '../components/home/category_list.dart';
import '../components/home/deal_of_hour_section.dart';
import '../components/home/home_deals_section.dart';
import '../components/home/banner_section.dart';
import '../components/home/featured_shops_list.dart';
import '../components/home/home_rewards_section.dart';
import '../components/shimmers/home_shimmer.dart';
import '../../data/utils/global_variables.dart';

import '../../data/providers/home_provider.dart';
import '../../data/providers/shops_provider.dart';
import '../../data/models/home_data_model.dart';
import 'partner/partner_home.dart';
import 'offer_pages/active_deals_page.dart';
import '../../data/providers/banners_provider.dart';

import '../components/home/restaurant_banner_card.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _searchQuery = '';
  StreamSubscription<void>? _connectivitySubscription;

  @override
  void initState() {
    super.initState();
    _connectivitySubscription =
        ConnectivityService.instance.onConnectionRestored.listen((_) {
      if (!mounted) return;
      _autoRetryIfError();
    });
  }

  void _autoRetryIfError() {
    final homeDataState = ref.read(homeDataProvider);
    if (homeDataState.hasError || homeDataState.value == null) {
      ref.invalidate(homeDataProvider);
      ref.invalidate(bannersProvider);
    }
  }

  void _onSearchChanged(String query) {
    setState(() => _searchQuery = query);
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _navigateToDealsGrid(
    BuildContext context,
    String dealType,
    String dealTitle,
  ) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ActiveDealsPage(dealType: dealType, dealTitle: dealTitle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final homeDataAsync = ref.watch(homeDataProvider);

    ref.listen<AsyncValue<HomeResponseState?>>(homeDataProvider, (previous, next) {
      if (next.hasError) {
        ConnectivityService.instance.checkConnectivity();
      }
    });

    if (GlobalVariables.isPartner) {
      return const PartnerHomePage();
    }

    final loyaltyCard = homeDataAsync.whenOrNull(
      data: (state) =>
          state is CustomerHomeState ? state.data.loyaltyCard : null,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: kHomePageBg,
        body: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () async {
            await Future.wait([
              ref.refresh(homeDataProvider.future),
              ref.refresh(restaurantShopsCountProvider.future),
            ]);
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HomeHeroSection(
                  loyaltyCard: loyaltyCard,
                  searchController: _searchController,
                  searchFocusNode: _searchFocusNode,
                  onSearchChanged: _onSearchChanged,
                ).fadeIn(),
                homeDataAsync.when(
                  data: (state) {
                    if (state == null) {
                      return _buildEmptyState(context, 'No data available');
                    }
                    if (state is CustomerHomeState) {
                      return _buildContent(context, ref, state.data, screenSize);
                    }
                    return _buildEmptyState(context, 'Invalid state');
                  },
                  loading: () => const HomeShimmer(),
                  error: (err, stack) => _buildEmptyState(
                    context,
                    'No Data Available',
                    isError: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, String message, {bool isError = false}) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.5,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isError ? Icons.wifi_off_rounded : Icons.inbox_outlined,
              size: 48,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isError) ...[
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () {
                  ref.invalidate(homeDataProvider);
                  ref.invalidate(bannersProvider);
                  ref.invalidate(restaurantShopsCountProvider);
                },
                icon: const Icon(Icons.refresh_rounded, size: 18),
                label: const Text('Retry'),
              ),
            ],
          ],
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
      return _buildEmptyState(context, 'No data available');
    }

    final homeBannersAsync = ref.watch(bannersProvider(const BannerFilter(page: 'home')));
    final effectiveBanners = (homeBannersAsync.value != null && homeBannersAsync.value!.isNotEmpty)
        ? homeBannersAsync.value
        : data.premiumBanners;

    final q = _searchQuery.trim();

    final categories = data.categories
        ?.where(
          (c) => q.isEmpty || (c.name?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final dealOfTheMonth = data.dealOfTheMonth
        ?.where(
          (o) => q.isEmpty || (o.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final dealOfTheWeek = data.dealOfTheWeek
        ?.where(
          (o) => q.isEmpty || (o.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final dealOfTheDay = data.dealOfTheDay
        ?.where(
          (o) => q.isEmpty || (o.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();
    final dealOfTheHour = data.dealOfTheHour
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
    final popularRewards = data.popularRewards
        ?.where(
          (r) => q.isEmpty || (r.title?.toLowerCase().contains(q) ?? false),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: screenSize.responsivePadding(20)),
        if (dealOfTheHour != null && dealOfTheHour.isNotEmpty) ...[
          DealOfHourSection(
            offers: dealOfTheHour,
            variant: DealOfHourVariant.promo,
            onViewAllTap: () => _navigateToDealsGrid(
              context,
              'deal_of_hour',
              'Deal of the Hour',
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(28)),
        ],
        if (categories != null && categories.isNotEmpty) ...[
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            child: const RestaurantBannerCard(),
          ),
          SizedBox(height: screenSize.responsivePadding(20)),
          CategoryList(categories: categories),
          SizedBox(height: screenSize.responsivePadding(28)),
        ],
        if (dealOfTheDay != null && dealOfTheDay.isNotEmpty) ...[
          HomeDealsSection(
            title: 'Deal of the Day',
            offers: dealOfTheDay,
            onViewAllTap: () =>
                _navigateToDealsGrid(context, 'deal_of_day', 'Deal of the Day'),
          ),
          SizedBox(height: screenSize.responsivePadding(28)),
        ],
        if (featuredShops != null && featuredShops.isNotEmpty) ...[
          FeaturedShopsList(shops: featuredShops),
          SizedBox(height: screenSize.responsivePadding(28)),
        ],
        if (popularRewards != null && popularRewards.isNotEmpty) ...[
          HomeRewardsSection(rewards: popularRewards),
          SizedBox(height: screenSize.responsivePadding(28)),
        ],
        if (dealOfTheWeek != null && dealOfTheWeek.isNotEmpty) ...[
          HomeDealsSection(
            title: 'Deal of the Week',
            offers: dealOfTheWeek,
            onViewAllTap: () => _navigateToDealsGrid(
              context,
              'deal_of_week',
              'Deal of the Week',
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(28)),
        ],
        if (dealOfTheMonth != null && dealOfTheMonth.isNotEmpty) ...[
          HomeDealsSection(
            title: 'Deal of the Month',
            offers: dealOfTheMonth,
            onViewAllTap: () => _navigateToDealsGrid(
              context,
              'deal_of_month',
              'Deal of the Month',
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(28)),
        ],
        if (effectiveBanners != null && effectiveBanners.isNotEmpty) ...[
          BannerSection(
            key: const ValueKey('home_banner_section'),
            banners: effectiveBanners,
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
        ],
        SizedBox(height: screenSize.responsivePadding(40)),
      ],
    );
  }
}
