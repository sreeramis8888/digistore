import 'package:setgo/src/data/constants/color_constants.dart';
import 'package:setgo/src/data/constants/style_constants.dart';
import 'package:setgo/src/data/providers/screen_size_provider.dart';
import 'package:setgo/src/data/models/shop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/advanced_network_image.dart';
import '../../components/shops/shop_header.dart';
import '../../components/shops/shop_about.dart';
import '../../components/shops/shop_gallery.dart';
import '../../components/shops/shop_address.dart';
import '../../components/shops/shop_reviews.dart';
import '../../components/shops/shop_socials.dart';
import '../../components/shops/shop_operating_hours.dart';
import '../../components/offers/deal_card.dart';
import '../../components/shops/product_card.dart';
import '../../../data/providers/shops_provider.dart';

import '../../components/shops/shop_branches.dart';
import '../../../../src/data/models/business_info.dart';
import '../../../data/providers/branches.dart';

class ShopDetailPage extends ConsumerStatefulWidget {
  final String? shopName;
  final ShopModel? shop;

  const ShopDetailPage({super.key, this.shopName, this.shop});

  @override
  ConsumerState<ShopDetailPage> createState() => _ShopDetailPageState();
}

class _ShopDetailPageState extends ConsumerState<ShopDetailPage> {
  BusinessBranch? _selectedBranch;

  @override
  void didUpdateWidget(ShopDetailPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.shop?.id != widget.shop?.id) {
      _selectedBranch = null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final shopId = widget.shop?.id ?? '';

    // Listen to branches provider to set the initial selected branch to the primary one
    if (shopId.isNotEmpty) {
      ref.listen<AsyncValue<List<BusinessBranch>>>(
        shopBranchesProvider(shopId),
        (previous, next) {
          if (next.hasValue && _selectedBranch == null) {
            final list = next.value ?? [];
            if (list.isNotEmpty) {
              final primary = list.firstWhere(
                (b) => b.isPrimary == true,
                orElse: () => list.first,
              );
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) {
                  setState(() {
                    _selectedBranch = primary;
                  });
                }
              });
            }
          }
        },
      );
    }
    // Featured shops return a minimal payload (no address, no branches, no contact info)
    // Full shops return complete nested objects.
    final needsFetch = widget.shop == null ||
        (widget.shop!.businessDetails?.address == null &&
         widget.shop!.businessInfo?.contactPhone == null &&
         (widget.shop!.businessInfo?.branches == null || widget.shop!.businessInfo!.branches!.isEmpty));

    final fullShopAsync = (shopId.isNotEmpty && needsFetch)
        ? ref.watch(getShopByPartnerIdProvider(shopId))
        : null;
    final currentShop = fullShopAsync?.value ?? widget.shop;

    final currentShopName =
        currentShop?.businessDetails?.businessName ??
        widget.shopName ??
        'Unknown Shop';
    final heroImage =
        currentShop?.businessInfo?.coverImage ??
        (currentShop?.businessInfo?.businessImages?.isNotEmpty == true
            ? currentShop!.businessInfo!.businessImages!.first
            : null);
    final offersAsync = shopId.isNotEmpty
        ? ref.watch(shopOffersProvider(shopId))
        : null;
    final productsAsync = shopId.isNotEmpty
        ? ref.watch(shopProductsProvider(shopId))
        : null;

    final crossAxisCount = screenSize.isTablet ? 3 : 2;
    final totalPadding =
        screenSize.responsivePadding(32) +
        screenSize.responsivePadding(12 * (crossAxisCount - 1));

    final offerItemWidth = (screenSize.width - totalPadding) / crossAxisCount;
    final offerItemHeight = screenSize.responsivePadding(200);
    final offerAspectRatio = offerItemWidth / offerItemHeight;

    final productItemWidth = (screenSize.width - totalPadding) / crossAxisCount;
    final productItemHeight = screenSize.responsivePadding(220);
    final productAspectRatio = productItemWidth / productItemHeight;

    return Scaffold(
      backgroundColor: kWhite,
      body: fullShopAsync?.isLoading == true && widget.shop == null
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: MediaQuery.of(context).orientation == Orientation.landscape
                ? MediaQuery.of(context).size.height * 0.5
                : screenSize.responsivePadding(260),
            scrolledUnderElevation: 0,
            floating: false,titleSpacing: 0,
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
                  ShopHeader(
                    shopName: currentShopName,
                    shop: currentShop,
                    selectedBranch: _selectedBranch,
                  ),
                  SizedBox(height: screenSize.responsivePadding(16)),
                  ShopBranches(
                    shopId: shopId,
                    selectedBranch: _selectedBranch,
                    onBranchSelected: (branch) {
                      setState(() {
                        _selectedBranch = branch;
                      });
                    },
                  ),
                  ShopAbout(shop: currentShop),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  if (currentShop?.businessInfo?.businessImages != null &&
                      currentShop!.businessInfo!.businessImages!.length >
                          1) ...[
                    ShopGallery(
                      images: currentShop!.businessInfo!.businessImages!,
                    ),
                    SizedBox(height: screenSize.responsivePadding(20)),
                  ],
                  ShopAddress(
                    shop: currentShop,
                    selectedBranch: _selectedBranch,
                  ),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  ShopReviews(shop: currentShop),
                  SizedBox(height: screenSize.responsivePadding(20)),
                  ShopSocials(shop: currentShop),
                  SizedBox(height: screenSize.responsivePadding(32)),
                  ShopOperatingHours(
                    operatingHours: _selectedBranch?.operatingHours ??
                        currentShop?.businessInfo?.operatingHours,
                  ),
                  if ((_selectedBranch?.operatingHours ??
                          currentShop?.businessInfo?.operatingHours) !=
                      null)
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
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: offerAspectRatio,
                                    crossAxisSpacing: screenSize
                                        .responsivePadding(12),
                                    mainAxisSpacing: screenSize
                                        .responsivePadding(12),
                                  ),
                              itemCount: offers.length,
                              itemBuilder: (context, index) {
                                return DealCard.fromOffer(
                                  offers[index],
                                  margin: EdgeInsets.zero,
                                  hideShopName: true,
                                );
                              },
                            ),
                            SizedBox(height: screenSize.responsivePadding(32)),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      ),
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
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    childAspectRatio: productAspectRatio,
                                    crossAxisSpacing: screenSize
                                        .responsivePadding(12),
                                    mainAxisSpacing: screenSize
                                        .responsivePadding(12),
                                  ),
                              itemCount: products.length,
                              itemBuilder: (context, index) {
                                final product = products[index];
                                return ProductCard(
                                  index: index,
                                  name: product.title,
                                  image: product.images?.isNotEmpty == true
                                      ? product.images!.first
                                      : null,
                                  description: product.description,
                                  price:
                                      '₹${product.price?.toStringAsFixed(2) ?? "0.0"}',
                                  tags: product.tags,
                                  rawProduct: product,
                                );
                              },
                            ),
                            SizedBox(height: screenSize.responsivePadding(32)),
                          ],
                        );
                      },
                      loading: () => const Center(
                        child: CircularProgressIndicator(color: kPrimaryColor),
                      ),
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
