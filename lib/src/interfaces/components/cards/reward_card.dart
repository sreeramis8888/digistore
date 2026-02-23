import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RewardCard extends ConsumerWidget {
  final String title;
  final String subtitle;
  final String points;
  final String? logoText;
  final Color? logoColor;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;
  final double? width;

  const RewardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.points,
    this.logoText,
    this.logoColor,
    this.icon,
    this.iconColor,
    this.margin,
    this.width,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Container(
      width: width,
      margin: margin,
      padding: EdgeInsets.all(screenSize.responsivePadding(5)),
      decoration: BoxDecoration(
        color: kWhite,
        borderRadius: BorderRadius.circular(16),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              SizedBox(height: screenSize.responsivePadding(10)),
              Text(
                title,
                style: kSmallerTitleL.copyWith(
                  color: kTextColor,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: screenSize.responsivePadding(4)),
              Text(
                subtitle,
                style: kSmallerTitleL.copyWith(
                  color: kSecondaryTextColor,
                  fontSize: 10,
                  letterSpacing: .5,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          if (icon != null)
            Icon(icon, color: iconColor ?? Colors.purpleAccent, size: 40)
          else if (logoText != null && logoColor != null)
            Container(
              width: screenSize.responsivePadding(60),
              height: screenSize.responsivePadding(60),
              color: logoColor,
              alignment: Alignment.center,
              child: Text(
                logoText!,
                style: kBodyTitleB.copyWith(
                  color: logoColor == Colors.white ? kTextColor : kWhite,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              vertical: screenSize.responsivePadding(8),
            ),
            decoration: BoxDecoration(
              color: kBlue,
              borderRadius: BorderRadius.circular(8),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Get it for $points',
                  style: kSmallerTitleB.copyWith(color: kWhite),
                ),
                const SizedBox(width: 4),
                SvgPicture.asset('assets/svg/coin.svg', height: 12),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
