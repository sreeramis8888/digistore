import 'package:flutter/material.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../shops/product_card.dart';

class PartnerUploadedProducts extends StatelessWidget {
  final ScreenSizeData screenSize;

  const PartnerUploadedProducts({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context) {
    final products = const [
      {'name': 'Fresh Juice', 'image': 'assets/png/shake.png', 'price': '₹ 30'},
      {'name': 'Onion', 'image': 'assets/png/waffle.png', 'price': '₹ 30/Kg'},
    ];

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: products.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final p = products[index];
          return SizedBox(
            width: 140,
            child: ProductCard(
              index: index,
              name: p['name']!,
              image: p['image']!,
              price: p['price']!,
            ),
          );
        },
      ),
    );
  }
}
