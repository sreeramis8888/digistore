import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import 'section_title.dart';

class RewardsCarousel extends ConsumerWidget {
  const RewardsCarousel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    
    return Container(
      color: const Color(0xFFEFFFFE),
      padding: EdgeInsets.symmetric(vertical: screenSize.responsivePadding(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(20)),
            child: Text(
              'Rewards',
              style: kHeadTitleB.copyWith(color: const Color(0xFF33B3C5)),
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
          CarouselSlider.builder(
            itemCount: 4,
            options: CarouselOptions(
              height: screenSize.responsivePadding(220),
              viewportFraction: 0.45,
              enableInfiniteScroll: false,
              padEnds: false,
              // padding is simulated with viewportFraction and margins
            ),
            itemBuilder: (context, index, realIndex) {
              return Container(
                width: screenSize.responsivePadding(145),
                margin: EdgeInsets.only(
                  left: index == 0 ? screenSize.responsivePadding(20) : screenSize.responsivePadding(12),
                  right: index == 3 ? screenSize.responsivePadding(20) : 0,
                ),
                padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: kBorder.withOpacity(0.3)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text('Flat ₹50 OFF', style: kSmallTitleB),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Text(
                          'lorem ipsum lorem ipsum',
                          style: kSmallerTitleR.copyWith(color: kSecondaryTextColor, fontSize: 10),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                      ],
                    ),
                    // Illustration mockup
                    Icon(
                      index == 0 ? Icons.local_offer : Icons.all_inclusive,
                      color: index == 0 ? Colors.purpleAccent : const Color(0xFFC79E53),
                      size: 40,
                    ),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(vertical: screenSize.responsivePadding(8)),
                      decoration: BoxDecoration(
                        color: kBlue,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            index == 0 ? 'Get it for 1000' : 'Get it for 200',
                            style: kSmallerTitleB.copyWith(color: kWhite),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 12),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(20)),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(12),
                    vertical: screenSize.responsivePadding(6),
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: kBorder),
                    borderRadius: BorderRadius.circular(20),
                    color: kWhite,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('See all', style: kSmallTitleSB),
                      const SizedBox(width: 4),
                      const Icon(Icons.chevron_right, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
