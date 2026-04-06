import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';
import '../../components/primary_button.dart';

class PartnerRedemptionSuccessPage extends ConsumerWidget {
  final Map<String, dynamic> args;

  const PartnerRedemptionSuccessPage({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    
    // Extract actual data from arguments
    final offerData = args['offer'] as Map<String, dynamic>? ?? {};
    final redemptionData = args['redemption'] as Map<String, dynamic>? ?? {};
    
    final String title = offerData['title'] ?? 'Reward Redemption';
    final String subtitle = offerData['subtitle'] ?? 'Transaction Completed';
    final String? imageUrl = offerData['imageUrl'];
    final String redemptionId = redemptionData['redemptionId'] ?? 'N/A';
    final String discountCode = offerData['discountType'] == 'BOGO' ? 'BUY 1 GET 1' : 'SUCCESS';

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
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(24),
          ),
          child: Column(
            children: [
              SizedBox(height: screenSize.responsivePadding(60)),
              // Success Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8F5E9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Color(0xFF1EA136),
                  size: 50,
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
              Text(
                'Redemption Successful',
                style: kSubHeadingM.copyWith(
                  color: const Color(0xFF1EA136),
                  fontSize: 22,
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(12)),
              Text(
                'Redemption ID: $redemptionId',
                style: kBodyTitleM.copyWith(
                  color: kSecondaryTextColor,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(32)),
              const Divider(color: Color(0xFFF1F1F1), thickness: 1),
              SizedBox(height: screenSize.responsivePadding(16)),

              Align(
                alignment: Alignment.centerLeft,
                child: Text('Offer Details', style: kBodyTitleB),
              ),

              SizedBox(height: screenSize.responsivePadding(16)),

              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFF),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8F0FF)),
                ),
                padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                child: Row(
                  children: [
                    Container(
                      width: screenSize.responsivePadding(60),
                      height: screenSize.responsivePadding(60),
                      decoration: BoxDecoration(
                        color: kGreyLight,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: imageUrl != null && imageUrl.startsWith('http')
                          ? AdvancedNetworkImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.celebration, color: kPrimaryColor),
                    ),
                    SizedBox(width: screenSize.responsivePadding(12)),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: kSmallTitleB,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          SizedBox(height: screenSize.responsivePadding(4)),
                          Text(
                            subtitle,
                            style: kSmallerTitleM.copyWith(
                              color: kSecondaryTextColor,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4A89FF).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        discountCode,
                        style: kSmallerTitleB.copyWith(
                          color: const Color(0xFF4A89FF),
                          fontSize: 10,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              PrimaryButton(
                text: 'Done',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
            ],
          ),
        ),
      ),
    );
  }
}
