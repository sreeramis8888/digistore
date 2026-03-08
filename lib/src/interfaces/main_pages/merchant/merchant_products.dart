import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../../components/shops/shop_product_card.dart';

class MerchantProductsPage extends ConsumerWidget {
  const MerchantProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    final products = const [
      {'name': 'Fresh Juice', 'image': 'assets/png/shake.png', 'price': '₹ 30'},
      {'name': 'Onion', 'image': 'assets/png/waffle.png', 'price': '₹ 30/Kg'},
      {
        'name': 'Tomato',
        'image': 'assets/png/italian_fruit_salad.png',
        'price': '₹ 25/Kg',
      },
      {'name': 'Oats', 'image': 'assets/png/shake.png', 'price': '₹ 120/kg'},
      {
        'name': 'Smoothie',
        'image': 'assets/png/gulabjamun_shake.png',
        'price': '₹ 70',
      },
      {'name': 'Potato', 'image': 'assets/png/waffle.png', 'price': '₹ 20/Kg'},
    ];

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.responsivePadding(24)),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Products',
                    style: kSmallTitleB.copyWith(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kBlue,
                      foregroundColor: kWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(16),
                        vertical: screenSize.responsivePadding(12),
                      ),
                    ),
                    child: Text(
                      'Create Product',
                      style: kSmallerTitleM.copyWith(
                        color: kWhite,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenSize.responsivePadding(16)),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: "Search for 'products'",
                    hintStyle: kSmallerTitleM.copyWith(
                      color: const Color(0xFF99A1AF),
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: Color(0xFF99A1AF),
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(16),
                      vertical: screenSize.responsivePadding(14),
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenSize.responsivePadding(24)),
              Expanded(
                child: GridView.builder(
                  padding: EdgeInsets.only(
                    bottom: screenSize.responsivePadding(24),
                  ),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: screenSize.responsivePadding(16),
                    crossAxisSpacing: screenSize.responsivePadding(16),
                    childAspectRatio: 0.8,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final p = products[index];
                    return ShopProductCard(
                      index: index,
                      name: p['name'],
                      image: p['image'],
                      price: p['price'],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
