import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';

class RewardDetailPage extends ConsumerWidget {
  final Map<String, dynamic> args;

  const RewardDetailPage({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final String title = args['title'] ?? 'Special Reward';
    final String subtitle = args['subtitle'] ?? 'Exclusive Reward for you';
    final String? imageUrl = args['imageUrl'];
    final String shopName = args['shopName'] ?? 'Store';
    final IconData? icon = args['icon'];
    final String? logoText = args['logoText'];
    final Color? logoColor = args['logoColor'];
    final String points = args['points']?.toString() ?? '0';

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
                    : (logoText != null && logoColor != null)
                    ? Container(
                        color: logoColor,
                        alignment: Alignment.center,
                        child: Text(
                          logoText,
                          style: kHeadTitleB.copyWith(
                            color: logoColor == Colors.white
                                ? kTextColor
                                : kWhite,
                            fontSize: 40,
                          ),
                        ),
                      )
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
                          shopName,
                          style: kBodyTitleB.copyWith(fontSize: 24),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Text(title, style: kSubHeadingL.copyWith(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: kBodyTitleSB.copyWith(
                      color: kSecondaryTextColor,
                      fontSize: 16,
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
                  PrimaryButton(
                    textSize: 14,
                    text: 'Get it For $points',
                    trailingIcon: Padding(
                      padding: const EdgeInsets.only(left: 4.0),
                      child: SvgPicture.asset(
                        'assets/svg/coin.svg',
                        height: 18,
                      ),
                    ),
                    onPressed: () {},
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
