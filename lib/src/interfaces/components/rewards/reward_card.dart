import 'package:setgo/src/data/utils/interactive_feedback_button.dart';
import 'package:setgo/src/data/constants/color_constants.dart';
import 'package:setgo/src/data/constants/style_constants.dart';
import 'package:setgo/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../advanced_network_image.dart';

/// Digistore-Pay rewards grid card (image → title → subtitle → CTA).
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

  void _openDetail(BuildContext context) {
    Navigator.of(context).pushNamed(
      'rewardDetail',
      arguments: {
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
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final showSubtitle =
        subtitle.isNotEmpty && subtitle != 'null' && subtitle != 'nil';

    return InteractiveFeedbackButton(
      onPressed: () => _openDetail(context),
      scaleFactor: 0.98,
      child: Container(
        width: width,
        height: height ?? double.infinity,
        margin: margin,
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: EdgeInsets.all(screenSize.responsivePadding(12)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                flex: 5,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: AdvancedNetworkImage(
                    imageUrl: imageUrl ?? '',
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                    disableFade: true,
                    errorWidget: Container(
                      color: const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      child: Icon(
                        icon ?? Icons.card_giftcard_rounded,
                        color: iconColor ?? const Color(0xFF9CA3AF),
                        size: 36,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(10)),
              Text(
                title,
                style: kSmallTitleB.copyWith(
                  color: const Color(0xFF111827),
                  fontSize: 14,
                  height: 1.2,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              if (showSubtitle) ...[
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  subtitle,
                  style: kSmallerTitleM.copyWith(
                    color: const Color(0xFF6B7280),
                    fontSize: 11,
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              SizedBox(height: screenSize.responsivePadding(10)),
              if (isClaimed)
                _ClaimedBadge(couponCode: couponCode, screenSize: screenSize)
              else
                _ClaimButton(
                  points: points,
                  screenSize: screenSize,
                  onPressed: () => _openDetail(context),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ClaimButton extends StatelessWidget {
  final String points;
  final ScreenSizeData screenSize;
  final VoidCallback onPressed;

  const _ClaimButton({
    required this.points,
    required this.screenSize,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return InteractiveFeedbackButton(
      onPressed: onPressed,
      scaleFactor: 0.96,
      child: Container(
        height: screenSize.responsivePadding(36),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: kRewardCtaPurple,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: Text(
                'Get it for $points',
                style: kSmallerTitleEB.copyWith(
                  color: kWhite,
                  fontSize: 12,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 4),
            SvgPicture.asset(
              'assets/svg/coin.svg',
              height: 12,
            ),
          ],
        ),
      ),
    );
  }
}

class _ClaimedBadge extends StatelessWidget {
  final String? couponCode;
  final ScreenSizeData screenSize;

  const _ClaimedBadge({
    required this.couponCode,
    required this.screenSize,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: screenSize.responsivePadding(36),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: kRewardCtaPurple.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        couponCode != null ? 'Code: $couponCode' : 'Claimed',
        style: kSmallTitleB.copyWith(
          color: kRewardCtaPurple,
          fontSize: 11,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
      ),
    );
  }
}
