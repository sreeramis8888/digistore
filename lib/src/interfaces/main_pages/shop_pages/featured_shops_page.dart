import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/models/shop_model.dart';
import '../../components/shops/featured_shop_card.dart';
import '../../components/loading_indicator.dart';
import '../../../data/providers/banners_provider.dart';
import '../../components/common/paginated_banner_grid.dart';
import '../../components/shimmers/card_shimmers.dart';

class FeaturedShopsPage extends ConsumerStatefulWidget {
  const FeaturedShopsPage({super.key});

  @override
  ConsumerState<FeaturedShopsPage> createState() => _FeaturedShopsPageState();
}

class _FeaturedShopsPageState extends ConsumerState<FeaturedShopsPage> {
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
      ref.read(featuredShopsProvider.notifier).updateSearch(query);
    });
  }

  void _onScroll() {
    final exploreState = ref.read(featuredShopsProvider);

    if (exploreState.isLoadingMore) return;
    if (exploreState.pagination == null) return;
    if (exploreState.pagination!.page >= exploreState.pagination!.pages) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(featuredShopsProvider.notifier).loadMore();
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



  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final crossAxisCount = 4;
    final itemWidth = (screenSize.width - screenSize.responsivePadding(32) - (screenSize.responsivePadding(16) * (crossAxisCount - 1))) / crossAxisCount;
    final itemHeight = itemWidth + screenSize.responsivePadding(50);
    final aspectRatio = itemWidth / itemHeight;

    final featuredState = ref.watch(featuredShopsProvider);
    final bannersAsync = ref.watch(
      bannersProvider(const BannerFilter(page: 'shops')),
    );
    final banners = bannersAsync.value ?? [];

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'Featured Shops',
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
            await ref.read(featuredShopsProvider.notifier).refresh();
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
                              hintText: "Search for 'featured shops'",
                              hintStyle: kSmallerTitleL.copyWith(
                                color: kBlack.withValues(alpha: .5),
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
              if (featuredState.isLoading)
                SliverPadding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenSize.responsivePadding(16),
                  ),
                  sliver: SliverGrid(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => CardShimmers.shopCardShimmer(screenSize),
                      childCount: 6,
                    ),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: screenSize.responsivePadding(16),
                      crossAxisSpacing: screenSize.responsivePadding(16),
                      childAspectRatio: aspectRatio,
                    ),
                  ),
                )
              else if (featuredState.error != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.responsivePadding(32)),
                    child: Center(
                      child: Text(
                        'Failed to load featured shops.',
                        style: kSmallerTitleL.copyWith(
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                )
              else if (featuredState.shops.isEmpty)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(screenSize.responsivePadding(32)),
                    child: Center(
                      child: Text(
                        'No featured shops found.',
                        style: kSmallerTitleL.copyWith(
                          color: kSecondaryTextColor,
                        ),
                      ),
                    ),
                  ),
                )
              else ...[
                SliverMainAxisGroup(
                  slivers: buildPaginatedGridSliversWithBanners(
                    items: featuredState.shops,
                    itemBuilder: (_, index, shop) => Align(
                      alignment: Alignment.topCenter,
                      child: FeaturedShopCard(shop: shop),
                    ),
                    banners: banners,
                    hasMore:
                        featuredState.pagination != null &&
                        featuredState.pagination!.page <
                            featuredState.pagination!.pages,
                    screenSize: screenSize,
                    childAspectRatio: aspectRatio,
                    crossAxisCount: crossAxisCount,
                  ),
                ),
                if (featuredState.isLoadingMore)
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
}
