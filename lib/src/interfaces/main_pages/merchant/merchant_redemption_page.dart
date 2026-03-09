import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/advanced_network_image.dart';

class MerchantRedemptionPage extends ConsumerWidget {
  final Map<String, dynamic> args;

  const MerchantRedemptionPage({super.key, required this.args});

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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: screenSize.responsivePadding(32)),
              Text(
                'Customer Redemption',
                style: kSubHeadingM.copyWith(fontSize: 20),
              ),
              SizedBox(height: screenSize.responsivePadding(8)),
              Text(
                'Share this OTP with customer',
                style: kBodyTitleM.copyWith(color: kSecondaryTextColor),
              ),
              SizedBox(height: screenSize.responsivePadding(32)),

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

              SizedBox(height: screenSize.responsivePadding(24)),

              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacementNamed(
                    'merchantRedemptionVerified',
                    arguments: args,
                  );
                },
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF7F7F7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: screenSize.responsivePadding(32),
                  ),
                  child: Column(
                    children: [
                      Text(
                        'YOUR OTP',
                        style: kBodyTitleM.copyWith(fontSize: 14),
                      ),
                      SizedBox(height: screenSize.responsivePadding(16)),
                      Text(
                        '3 3 3 3 3 3',
                        style: kHeadTitleB.copyWith(
                          fontSize: 40,
                          letterSpacing: 4,
                        ),
                      ),
                      SizedBox(height: screenSize.responsivePadding(24)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Expiring in : ',
                            style: kSmallTitleM.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                          Text(
                            '04:13',
                            style: kSmallTitleM.copyWith(
                              color: const Color(0xFF4A89FF),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: screenSize.responsivePadding(24)),
              Text(
                'Waiting for customer to enter OTP...',
                style: kBodyTitleM.copyWith(color: kSecondaryTextColor),
              ),

              const Spacer(),

              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.responsivePadding(16),
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFE8E8E8)),
                ),
                alignment: Alignment.center,
                child: Text(
                  'Generate OTP',
                  style: kBodyTitleSB.copyWith(color: kSecondaryTextColor),
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
            ],
          ),
        ),
      ),
    );
  }
}
