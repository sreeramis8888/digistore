import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/models/offer_model.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/offers_provider.dart';
import '../../data/providers/screen_size_provider.dart';
import '../../data/router/nav_router.dart';
import '../../data/utils/global_variables.dart';
import '../animations/index.dart';
import '../components/empty_state.dart';
import '../components/offers/deal_card.dart';
import '../components/offers/offers_filter_chips.dart';
import '../components/primary_button.dart';
import '../components/shimmers/card_shimmers.dart';
import 'partner/create_offer_page.dart';

class OffersPage extends ConsumerStatefulWidget {
  const OffersPage({super.key});

  @override
  ConsumerState<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends ConsumerState<OffersPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(offersProvider.notifier).updateSearch(query);
    });
  }

  void _fetchOffers({int? index}) {
    final currentIndex = index ?? ref.read(selectedOffersCategoryProvider);
    final categoriesAsync = ref.read(categoriesProvider);
    String? categoryId;

    if (categoriesAsync.hasValue) {
      final categories = categoriesAsync.value!;
      if (currentIndex != null &&
          currentIndex > 0 &&
          currentIndex <= categories.length) {
        categoryId = categories[currentIndex - 1].id;
      }
    }

    ref.read(offersProvider.notifier).fetchOffers(categoryId: categoryId);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<int>(selectedOffersCategoryProvider, (previous, next) {
      if (previous != next) {
        _fetchOffers(index: next);
      }
    });

    final screenSize = ref.watch(screenSizeProvider);
    final offersState = ref.watch(offersProvider);

    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(230);
    final aspectRatio = itemWidth / itemHeight;

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'Offers',
          style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (GlobalVariables.isPartner)
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
                vertical: screenSize.responsivePadding(8),
              ),
              child: PrimaryButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateOfferPage(),
                    ),
                  );
                },
                width: screenSize.responsivePadding(120),
                text: 'Create Offer',
                textSize: 12,
                backgroundColor: kPrimaryColor,
                textColor: kWhite,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            if (!GlobalVariables.isPartner) const OffersFilterChips(),
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
                          hintText: "Search for 'offers'",
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
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
            Expanded(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildBody(
                  context,
                  offersState: offersState,
                  aspectRatio: aspectRatio,
                  screenSize: screenSize,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context, {
    required PaginatedOffers offersState,
    required double aspectRatio,
    required ScreenSizeData screenSize,
  }) {
    // Partner view — simple grid, no split
    if (GlobalVariables.isPartner) {
      if (offersState.isLoading && offersState.offers.isEmpty) {
        return _shimmerGrid(
          screenSize,
          aspectRatio,
          key: const ValueKey('partner_shimmer'),
        );
      }
      if (offersState.offers.isEmpty) {
        return RefreshIndicator(
          color: kPrimaryColor,
          key: const ValueKey('partner_empty'),
          onRefresh: () async {
            await ref.read(offersProvider.notifier).fetchOffers();
          },
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyState(
                  imagePath: 'assets/png/empty_offers.png',
                  title: 'No offer created yet',
                  subtitle:
                      'You haven\'t created any offers yet. Start by creating your first deal!',
                ).fadeIn(),
              ),
            ],
          ),
        );
      }
      return RefreshIndicator(
        color: kPrimaryColor,
        key: ValueKey('partner_grid_${offersState.currentCategoryId ?? 'all'}'),
        onRefresh: () async {
          await ref.read(offersProvider.notifier).fetchOffers();
        },
        child: _offersGrid(offersState.offers, aspectRatio, screenSize),
      );
    }

    // Customer view — two sections
    final hasNearby = offersState.offers.isNotEmpty;
    final hasExplore = offersState.exploreOffers.isNotEmpty;
    final isLoadingNearby = offersState.isLoading;
    final isLoadingExplore = offersState.isExploreLoading;

    if (isLoadingNearby && !hasNearby) {
      return _shimmerGrid(
        screenSize,
        aspectRatio,
        key: const ValueKey('customer_shimmer'),
      );
    }

    if (!hasNearby && !hasExplore && !isLoadingExplore) {
      return RefreshIndicator(
        color: kPrimaryColor,
        key: const ValueKey('customer_empty'),
        onRefresh: () async {
          await ref
              .read(offersProvider.notifier)
              .fetchOffers(categoryId: offersState.currentCategoryId);
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: EmptyState(
                imagePath: 'assets/png/empty_offers.png',
                title: 'No offers found',
                subtitle:
                    'Check back later for exciting new deals and discounts in this category.',
              ).fadeIn(),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      color: kPrimaryColor,
      key: ValueKey(
        'customer_content_${offersState.currentCategoryId ?? 'all'}',
      ),
      onRefresh: () async {
        await ref
            .read(offersProvider.notifier)
            .fetchOffers(categoryId: offersState.currentCategoryId);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          if (hasNearby || isLoadingNearby) ...[
            SliverToBoxAdapter(
              child: _sectionHeader('Offers Near You', screenSize),
            ),
            if (isLoadingNearby && !hasNearby)
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16.0),
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (_, i) => CardShimmers.dealCardShimmer(screenSize),
                    childCount: 4,
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: screenSize.responsivePadding(16.0),
                    crossAxisSpacing: screenSize.responsivePadding(16.0),
                    childAspectRatio: aspectRatio,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16.0),
                ),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate((_, index) {
                    final o = offersState.offers[index];
                    return DealCard.fromOffer(o);
                  }, childCount: offersState.offers.length),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: screenSize.responsivePadding(16.0),
                    crossAxisSpacing: screenSize.responsivePadding(16.0),
                    childAspectRatio: aspectRatio,
                  ),
                ),
              ),
            SliverToBoxAdapter(
              child: SizedBox(height: screenSize.responsivePadding(24.0)),
            ),
          ],

          // ── Explore More Offers ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _sectionHeader('Explore More Offers', screenSize),
          ),
          if (isLoadingExplore && !hasExplore)
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16.0),
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate(
                  (_, i) => CardShimmers.dealCardShimmer(screenSize),
                  childCount: 4,
                ),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: screenSize.responsivePadding(16.0),
                  crossAxisSpacing: screenSize.responsivePadding(16.0),
                  childAspectRatio: aspectRatio,
                ),
              ),
            )
          else if (!hasExplore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(screenSize.responsivePadding(32.0)),
                child: Center(
                  child: Text(
                    'No more offers to explore.',
                    style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16.0),
              ),
              sliver: SliverGrid(
                delegate: SliverChildBuilderDelegate((_, index) {
                  final o = offersState.exploreOffers[index];
                  return DealCard.fromOffer(o);
                }, childCount: offersState.exploreOffers.length),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: screenSize.responsivePadding(16.0),
                  crossAxisSpacing: screenSize.responsivePadding(16.0),
                  childAspectRatio: aspectRatio,
                ),
              ),
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: screenSize.responsivePadding(24.0)),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title, ScreenSizeData screenSize) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenSize.responsivePadding(16.0),
        0,
        screenSize.responsivePadding(16.0),
        screenSize.responsivePadding(12.0),
      ),
      child: Text(
        title,
        style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
      ),
    );
  }

  Widget _shimmerGrid(
    ScreenSizeData screenSize,
    double aspectRatio, {
    Key? key,
  }) {
    return GridView.builder(
      key: key,
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16.0),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: screenSize.responsivePadding(16.0),
        crossAxisSpacing: screenSize.responsivePadding(16.0),
        childAspectRatio: aspectRatio,
      ),
      itemCount: 6,
      itemBuilder: (_, __) => CardShimmers.dealCardShimmer(screenSize),
    );
  }

  Widget _offersGrid(
    List<OfferModel> offers,
    double aspectRatio,
    ScreenSizeData screenSize,
  ) {
    return GridView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16.0),
      ),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: screenSize.responsivePadding(16.0),
        crossAxisSpacing: screenSize.responsivePadding(16.0),
        childAspectRatio: aspectRatio,
      ),
      itemCount: offers.length,
      itemBuilder: (_, index) {
        final o = offers[index];
        return DealCard.fromOffer(o);
      },
    );
  }
}
