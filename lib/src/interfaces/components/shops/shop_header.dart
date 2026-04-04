import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../../../src/data/models/shop_model.dart';
import '../../../../src/data/providers/user_provider.dart';
import '../../../../src/data/utils/location_utils.dart';
import '../../../../src/data/utils/launch_url.dart';
import '../advanced_network_image.dart';

class ShopHeader extends ConsumerWidget {
  final String shopName;
  final ShopModel? shop;

  const ShopHeader({super.key, required this.shopName, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final rating = shop?.businessInfo?.rating ?? 0.0;
    final totalSales = shop?.businessInfo?.totalReviews ?? 0;
    final category = shop?.serviceCategories?.isNotEmpty == true ? shop!.serviceCategories!.first : 'General';
    final address = shop?.businessInfo?.storeLocation?.address ?? 'No address provided';

    final user = ref.watch(userProvider);
    final userLat = user?.location?.coordinates?.lat;
    final userLng = user?.location?.coordinates?.lng;
    final shopCoords = shop?.businessInfo?.storeLocation?.coordinates;

    String distanceLabel = '';
    if (userLat != null && userLng != null && shopCoords != null && shopCoords.length >= 2) {
      final d = LocationUtils.calculateDistance(
        userLat,
        userLng,
        shopCoords[1], // lat
        shopCoords[0], // lng
      );
      distanceLabel = ' (${d.toStringAsFixed(1)} km)';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: screenSize.responsivePadding(40),
              height: screenSize.responsivePadding(40),
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor,
              ),
              child: shop?.businessInfo?.businessLogo != null
                  ? AdvancedNetworkImage(
                      imageUrl: shop!.businessInfo!.businessLogo!,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.circular(20),
                    )
                  : const Icon(Icons.storefront, color: kWhite),
            ),
            SizedBox(width: screenSize.responsivePadding(12)),
            Expanded(
              child: Text(
                shopName, 
                style: kBodyTitleM.copyWith(fontSize: 24),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            SizedBox(width: screenSize.responsivePadding(8)),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(8),
                vertical: screenSize.responsivePadding(4),
              ),
              decoration: BoxDecoration(
                color: const Color(0XFFDFEAFF),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                category,
                style: kSmallerTitleSB.copyWith(
                  color: kPrimaryColor,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.responsivePadding(8)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.only(top: 2),
              child: Icon(
                Icons.location_on_outlined,
                size: 14,
                color: kSecondaryTextColor,
              ),
            ),
            SizedBox(width: screenSize.responsivePadding(4)),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: kSmallTitleL.copyWith(color: const Color(0xFF4E4E4E)),
                  children: [
                    TextSpan(text: address),
                    if (distanceLabel.isNotEmpty)
                      TextSpan(
                        text: distanceLabel,
                        style: kSmallTitleSB.copyWith(color: kPrimaryColor),
                      ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Text(
                  rating.toString(),
                  style: kBodyTitleM.copyWith(color: const Color(0xFF4E4E4E)),
                ),
                SizedBox(width: screenSize.responsivePadding(4)),
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                SizedBox(width: screenSize.responsivePadding(4)),
                Text(
                  '($totalSales reviews)',
                  style: kSmallerTitleL.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {
                final phone = shop?.businessInfo?.contactPhone;
                if (phone != null && phone.isNotEmpty) {
                  launchPhone(phone);
                }
              },
              icon: const Icon(Icons.call, size: 16, color: kTextColor),
              label: Text(
                'Call',
                style: kSmallerTitleL.copyWith(color: kTextColor),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(8),
                  vertical: screenSize.responsivePadding(2),
                ),
                side: const BorderSide(color: kBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
