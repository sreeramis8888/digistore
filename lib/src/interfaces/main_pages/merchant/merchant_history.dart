import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';

class MerchantHistoryPage extends ConsumerWidget {
  const MerchantHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  'History',
                  style: kSmallTitleB.copyWith(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(24)),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(
                          screenSize.responsivePadding(16),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F7FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Today's\nRedemption",
                              style: kSmallTitleB.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: screenSize.responsivePadding(16)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '18',
                                  style: kDisplayTitleB.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: kBlue,
                                  ),
                                ),
                                const Icon(
                                  Icons.people_alt_outlined,
                                  size: 40,
                                  color: Color(0xFFC4DBED),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: screenSize.responsivePadding(16)),
                    Expanded(
                      child: Container(
                        padding: EdgeInsets.all(
                          screenSize.responsivePadding(16),
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F7FA),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Total\nRedemption",
                              style: kSmallTitleB.copyWith(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: const Color(0xFF333333),
                              ),
                            ),
                            SizedBox(height: screenSize.responsivePadding(16)),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '90',
                                  style: kDisplayTitleB.copyWith(
                                    fontSize: 32,
                                    fontWeight: FontWeight.bold,
                                    color: kBlue,
                                  ),
                                ),
                                const Icon(
                                  Icons.stars_outlined,
                                  size: 40,
                                  color: Color(0xFFC4DBED),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  'Today',
                  style: kSmallTitleB.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(12)),
                _buildRedemptionList(screenSize, 3),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  'Yesterday',
                  style: kSmallTitleB.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(12)),
                _buildRedemptionList(screenSize, 3),
                SizedBox(height: screenSize.responsivePadding(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRedemptionList(ScreenSizeData screenSize, int count) {
    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: count,
      separatorBuilder: (context, index) =>
          SizedBox(height: screenSize.responsivePadding(12)),
      itemBuilder: (context, index) {
        final isVerified = index % 2 == 0;
        final statusColor = isVerified
            ? const Color(0xFF139F5A)
            : const Color(0xFFEB4335);
        final statusText = isVerified ? 'Verified' : 'Rejected';

        return Container(
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          decoration: BoxDecoration(
            color: kWhite,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFEFEFEF), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.asset(
                      'assets/png/shake.png',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Beverage Bonanza',
                          style: kSmallTitleB.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Text(
                          'Mix and match 3 drinks → Get 20% off',
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    statusText,
                    style: kSmallTitleB.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: statusColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(12)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Redeemed on: 03:30 PM, Yesterday',
                    style: kSmallerTitleM.copyWith(
                      color: const Color(0xFFA1A1AA),
                      fontSize: 10,
                    ),
                  ),
                  Text(
                    'Redemption ID: 12345',
                    style: kSmallerTitleM.copyWith(
                      color: const Color(0xFFA1A1AA),
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
