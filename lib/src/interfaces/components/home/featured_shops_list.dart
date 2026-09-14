import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/models/shop_model.dart';
import '../../main_pages/shop_pages/featured_shops_page.dart';
import 'home_featured_shop_card.dart';
import 'section_title.dart';

class FeaturedShopsList extends ConsumerWidget {
  final List<ShopModel>? shops;
  const FeaturedShopsList({super.key, this.shops});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (shops == null || shops!.isEmpty) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);
    final hPad = screenSize.responsivePadding(16);
    final gap = screenSize.responsivePadding(12);
    final listHeight = screenSize.responsivePadding(146);

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
            itemCount: shops!.length,
            separatorBuilder: (_, _) => SizedBox(width: gap),
            itemBuilder: (context, index) {
              return HomeFeaturedShopCard(shop: shops![index]);
            },
          ),
        ),
      ],
    );
  }
}
