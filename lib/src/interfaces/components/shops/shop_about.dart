import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';

class ShopAbout extends ConsumerWidget {
  final ShopModel? shop;

  const ShopAbout({super.key, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final description = shop?.businessInfo?.description ?? 
        'Offering premium services in ${shop?.businessDetails?.businessType ?? 'Shop'} category.';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About', style: kSmallTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Text(
          description,
          style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
        ),
      ],
    );
  }
}
