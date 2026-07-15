import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/category_model.dart';
import '../../../data/providers/category_offers_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../animations/index.dart';
import '../../components/empty_state.dart';
import '../../components/loading_indicator.dart';
import '../../components/offers/deal_card.dart';
import '../../components/shimmers/card_shimmers.dart';
import '../../../data/providers/banners_provider.dart';
import '../../components/common/paginated_banner_grid.dart';

class CategoryOffersPage extends ConsumerStatefulWidget {
  final CategoryModel category;

  const CategoryOffersPage({
    super.key,
    required this.category,
  });

  @override
  ConsumerState<CategoryOffersPage> createState() => _CategoryOffersPageState();
}

class _CategoryOffersPageState extends ConsumerState<CategoryOffersPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(categoryOffersProvider(widget.category.id));
      if (!state.isLoading && state.hasMore) {
        ref
            .read(categoryOffersProvider(widget.category.id).notifier)
            .fetchOffers(isRefresh: false);
      } else if (!state.isExploreLoading && state.exploreHasMore) {
        ref
            .read(categoryOffersProvider(widget.category.id).notifier)
            .fetchExploreOffers(isRefresh: false);
      }
    }
  }

  Widget _sectionHeader(String title, dynamic screenSize) {
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

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final state = ref.watch(categoryOffersProvider(widget.category.id));
    final bannersAsync = ref.watch(bannersProvider(BannerFilter(category: widget.category.id)));
    final banners = bannersAsync.value ?? [];

    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(230);
    final aspectRatio = itemWidth / itemHeight;

    Widget bodyContent;

    if (state.isLoading && state.offers.isEmpty && state.exploreOffers.isEmpty) {
      bodyContent = GridView.builder(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(16.0),
          vertical: screenSize.responsivePadding(16.0),
        ),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: screenSize.responsivePadding(16.0),
          crossAxisSpacing: screenSize.responsivePadding(16.0),
          childAspectRatio: aspectRatio,
        ),
        itemCount: 6,
        itemBuilder: (context, index) =>
            CardShimmers.dealCardShimmer(screenSize),
      );
    } else if (state.error != null &&
        state.offers.isEmpty &&
        state.exploreOffers.isEmpty) {
      bodyContent = CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(32.0),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: kRed,
                      size: screenSize.responsivePadding(48),
                    ),
                    SizedBox(height: screenSize.responsivePadding(16)),
                    Text(
                      'Failed to load category offers',
                      style: kBodyTitleM.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenSize.responsivePadding(8)),
                    Text(
                      state.error!,
                      style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenSize.responsivePadding(24)),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kPrimaryColor,
                        foregroundColor: kWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.responsivePadding(24),
                          vertical: screenSize.responsivePadding(12),
                        ),
                      ),
                      onPressed: () => ref
                          .read(categoryOffersProvider(widget.category.id)
                              .notifier)
                          .fetchOffers(isRefresh: true),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else if (state.offers.isEmpty && state.exploreOffers.isEmpty) {
      bodyContent = CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              imagePath: 'assets/png/empty_offers.png',
              title: 'No offers in ${widget.category.name ?? 'this category'}',
              subtitle: 'We couldn\'t find any active deals under this category right now.',
            ).fadeIn(),
          ),
        ],
      );
    } else {
      bodyContent = CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(
            child: _sectionHeader('Offers Near You', screenSize),
          ),
          if (state.isLoading)
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
          else if (state.error != null && state.offers.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16.0),
                  vertical: screenSize.responsivePadding(8.0),
                ),
                child: Text(
                  'No nearby offers',
                  style: kSmallerTitleL.copyWith(
                    color: kSecondaryTextColor,
                  ),
                ),
              ),
            )
          else if (state.offers.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16.0),
                  vertical: screenSize.responsivePadding(8.0),
                ),
                child: Text(
                  'No offers found near your location.',
                  style: kSmallerTitleL.copyWith(
                    color: kSecondaryTextColor,
                  ),
                ),
              ),
            )
          else
            ...buildPaginatedGridSliversWithBanners(
              items: state.offers,
              itemBuilder: (_, index, deal) => DealCard.fromOffer(deal),
              banners: banners,
              hasMore: state.hasMore,
              screenSize: screenSize,
              childAspectRatio: aspectRatio,
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: screenSize.responsivePadding(24.0)),
          ),

          // ── Explore More Offers ──────────────────────────────────────
          SliverToBoxAdapter(
            child: _sectionHeader('Explore More Offers', screenSize),
          ),
          if (state.isExploreLoading)
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
          else if (state.exploreOffers.isEmpty)
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
            ...buildPaginatedGridSliversWithBanners(
              items: state.exploreOffers,
              itemBuilder: (_, index, deal) => DealCard.fromOffer(deal),
              banners: banners,
              hasMore: state.exploreHasMore,
              screenSize: screenSize,
              childAspectRatio: aspectRatio,
              bannerIndexOffset: state.offers.length ~/ 10,
            ),

          SliverToBoxAdapter(
            child: SizedBox(height: screenSize.responsivePadding(24.0)),
          ),
          if (state.isFetchingMore || state.isExploreFetchingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: screenSize.responsivePadding(24.0),
                ),
                child: Center(
                  child: LoadingAnimation(
                    size: screenSize.responsivePadding(30),
                  ),
                ),
              ),
            ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.category.name ?? 'Category Offers',
          style: kBodyTitleM.copyWith(
            fontWeight: FontWeight.w700,
            color: kTextColor,
          ),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        color: kPrimaryColor,
        onRefresh: () async {
          await ref
              .read(categoryOffersProvider(widget.category.id).notifier)
              .fetchOffers(isRefresh: true);
        },
        child: bodyContent,
      ),
    );
  }
}
