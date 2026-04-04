import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class PartnerActionCard extends StatelessWidget {
  final ScreenSizeData screenSize;
  final String title;
  final IconData iconData;

  const PartnerActionCard({
    super.key,
    required this.screenSize,
    required this.title,
    required this.iconData,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: screenSize.responsivePadding(90),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(iconData, color: const Color(0xFF6B7280), size: 24),
            SizedBox(height: screenSize.responsivePadding(8)),
            Text(
              title,
              style: kSmallTitleL.copyWith(
                color: kBlack,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
