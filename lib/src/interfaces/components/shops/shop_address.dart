import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';

class ShopAddress extends ConsumerWidget {
  final ShopModel? shop;

  const ShopAddress({super.key, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final location = shop?.businessInfo?.storeLocation;
    final addressText = location?.address ?? 
        (shop?.coverageAreas?.districts?.isNotEmpty == true 
            ? shop!.coverageAreas!.districts!.join(', ') 
            : 'Explore this shop\'s unique offerings and services.');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Text(
          addressText,
          style: kSmallTitleR.copyWith(color: kSecondaryTextColor, height: 1.5),
        ),
        if (location?.city != null) ...[
          SizedBox(height: screenSize.responsivePadding(4)),
          Text(
            '${location!.city}, ${location.state ?? ''} ${location.pincode ?? ''}',
            style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
          ),
        ],
        SizedBox(height: screenSize.responsivePadding(12)),
        Container(
          width: double.infinity,
          height: screenSize.responsivePadding(120),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on,
                  color: kPrimaryColor,
                  size: 20,
                ),
                SizedBox(width: screenSize.responsivePadding(8)),
                Text(shop?.businessDetails?.businessName ?? 'Shop Location', style: kSmallTitleM),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
