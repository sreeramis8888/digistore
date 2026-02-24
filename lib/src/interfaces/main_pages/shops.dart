import 'package:flutter/material.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../components/shops/shop_grid_card.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/providers/screen_size_provider.dart';

class ShopsPage extends ConsumerWidget {
  const ShopsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(230);
    final aspectRatio = itemWidth / itemHeight;

    final shops = [
      {
        'category': 'Daily Needs',
        'shopName': 'Chill Bite',
        'address': 'Chill Nagar, Ernakulam, 4 km',
        'distance': '4 km',
        'rating': '4.5',
        'color': Colors.indigo,
        'icon': Icons.icecream,
      },
      {
        'category': 'Personal Care',
        'shopName': 'Vibe',
        'address': 'Chill Nagar, Panampallynagar Ernakulam',
        'distance': '4 km',
        'rating': '4.5',
        'color': Colors.green,
        'icon': Icons.self_improvement,
      },
      {
        'category': 'Construction',
        'shopName': 'Swingin Spoon',
        'address': 'Chill Nagar, Panampallynagar Ernakulam',
        'distance': '4 km',
        'rating': '4.5',
        'color': Colors.amber,
        'icon': Icons.restaurant,
      },
      {
        'category': 'Daily Needs',
        'shopName': 'GOOD',
        'address': 'Chill Nagar, Panampallynagar Ernakulam',
        'distance': '4 km',
        'rating': '4.5',
        'color': Colors.black,
        'icon': Icons.storefront,
      },
      {
        'category': 'Medical',
        'shopName': 'Good Idea',
        'address': 'Chill Nagar, Panampallynagar Ernakulam',
        'distance': '4 km',
        'rating': '4.5',
        'color': Colors.orange,
        'icon': Icons.medical_services,
      },
      {
        'category': 'Medical',
        'shopName': 'Boycot',
        'address': 'Chill Nagar, Panampallynagar Ernakulam',
        'distance': '4 km',
        'rating': '4.5',
        'color': Colors.red,
        'icon': Icons.local_hospital,
      },
    ];

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'Shops',
          style: kSubHeadingM.copyWith(color: Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: GridView.builder(
          padding: EdgeInsets.all(screenSize.responsivePadding(16)),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: screenSize.responsivePadding(16),
            crossAxisSpacing: screenSize.responsivePadding(16),
            childAspectRatio: aspectRatio,
          ),
          itemCount: shops.length,
          itemBuilder: (context, index) {
            final shop = shops[index];
            return ShopGridCard(
              category: shop['category'] as String,
              shopName: shop['shopName'] as String,
              address: shop['address'] as String,
              distance: shop['distance'] as String,
              rating: shop['rating'] as String,
              avatarColor: shop['color'] as Color,
              avatarIcon: shop['icon'] as IconData,
            );
          },
        ),
      ),
    );
  }
}
