import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../advanced_network_image.dart';
import '../../main_pages/partner/product_details_page.dart';
import '../../../../src/data/models/product_model.dart';

class ProductCard extends ConsumerWidget {
  final int index;

  final String? name;
  final String? image;
  final String? description;
  final String? price;
  final List<String>? tags;
  final ProductModel? rawProduct;

  const ProductCard({
    super.key,
    required this.index,
    this.name,
    this.image,
    this.description,
    this.price,
    this.tags,
    this.rawProduct,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    final product = (name != null && image != null)
        ? {
            'name': name ?? '',
            'image': image ?? '',
            'price': price ?? '',
            'description': description ?? '',
            'tags': tags ?? [],
          }
        : {'name': '', 'image': '', 'price': '', 'description': '', 'tags': []};

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              product: rawProduct?.toJson() ?? product,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF6F6F6),
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
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AdvancedNetworkImage(
                imageUrl: product['image'] as String,
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
                    product['name'] as String,
                    style: kSmallTitleB.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenSize.responsivePadding(4)),
                  (price == null || price!.isEmpty || price == '₹ 0.0' || price == '₹ 0' || price == '₹ null')
                      ? (tags != null && tags!.isNotEmpty)
                          ? Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: screenSize.responsivePadding(8),
                                vertical: screenSize.responsivePadding(4),
                              ),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [Color(0xFFF3F4F6), Color(0xFFF9FAFB)],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.local_offer_rounded,
                                    size: 10,
                                    color: Color(0xFF6B7280),
                                  ),
                                  SizedBox(width: screenSize.responsivePadding(4)),
                                  Flexible(
                                    child: Text(
                                      tags!.join(', '),
                                      style: kSmallerTitleM.copyWith(
                                        color: const Color(0xFF4B5563),
                                        fontWeight: FontWeight.w600,
                                        fontSize: 10,
                                        height: 1.0,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            )
                          : const SizedBox.shrink()
                      : Text(
                          product['price'] as String,
                          style: kSmallTitleB.copyWith(fontWeight: FontWeight.w600),
                        ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
