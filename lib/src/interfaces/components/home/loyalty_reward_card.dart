import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LoyaltyRewardCard extends ConsumerWidget {
  const LoyaltyRewardCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(20),
        vertical: screenSize.responsivePadding(15),
      ),
      child: Container(
        padding: EdgeInsets.all(screenSize.responsivePadding(20)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF8A6B32), Color(0xFFC79E53), Color(0xFF6B4D1E)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
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
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Maria Vinaya',
                      style: kBodyTitleM.copyWith(color: kWhite.withOpacity(0.9)),
                    ),
                    SizedBox(height: screenSize.responsivePadding(4)),
                    Row(
                      children: [
                        const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 20),
                        SizedBox(width: screenSize.responsivePadding(6)),
                        Text(
                          '8,000 points',
                          style: kHeadTitleB.copyWith(color: kWhite),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(12),
                    vertical: screenSize.responsivePadding(6),
                  ),
                  decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.hexagon, color: Color(0xFFF39C12), size: 16),
                      SizedBox(width: screenSize.responsivePadding(4)),
                      Text(
                        'GOLD',
                        style: kSmallTitleB.copyWith(color: const Color(0xFFF39C12)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.responsivePadding(20)),
            Stack(
              children: [
                Container(
                  height: 6,
                  decoration: BoxDecoration(
                    color: kWhite.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
                Container(
                  height: 6,
                  width: screenSize.widthPercent(60),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4A90E2),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ],
            ),
            SizedBox(height: screenSize.responsivePadding(12)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Points earned',
                  style: kSmallTitleR.copyWith(color: kWhite.withOpacity(0.9)),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(12),
                    vertical: screenSize.responsivePadding(6),
                  ),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'View Benefits',
                    style: kSmallerTitleB.copyWith(color: const Color(0xFF8A6B32)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
