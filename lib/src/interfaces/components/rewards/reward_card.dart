import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../advanced_network_image.dart';
import '../primary_button.dart';

class RewardCard extends ConsumerWidget {
  final String? id;
  final String title;
  final String subtitle;
  final String points;
  final String? logoText;
  final Color? logoColor;
  final IconData? icon;
  final Color? iconColor;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final String? imageUrl;
  final bool isClaimed;
  final String? couponCode;

  const RewardCard({
    super.key,
    this.id,
    required this.title,
    required this.subtitle,
    required this.points,
    this.logoText,
    this.logoColor,
    this.icon,
    this.iconColor,
    this.margin,
    this.width,
    this.imageUrl,
    this.isClaimed = false,
    this.couponCode,
  });

  factory RewardCard.fromReward(
    dynamic reward, {
    EdgeInsetsGeometry? margin,
    double? width,
  }) {
    return RewardCard(
      id: reward.id,
      title: reward.title ?? '',
      subtitle: reward.description ?? '',
      points: reward.pointsCost?.toString() ?? '0',
      imageUrl: reward.image,
      logoText: reward.category,
      logoColor: Colors.blue.withOpacity(0.1),
      margin: margin,
      width: width,
    );
  }

  factory RewardCard.fromClaimedReward(
    dynamic claimed, {
    EdgeInsetsGeometry? margin,
    double? width,
  }) {
    final reward = claimed.rewardId;
    return RewardCard(
      id: reward?.id,
      title: reward?.title ?? '',
      subtitle: reward?.description ?? '',
      points: claimed.pointsSpent?.toString() ?? '0',
      imageUrl: reward?.image,
      logoText: reward?.category,
      logoColor: Colors.blue.withOpacity(0.1),
      margin: margin,
      width: width,
      isClaimed: true,
      couponCode: claimed.couponCode,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed(
          'rewardDetail',
          arguments: {
            'id': id,
            'title': title,
            'subtitle': subtitle,
            'points': points,
            'logoText': logoText,
            'logoColor': logoColor,
            'icon': icon,
            'imageUrl': imageUrl,
            'shopName': logoText ?? title,
            'isClaimed': isClaimed,
            'couponCode': couponCode,
          },
        );
      },
      child: Container(
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
            SizedBox(
              height: screenSize.responsivePadding(60),
              width: screenSize.responsivePadding(60),
              child: AdvancedNetworkImage(
                imageUrl: imageUrl ?? "",
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
                errorWidget: logoText != null && logoColor != null
                    ? Container(
                        width: screenSize.responsivePadding(60),
                        height: screenSize.responsivePadding(60),
                        decoration: BoxDecoration(
                          color: logoColor!.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: logoColor!.withOpacity(0.1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              color: logoColor!.withOpacity(0.4),
                              size: 24,
                            ),
                          ],
                        ),
                      )
                    : icon != null
                    ? Icon(
                        icon,
                        color: iconColor ?? Colors.purpleAccent,
                        size: 40,
                      )
                    : const Icon(
                        Icons.error_outline_rounded,
                        color: kGrey,
                        size: 40,
                      ),
              ),
            ),
            if (isClaimed) ...[
              if (couponCode != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Code: $couponCode',
                    style: kSmallTitleB.copyWith(
                      color: kPrimaryColor,
                      fontSize: 10,
                    ),
                  ),
                )
              else
                 Text('Claimed', style: kSmallTitleB.copyWith(color: kPrimaryColor)),
            ] else
              PrimaryButton(
                height: screenSize.responsivePadding(35),
                borderRadius: BorderRadius.circular(8),
                backgroundColor: kBlue,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    'rewardDetail',
                    arguments: {
                      'id': id,
                      'title': title,
                      'subtitle': subtitle,
                      'points': points,
                      'logoText': logoText,
                      'logoColor': logoColor,
                      'icon': icon,
                      'imageUrl': imageUrl,
                      'shopName': logoText ?? title,
                      'isClaimed': isClaimed,
                      'couponCode': couponCode,
                    },
                  );
                },
                padding: const EdgeInsets.symmetric(horizontal: 4),
                text: 'Get it for $points',
                trailingIcon: SvgPicture.asset('assets/svg/coin.svg', height: 12),
              ),
          ],
        ),
      ),
    );
  }
}
