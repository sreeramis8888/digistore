import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';

class ShopReviews extends ConsumerWidget {
  const ShopReviews({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final reviews = [
      {
        'name': 'Alice',
        'rating': '4.5',
        'comment': 'Best bakery in town',
        'color': const Color(0xFFFFB74D),
      },
      {
        'name': 'Sajid Sab',
        'rating': '4.5',
        'comment': 'Good ambiance and awesome taste.',
        'color': const Color(0xFF64B5F6),
      },
      {
        'name': 'David',
        'rating': '4.0',
        'comment': 'Great spot for a quick bite.',
        'color': const Color(0xFF81C784),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('Customer Reviews', style: kBodyTitleM),
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
        SizedBox(
          height: screenSize.responsivePadding(100),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: reviews.length,
            separatorBuilder: (context, index) =>
                SizedBox(width: screenSize.responsivePadding(12)),
            itemBuilder: (context, index) {
              final review = reviews[index];
              return Container(
                width: screenSize.responsivePadding(240),
                padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Color(0xFFF9F9F9)),
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
                              backgroundColor: (review['color'] as Color)
                                  .withOpacity(0.2),
                              child: Text(
                                (review['name'] as String)[0],
                                style: kSmallTitleB.copyWith(
                                  color: review['color'] as Color,
                                ),
                              ),
                            ),
                            SizedBox(width: screenSize.responsivePadding(8)),
                            Text(review['name'] as String, style: kSmallTitleM),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              review['rating'] as String,
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
                      review['comment'] as String,
                      style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
