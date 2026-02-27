import 'package:digistore/src/data/constants/color_constants.dart';
import 'package:digistore/src/data/constants/style_constants.dart';
import 'package:digistore/src/data/providers/screen_size_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/advanced_network_image.dart';
import '../../components/shops/shop_header.dart';
import '../../components/shops/shop_branches.dart';
import '../../components/shops/shop_about.dart';
import '../../components/shops/shop_gallery.dart';
import '../../components/shops/shop_address.dart';
import '../../components/shops/shop_reviews.dart';
import '../../components/shops/shop_socials.dart';
import '../../components/offers/deal_card.dart';
import '../../components/shops/shop_product_card.dart';

class ShopDetailPage extends ConsumerWidget {
  final String shopName;

  const ShopDetailPage({super.key, required this.shopName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(44)) / 2;
    final offersAspectRatio = itemWidth / screenSize.responsivePadding(230);
    final productsAspectRatio = itemWidth / screenSize.responsivePadding(220);

    final explicitImages = const {
      'Chill Bite': 'assets/png/chill_bite.png',
      'Vibe': 'assets/png/vibe.png',
      'Swingin Spoon': 'assets/png/swinging_spoon.png',
      'GOOD': 'assets/png/good.png',
    };
    final fallbackImages = const [
      'assets/png/swinging_spoon.png',
      'assets/png/good.png',
      'assets/png/chill_bite.png',
      'assets/png/vibe.png',
    ];
    final heroImage = explicitImages[shopName] ?? fallbackImages[shopName.hashCode.abs() % fallbackImages.length];

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
                childAspectRatio: offersAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => DealCard(
                  title: 'Valentines Day Deal',
                  subtitle: 'Buy one get one free',
                  shopName: shopName,
                  badgeText: '50% OFF',
                  avatarColor: kPrimaryColor,
                  dealOfTheHour: 'Deal of the day',
                ),
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
                childAspectRatio: productsAspectRatio,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ShopProductCard(index: index),
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
