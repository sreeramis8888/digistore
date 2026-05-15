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
import '../../components/offers/deal_card.dart';
import '../../components/shops/product_card.dart';
import '../../../data/providers/shops_provider.dart';

class ShopDetailPage extends ConsumerWidget {
  final String? shopName;
  final ShopModel? shop;

  const ShopDetailPage({super.key, this.shopName, this.shop});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final currentShopName =
        shop?.businessDetails?.businessName ?? shopName ?? 'Unknown Shop';
    final heroImage =
        shop?.businessInfo?.coverImage ??
        (shop?.businessInfo?.businessImages?.isNotEmpty == true
            ? shop!.businessInfo!.businessImages!.first
            : null);
    final shopId = shop?.id ?? '';
    final offersAsync = shopId.isNotEmpty ? ref.watch(shopOffersProvider(shopId)) : null;
    final productsAsync = shopId.isNotEmpty ? ref.watch(shopProductsProvider(shopId)) : null;

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
                child: heroImage != null
                    ? AdvancedNetworkImage(
                        imageUrl: heroImage,
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: const Color(0xFFF0F0F0),
                        child: const Center(
                          child: Icon(
                            Icons.store,
                            size: 64,
                            color: Color(0xFFCCCCCC),
                          ),
                        ),
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
                  if (shop?.businessInfo?.businessImages != null &&
                      shop!.businessInfo!.businessImages!.length > 1) ...[
                    ShopGallery(images: shop!.businessInfo!.businessImages!),
                    SizedBox(height: screenSize.responsivePadding(20)),
                  ],
                  ShopAddress(shop: shop),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  ShopReviews(shop: shop),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  ShopSocials(shop: shop),
                  SizedBox(height: screenSize.responsivePadding(32)),
                  if (offersAsync != null)
                    offersAsync.when(
                      data: (offers) {
                        if (offers.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Offers', style: kBodyTitleM),
                            SizedBox(height: screenSize.responsivePadding(16)),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: screenSize.responsivePadding(12),
                                mainAxisSpacing: screenSize.responsivePadding(12),
                              ),
                              itemCount: offers.length,
                              itemBuilder: (context, index) {
                                return DealCard.fromOffer(
                                  offers[index],
                                  margin: EdgeInsets.zero,
                                );
                              },
                            ),
                            SizedBox(height: screenSize.responsivePadding(32)),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
                      error: (e, s) => const SizedBox.shrink(),
                    ),
                  if (productsAsync != null)
                    productsAsync.when(
                      data: (products) {
                        if (products.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Products', style: kBodyTitleM),
                            SizedBox(height: screenSize.responsivePadding(16)),
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.zero,
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                childAspectRatio: 0.75,
                                crossAxisSpacing: screenSize.responsivePadding(12),
                                mainAxisSpacing: screenSize.responsivePadding(12),
                              ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ProductCard(
                                  index: index,
                                  name: product.title,
                                  image: product.images?.isNotEmpty == true ? product.images!.first : null,
                                  description: product.description,
                                  price: '₹${product.price?.toStringAsFixed(2) ?? "0.0"}',
                                  tags: product.tags,
                                  rawProduct: product,
                                );
                              },
                            ),
                            SizedBox(height: screenSize.responsivePadding(32)),
                          ],
                        );
                      },
                      loading: () => const Center(child: CircularProgressIndicator(color: kPrimaryColor)),
                      error: (e, s) => const SizedBox.shrink(),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
