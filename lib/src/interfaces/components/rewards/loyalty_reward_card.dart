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
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(15),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              Positioned.fill(
                child: Transform.translate(
                  offset: const Offset(200, 0),
                  child: Transform.scale(
                    scale: 2.5,
                    child: Transform.flip(
                      flipX: true,
                      child: Image.asset(
                        'assets/png/loyalty_card_bg.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: Container(color: Colors.black.withOpacity(0.1)),
              ),
              Padding(
                padding: EdgeInsets.all(screenSize.responsivePadding(20)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Maria Vinaya',
                          style: kBodyTitleR.copyWith(
                            color: const Color(0xFF3B4859),
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Row(
                          children: [
                            SvgPicture.asset('assets/svg/coin.svg', height: 24),
                            SizedBox(width: screenSize.responsivePadding(8)),
                            Text(
                              '8,000 points',
                              style: kHeadTitleB.copyWith(
                                color: const Color(0xFF3B4859),
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: screenSize.responsivePadding(20)),
                    Container(
                      height: 12,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          width: screenSize.widthPercent(60),
                          decoration: BoxDecoration(
                            color: const Color(0xFF4FACFD),
                            border: Border.all(
                              color: const Color(0xFFA8A8A8),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: kWhite.withOpacity(0.45),
                                blurRadius: 2,
                                blurStyle: BlurStyle.outer,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(10)),
                    Text(
                      'Points earned',
                      style: kSmallerTitleM.copyWith(color: kWhite),
                    ),
                    SizedBox(height: screenSize.responsivePadding(10)),
                    Center(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: screenSize.responsivePadding(15),
                          vertical: screenSize.responsivePadding(8),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFF1DF),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'View Benefits',
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFF80592B),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 1, left: 1, right: 1),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFFFDCB4F),
                        Color(0xFFEF9A2D),
                        Color(0xFFED8E2F),
                        Color(0xFFFFC43E),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8),
                    ),
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(12),
                      vertical: screenSize.responsivePadding(6),
                    ),
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFF7E2),
                          Color(0xFFFFF0D9),
                          Color(0xFFFFE9D6),
                          Color(0xFFFFDDBB),
                        ],
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(7),
                        bottomRight: Radius.circular(7),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SvgPicture.asset(
                          'assets/svg/gold_icon.svg',
                          height: 25,
                        ),
                        SizedBox(width: screenSize.responsivePadding(4)),
                        Text(
                          'GOLD',
                          style: kBodyTitleSB.copyWith(
                            color: const Color(0xFFE67E22),
                          ),
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
    );
  }
}
