import 'package:setgo/src/data/constants/color_constants.dart';
import 'package:setgo/src/data/providers/screen_size_provider.dart';
import 'package:setgo/src/data/models/shop_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../components/advanced_network_image.dart';
import '../../components/full_screen_gallery.dart';
import '../../components/shops/shop_header.dart';
import '../../components/shops/shop_about.dart';
import '../../components/shops/shop_gallery.dart';
import '../../components/shops/shop_address.dart';
import '../../components/shops/shop_reviews.dart';
import '../../components/shops/shop_socials.dart';
import '../../components/shops/shop_operating_hours.dart';
import '../../components/shops/shop_faqs.dart';
import '../../components/offers/deal_card.dart';
import '../../components/shops/product_card.dart';
import '../../components/services/service_card.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/models/service_model.dart';
import '../services/service_details_page.dart';

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

  void _openGallery({
    required List<String> images,
    required String? initialUrl,
  }) {
    if (images.isEmpty) return;
    final initialIndex = initialUrl != null
        ? images.indexOf(initialUrl).clamp(0, images.length - 1)
        : 0;
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FullScreenGallery(
            images: images,
            initialIndex: initialIndex,
          );
        },
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

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

    final allImages = <String>[];
    if (currentShop?.businessInfo?.coverImage != null &&
        currentShop!.businessInfo!.coverImage!.isNotEmpty) {
      allImages.add(currentShop.businessInfo!.coverImage!);
    }
    if (currentShop?.businessInfo?.businessImages != null) {
      for (final img in currentShop!.businessInfo!.businessImages!) {
        if (img.isNotEmpty && !allImages.contains(img)) {
          allImages.add(img);
        }
      }
    }

    final offersAsync = shopId.isNotEmpty
        ? ref.watch(shopOffersProvider(shopId))
        : null;
    final productsAsync = shopId.isNotEmpty
        ? ref.watch(shopProductsProvider(shopId))
        : null;
    // Shop id === partner id in mobile shops API; same source as getPartnerServicesPublic.
    final servicesAsync = shopId.isNotEmpty
        ? ref.watch(storeServicesProvider(shopId))
        : null;

    final category = currentShop?.serviceCategories?.isNotEmpty == true
        ? currentShop!.serviceCategories!.first
        : (currentShop?.businessDetails?.businessType ?? 'General');

    // Food / Restaurants / Cafes — same group as the home restaurant banner.
    final isFoodOrRestaurantShop = currentShop != null &&
        isShopInCategory(currentShop, 'Restaurants');
    final servicesSectionTitle =
        isFoodOrRestaurantShop ? 'Menu' : 'Explore Services';
    final servicesModalTitle =
        isFoodOrRestaurantShop ? 'Menu' : 'Explore Services';

    return Scaffold(
      backgroundColor: kWhite,
      body: fullShopAsync?.isLoading == true && widget.shop == null
          ? const Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenSize.responsivePadding(210),
            scrolledUnderElevation: 0,
            floating: false,
            pinned: true,
            backgroundColor: kWhite,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.85),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new,
                    color: Color(0xFF111827),
                    size: 16,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  GestureDetector(
                    onTap: allImages.isNotEmpty
                        ? () => _openGallery(
                              images: allImages,
                              initialUrl: heroImage,
                            )
                        : null,
                    child: heroImage != null
                        ? AdvancedNetworkImage(
                            imageUrl: heroImage,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            color: const Color(0xFFF3F4F6),
                            child: const Center(
                              child: Icon(
                                Icons.storefront_outlined,
                                size: 56,
                                color: Color(0xFF9CA3AF),
                              ),
                            ),
                          ),
                  ),
                  Positioned(
                    top: MediaQuery.paddingOf(context).top + 10,
                    right: 16,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(10),
                        vertical: screenSize.responsivePadding(5),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.75),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF292929),
                        ),
                      ),
                    ),
                  ),
                ],
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
                      images: currentShop.businessInfo!.businessImages!,
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
                  SizedBox(height: screenSize.responsivePadding(24)),
                  ShopOperatingHours(
                    operatingHours: _selectedBranch?.operatingHours ??
                        currentShop?.businessInfo?.operatingHours,
                  ),
                  if ((_selectedBranch?.operatingHours ??
                          currentShop?.businessInfo?.operatingHours) !=
                      null)
                    SizedBox(height: screenSize.responsivePadding(24)),
                  if (currentShop?.businessInfo?.faqs?.isNotEmpty == true) ...[
                    ShopFaqs(faqs: currentShop?.businessInfo?.faqs),
                    SizedBox(height: screenSize.responsivePadding(24)),
                  ],
                  if (offersAsync != null)
                    offersAsync.when(
                      data: (offers) {
                        if (offers.isEmpty) return const SizedBox.shrink();
                        final displayOffers = offers.take(5).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Offers',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                if (offers.length > 2)
                                  GestureDetector(
                                    onTap: () {
                                      _showAllOffersModal(context, offers, screenSize);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'View All',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF07982C),
                                          ),
                                        ),
                                        SizedBox(width: screenSize.responsivePadding(2)),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16,
                                          color: Color(0xFF07982C),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: screenSize.responsivePadding(12)),
                            SizedBox(
                              height: screenSize.responsivePadding(195),
                              child: ListView.separated(
                                clipBehavior: Clip.none,
                                scrollDirection: Axis.horizontal,
                                itemCount: displayOffers.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: screenSize.responsivePadding(12)),
                                itemBuilder: (context, index) {
                                  return SizedBox(
                                    width: screenSize.responsivePadding(190),
                                    child: DealCard.fromOffer(
                                      displayOffers[index],
                                      margin: EdgeInsets.zero,
                                      hideShopName: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: screenSize.responsivePadding(24)),
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
                        final displayProducts = products.take(5).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Explore Products',
                                  style: TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                if (products.length > 2)
                                  GestureDetector(
                                    onTap: () {
                                      _showAllProductsModal(context, products, screenSize);
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'View All',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF07982C),
                                          ),
                                        ),
                                        SizedBox(width: screenSize.responsivePadding(2)),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16,
                                          color: Color(0xFF07982C),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: screenSize.responsivePadding(12)),
                            SizedBox(
                              height: screenSize.responsivePadding(225),
                              child: ListView.separated(
                                clipBehavior: Clip.none,
                                scrollDirection: Axis.horizontal,
                                itemCount: displayProducts.length,
                                separatorBuilder: (context, index) =>
                                    SizedBox(width: screenSize.responsivePadding(12)),
                                itemBuilder: (context, index) {
                                  final product = displayProducts[index];
                                  return SizedBox(
                                    width: screenSize.responsivePadding(180),
                                    child: ProductCard(
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
                                      hideShopInfo: true,
                                    ),
                                  );
                                },
                              ),
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
                  if (servicesAsync != null)
                    servicesAsync.when(
                      data: (services) {
                        if (services.isEmpty) return const SizedBox.shrink();
                        final displayServices = services.take(5).toList();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  servicesSectionTitle,
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF111827),
                                  ),
                                ),
                                if (services.length > 2)
                                  GestureDetector(
                                    onTap: () {
                                      _showAllServicesModal(
                                        context,
                                        services,
                                        screenSize,
                                        title: servicesModalTitle,
                                      );
                                    },
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text(
                                          'View All',
                                          style: TextStyle(
                                            fontFamily: 'Montserrat',
                                            fontSize: 12,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF07982C),
                                          ),
                                        ),
                                        SizedBox(
                                          width: screenSize.responsivePadding(2),
                                        ),
                                        const Icon(
                                          Icons.chevron_right_rounded,
                                          size: 16,
                                          color: Color(0xFF07982C),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                            SizedBox(height: screenSize.responsivePadding(12)),
                            SizedBox(
                              height: screenSize.responsivePadding(225),
                              child: ListView.separated(
                                clipBehavior: Clip.none,
                                scrollDirection: Axis.horizontal,
                                itemCount: displayServices.length,
                                separatorBuilder: (context, index) => SizedBox(
                                  width: screenSize.responsivePadding(12),
                                ),
                                itemBuilder: (context, index) {
                                  final service = displayServices[index];
                                  return SizedBox(
                                    width: screenSize.responsivePadding(180),
                                    child: ServiceCard(
                                      service: service,
                                      hideShopInfo: true,
                                    ),
                                  );
                                },
                              ),
                            ),
                            SizedBox(height: screenSize.responsivePadding(32)),
                          ],
                        );
                      },
                      loading: () => Padding(
                        padding: EdgeInsets.only(
                          bottom: screenSize.responsivePadding(24),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: kPrimaryColor),
                        ),
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

  void _showAllOffersModal(BuildContext context, List<dynamic> offers, ScreenSizeData screenSize) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final crossAxisCount = screenSize.isTablet ? 3 : 2;
        final totalPadding =
            screenSize.responsivePadding(32) +
            screenSize.responsivePadding(12 * (crossAxisCount - 1));
        final offerItemWidth = (screenSize.width - totalPadding) / crossAxisCount;
        final offerItemHeight = screenSize.responsivePadding(175);
        final offerAspectRatio = offerItemWidth / offerItemHeight;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
                vertical: screenSize.responsivePadding(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Offers (${offers.length})',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF3F4F6)),
                  Expanded(
                    child: GridView.builder(
                      controller: controller,
                      padding: EdgeInsets.symmetric(
                        vertical: screenSize.responsivePadding(12),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: offerAspectRatio,
                        crossAxisSpacing: screenSize.responsivePadding(12),
                        mainAxisSpacing: screenSize.responsivePadding(12),
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
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAllProductsModal(BuildContext context, List<dynamic> products, ScreenSizeData screenSize) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final crossAxisCount = screenSize.isTablet ? 3 : 2;
        final totalPadding =
            screenSize.responsivePadding(32) +
            screenSize.responsivePadding(12 * (crossAxisCount - 1));
        final productItemWidth = (screenSize.width - totalPadding) / crossAxisCount;
        final productItemHeight = screenSize.responsivePadding(220);
        final productAspectRatio = productItemWidth / productItemHeight;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
                vertical: screenSize.responsivePadding(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'All Products (${products.length})',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF3F4F6)),
                  Expanded(
                    child: GridView.builder(
                      controller: controller,
                      padding: EdgeInsets.symmetric(
                        vertical: screenSize.responsivePadding(12),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: productAspectRatio,
                        crossAxisSpacing: screenSize.responsivePadding(12),
                        mainAxisSpacing: screenSize.responsivePadding(12),
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
                          price: '₹${product.price?.toStringAsFixed(2) ?? "0.0"}',
                          tags: product.tags,
                          rawProduct: product,
                          hideShopInfo: true,
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showAllServicesModal(
    BuildContext context,
    List<ServiceModel> services,
    ScreenSizeData screenSize, {
    String title = 'All Services',
  }) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final crossAxisCount = screenSize.isTablet ? 3 : 2;
        final totalPadding =
            screenSize.responsivePadding(32) +
            screenSize.responsivePadding(12 * (crossAxisCount - 1));
        final itemWidth = (screenSize.width - totalPadding) / crossAxisCount;
        final itemHeight = screenSize.responsivePadding(220);
        final aspectRatio = itemWidth / itemHeight;

        return DraggableScrollableSheet(
          initialChildSize: 0.85,
          maxChildSize: 0.95,
          minChildSize: 0.5,
          builder: (_, controller) {
            return Container(
              decoration: const BoxDecoration(
                color: kWhite,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
                vertical: screenSize.responsivePadding(12),
              ),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$title (${services.length})',
                        style: const TextStyle(
                          fontFamily: 'Montserrat',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, size: 20),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(color: Color(0xFFF3F4F6)),
                  Expanded(
                    child: GridView.builder(
                      controller: controller,
                      padding: EdgeInsets.symmetric(
                        vertical: screenSize.responsivePadding(12),
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: aspectRatio,
                        crossAxisSpacing: screenSize.responsivePadding(12),
                        mainAxisSpacing: screenSize.responsivePadding(12),
                      ),
                      itemCount: services.length,
                      itemBuilder: (context, index) {
                        return ServiceCard(
                          service: services[index],
                          hideShopInfo: true,
                          onTap: () {
                            Navigator.pop(ctx);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ServiceDetailsPage(
                                  service: services[index],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
