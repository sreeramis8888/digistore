import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';
import '../../../../src/data/providers/reviews_provider.dart';
import '../../../../src/data/models/review_model.dart';

class ShopReviews extends ConsumerWidget {
  final ShopModel? shop;

  const ShopReviews({super.key, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final reviewCount = shop?.businessInfo?.totalReviews ?? 0;
    final shopId = shop?.id;

    final reviewsAsync = ref.watch(reviewsProvider(shopId: shopId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customer Reviews ($reviewCount)', style: kBodyTitleM),
            GestureDetector(
              onTap: () {},
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
                  padding: EdgeInsets.symmetric(vertical: screenSize.responsivePadding(20)),
                  child: Text(
                    'No reviews yet. Be the first to review!',
                    style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                  ),
                ),
              );
            }
            return SizedBox(
              height: screenSize.responsivePadding(110),
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
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text(e.toString())),
        ),
      ],
    );
  }
}

class _ReviewCard extends StatelessWidget {
  final ReviewModel review;
  final dynamic screenSize;

  const _ReviewCard({required this.review, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final colors = [const Color(0xFFFFB74D), const Color(0xFF64B5F6), const Color(0xFF81C784)];
    final color = colors[review.userName.hashCode.abs() % colors.length];

    return Container(
      width: screenSize.responsivePadding(240),
      padding: EdgeInsets.all(screenSize.responsivePadding(12)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF9F9F9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    review.rating?.toString() ?? '0.0',
                    style: kSmallTitleM,
                  ),
                  SizedBox(width: screenSize.responsivePadding(4)),
                  const Icon(
                    Icons.star,
                    color: Color(0xFFFFD700),
                    size: 14,
                  ),
                ],
              ),
            ],
          ),
          Text(
            review.comment ?? '',
            style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
