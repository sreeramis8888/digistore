import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';
import 'section_title.dart';
import '../shops/featured_shop_card.dart';

import '../../../data/models/featured_shop.dart';

class FeaturedShopsList extends ConsumerWidget {
  final List<FeaturedShop>? shops;
  const FeaturedShopsList({super.key, this.shops});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (shops == null || shops!.isEmpty) return const SizedBox.shrink();
    final screenSize = ref.watch(screenSizeProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(8),
          ),
          child: SectionTitle(
            title: 'Featured Shops',
            onViewAll: () {
              ref.read(selectedIndexProvider.notifier).updateIndex(2);
            },
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(10)),
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: shops!
                .take(4)
                .map((shop) => FeaturedShopCard(shop: shop))
                .toList(),
          ),
        ),
      ],
    );
  }
}
