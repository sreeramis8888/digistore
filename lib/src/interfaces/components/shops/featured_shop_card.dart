import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../advanced_network_image.dart';

class FeaturedShopCard extends ConsumerWidget {
  final Map<String, dynamic> shop;

  const FeaturedShopCard({super.key, required this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).pushNamed('shopDetail', arguments: shop['name'] as String);
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
                color: shop['color'] as Color,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: shop['image'] != null
                  ? ClipOval(
                      child: AdvancedNetworkImage(
                        imageUrl: shop['image'] as String,
                        width: screenSize.responsivePadding(70),
                        height: screenSize.responsivePadding(70),
                        fit: BoxFit.cover,
                      ),
                    )
                  : const Center(
                      child: Icon(Icons.storefront, color: kWhite, size: 30),
                    ),
            ),
            SizedBox(height: screenSize.responsivePadding(8)),
            Text(
              shop['name'] as String,
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
