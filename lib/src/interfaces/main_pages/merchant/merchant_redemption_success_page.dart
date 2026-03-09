import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';

class MerchantRedemptionSuccessPage extends ConsumerWidget {
  final Map<String, dynamic> args;

  const MerchantRedemptionSuccessPage({super.key, required this.args});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final String title = args['title'] ?? 'Fresh Bakes Deal';
    final String subtitle = args['subtitle'] ?? 'Buy one bun Get one free';
    final String? imageUrl = args['imageUrl'];

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
              SvgPicture.asset(
                'assets/svg/verified.svg',
                height: screenSize.responsivePadding(120),
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
              Text(
                'OTP Verified Successfully',
                style: kSubHeadingM.copyWith(
                  color: const Color(0xFF1EA136),
                  fontSize: 22,
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(12)),
              Text(
                'Redemption Complete',
                style: kBodyTitleM.copyWith(color: kSecondaryTextColor),
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
                      height: screenSize.responsivePadding(40),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: AdvancedNetworkImage(
                        imageUrl: imageUrl ?? 'assets/jpg/bakes.jpg',
                        fit: BoxFit.cover,
                      ),
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
                          SizedBox(height: screenSize.responsivePadding(2)),
                          Text(
                            subtitle,
                            style: kSmallerTitleM.copyWith(
                              color: kSecondaryTextColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'BUY 1 GET 1',
                      style: kSmallerTitleB.copyWith(
                        color: const Color(0xFF4A89FF),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenSize.responsivePadding(48)),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                child: Text(
                  'Back to Home',
                  style: kBodyTitleB.copyWith(color: const Color(0xFF4A89FF)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
