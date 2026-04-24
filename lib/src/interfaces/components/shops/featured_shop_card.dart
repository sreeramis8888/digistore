import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../advanced_network_image.dart';

import '../../../data/models/shop_model.dart';

class FeaturedShopCard extends ConsumerWidget {
  final ShopModel shop;

  const FeaturedShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return GestureDetector(
      onTap: () {
        Navigator.of(context).pushNamed('shopDetail', arguments: shop);
      },
      child: SizedBox(
        width: screenSize.responsivePadding(76),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              width: screenSize.responsivePadding(70),
              height: screenSize.responsivePadding(70),
              decoration: BoxDecoration(
                color: kPrimaryLightColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: AdvancedNetworkImage(
                  imageUrl: shop.businessInfo?.businessLogo ?? '',
                  width: screenSize.responsivePadding(70),
                  height: screenSize.responsivePadding(70),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(8)),
            Text(
              shop.businessDetails?.businessName ?? '',
              style: kSmallTitleL,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.visible,
            ),
          ],
        ),
      ),
    );
  }
}
