import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/offers_provider.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/empty_state.dart';
import '../../components/offers/deal_card.dart';
import '../../components/shimmers/card_shimmers.dart';
import '../../animations/index.dart';

class ActiveDealsPage extends ConsumerWidget {
  final String dealType;
  final String dealTitle;

  const ActiveDealsPage({
    super.key,
    required this.dealType,
    required this.dealTitle,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final dealsAsync = ref.watch(activeDealsProvider(dealType: dealType));

    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(230);
    final aspectRatio = itemWidth / itemHeight;

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          dealTitle,
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
          onRefresh: () => ref.refresh(activeDealsProvider(dealType: dealType).future),
          child: dealsAsync.when(
            data: (deals) {
              if (deals.isEmpty) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        imagePath: 'assets/png/empty_offers.png',
                        title: 'No active deals',
                        subtitle: 'There are currently no active offers for $dealTitle.',
                      ).fadeIn(),
                    ),
                  ],
                );
              }

              return GridView.builder(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16.0),
                  vertical: screenSize.responsivePadding(16.0),
                ),
                physics: const AlwaysScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: screenSize.responsivePadding(16.0),
                  crossAxisSpacing: screenSize.responsivePadding(16.0),
                  childAspectRatio: aspectRatio,
                ),
                itemCount: deals.length,
                itemBuilder: (context, index) {
                  final deal = deals[index];
                  return DealCard.fromOffer(deal).fadeIn(
                    delayMilliseconds: index * 50,
                  );
                },
              );
            },
            loading: () => GridView.builder(
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
            ),
            error: (error, stackTrace) => CustomScrollView(
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
                            error.toString(),
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
                            onPressed: () => ref.invalidate(activeDealsProvider(dealType: dealType)),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
