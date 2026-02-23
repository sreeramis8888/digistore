import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import 'section_title.dart';
import 'package:flutter_svg/flutter_svg.dart';

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
        SectionTitle(title: 'Featured Shops', onViewAll: () {}),
        SizedBox(
          height: screenSize.responsivePadding(110),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(horizontal: screenSize.responsivePadding(20)),
            itemCount: shops.length,
            itemBuilder: (context, index) {
              final shop = shops[index];
              return Padding(
                padding: EdgeInsets.only(right: screenSize.responsivePadding(20)),
                child: Column(
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
                      child: const Center(
                        child: Icon(Icons.storefront, color: kWhite, size: 30),
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(8)),
                    SizedBox(
                      width: screenSize.responsivePadding(70),
                      child: Text(
                        shop['name'] as String,
                        style: kSmallTitleR,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
