import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../../data/providers/shops_provider.dart';
import '../../data/providers/user_provider.dart';
import '../../data/models/shop_model.dart';
import '../../data/utils/location_utils.dart';
import '../components/shops/shop_grid_card.dart';

class ShopsPage extends ConsumerStatefulWidget {
  const ShopsPage({super.key});

  @override
  ConsumerState<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends ConsumerState<ShopsPage> {
  Color _getCategoryColor(String? type) {
    switch (type) {
      case 'Restaurants & Cafes': return Colors.orange;
      case 'Beauty & Wellness': return Colors.pink;
      case 'Fitness & Sports': return Colors.green;
      case 'Automotive Services': return Colors.blue;
      case 'Construction': return Colors.amber;
      case 'Medical': return Colors.red;
      case 'PG Hostels': return Colors.indigo;
      default: return kPrimaryColor;
    }
  }

  IconData _getCategoryIcon(String? type) {
    switch (type) {
      case 'Restaurants & Cafes': return Icons.restaurant;
      case 'Beauty & Wellness': return Icons.spa;
      case 'Fitness & Sports': return Icons.fitness_center;
      case 'Automotive Services': return Icons.home_repair_service;
      case 'Construction': return Icons.construction;
      case 'Medical': return Icons.medical_services;
      case 'PG Hostels': return Icons.home_filled;
      default: return Icons.store;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(230);
    final aspectRatio = itemWidth / itemHeight;

    final shopsAsync = ref.watch(shopsProvider());
    final user = ref.watch(userProvider);
    final userLat = user?.location?.coordinates?.lat;
    final userLng = user?.location?.coordinates?.lng;

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'Shops',
          style: kSubHeadingM.copyWith(color: const Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: shopsAsync.when(
          data: (paginated) => GridView.builder(
            padding: EdgeInsets.all(screenSize.responsivePadding(16)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: screenSize.responsivePadding(16),
              crossAxisSpacing: screenSize.responsivePadding(16),
              childAspectRatio: aspectRatio,
            ),
            itemCount: paginated.shops.length,
            itemBuilder: (context, index) {
              final ShopModel shop = paginated.shops[index];
              final type = shop.businessDetails?.businessType;
              final logo = shop.businessInfo?.businessLogo;
              final address = shop.businessInfo?.storeLocation?.address ?? 
                  shop.businessDetails?.businessType ?? 'No address provided';

              String distance = '...';
              final shopCoords = shop.businessInfo?.storeLocation?.coordinates;
              if (userLat != null && userLng != null && shopCoords != null && shopCoords.length >= 2) {
                final d = LocationUtils.calculateDistance(
                  userLat, 
                  userLng, 
                  shopCoords[1], 
                  shopCoords[0], 
                );
                distance = '${d.toStringAsFixed(1)} km';
              }
              
              return ShopGridCard(
                category: shop.serviceCategories?.first ?? 'Other',
                shopName: shop.businessDetails?.businessName ?? 'Unnamed Shop',
                address: address,
                distance: distance,
                rating: shop.businessInfo?.rating?.toString() ?? '0.0',
                avatarColor: _getCategoryColor(type),
                avatarIcon: _getCategoryIcon(type),
                imageUrl: logo ?? (shop.businessInfo?.businessImages?.isNotEmpty == true 
                    ? shop.businessInfo!.businessImages!.first 
                    : null),
                shop: shop,
              );
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => Center(child: Text(e.toString())),
        ),
      ),
    );
  }
}
