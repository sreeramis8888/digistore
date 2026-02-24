import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../components/advanced_network_image.dart';
import '../components/shops/shop_header.dart';
import '../components/shops/shop_branches.dart';
import '../components/shops/shop_about.dart';
import '../components/shops/shop_gallery.dart';
import '../components/shops/shop_address.dart';
import '../components/shops/shop_reviews.dart';
import '../components/shops/shop_socials.dart';
import '../components/shops/shop_offer_card.dart';
import '../components/shops/shop_product_card.dart';

class ShopDetailPage extends ConsumerWidget {
  final String shopName;

  const ShopDetailPage({super.key, required this.shopName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    return Scaffold(
      backgroundColor: kWhite,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenSize.responsivePadding(200),
            floating: false,
            pinned: true,
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
                  top: kToolbarHeight + screenSize.responsivePadding(20),
                ),
                child: const AdvancedNetworkImage(
                  imageUrl:
                      'https://images.unsplash.com/photo-1555396273-367dd4bc4b27?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
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
                  ShopHeader(shopName: shopName),
                  SizedBox(height: screenSize.responsivePadding(16)),
                  const ShopBranches(),
                  SizedBox(height: screenSize.responsivePadding(16)),
                  const ShopAbout(),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  const ShopGallery(),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  const ShopAddress(),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  const ShopReviews(),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  const ShopSocials(),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  Text('Offers', style: kBodyTitleM),
                  SizedBox(height: screenSize.responsivePadding(12)),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: screenSize.responsivePadding(12),
                crossAxisSpacing: screenSize.responsivePadding(12),
                childAspectRatio: 0.8,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => const ShopOfferCard(),
                childCount: 2,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                screenSize.responsivePadding(16),
                screenSize.responsivePadding(24),
                screenSize.responsivePadding(16),
                screenSize.responsivePadding(12),
              ),
              child: Text('Explore Products', style: kBodyTitleM),
            ),
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            sliver: SliverGrid(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: screenSize.responsivePadding(12),
                crossAxisSpacing: screenSize.responsivePadding(12),
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => const ShopProductCard(),
                childCount: 16,
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: screenSize.responsivePadding(32)),
          ),
        ],
      ),
    );
  }
}
