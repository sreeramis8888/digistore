import 'package:setgo/src/data/utils/interactive_feedback_button.dart';
import 'package:setgo/src/data/constants/color_constants.dart';
import 'package:setgo/src/data/constants/style_constants.dart';
import 'package:setgo/src/data/providers/screen_size_provider.dart';
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
  final double? height;
  final String? imageUrl;
  final bool isClaimed;
  final String? couponCode;
  final double? value;
  final String? valueType;
  final String? category;
  final String? requiredTier;
  final List<String>? terms;
  final List<String>? images;
  final dynamic expiresAt;

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
    this.height,
    this.imageUrl,
    this.isClaimed = false,
    this.couponCode,
    this.value,
    this.valueType,
    this.category,
    this.requiredTier,
    this.terms,
    this.images,
    this.expiresAt,
  });

  factory RewardCard.fromReward(
    dynamic reward, {
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    return RewardCard(
      id: reward.id,
      title: reward.title ?? '',
      subtitle: reward.description ?? '',
      points: reward.pointsCost?.toString() ?? '0',
      imageUrl: reward.image,
      logoText: reward.category,
      logoColor: Colors.blue.withValues(alpha: 0.1),
      margin: margin,
      width: width,
      height: height,
      value: reward.value,
      valueType: reward.valueType,
      category: reward.category,
      requiredTier: reward.requiredTier,
      terms: reward.terms,
      images: reward.images,
      expiresAt: reward.expiresAt,
    );
  }

  factory RewardCard.fromClaimedReward(
    dynamic claimed, {
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
  }) {
    final reward = claimed.rewardId;
    return RewardCard(
      id: reward?.id,
      title: reward?.title ?? '',
      subtitle: reward?.description ?? '',
      points: claimed.pointsSpent?.toString() ?? '0',
      imageUrl: reward?.image,
      logoText: reward?.category,
      logoColor: Colors.blue.withValues(alpha: 0.1),
      margin: margin,
      width: width,
      height: height,
      isClaimed: true,
      couponCode: claimed.couponCode,
      value: reward?.value,
      valueType: reward?.valueType,
      category: reward?.category,
      requiredTier: reward?.requiredTier,
      terms: reward?.terms,
      images: reward?.images,
      expiresAt: claimed.validUntil ?? reward?.expiresAt,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    final detailArgs = {
      'id': id,
      'title': title,
      'subtitle': subtitle,
      'description': subtitle,
      'points': points,
      'logoText': logoText,
      'logoColor': logoColor,
      'icon': icon,
      'imageUrl': imageUrl,
      'shopName': '',
      'isClaimed': isClaimed,
      'couponCode': couponCode,
      'value': value,
      'valueType': valueType,
      'category': category ?? logoText,
      'requiredTier': requiredTier,
      'terms': terms,
      'images': images,
      'gallery': images,
      'expiresAt': expiresAt,
    };

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.of(context).pushNamed(
          'rewardDetail',
          arguments: detailArgs,
        );
      },
      scaleFactor: 0.98,
      child: Container(
        width: width,
        height: height ?? double.infinity,
        margin: margin,
        padding: EdgeInsets.all(screenSize.responsivePadding(5)),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: kBorder.withValues(alpha: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            SizedBox(
              height: screenSize.responsivePadding(46),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: kSmallerTitleL.copyWith(
                      color: kTextColor,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty && subtitle != 'null' && subtitle != 'nil') ...[
                    SizedBox(height: screenSize.responsivePadding(2)),
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
                ],
              ),
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
                          color: logoColor!.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: logoColor!.withValues(alpha: 0.1),
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.image_not_supported_outlined,
                              color: logoColor!.withValues(alpha: 0.4),
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
                    color: kPrimaryColor.withValues(alpha: 0.1),
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
                Text(
                  'Claimed',
                  style: kSmallTitleB.copyWith(color: kPrimaryColor),
                ),
            ] else
              PrimaryButton(
                height: screenSize.responsivePadding(35),
                borderRadius: BorderRadius.circular(8),
                backgroundColor: kBlue,
                onPressed: () {
                  Navigator.of(context).pushNamed(
                    'rewardDetail',
                    arguments: detailArgs,
                  );
                },
                padding: const EdgeInsets.symmetric(horizontal: 4),
                text: 'Get it for $points',
                trailingIcon: SvgPicture.asset(
                  'assets/svg/coin.svg',
                  height: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
