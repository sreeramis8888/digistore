import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';
import '../../../data/utils/global_variables.dart';

class OfferDetailPage extends ConsumerWidget {
  final Map<String, dynamic> args;

  const OfferDetailPage({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final String title = args['title'] ?? '';
    final String subtitle = args['subtitle'] ?? '';
    final String? imageUrl = args['imageUrl'];
    final String shopName = args['shopName'] ?? 'HomeGoods';
    final IconData? icon = args['icon'];
    final String? logoText = args['logoText'];
    final Color? logoColor = args['logoColor'];

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
          'Offer Detail',
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
                  if (args['validTo'] != null) ...[
                    Text(
                      'Expires on: ${args['validTo']}',
                      style: kSmallerTitleM.copyWith(
                        color: kSecondaryTextColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  if (args['terms'] != null && (args['terms'] as List).isNotEmpty)
                    ...(args['terms'] as List).map((term) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: _buildBulletPoint(term.toString()),
                    ))
                  else ...[
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
                  ],
                  const SizedBox(height: 32),
                  PrimaryButton(
                    textSize: 14,
                    text: GlobalVariables.isMerchant ? 'Generate OTP' : 'Redeem Now',
                    onPressed: () {
                      if (GlobalVariables.isMerchant) {
                        Navigator.of(context).pushNamed('merchantRedemption', arguments: args);
                      } else {
                        Navigator.of(context).pushNamed('redemptionOtp');
                      }
                    },
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
