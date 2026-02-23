import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class HomeSearchBar extends ConsumerWidget {
  const HomeSearchBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(20),
      ),
      child: Container(
        height: screenSize.responsivePadding(50),
        padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(16)),
        decoration: BoxDecoration(
          color: kTertiary.withOpacity(0.5),
          borderRadius: BorderRadius.circular(25),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: kSecondaryTextColor, size: 22),
            SizedBox(width: screenSize.responsivePadding(12)),
            Expanded(
              child: Text(
                "Search for 'services'",
                style: kBodyTitleR.copyWith(color: kSecondaryTextColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
