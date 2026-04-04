import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class PartnerOverviewCards extends StatelessWidget {
  final ScreenSizeData screenSize;
  final int? totalCustomers;
  final double? commissionAmount;
  final int? totalSalesViaSetgo;

  const PartnerOverviewCards({
    super.key,
    required this.screenSize,
    this.totalCustomers,
    this.commissionAmount,
    this.totalSalesViaSetgo,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _overviewCard(
          "Total\nCustomers",
          (totalCustomers ?? 0).toString(),
          "assets/svg/total_customers.svg",
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _overviewCard(
          "Your\nCommission",
          "₹${(commissionAmount ?? 0).toStringAsFixed(1)}",
          "assets/svg/your_commission.svg",
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _overviewCard(
          "Total Sales\nvia Setgo",
          (totalSalesViaSetgo ?? 0).toString(),
          "assets/svg/total_sales.svg",
        ),
      ],
    );
  }

  Widget _overviewCard(String title, String value, String svgAsset) {
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
}
