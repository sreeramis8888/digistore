import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class RewardGridCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String logoText;
  final Color logoColor;
  final String points;

  const RewardGridCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.logoText,
    required this.logoColor,
    required this.points,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Container(
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: kBorder.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(16)),
            child: Column(
              children: [
                Text(title, style: kBodyTitleB),
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  subtitle,
                  style: kSmallerTitleR.copyWith(color: kSecondaryTextColor),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                Container(
                  width: screenSize.responsivePadding(60),
                  height: screenSize.responsivePadding(60),
                  color: logoColor,
                  alignment: Alignment.center,
                  child: Text(
                    logoText,
                    style: kBodyTitleB.copyWith(color: logoColor == Colors.white ? kTextColor : kWhite),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: screenSize.responsivePadding(10)),
            decoration: const BoxDecoration(
              color: kBlue,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(12),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Get it for $points',
                  style: kSmallTitleB.copyWith(color: kWhite),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.monetization_on, color: Color(0xFFFFD700), size: 14),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
