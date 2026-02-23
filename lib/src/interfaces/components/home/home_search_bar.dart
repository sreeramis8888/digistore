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
        horizontal: screenSize.responsivePadding(16),
      ),
      child: Container(
        height: screenSize.responsivePadding(54),
        padding: EdgeInsets.symmetric(
          horizontal: screenSize.responsivePadding(20),
        ),
        decoration: BoxDecoration(
          color: kField,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF7D848D), size: 24),
            SizedBox(width: screenSize.responsivePadding(12)),
            Expanded(
              child: Text(
                "Search for 'services'",
                style: kSmallerTitleL.copyWith(color: kBlack.withOpacity(.5)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
