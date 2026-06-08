import 'dart:async';
import 'package:setgo/src/interfaces/components/shimmers/card_shimmers.dart';
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
import '../components/loading_indicator.dart';

class ShopsPage extends ConsumerStatefulWidget {
  const ShopsPage({super.key});

  @override
  ConsumerState<ShopsPage> createState() => _ShopsPageState();
}

class _ShopsPageState extends ConsumerState<ShopsPage> {
  final Map<String, Map<String, dynamic>> _distanceCache = {};
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void deactivate() {
    // Clear search state when leaving the page — ref is still safe here
    ref.read(shopsProvider.notifier).updateSearch('');
    ref.read(allShopsProvider.notifier).updateSearch('');
    super.deactivate();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(shopsProvider.notifier).updateSearch(query);
      ref.read(allShopsProvider.notifier).updateSearch(query);
    });
  }

  void _onScroll() {
    final exploreState = ref.read(allShopsProvider);

    // Don't trigger if already loading or no more pages
    if (exploreState.isLoadingMore) return;
    if (exploreState.pagination == null) return;
    if (exploreState.pagination!.page >= exploreState.pagination!.pages) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(allShopsProvider.notifier).loadMore();
    }
  }

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

  Widget _buildShopCard(
    ShopModel shop,
    int index,
    double? userLat,
    double? userLng,
    screenSize,
  ) {
    final type = shop.businessDetails?.businessType;
    final coverImage =
        shop.businessInfo?.coverImage ??
        (shop.businessInfo?.businessLogo != null
            ? shop.businessInfo!.businessLogo!
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
    final shopCoords = shop.businessInfo?.storeLocation?.coordinates;

    final cachedData = _distanceCache[shopId];
    if (cachedData != null) {
      distance = cachedData['distance'] as String;
    } else if (userLat != null &&
        userLng != null &&
        shopCoords != null &&
        shopCoords.length >= 2) {
      final initialDistance = shop.distance ?? LocationUtils.calculateDistance(
        userLat,
        userLng,
        shopCoords[1],
        shopCoords[0],
      );
      distance = '${initialDistance.toStringAsFixed(1)} km';

      LocationUtils.calculateRoadDistanceAndDuration(
        fromLat: userLat,
        fromLng: userLng,
        toLat: shopCoords[1],
        toLng: shopCoords[0],
      ).then((result) {
        if (mounted && result != null) {
          setState(() {
            _distanceCache[shopId] = {
              'distance': '${result['distance']!.toStringAsFixed(1)} km',
              'duration': result['duration'],
            };
          });
        }
      });
    } else if (shop.distance != null) {
      distance = '${shop.distance!.toStringAsFixed(1)} km';
    }

    final passingShop = shop.copyWith(
      roadDistance: cachedData?['distance'] != null
          ? (cachedData!['distance'] as String).replaceAll(' km', '')
          : null,
      roadDuration: cachedData?['duration'] as double?,
    );

    return ShopGridCard(
      category: shop.serviceCategories?.first ?? 'Other',
      shopName: shop.businessDetails?.businessName ?? 'Unnamed Shop',
      address: address,
      distance: distance,
      rating: shop.businessInfo?.rating?.toString() ?? '0.0',
      avatarColor: _getCategoryColor(type),
      avatarIcon: _getCategoryIcon(type),
      logoUrl: coverImage,
      imageUrl: coverImage,
      shop: passingShop,
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(230);
    final aspectRatio = itemWidth / itemHeight;

    final nearbyState = ref.watch(shopsProvider);
    final exploreState = ref.watch(allShopsProvider);
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
        child: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () async {
            ref.read(shopsProvider.notifier).refresh();
            await ref.read(allShopsProvider.notifier).refresh();
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    screenSize.responsivePadding(16),
                    screenSize.responsivePadding(16),
                    screenSize.responsivePadding(16),
                    screenSize.responsivePadding(8),
                  ),
                  child: Container(
                    height: screenSize.responsivePadding(54),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(20),
                    ),
                    decoration: BoxDecoration(
                      color: kField,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search,
                          color: Color(0xFF7D848D),
                          size: 24,
                        ),
                        SizedBox(width: screenSize.responsivePadding(12)),
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            onTapOutside: (event) => _searchFocusNode.unfocus(),
                            onChanged: _onSearchChanged,
                            style: kSmallerTitleL.copyWith(color: kBlack),
                            decoration: InputDecoration(
                              hintText: "Search for 'shops'",
                              hintStyle: kSmallerTitleL.copyWith(
                                color: kBlack.withOpacity(.5),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _sectionHeader('Shops Nearby', screenSize),
              ),
              if (nearbyState.isLoading)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(16),
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => CardShimmers.shopCardShimmer(screenSize),
                      childCount: 4,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: screenSize.responsivePadding(16),
                      crossAxisSpacing: screenSize.responsivePadding(16),
                      childAspectRatio: aspectRatio,
                    ),
                  ),
                )
              else if (nearbyState.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(16),
                      vertical: screenSize.responsivePadding(8),
                    ),
                    child: Text(
                      'No nearby shops.',
                      style: kSmallerTitleL.copyWith(
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ),
                )
              else if (nearbyState.shops.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(16),
                      vertical: screenSize.responsivePadding(8),
                    ),
                    child: Text(
                      'No shops found near your location.',
                      style: kSmallerTitleL.copyWith(
                        color: kSecondaryTextColor,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(16),
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, index) => _buildShopCard(
                        nearbyState.shops[index],
                        index,
                        userLat,
                        userLng,
                        screenSize,
                      ),
                      childCount: nearbyState.shops.length,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: screenSize.responsivePadding(16),
                      crossAxisSpacing: screenSize.responsivePadding(16),
                      childAspectRatio: aspectRatio,
                    ),
                  ),
                ),

              SliverToBoxAdapter(
                child: SizedBox(height: screenSize.responsivePadding(24)),
              ),
              SliverToBoxAdapter(
                child: _sectionHeader('Explore More Shops', screenSize),
              ),
              if (exploreState.isLoading)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(16),
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (_, __) => CardShimmers.shopCardShimmer(screenSize),
                      childCount: 4,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: screenSize.responsivePadding(16),
                      crossAxisSpacing: screenSize.responsivePadding(16),
                      childAspectRatio: aspectRatio,
                    ),
                  ),
                )
              else if (exploreState.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.responsivePadding(32)),
                    child: Center(
                      child: Text(
                        'No more shops to explore.',
                        style: kSmallerTitleL.copyWith(
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                () {
                  final nearbyIds = nearbyState.shops.map((s) => s.id).toSet();
                  final exploreShops = exploreState.shops
                      .where((s) => !nearbyIds.contains(s.id))
                      .toList();

                  if (exploreShops.isEmpty) {
                    return SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(
                          screenSize.responsivePadding(32),
                        ),
                        child: Center(
                          child: Text(
                            'No more shops to explore.',
                            style: kSmallerTitleL.copyWith(
                              color: kSecondaryTextColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }

                  return SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(16),
                    ),
                    sliver: SliverGrid(
                      delegate: SliverChildBuilderDelegate(
                        (_, index) => _buildShopCard(
                          exploreShops[index],
                          index,
                          userLat,
                          userLng,
                          screenSize,
                        ),
                        childCount: exploreShops.length,
                      ),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        mainAxisSpacing: screenSize.responsivePadding(16),
                        crossAxisSpacing: screenSize.responsivePadding(16),
                        childAspectRatio: aspectRatio,
                      ),
                    ),
                  );
                }(),
                if (exploreState.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                      child: const Center(
                        child: LoadingAnimation(loadingColor: kPrimaryColor),
                      ),
                    ),
                  ),
              ],

              SliverToBoxAdapter(
                child: SizedBox(height: screenSize.responsivePadding(24)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, screenSize) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenSize.responsivePadding(16.0),
        screenSize.responsivePadding(8.0),
        screenSize.responsivePadding(16.0),
        screenSize.responsivePadding(12.0),
      ),
      child: Text(
        title,
        style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
      ),
    );
  }
}
