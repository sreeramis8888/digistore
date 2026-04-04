import 'package:flutter/material.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../components/advanced_network_image.dart';
import 'partner_product_page.dart';

class ProductDetailsPage extends StatelessWidget {
  final Map<String, String> product;

  const ProductDetailsPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
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
              onPressed: () {
                // Delete logic
              },
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AdvancedNetworkImage(
              imageUrl: product['image'] ?? '',
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['name'] ?? '',
                    style: kBodyTitleM.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    product['price'] ?? '',
                    style: kBodyTitleL.copyWith(fontSize: 24),
                  ),
                  const SizedBox(height: 24),
                  Text('Description', style: kSmallTitleM),
                  const SizedBox(height: 8),
                  Text(
                    'Sodales cras etiam senectus turpis at scelerisque sed ullamcorper. Orci tincidunt scelerisque nunc in. Ut semper cursus in vel. Gravida vehicula lorem amet faucibus. Nec tellus nisi arcu neque ultrices. Urna lobortis ipsum sollicitudin quis id tortor.',
                    style: kSmallerTitleL.copyWith(color: Color(0xFF4E4E4E)),
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
