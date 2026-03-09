import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class MerchantMenuItem extends StatelessWidget {
  final String title;
  final Widget icon;
  final ScreenSizeData screenSize;
  final VoidCallback? onTap;

  const MerchantMenuItem({
    super.key,
    required this.title,
    required this.icon,
    required this.screenSize,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap ?? () {},
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(16),
          vertical: screenSize.responsivePadding(16),
        ),
        child: Row(
          children: [
            SizedBox(
              width: screenSize.responsivePadding(24),
              height: screenSize.responsivePadding(24),
              child: Center(child: icon),
            ),
            SizedBox(width: screenSize.responsivePadding(16)),
            Expanded(
              child: Text(title, style: kSmallTitleL.copyWith(color: kBlack)),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: screenSize.responsivePadding(14),
              color: const Color(0xFFD1D5DB),
            ),
          ],
        ),
      ),
    );
  }
}
