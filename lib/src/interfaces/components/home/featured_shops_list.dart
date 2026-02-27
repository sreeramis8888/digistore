import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';
import 'section_title.dart';
import '../shops/featured_shop_card.dart';

class FeaturedShopsList extends ConsumerWidget {
  const FeaturedShopsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final shops = [
      {'name': 'Vibe', 'color': Colors.greenAccent},
      {'name': 'Swingin\nSpoon', 'color': Colors.orangeAccent.withOpacity(0.2)},
      {'name': 'GOOD', 'color': Colors.black87},
      {'name': 'Chill Bite', 'color': Colors.blue},
    ];

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
            children: shops
                .map((shop) => FeaturedShopCard(shop: shop))
                .toList(),
          ),
        ),
      ],
    );
  }
}
