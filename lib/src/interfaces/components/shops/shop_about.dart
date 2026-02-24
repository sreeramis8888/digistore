import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';

class ShopAbout extends ConsumerWidget {
  const ShopAbout({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        RichText(
          text: TextSpan(
            style: kSmallTitleR.copyWith(
              color: kSecondaryTextColor,
              height: 1.5,
            ),
            children: [
              const TextSpan(
                text:
                    'Chill bite is your one-stop destination for all things ice cream. We offer a wide variety of flavors, from classic vanilla to exot... ',
              ),
              TextSpan(
                text: 'See more',
                style: kSmallTitleSB.copyWith(color: kPrimaryColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
