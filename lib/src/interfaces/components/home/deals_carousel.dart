import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../offers/deal_card.dart';

class DealsCarousel extends ConsumerWidget {
  final String title;
  final List<DealCard> deals;
  final VoidCallback? onViewAllTap;

  const DealsCarousel({
    super.key,
    required this.title,
    required this.deals,
    this.onViewAllTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (deals.isEmpty) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);
    final padding = screenSize.responsivePadding(16);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: kBodyTitleM.copyWith(
                  color: kTextColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onViewAllTap != null)
                GestureDetector(
                  onTap: onViewAllTap,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text(
                      'View all',
                      style: kSmallTitleSB.copyWith(
                        color: kPrimaryColor,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(12)),
        CarouselSlider.builder(
          itemCount: deals.length,
          options: CarouselOptions(
            height: screenSize.responsivePadding(230),
            viewportFraction: 0.45,
            enableInfiniteScroll: false,
            padEnds: false,
          ),
          itemBuilder: (context, index, realIndex) {
            return Padding(
              padding: EdgeInsets.only(
                left: index == 0 ? padding : padding / 2,
                right: index == deals.length - 1 ? padding : padding / 2,
              ),
              child: deals[index],
            );
          },
        ),
      ],
    );
  }
}
