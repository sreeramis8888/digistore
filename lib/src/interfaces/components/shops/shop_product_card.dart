import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../advanced_network_image.dart';

class ShopProductCard extends ConsumerWidget {
  final int index;

  const ShopProductCard({super.key, required this.index});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final mockProducts = const [
      {'name': 'Gulabjamun Shake', 'image': 'assets/png/gulabjamun_shake.png', 'price': '₹ 200'},
      {'name': 'Waffle', 'image': 'assets/png/waffle.png', 'price': '₹ 150'},
      {'name': 'Italian Fruit Salad', 'image': 'assets/png/italian_fruit_salad.png', 'price': '₹ 250'},
      {'name': 'Shake', 'image': 'assets/png/shake.png', 'price': '₹ 180'},
    ];
    final product = mockProducts[index % mockProducts.length];


    return Container(
      decoration: BoxDecoration(
        color: Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: AdvancedNetworkImage(
              imageUrl: product['image']!,
              fit: BoxFit.cover,
              width: double.infinity,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(screenSize.responsivePadding(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']!,
                  style: kSmallTitleB.copyWith(fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: screenSize.responsivePadding(4)),
                Text(
                  product['price']!,
                  style: kSmallTitleB.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
