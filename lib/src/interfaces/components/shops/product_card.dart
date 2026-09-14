import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../advanced_network_image.dart';
import '../../main_pages/partner/product_details_page.dart';
import '../../../../src/data/models/product_model.dart';
import '../../../data/utils/interactive_feedback_button.dart';

class ProductCard extends ConsumerWidget {
  final int index;

  final String? name;
  final String? image;
  final String? description;
  final String? price;
  final List<String>? tags;
  final ProductModel? rawProduct;
  final bool hideShopInfo;

  const ProductCard({
    super.key,
    required this.index,
    this.name,
    this.image,
    this.description,
    this.price,
    this.tags,
    this.rawProduct,
    this.hideShopInfo = false,
  });

  bool get _hasPrice {
    if (price == null || price!.isEmpty) return false;
    if (price == '₹ 0.0' || price == '₹ 0' || price == '₹ null') return false;
    return true;
  }

  String get _formattedPrice {
    String priceStr = price ?? '';
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(priceStr);
    if (match != null) {
      final val = double.tryParse(match.group(1)!);
      if (val != null) {
        priceStr =
            priceStr.replaceFirst(match.group(1)!, val.toStringAsFixed(2));
      }
    }
    return priceStr;
  }

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

    return InteractiveFeedbackButton(
      onPressed: () {
        final Map<String, dynamic> productData =
            Map<String, dynamic>.from(rawProduct?.toJson() ?? product);
        if (hideShopInfo) {
          productData['hideShopInfo'] = true;
        }

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailsPage(
              product: productData,
              hideShopInfo: hideShopInfo,
            ),
          ),
        );
      },
      scaleFactor: 0.98,
      child: Container(
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AdvancedNetworkImage(
                imageUrl: product['image'] as String,
                fit: BoxFit.cover,
                width: double.infinity,
                disableFade: true,
              ),
            ),
            Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    product['name'] as String,
                    style: kSmallTitleB.copyWith(
                      color: const Color(0xFF111827),
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenSize.responsivePadding(6)),
                  if (_hasPrice)
                    Text(
                      _formattedPrice,
                      style: kSmallTitleB.copyWith(
                        color: kPrimaryColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    )
                  else if (tags != null && tags!.isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(8),
                        vertical: screenSize.responsivePadding(4),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9FAFB),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE5E7EB)),
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
