import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';

class ShopHeader extends ConsumerWidget {
  final String shopName;

  const ShopHeader({super.key, required this.shopName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: screenSize.responsivePadding(40),
              height: screenSize.responsivePadding(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: kPrimaryColor,
              ),
              child: const Icon(Icons.storefront, color: kWhite),
            ),
            SizedBox(width: screenSize.responsivePadding(12)),
            Text(shopName, style: kBodyTitleB.copyWith(fontSize: 20)),
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
                'Daily Needs',
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
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(
                Icons.location_on_outlined,
                size: 14,
                color: kSecondaryTextColor,
              ),
            ),
            SizedBox(width: screenSize.responsivePadding(4)),
            Expanded(
              child: Text(
                'Chill Nagar, Panampallynagar, Ernakulam, 7.8km',
                style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
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
                Text('4.5', style: kBodyTitleB.copyWith(fontSize: 16)),
                SizedBox(width: screenSize.responsivePadding(4)),
                const Icon(Icons.star, color: Color(0xFFFFD700), size: 18),
                SizedBox(width: screenSize.responsivePadding(4)),
                Text(
                  'out of 10',
                  style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
                ),
              ],
            ),
            OutlinedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.call, size: 16, color: kTextColor),
              label: Text(
                'Call',
                style: kSmallTitleM.copyWith(color: kTextColor),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: screenSize.responsivePadding(16),
                  vertical: screenSize.responsivePadding(8),
                ),
                side: const BorderSide(color: kBorder),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
