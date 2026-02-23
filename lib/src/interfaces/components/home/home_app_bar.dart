import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(10),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.responsivePadding(50),
            height: screenSize.responsivePadding(50),
            decoration: BoxDecoration(
              color: kSecondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text('M', style: kLargeTitleM.copyWith(color: kWhite)),
          ),
          SizedBox(width: screenSize.responsivePadding(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maria Vinaya', style: kSubHeadingM),
                SizedBox(height: screenSize.responsivePadding(4)),
                Row(
                  children: [
                    Icon(
                      Icons.location_on_outlined,
                      color: kSecondaryTextColor,
                      size: 16,
                    ),
                    SizedBox(width: screenSize.responsivePadding(4)),
                    Text(
                      'Location 1234',
                      style: kBodyTitleL.copyWith(color: kSecondaryTextColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(screenSize.responsivePadding(10)),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: kBorder),
            ),
            child: SvgPicture.asset('assets/svg/bell.svg'),
          ),
        ],
      ),
    );
  }
}
