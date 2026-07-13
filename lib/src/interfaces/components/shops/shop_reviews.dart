import 'package:setgo/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';
import '../../../../src/data/providers/reviews_provider.dart';
import '../../../../src/data/models/review_model.dart';
import './add_review_sheet.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customer Reviews ($totalFetchedReviews)', style: kBodyTitleM),
            GestureDetector(
              onTap: () async {
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
            return SizedBox(
              height: screenSize.responsivePadding(cardHeight),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: paginated.reviews.length,
                separatorBuilder: (context, index) =>
                    SizedBox(width: screenSize.responsivePadding(12)),
                itemBuilder: (context, index) {
                  final review = paginated.reviews[index];
                  return _ReviewCard(review: review, screenSize: screenSize);
                },
              ),
            );
          },
          loading: () => const Center(child: LoadingAnimation()),
          error: (e, s) => Center(child: Text(e.toString())),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final ScreenSizeData screenSize;

  const _ReviewCard({required this.review, required this.screenSize});

  void _showFullImageDialog(BuildContext context, List<String> imageUrls, int initialIndex) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (context) {
        final controller = PageController(initialPage: initialIndex);
        return StatefulBuilder(
          builder: (context, setState) {
            int currentIndex = initialIndex;
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: EdgeInsets.zero,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  PageView.builder(
                    controller: controller,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      return InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: Center(
                          child: Image.network(
                            imageUrls[index],
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) => const Icon(
                              Icons.broken_image,
                              color: Colors.white,
                              size: 48,
                            ),
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    top: 40,
                    right: 20,
                    child: IconButton(
                      icon: const Icon(Icons.close, color: Colors.white, size: 30),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 40,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentIndex + 1} / ${imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        );
      },
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
            color: Colors.black.withOpacity(0.02),
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
                    backgroundColor: color.withOpacity(0.2),
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
                    onTap: () => _showFullImageDialog(context, review.images!, index),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: screenSize.responsivePadding(42),
                        height: screenSize.responsivePadding(42),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          border: Border.all(color: const Color(0xFFEEEEEE)),
                        ),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(
                            Icons.image_not_supported_outlined,
                            size: 18,
                            color: Colors.grey,
                          ),
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
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
