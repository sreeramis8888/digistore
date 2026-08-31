import 'package:setgo/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';
import '../../../../src/data/providers/reviews_provider.dart';
import '../../../../src/data/models/review_model.dart';
import '../advanced_network_image.dart';
import '../full_screen_gallery.dart';
import './add_review_sheet.dart';
import './all_reviews_page.dart';

class ShopReviews extends ConsumerWidget {
  final ShopModel? shop;

  const ShopReviews({super.key, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final reviewCount = shop?.businessInfo?.totalReviews ?? 0;
    final shopId = shop?.id;

    final reviewsAsync = ref.watch(reviewsProvider(shopId: shopId));
    final fetchedTotal = reviewsAsync.value?.total ?? 0;
    final totalFetchedReviews = fetchedTotal > 0 ? fetchedTotal : reviewCount;
    final showViewAll = totalFetchedReviews > 0 && shop != null;

    void openAllReviewsPage() {
      if (shop == null) return;
      Navigator.of(context).push(
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              AllReviewsPage(shop: shop!),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customer Reviews ($totalFetchedReviews)', style: kBodyTitleM),
            GestureDetector(
              onTap: () async {
                if (shop == null) return;
                final result = await showModalBottomSheet<bool>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => AddReviewSheet(shop: shop!),
                );

                if (result == true && shopId != null) {
                  ref.invalidate(reviewsProvider(shopId: shopId));
                }
              },
              child: Text(
                'Add Review',
                style: kSmallTitleM.copyWith(color: kPrimaryColor),
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        reviewsAsync.when(
          data: (paginated) {
            if (paginated.reviews.isEmpty) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.responsivePadding(20),
                  ),
                  child: Text(
                    'No reviews yet. Be the first to review!',
                    style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                  ),
                ),
              );
            }
            final hasImages = paginated.reviews.any((r) => r.images != null && r.images!.isNotEmpty);
            final cardHeight = hasImages ? 170.0 : 110.0;
            final displayCount = paginated.reviews.length > 10 ? 10 : paginated.reviews.length;
            final totalCards = showViewAll ? displayCount + 1 : displayCount;

            return SizedBox(
              height: screenSize.responsivePadding(cardHeight),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: totalCards,
                separatorBuilder: (context, index) =>
                    SizedBox(width: screenSize.responsivePadding(12)),
                itemBuilder: (context, index) {
                  if (showViewAll && index == displayCount) {
                    return _ViewAllCard(
                      screenSize: screenSize,
                      totalCount: totalFetchedReviews,
                      onTap: openAllReviewsPage,
                    );
                  }
                  final review = paginated.reviews[index];
                  return _ReviewCard(review: review, screenSize: screenSize);
                },
              ),
            );
          },
          loading: () => const Center(child: LoadingAnimation()),
          error: (e, s) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

class _ViewAllCard extends StatelessWidget {
  final ScreenSizeData screenSize;
  final int totalCount;
  final VoidCallback onTap;

  const _ViewAllCard({
    required this.screenSize,
    required this.totalCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenSize.responsivePadding(150),
        padding: EdgeInsets.all(screenSize.responsivePadding(12)),
        decoration: BoxDecoration(
          color: kPrimaryColor.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kPrimaryColor.withValues(alpha: 0.18)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(screenSize.responsivePadding(10)),
              decoration: BoxDecoration(
                color: kPrimaryColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_forward_rounded,
                color: kPrimaryColor,
                size: 20,
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(10)),
            Text(
              'View All Reviews',
              style: kSmallTitleSB.copyWith(color: kPrimaryColor, fontSize: 12),
            ),
            SizedBox(height: screenSize.responsivePadding(4)),
            Text(
              '$totalCount total verified reviews',
              style: kSmallTitleR.copyWith(
                color: kSecondaryTextColor,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final ScreenSizeData screenSize;

  const _ReviewCard({required this.review, required this.screenSize});

  void _showFullImageGallery(BuildContext context, List<String> imageUrls, int initialIndex) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenGallery(
            images: imageUrls,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = [
      const Color(0xFFFFB74D),
      const Color(0xFF64B5F6),
      const Color(0xFF81C784),
    ];
    final color = colors[review.userName.hashCode.abs() % colors.length];
    final hasImages = review.images != null && review.images!.isNotEmpty;

    return Container(
      width: screenSize.responsivePadding(240),
      padding: EdgeInsets.all(screenSize.responsivePadding(12)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF9F9F9)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: screenSize.responsivePadding(14),
                    backgroundColor: color.withValues(alpha: 0.2),
                    child: Text(
                      (review.userName ?? 'U')[0].toUpperCase(),
                      style: kSmallTitleB.copyWith(color: color),
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(8)),
                  SizedBox(
                    width: screenSize.responsivePadding(100),
                    child: Text(
                      review.userName ?? 'Anonymous',
                      style: kSmallTitleM,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    review.rating?.toStringAsFixed(1) ?? '0.0',
                    style: kSmallTitleM,
                  ),
                  SizedBox(width: screenSize.responsivePadding(4)),
                  const Icon(Icons.star, color: Color(0xFFFFD700), size: 14),
                ],
              ),
            ],
          ),
          SizedBox(height: screenSize.responsivePadding(8)),
          Expanded(
            child: Text(
              review.comment ?? '',
              style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
              maxLines: hasImages ? 2 : 4,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (hasImages) ...[
            SizedBox(height: screenSize.responsivePadding(8)),
            SizedBox(
              height: screenSize.responsivePadding(42),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                physics: const ClampingScrollPhysics(),
                itemCount: review.images!.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: screenSize.responsivePadding(6)),
                itemBuilder: (context, index) {
                  final imageUrl = review.images![index];
                  return GestureDetector(
                    onTap: () => _showFullImageGallery(context, review.images!, index),
                    child: AdvancedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(8),
                      width: screenSize.responsivePadding(42),
                      height: screenSize.responsivePadding(42),
                    ),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
