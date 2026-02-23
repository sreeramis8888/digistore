import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        horizontal: screenSize.responsivePadding(20),
        vertical: screenSize.responsivePadding(10),
      ),
      child: Row(
        children: [
          Container(
            width: screenSize.responsivePadding(45),
            height: screenSize.responsivePadding(45),
            decoration: BoxDecoration(
              color: kSecondaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            alignment: Alignment.center,
            child: Text(
              'M',
              style: kDisplayTitleB.copyWith(color: kWhite),
            ),
          ),
          SizedBox(width: screenSize.responsivePadding(12)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Maria Vinaya',
                  style: kHeadTitleB,
                ),
                SizedBox(height: screenSize.responsivePadding(4)),
                Row(
                  children: [
                    Icon(Icons.location_on_outlined, color: kSecondaryTextColor, size: 16),
                    SizedBox(width: screenSize.responsivePadding(4)),
                    Text(
                      'Location 1234',
                      style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
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
            child: const Icon(Icons.notifications_none_outlined, color: kTextColor, size: 24),
          ),
        ],
      ),
    );
  }
}
