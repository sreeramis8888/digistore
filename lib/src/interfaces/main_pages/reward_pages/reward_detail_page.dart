import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';

import '../../../data/services/toast_service.dart';
import '../../../data/providers/rewards_provider.dart';

class RewardDetailPage extends ConsumerStatefulWidget {
  final Map<String, dynamic> args;

  const RewardDetailPage({super.key, required this.args});

  @override
  ConsumerState<RewardDetailPage> createState() => _RewardDetailPageState();
}

class _RewardDetailPageState extends ConsumerState<RewardDetailPage> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final args = widget.args;
    final screenSize = ref.watch(screenSizeProvider);
    final String title = args['title'] ?? 'Special Reward';
    final String subtitle = args['subtitle'] ?? 'Exclusive Reward for you';
    final String? imageUrl = args['imageUrl'];
    final String shopName = args['shopName'] ?? 'Store';
    final IconData? icon = args['icon'];
    final String points = args['points']?.toString() ?? '0';
    final bool isClaimed = args['isClaimed'] == true;
    final String? couponCode = args['couponCode'];

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            size: 20,
            color: kTextColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Reward Detail',
          style: kSmallerTitleB.copyWith(color: kTextColor, fontSize: 16),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Section
            if (imageUrl != null)
              SizedBox(
                width: double.infinity,
                height: screenSize.responsivePadding(220),
                child: AdvancedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.zero,
                ),
              )
            else
              Container(
                width: double.infinity,
                height: screenSize.responsivePadding(220),
                color: kGreyLight,
                alignment: Alignment.center,
                child: icon != null
                    ? Icon(icon, size: 80, color: kPrimaryColor)
                    : const Icon(
                        Icons.image_not_supported,
                        size: 80,
                        color: kGrey,
                      ),
              ),

            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop Header
                  Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: kPrimaryColor,
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: imageUrl != null
                            ? AdvancedNetworkImage(
                                imageUrl: imageUrl,
                                fit: BoxFit.cover,
                              )
                            : const Icon(
                                Icons.storefront,
                                color: kWhite,
                                size: 20,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          title,
                          style: kBodyTitleB.copyWith(fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (shopName != title)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        shopName,
                        style: kBodyTitleSB.copyWith(
                          color: kPrimaryColor,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  
                  Text(
                    subtitle,
                    style: kBodyTitleSB.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 32),

                  Text('Details', style: kSmallTitleSB),
                  const SizedBox(height: 12),
                  Text(
                    'Expires on: 31st December 2026',
                    style: kSmallerTitleM.copyWith(
                      color: kSecondaryTextColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),

                  _buildBulletPoint(
                    'Get an exclusive reward to upgrade your experience!',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                    'Eligibility: Offer valid for early claimers. Non-transferable.',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                    'Refund Policy: Rewards once claimed cannot be reversed.',
                  ),
                  const SizedBox(height: 8),
                  _buildBulletPoint(
                    'Support: For queries, contact us via support channel.',
                  ),
                  const SizedBox(height: 32),
                  if (!isClaimed)
                    PrimaryButton(
                      isLoading: _isLoading,
                      textSize: 14,
                      text: 'Get it For $points',
                      trailingIcon: Padding(
                        padding: const EdgeInsets.only(left: 4.0),
                        child: SvgPicture.asset(
                          'assets/svg/coin.svg',
                          height: 18,
                        ),
                      ),
                      onPressed: () async {
                        final rewardId = args['id'];
                        if (rewardId == null) {
                          ToastService().showToast(
                            context,
                            'Invalid reward ID',
                            type: ToastType.error,
                          );
                          return;
                        }

                        setState(() => _isLoading = true);
                        try {
                          final response = await ref
                              .read(rewardActionProvider.notifier)
                              .redeemReward(rewardId);

                          if (response.success && mounted) {
                            ToastService().showToast(
                              context,
                              response.message ?? 'Reward redeemed successfully!',
                            );
                            Navigator.of(context).pop();
                          } else if (mounted) {
                            ToastService().showToast(
                              context,
                              response.message ?? 'Failed to redeem reward',
                              type: ToastType.error,
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            log('Error redeeming reward: $e');
                            ToastService().showToast(
                              context,
                              'An error occurred: $e',
                              type: ToastType.error,
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() => _isLoading = false);
                          }
                        }
                      },
                    )
                  else if (couponCode != null)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: kPrimaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Your Coupon Code: $couponCode',
                          style: kBodyTitleB.copyWith(color: kPrimaryColor),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: MediaQuery.of(context).padding.bottom > 0
                        ? MediaQuery.of(context).padding.bottom
                        : 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBulletPoint(String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 6, right: 8, left: 4),
          child: Container(
            width: 4,
            height: 4,
            decoration: const BoxDecoration(
              color: kSecondaryTextColor,
              shape: BoxShape.circle,
            ),
          ),
        ),
        Expanded(
          child: Text(
            text,
            style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
          ),
        ),
      ],
    );
  }
}
