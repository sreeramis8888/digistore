import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/advanced_network_image.dart';
import '../../components/confirmation_dialog.dart';
import '../../../data/providers/partner_products_provider.dart';
import 'partner_product_page.dart';

class ProductDetailsPage extends ConsumerWidget {
  final Map<String, dynamic> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: kBlack, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('Product Details', style: kSmallTitleM),
        centerTitle: false,
        actions: [
          Container(
            height: 32,
            margin: const EdgeInsets.symmetric(vertical: 12),
            child: OutlinedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CreateProductPage(product: product),
                  ),
                );
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: kPrimaryColor),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(6),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              child: Text(
                'Edit',
                style: kSmallTitleM.copyWith(color: kPrimaryColor),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            height: 32,
            width: 32,
            margin: const EdgeInsets.only(right: 16, top: 12, bottom: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.red.shade300),
              borderRadius: BorderRadius.circular(6),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: Icon(
                Icons.delete_outline,
                color: Colors.red.shade400,
                size: 18,
              ),
              onPressed: () async {
                final confirm = await showConfirmationDialog(
                  context: context,
                  title: 'Delete Product',
                  message: 'Are you sure you want to delete this product?',
                  confirmText: 'Delete',
                  isDestructive: true,
                );

                if (confirm == true && context.mounted) {
                  try {
                    await ref.read(partnerProductsProvider.notifier).deleteProduct(product['_id'] ?? product['id']);
                    if (context.mounted) {
                      Navigator.pop(context); // Go back to products list
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: $e')),
                      );
                    }
                  }
                }
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: AdvancedNetworkImage(
                imageUrl: (product['images'] != null && (product['images'] as List).isNotEmpty) ? product['images'][0] : (product['image'] ?? ''),
                fit: BoxFit.cover,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['title'] ?? product['name'] ?? '',
                    style: kBodyTitleM.copyWith(fontSize: 24),
                  ),
                  if (product['price'] != null && (product['price'] is num ? product['price'] > 0 : (product['price'].toString().trim().isNotEmpty && product['price'].toString().trim() != '0' && product['price'].toString().trim() != '0.0'))) ...[
                    const SizedBox(height: 8),
                    Text(
                      product['price'] is num ? '₹ ${product['price']}' : (product['price']?.toString() ?? ''),
                      style: kBodyTitleL.copyWith(fontSize: 24),
                    ),
                  ],
                  const SizedBox(height: 24),
                  if (product['description'] != null &&
                      product['description'].isNotEmpty) ...[
                    Text('Description', style: kSmallTitleM),
                    const SizedBox(height: 8),
                    Text(
                      product['description'] ?? '',
                      style: kSmallerTitleL.copyWith(color: Color(0xFF4E4E4E)),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
