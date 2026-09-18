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
        final cleaned = val % 1 == 0
            ? val.toInt().toString()
            : val.toStringAsFixed(2);
        priceStr = priceStr.replaceFirst(match.group(1)!, cleaned);
      }
    }
    return priceStr;
  }

  String? get _badgeLabel {
    final category =
        rawProduct?.category?.category ?? rawProduct?.category?.subcategory;
    if (category != null && category.trim().isNotEmpty) return category.trim();
    if (tags != null && tags!.isNotEmpty) return tags!.first;
    return null;
  }

  String? get _shopName {
    final productMap = rawProduct?.toJson() ?? {};
    final partner =
        rawProduct?.partnerObj ??
        (productMap['partner'] is Map
            ? Map<String, dynamic>.from(productMap['partner'] as Map)
            : productMap['partnerId'] is Map
            ? Map<String, dynamic>.from(productMap['partnerId'] as Map)
            : null);

    final fromProduct = productMap['shopName']?.toString().trim();
    if (fromProduct != null && fromProduct.isNotEmpty) return fromProduct;

    if (partner != null) {
      final businessDetails = partner['businessDetails'];
      final fromBusinessDetails = businessDetails is Map
          ? businessDetails['businessName']?.toString().trim()
          : null;
      if (fromBusinessDetails != null && fromBusinessDetails.isNotEmpty) {
        return fromBusinessDetails;
      }

      final businessInfo = partner['businessInfo'];
      final fromBusinessInfo = businessInfo is Map
          ? (businessInfo['businessName'] ?? businessInfo['shopName'])
                ?.toString()
                .trim()
          : null;
      if (fromBusinessInfo != null && fromBusinessInfo.isNotEmpty) {
        return fromBusinessInfo;
      }

      final fromPartner =
          (partner['shopName'] ?? partner['businessName'] ?? partner['name'])
              ?.toString()
              .trim();
      if (fromPartner != null &&
          fromPartner.isNotEmpty &&
          fromPartner.toLowerCase() != 'setgo partner') {
        return fromPartner;
      }
    }

    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final productName = name ?? rawProduct?.title ?? '';
    final imageUrl =
        image ??
        ((rawProduct?.images != null && rawProduct!.images!.isNotEmpty)
            ? rawProduct!.images!.first
            : '');
    final badge = _badgeLabel;

    return InteractiveFeedbackButton(
      onPressed: () {
        final Map<String, dynamic> productData = Map<String, dynamic>.from(
          rawProduct?.toJson() ??
              {
                'name': productName,
                'image': imageUrl,
                'price': price ?? '',
                'description': description ?? '',
                'tags': tags ?? [],
              },
        );
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(23),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: screenSize.responsivePadding(115),
                width: double.infinity,
                child: AdvancedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  disableFade: true,
                  errorWidget: Container(
                    color: const Color(0xFFF3F4F6),
                    child: const Center(
                      child: Icon(
                        Icons.shopping_bag_outlined,
                        color: Color(0xFF9CA3AF),
                        size: 32,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: EdgeInsets.all(screenSize.responsivePadding(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            productName,
                            style: kSmallTitleSB.copyWith(
                              color: const Color(0xFF111827),
                              fontSize: 15,
                              height: 1.2,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!hideShopInfo && _shopName != null) ...[
                            SizedBox(height: screenSize.responsivePadding(4)),
                            Row(
                              children: [
                                const Icon(
                                  Icons.location_on,
                                  size: 13,
                                  color: Color(0xFF1C274C),
                                ),
                                const SizedBox(width: 2),
                                Expanded(
                                  child: Text(
                                    _shopName!,
                                    style: kSmallerTitleM.copyWith(
                                      color: const Color(0xFF111827),
                                      fontSize: 11,
                                      height: 1.2,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Expanded(
                            child: _hasPrice
                                ? Text(
                                    _formattedPrice,
                                    style: kSmallerTitleM.copyWith(
                                      color: const Color(0xFF4E4E4E),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : (tags != null && tags!.isNotEmpty)
                                ? Text(
                                    tags!.join(', '),
                                    style: kSmallerTitleM.copyWith(
                                      color: const Color(0xFF4E4E4E),
                                      fontSize: 11,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  )
                                : const SizedBox.shrink(),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Flexible(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4.5,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF34C759),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  badge,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: kSmallerTitleB.copyWith(
                                    color: kWhite,
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
