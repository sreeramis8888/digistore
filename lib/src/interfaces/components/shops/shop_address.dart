import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';
import '../../../../src/data/utils/launch_url.dart';

class ShopAddress extends ConsumerWidget {
  final ShopModel? shop;

  const ShopAddress({super.key, this.shop});

  void _openDirections() {
    final shopCoords = shop?.businessInfo?.storeLocation?.coordinates;
    if (shopCoords != null && shopCoords.length >= 2) {
      final lat = shopCoords[1];
      final lng = shopCoords[0];
      launchURL('https://www.google.com/maps/dir/?api=1&destination=$lat,$lng');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final location = shop?.businessInfo?.storeLocation;
    
    String addressText = 'No address provided';
    String? cityStateText;
    
    if (shop?.businessDetails?.address != null) {
      addressText = shop!.businessDetails!.address!;
      if (shop?.businessDetails?.pincode != null) {
        cityStateText = 'Pincode: ${shop?.businessDetails?.pincode}';
      }
    } else if (location?.address != null) {
      addressText = location!.address!;
      if (location.city != null || location.state != null || location.pincode != null) {
        cityStateText = '${location.city ?? ''} ${location.state ?? ''} ${location.pincode ?? ''}'.trim();
      }
    } else if (shop?.coverageAreas?.districts?.isNotEmpty == true) {
      addressText = shop!.coverageAreas!.districts!.join(', ');
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Text(
          addressText,
          style: kSmallTitleR.copyWith(color: kSecondaryTextColor, height: 1.5),
        ),
        if (cityStateText != null && cityStateText.isNotEmpty) ...[
          SizedBox(height: screenSize.responsivePadding(4)),
          Text(
            cityStateText,
            style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
          ),
        ],
        SizedBox(height: screenSize.responsivePadding(12)),
        InkWell(
          onTap: _openDirections,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            height: screenSize.responsivePadding(120),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: kPrimaryColor.withAlpha(76)),
            ),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.directions,
                    color: kPrimaryColor,
                    size: 32,
                  ),
                  SizedBox(height: screenSize.responsivePadding(8)),
                  Text(
                    'Get Directions',
                    style: kSmallTitleM.copyWith(color: kPrimaryColor),
                  ),
                  SizedBox(height: screenSize.responsivePadding(4)),
                  Text(
                    shop?.businessDetails?.businessName ?? 'Shop Location',
                    style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
