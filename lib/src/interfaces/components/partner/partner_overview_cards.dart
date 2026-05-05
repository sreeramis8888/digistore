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
          _formatValue(totalCustomers ?? 0),
          "assets/svg/total_customers.svg",
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _overviewCard(
          "Your\nCommission",
          "₹${_formatValue(commissionAmount ?? 0)}",
          "assets/svg/your_commission.svg",
        ),
        SizedBox(width: screenSize.responsivePadding(12)),
        _overviewCard(
          "Total Sales\nvia Setgo",
          _formatValue(totalSalesViaSetgo ?? 0),
          "assets/svg/total_sales.svg",
        ),
      ],
    );
  }

  String _formatValue(num value) {
    if (value >= 100000) {
      final lakhs = value / 100000;
      return lakhs % 1 == 0 ? '${lakhs.toInt()}L' : '${lakhs.toStringAsFixed(1)}L';
    } else if (value >= 1000) {
      final k = value / 1000;
      return k % 1 == 0 ? '${k.toInt()}k' : '${k.toStringAsFixed(1)}k';
    } else {
      return value is double ? value.toStringAsFixed(1) : value.toString();
    }
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
            Positioned(
              bottom: 0,
              right: 0,
              child: SvgPicture.asset(svgAsset, fit: BoxFit.contain),
            ),
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
          ],
        ),
      ),
    );
  }
}
