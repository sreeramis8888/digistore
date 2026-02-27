import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';

class ShopSocials extends ConsumerWidget {
  const ShopSocials({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Social Media', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(
                Icons.camera_alt,
                color: Colors.purple,
                size: 18,
              ),
              label: Text('Instagram', style: kSmallTitleM),
              style: OutlinedButton.styleFrom(
                backgroundColor: Color(0xFFF9F9F9),
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(12),
                  vertical: screenSize.responsivePadding(8),
                ),
                side: const BorderSide(color: Color(0xFFF9F9F9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            SizedBox(width: screenSize.responsivePadding(12)),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.facebook, color: Colors.blue, size: 18),
              label: Text('Facebook', style: kSmallTitleM),
              style: OutlinedButton.styleFrom(
                backgroundColor: Color(0xFFF9F9F9),
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(12),
                  vertical: screenSize.responsivePadding(8),
                ),
                side: const BorderSide(color: Color(0xFFF9F9F9)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
