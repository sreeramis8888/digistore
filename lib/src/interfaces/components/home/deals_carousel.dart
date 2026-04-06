import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../offers/deal_card.dart';

class DealsCarousel extends ConsumerWidget {
  final String title;
  final List<DealCard> deals;

  const DealsCarousel({
    super.key,
    required this.title,
    required this.deals,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final screenWidth = MediaQuery.of(context).size.width;
    final padding = screenSize.responsivePadding(16);
    
    final itemWidth = (screenWidth - (3 * padding)) / 2.25;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Text(
            title,
            style: kBodyTitleM.copyWith(color: kTextColor, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(12)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: EdgeInsets.symmetric(horizontal: padding),
          child: Row(
            children: deals.map((deal) {
              return Padding(
                padding: EdgeInsets.only(right: padding),
                child: SizedBox(
                  width: itemWidth,
                  child: deal,
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
