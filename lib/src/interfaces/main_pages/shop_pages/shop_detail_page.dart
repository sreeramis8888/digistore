import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:digistore/src/data/models/shop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/advanced_network_image.dart';
import '../../components/shops/shop_header.dart';
import '../../components/shops/shop_about.dart';
import '../../components/shops/shop_gallery.dart';
import '../../components/shops/shop_address.dart';
import '../../components/shops/shop_reviews.dart';
import '../../components/shops/shop_socials.dart';

class ShopDetailPage extends ConsumerWidget {
  final String? shopName;
  final ShopModel? shop;

  const ShopDetailPage({super.key, this.shopName, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final currentShopName = shop?.businessDetails?.businessName ?? shopName ?? 'Unknown Shop';

    final fallbackImages = const [
      'assets/png/swinging_spoon.png',
      'assets/png/good.png',
      'assets/png/chill_bite.png',
      'assets/png/vibe.png',
    ];
    
    final heroImage = shop?.businessInfo?.businessLogo ?? 
        (shop?.businessInfo?.businessImages?.isNotEmpty == true 
            ? shop!.businessInfo!.businessImages!.first 
            : fallbackImages[currentShopName.hashCode.abs() % fallbackImages.length]);

    return Scaffold(
      backgroundColor: kWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenSize.responsivePadding(260),
            scrolledUnderElevation: 0,
            floating: false,
            pinned: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: kTextColor,
                size: 20,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            title: Text(
              'Shop Detail',
              style: kBodyTitleM.copyWith(color: kTextColor),
            ),
            backgroundColor: kWhite,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                margin: EdgeInsets.only(
                  top: MediaQuery.paddingOf(context).top + kToolbarHeight,
                ),
                child: AdvancedNetworkImage(
                  imageUrl: heroImage,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShopHeader(shopName: currentShopName, shop: shop),
                  SizedBox(height: screenSize.responsivePadding(16)),
                  ShopAbout(shop: shop),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  if (shop?.businessInfo?.businessImages != null && shop!.businessInfo!.businessImages!.length > 1) ...[
                    ShopGallery(images: shop!.businessInfo!.businessImages!),
                    SizedBox(height: screenSize.responsivePadding(20)),
                  ],
                  ShopAddress(shop: shop),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  ShopReviews(shop: shop),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  ShopSocials(shop: shop),
                  SizedBox(height: screenSize.responsivePadding(32)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
