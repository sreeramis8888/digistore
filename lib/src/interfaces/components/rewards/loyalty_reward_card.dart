import 'package:digistore/src/interfaces/animations/index.dart';
import 'package:digistore/src/interfaces/components/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/models/loyalty_card.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/utils/interactive_feedback_button.dart';

class LoyaltyRewardCard extends ConsumerWidget {
  final LoyaltyCard? loyaltyCard;
  const LoyaltyRewardCard({super.key, this.loyaltyCard});

  void _showBenefitsDialog(BuildContext context, ScreenSizeData screenSize, bool isSilver) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(24)),
        child: Container(
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(screenSize.responsivePadding(24)),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isSilver
                        ? [const Color(0xFFF5F5F5), const Color(0xFFE0E0E0)]
                        : [const Color(0xFFFFF7E2), const Color(0xFFFFE9D6)],
                  ),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      isSilver ? 'assets/svg/silver_coin.svg' : 'assets/svg/gold_icon.svg',
                      height: 60,
                    ).fadeScaleUp(),
                    SizedBox(height: screenSize.responsivePadding(16)),
                    Text(
                      '${loyaltyCard?.tier} Tier Benefits',
                      style: kSubHeadingSB.copyWith(
                        color: isSilver ? const Color(0xFF757575) : const Color(0xFFE67E22),
                        fontSize: 20,
                      ),
                    ).fadeIn(delayMilliseconds: 100),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(screenSize.responsivePadding(24)),
                child: Column(
                  children: [
                    if (loyaltyCard?.tierBenefits != null)
                      ...loyaltyCard!.tierBenefits!.asMap().entries.map((entry) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: screenSize.responsivePadding(16)),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: isSilver ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(
                                  Icons.check_rounded,
                                  size: 16,
                                  color: isSilver ? const Color(0xFF2E7D32) : const Color(0xFFEF6C00),
                                ),
                              ),
                              SizedBox(width: screenSize.responsivePadding(12)),
                              Expanded(
                                child: Text(
                                  entry.value,
                                  style: kSmallTitleL.copyWith(
                                    color: kTextColor,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ).fadeSlideInFromLeft(delayMilliseconds: 200 + (entry.key * 100)),
                        );
                      }),
                    SizedBox(height: screenSize.responsivePadding(16)),
                    PrimaryButton(
                      text: 'Awesome!',
                      onPressed: () => Navigator.pop(context),
                      width: double.infinity,
                    ).fadeIn(delayMilliseconds: 500),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (loyaltyCard == null) return const SizedBox.shrink();
    final screenSize = ref.watch(screenSizeProvider);
    final isSilver = loyaltyCard?.tier?.toLowerCase() == 'silver';
    
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
                        isSilver ? 'assets/png/loyalty_card_silver_bg.png' : 'assets/png/loyalty_card_bg.png',
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
                          loyaltyCard?.name ?? 'Guest User',
                          style: kBodyTitleR.copyWith(
                            color: const Color(0xFF3B4859),
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Row(
                          children: [
                            SvgPicture.asset(isSilver ? 'assets/svg/silver_coin.svg' : 'assets/svg/coin.svg', height: 24),
                            SizedBox(width: screenSize.responsivePadding(8)),
                            Text(
                              '${loyaltyCard?.pointsBalance ?? 0} points',
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
                        child: FractionallySizedBox(
                          widthFactor: (loyaltyCard?.pointsBalance ?? 0) /
                              (loyaltyCard?.totalPointsEarned ?? 1000).clamp(1, double.infinity),
                          child: Container(
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
                    ),
                    SizedBox(height: screenSize.responsivePadding(10)),
                    Text(
                      'Points earned',
                      style: kSmallerTitleM.copyWith(color: kWhite),
                    ),
                    SizedBox(height: screenSize.responsivePadding(10)),
                    Center(
                      child: InteractiveFeedbackButton(
                        onPressed: () => _showBenefitsDialog(context, screenSize, isSilver),
                        scaleFactor: 0.9,
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
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 0,
                right: 20,
                child: Container(
                  padding: const EdgeInsets.only(bottom: 1, left: 1, right: 1),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: isSilver
                          ? [
                              const Color(0xFFE0E0E0),
                              const Color(0xFFBDBDBD),
                              const Color(0xFF9E9E9E),
                              const Color(0xFFD6D6D6),
                            ]
                          : [
                              const Color(0xFFFDCB4F),
                              const Color(0xFFEF9A2D),
                              const Color(0xFFED8E2F),
                              const Color(0xFFFFC43E),
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
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: isSilver
                            ? [
                                const Color(0xFFF5F5F5),
                                const Color(0xFFEEEEEE),
                                const Color(0xFFE0E0E0),
                                const Color(0xFFF0F0F0),
                              ]
                            : [
                                const Color(0xFFFFF7E2),
                                const Color(0xFFFFF0D9),
                                const Color(0xFFFFE9D6),
                                const Color(0xFFFFDDBB),
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
                          isSilver ? 'assets/svg/silver_coin.svg' : 'assets/svg/gold_icon.svg',
                          height: 25,
                        ),
                        SizedBox(width: screenSize.responsivePadding(4)),
                        Text(
                          (loyaltyCard?.tier ?? 'BRONZE').toUpperCase(),
                          style: kBodyTitleSB.copyWith(
                            color: isSilver ? const Color(0xFF757575) : const Color(0xFFE67E22),
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
