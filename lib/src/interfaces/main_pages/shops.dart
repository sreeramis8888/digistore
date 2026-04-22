import 'package:digistore/src/interfaces/animations/index.dart';
import 'package:digistore/src/interfaces/components/shimmers/card_shimmers.dart';
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

import '../components/empty_state.dart';

class ShopsPage extends ConsumerStatefulWidget {
  const ShopsPage({super.key});

  @override
  ConsumerState<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends ConsumerState<ShopsPage> {
  final Map<String, String> _distanceCache = {};

  Color _getCategoryColor(String? type) {
    switch (type) {
      case 'Restaurants & Cafes':
        return Colors.orange;
      case 'Beauty & Wellness':
        return Colors.pink;
      case 'Fitness & Sports':
        return Colors.green;
      case 'Automotive Services':
        return Colors.blue;
      case 'Construction':
        return Colors.amber;
      case 'Medical':
        return Colors.red;
      case 'PG Hostels':
        return Colors.indigo;
      default:
        return kPrimaryColor;
    }
  }

  IconData _getCategoryIcon(String? type) {
    switch (type) {
      case 'Restaurants & Cafes':
        return Icons.restaurant;
      case 'Beauty & Wellness':
        return Icons.spa;
      case 'Fitness & Sports':
        return Icons.fitness_center;
      case 'Automotive Services':
        return Icons.home_repair_service;
      case 'Construction':
        return Icons.construction;
      case 'Medical':
        return Icons.medical_services;
      case 'PG Hostels':
        return Icons.home_filled;
      default:
        return Icons.store;
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
          data: (paginated) {
            if (paginated.shops.isEmpty) {
              return const EmptyState(
                imagePath: 'assets/png/empty_shops.png',
                title: 'No shops found',
                subtitle:
                    'We couldn\'t find any shops in your area. Try a different category or change your location.',
              );
            }
            return GridView.builder(
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
                final coverImage = logo ??
                    (shop.businessInfo?.businessImages?.isNotEmpty == true
                        ? shop.businessInfo!.businessImages!.first
                        : null);

                String address = 'No address provided';
                if (shop.businessDetails?.address != null) {
                  address = shop.businessDetails!.address!;
                  if (shop.businessDetails?.pincode != null) {
                    address += ', ${shop.businessDetails!.pincode}';
                  }
                } else if (shop.businessInfo?.storeLocation?.address != null) {
                  address = shop.businessInfo!.storeLocation!.address!;
                }

                String distance = '0 km';
                final shopId = shop.id ?? index.toString();
                final shopCoords =
                    shop.businessInfo?.storeLocation?.coordinates;

                if (_distanceCache.containsKey(shopId)) {
                  distance = _distanceCache[shopId]!;
                } else if (userLat != null &&
                    userLng != null &&
                    shopCoords != null &&
                    shopCoords.length >= 2) {
                  final straightLineDistance = LocationUtils.calculateDistance(
                    userLat,
                    userLng,
                    shopCoords[1],
                    shopCoords[0],
                  );
                  distance = '${straightLineDistance.toStringAsFixed(1)} km';

                  LocationUtils.calculateRoadDistance(
                    fromLat: userLat,
                    fromLng: userLng,
                    toLat: shopCoords[1],
                    toLng: shopCoords[0],
                  ).then((roadDistance) {
                    if (mounted) {
                      setState(() {
                        _distanceCache[shopId] =
                            '${roadDistance.toStringAsFixed(1)} km';
                      });
                    }
                  });
                }

                return ShopGridCard(
                  category: shop.serviceCategories?.first ?? 'Other',
                  shopName:
                      shop.businessDetails?.businessName ?? 'Unnamed Shop',
                  address: address,
                  distance: distance,
                  rating: shop.businessInfo?.rating?.toString() ?? '0.0',
                  avatarColor: _getCategoryColor(type),
                  avatarIcon: _getCategoryIcon(type),
                  logoUrl: logo,
                  imageUrl: coverImage,
                  shop: shop,
                ).fadeSlideInFromBottom(delayMilliseconds: index * 50);
              },
            );
          },
          loading: () => GridView.builder(
            padding: EdgeInsets.all(screenSize.responsivePadding(16)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: screenSize.responsivePadding(16),
              crossAxisSpacing: screenSize.responsivePadding(16),
              childAspectRatio: aspectRatio,
            ),
            itemCount: 6,
            itemBuilder: (context, index) =>
                CardShimmers.shopCardShimmer(screenSize),
          ),
          error: (e, s) => const EmptyState(
            imagePath: 'assets/png/empty_shops.png',
            title: 'No shops found',
            subtitle:
                'We couldn\'t find any shops in your area. Try a different category or change your location.',
          ),
        ),
      ),
    );
  }
}
