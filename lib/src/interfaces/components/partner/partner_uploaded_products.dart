import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/models/product_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../components/advanced_network_image.dart';

class PartnerUploadedProducts extends ConsumerWidget {
  final ScreenSizeData screenSize;
  final List<ProductModel>? products;

  const PartnerUploadedProducts({
    super.key,
    required this.screenSize,
    this.products,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (products == null || products!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Uploaded Products',
                style: GoogleFonts.urbanist(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF111827),
                ),
              ),
              InkWell(
                onTap: () {
                  ref.read(selectedIndexProvider.notifier).updateIndex(2);
                },
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'View All',
                      style: GoogleFonts.urbanist(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF10B981),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: Color(0xFF10B981),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(16)),
        SizedBox(
          height: screenSize.responsivePadding(123),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            itemCount: products!.length,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final product = products![index];
              return _buildProductCard(context, product);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildProductCard(BuildContext context, ProductModel product) {
    final imageUrl = (product.images != null && product.images!.isNotEmpty)
        ? product.images!.first
        : '';

    final priceStr = product.price != null && product.price! > 0
        ? '₹ ${product.price! % 1 == 0 ? product.price!.toInt() : product.price}'
        : '';

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.pushNamed(
          context,
          'productDetails',
          arguments: product.toJson(),
        );
      },
      scaleFactor: 0.98,
      child: Container(
        width: 160,
        height: 123,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cover Image
            SizedBox(
              width: double.infinity,
              height: 90,
              child: imageUrl.isNotEmpty
                  ? AdvancedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      borderRadius: BorderRadius.zero,
                      disableFade: true,
                    )
                  : Container(
                      color: const Color(0xFFF3F4F6),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.inventory_2_outlined,
                        size: 32,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
            ),

            // Product Details Row
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        product.title ?? 'Product',
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111827),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (priceStr.isNotEmpty) ...[
                      const SizedBox(width: 6),
                      Text(
                        priceStr,
                        style: GoogleFonts.urbanist(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF111827),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

