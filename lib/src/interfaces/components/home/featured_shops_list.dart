import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/models/shop_model.dart';
import '../../main_pages/shop_pages/featured_shops_page.dart';
import 'home_featured_shop_card.dart';
import 'section_title.dart';

class FeaturedShopsList extends ConsumerWidget {
  final List<ShopModel>? shops;
  const FeaturedShopsList({super.key, this.shops});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Prefer /shops/featured (same source as View All) so home isn't stuck
    // with a single shop from the /home payload.
    final featuredState = ref.watch(featuredShopsProvider);
    final displayShops = featuredState.shops.isNotEmpty
        ? featuredState.shops
        : (shops ?? const <ShopModel>[]);

    if (displayShops.isEmpty) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);
    final hPad = screenSize.responsivePadding(16);
    final gap = screenSize.responsivePadding(12);
    final listHeight = screenSize.responsivePadding(146);
    // Slightly narrower so ~2 cards fit on typical phone widths.
    final cardWidth = screenSize.responsivePadding(148);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(
          title: 'Featured Shops',
          revampStyle: true,
          onViewAll: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const FeaturedShopsPage(),
              ),
            );
          },
        ),
        SizedBox(height: screenSize.responsivePadding(8)),
        SizedBox(
          height: listHeight,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: hPad),
            itemCount: displayShops.length,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              return HomeFeaturedShopCard(
                shop: displayShops[index],
                width: cardWidth,
              );
            },
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(28)),
      ],
    );
  }
}
