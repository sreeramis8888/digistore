import 'package:flutter/material.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../shops/product_card.dart';
import '../../../data/models/product_model.dart';

class PartnerUploadedProducts extends StatelessWidget {
  final ScreenSizeData screenSize;
  final List<ProductModel>? products;

  const PartnerUploadedProducts({
    super.key,
    required this.screenSize,
    this.products,
  });

  @override
  Widget build(BuildContext context) {
    if (products == null || products!.isEmpty) {
      return const Center(child: Text('No products available'));
    }

    return SizedBox(
      height: 180,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        clipBehavior: Clip.none,
        itemCount: products!.length,
        separatorBuilder: (context, index) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          final p = products![index];
          return SizedBox(
            width: 140,
            child: ProductCard(
              index: index,
              name: p.title,
              image: (p.images != null && p.images!.isNotEmpty) ? p.images!.first : '',
              price: '₹ ${p.price ?? 0}',
            ),
          );
        },
      ),
    );
  }
}
