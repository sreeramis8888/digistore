import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class RedemptionVerifiedPage extends ConsumerWidget {
  const RedemptionVerifiedPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

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
        child: SingleChildScrollView(
          padding: EdgeInsets.all(screenSize.responsivePadding(24)),
          child: Column(
            children: [
              SizedBox(height: screenSize.responsivePadding(40)),
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
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: kBodyTitleM.copyWith(
                    color: kSecondaryTextColor,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Your purchase at '),
                    TextSpan(
                      text: 'DailyMart',
                      style: kBodyTitleB.copyWith(color: kTextColor),
                    ),
                    const TextSpan(text: ' has been verified.'),
                  ],
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(40)),
              Container(
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFEFEFEF)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.02),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      child: Text(
                        'Purchase Details',
                        style: kBodyTitleB.copyWith(fontSize: 16),
                      ),
                    ),
                    const Divider(
                      color: Color(0xFFF1F1F1),
                      height: 1,
                      thickness: 1,
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      child: _buildDetailRow('Bill Amount', '₹2,223', false),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(16),
                      ),
                      child: const Divider(
                        color: Color(0xFFF1F1F1),
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      child: _buildDetailRow('Category', 'Daily Needs', true),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(16),
                      ),
                      child: const Divider(
                        color: Color(0xFFF1F1F1),
                        height: 1,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Base Points Earned',
                            style: kSmallTitleB.copyWith(
                              color: kSecondaryTextColor,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: [
                              SvgPicture.asset(
                                'assets/svg/coin.svg',
                                height: 18,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '1,250',
                                style: kSubHeadingL.copyWith(
                                  color: const Color(0xFF1EA136),
                                  fontSize: 24,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String title, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: kSmallTitleR.copyWith(
            color: kSecondaryTextColor,
            fontSize: 15,
          ),
        ),
        Text(
          value,
          style: isBold
              ? kBodyTitleB.copyWith(fontSize: 15)
              : kBodyTitleM.copyWith(fontSize: 15),
        ),
      ],
    );
  }
}
