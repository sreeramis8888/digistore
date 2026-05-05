import 'package:digistore/src/data/router/nav_router.dart';
import 'package:digistore/src/interfaces/animations/index.dart';
import 'package:digistore/src/interfaces/components/shimmers/card_shimmers.dart';
import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../components/offers/offers_filter_chips.dart';
import '../components/offers/deal_card.dart';
import '../../data/utils/global_variables.dart';
import '../components/home/home_search_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/screen_size_provider.dart';

import '../../data/providers/offers_provider.dart';
import '../../data/providers/category_provider.dart';
import '../components/empty_state.dart';
import '../components/primary_button.dart';
import 'partner/create_offer_page.dart';

class OffersPage extends ConsumerStatefulWidget {
  const OffersPage({super.key});

  @override
  ConsumerState<OffersPage> createState() => _OffersPageState();
}

class _OffersPageState extends ConsumerState<OffersPage> {
  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(235);
    final aspectRatio = itemWidth / itemHeight;

    final selectedCategoryIndex = ref.watch(selectedOffersCategoryProvider);
    final categoriesAsync = ref.watch(categoriesProvider);

    String? categoryId;
    categoriesAsync.whenData((categories) {
      if (selectedCategoryIndex > 0 &&
          selectedCategoryIndex <= categories.length) {
        categoryId = categories[selectedCategoryIndex - 1].id;
      }
    });

    final offersState = ref.watch(offersProvider);

    if (categoryId != offersState.currentCategoryId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(offersProvider.notifier).fetchOffers(categoryId: categoryId);
      });
    }

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
            if (GlobalVariables.isPartner) ...[
              SizedBox(height: screenSize.responsivePadding(16)),
              const HomeSearchBar(hintText: "Search for 'offers'"),
            ] else
              const OffersFilterChips(),
            SizedBox(height: screenSize.responsivePadding(16)),
            Expanded(
              child: _buildBody(
                context,
                offersState: offersState,
                aspectRatio: aspectRatio,
                screenSize: screenSize,
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
    required screenSize,
  }) {
    // Partner view — simple grid, no split
    if (GlobalVariables.isPartner) {
      if (offersState.isLoading) {
        return _shimmerGrid(screenSize, aspectRatio);
      }
      if (offersState.offers.isEmpty) {
        return RefreshIndicator(
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
      return _shimmerGrid(screenSize, aspectRatio);
    }

    if (!hasNearby && !hasExplore && !isLoadingExplore) {
      return RefreshIndicator(
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
      onRefresh: () async {
        await ref
            .read(offersProvider.notifier)
            .fetchOffers(categoryId: offersState.currentCategoryId);
      },
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
        // ── Offers Near You ──────────────────────────────────────────
        if (hasNearby || isLoadingNearby) ...[
          SliverToBoxAdapter(
            child: _sectionHeader(
              'Offers Near You',
              screenSize,
            ),
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
                delegate: SliverChildBuilderDelegate(
                  (_, index) {
                    final o = offersState.offers[index];
                    return DealCard.fromOffer(o).fadeSlideInFromBottom(
                      delayMilliseconds: index * 50,
                    );
                  },
                  childCount: offersState.offers.length,
                ),
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
              delegate: SliverChildBuilderDelegate(
                (_, index) {
                  final o = offersState.exploreOffers[index];
                  return DealCard.fromOffer(o).fadeSlideInFromBottom(
                    delayMilliseconds: index * 50,
                  );
                },
                childCount: offersState.exploreOffers.length,
              ),
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

  Widget _sectionHeader(String title, screenSize) {
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

  Widget _shimmerGrid(screenSize, double aspectRatio) {
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
      itemCount: 6,
      itemBuilder: (_, __) => CardShimmers.dealCardShimmer(screenSize),
    );
  }

  Widget _offersGrid(offers, double aspectRatio, screenSize) {
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
        return DealCard.fromOffer(o).fadeSlideInFromBottom(
          delayMilliseconds: index * 50,
        );
      },
    );
  }
}
