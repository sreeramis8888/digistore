import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
                  style: kBodyTitleM.copyWith(color: Color(0xFF373737)),
                ),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Today's Overview",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                _buildOverviewCards(screenSize),
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

  Widget _buildOverviewCards(ScreenSizeData screenSize) {
    return Row(
      children: [
        _overviewCard(
          screenSize,
          "Total\nCustomers",
          "90",
          "assets/svg/total_customers.svg",
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _overviewCard(
          screenSize,
          "Your\nCommission",
          "1.5k",
          "assets/svg/your_commission.svg",
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _overviewCard(
          screenSize,
          "Total Sales\nvia Setgo",
          "12",
          "assets/svg/total_sales.svg",
        ),
      ],
    );
  }

  Widget _overviewCard(
    ScreenSizeData screenSize,
    String title,
    String value,
    String svgAsset,
  ) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF3F7FA),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: kSmallTitleB.copyWith(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                    maxLines: 2,
                  ),
                  SizedBox(height: screenSize.responsivePadding(12)),
                  Text(
                    value,
                    style: kBodyTitleL.copyWith(fontSize: 24, color: kBlue),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(svgAsset, fit: BoxFit.contain),
            ),
          ],
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
            color: Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(4),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.002),
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
                          maxLines: 1,
                          'Mix and match 3 drinks → Get 20% off',
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFF6B7280),
                            overflow: TextOverflow.ellipsis,
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
              SizedBox(height: screenSize.responsivePadding(10)),
              Divider(color: const Color(0xFFDFDFDF), height: .5),
              SizedBox(height: screenSize.responsivePadding(10)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Redeemed on: ',
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TextSpan(
                          text: '03:30 PM, Yesterday',
                          style: kSmallerTitleM.copyWith(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'Redemption ID: ',
                          style: kSmallerTitleM.copyWith(
                            color: const Color(0xFFA1A1AA),
                            fontSize: 10,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                        TextSpan(
                          text: '12345',
                          style: kSmallerTitleM.copyWith(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
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
