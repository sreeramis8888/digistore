import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/offers_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/empty_state.dart';
import '../../components/loading_indicator.dart';
import '../../components/offers/deal_card.dart';
import '../../components/shimmers/card_shimmers.dart';

class ActiveDealsPage extends ConsumerStatefulWidget {
  final String dealType;
  final String dealTitle;

  const ActiveDealsPage({
    super.key,
    required this.dealType,
    required this.dealTitle,
  });

  @override
  ConsumerState<ActiveDealsPage> createState() => _ActiveDealsPageState();
}

class _ActiveDealsPageState extends ConsumerState<ActiveDealsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final state = ref.read(activeDealsProvider(dealType: widget.dealType));
      if (!state.isLoading && !state.isFetchingMore && state.hasMore) {
        ref
            .read(activeDealsProvider(dealType: widget.dealType).notifier)
            .fetchDeals(isRefresh: false);
      }
    }
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
    final dealsState =
        ref.watch(activeDealsProvider(dealType: widget.dealType));

    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(230);
    final aspectRatio = itemWidth / itemHeight;

    Widget bodyContent;

    if (dealsState.isLoading && dealsState.offers.isEmpty) {
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
        itemBuilder: (context, index) => CardShimmers.dealCardShimmer(screenSize),
      );
    } else if (dealsState.error != null && dealsState.offers.isEmpty) {
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
                      'Failed to load deals',
                      style: kBodyTitleM.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenSize.responsivePadding(8)),
                    Text(
                      dealsState.error!,
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
                          .read(activeDealsProvider(dealType: widget.dealType).notifier)
                          .fetchDeals(isRefresh: true),
                      child: const Text('Try Again'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    } else if (dealsState.offers.isEmpty) {
      bodyContent = CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: EmptyState(
              imagePath: 'assets/png/empty_offers.png',
              title: 'No active deals',
              subtitle: 'There are currently no active offers for ${widget.dealTitle}.',
            ),
          ),
        ],
      );
    } else {
      bodyContent = CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16.0),
              vertical: screenSize.responsivePadding(16.0),
            ),
            sliver: SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final deal = dealsState.offers[index];
                  return DealCard.fromOffer(deal);
                },
                childCount: dealsState.offers.length,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: screenSize.responsivePadding(16.0),
                crossAxisSpacing: screenSize.responsivePadding(16.0),
                childAspectRatio: aspectRatio,
              ),
            ),
          ),
          if (dealsState.isFetchingMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.responsivePadding(24.0),
                ),
                child: Center(
                  child: LoadingAnimation(size: screenSize.responsivePadding(30)),
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: SizedBox(height: screenSize.responsivePadding(24.0)),
          ),
        ],
      );
    }

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(   titleSpacing: 0,
        title: Text(
          widget.dealTitle,
          style: kBodyTitleM.copyWith(
            color: const Color(0xFF373737),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 20, color: kTextColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () => ref
              .read(activeDealsProvider(dealType: widget.dealType).notifier)
              .fetchDeals(isRefresh: true),
          child: bodyContent,
        ),
      ),
    );
  }
}
