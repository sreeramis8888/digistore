import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/models/banner_model.dart';
import '../../data/providers/banners_provider.dart';
import '../../data/providers/category_provider.dart';
import '../../data/providers/partner_products_provider.dart';
import '../../data/providers/partner_services_provider.dart';
import '../../data/providers/screen_size_provider.dart';
import '../../data/providers/services_provider.dart';
import '../../data/providers/user_type_provider.dart';
import '../../data/router/nav_router.dart';
import '../../data/utils/global_variables.dart';
import '../../data/utils/interactive_feedback_button.dart';
import '../components/common/paginated_banner_grid.dart';
import '../components/loading_indicator.dart';
import '../components/products/products_filter_chips.dart';
import '../components/products/products_services_segmented_tabs.dart';
import '../components/services/service_card.dart';
import '../components/services/services_filter_chips.dart';
import '../components/shimmers/card_shimmers.dart';
import '../components/shops/product_card.dart';
import 'partner/create_product.dart';
import 'partner/create_service.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() => _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final ScrollController _scrollController = ScrollController();
  int _lastFetchedCategoryIndex = -1;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      final selectedTab = ref.read(selectedProductsTabProvider);
      if (selectedTab == 0) {
        ref.read(partnerProductsProvider.notifier).loadMore();
      } else {
        ref.read(servicesListProvider.notifier).loadMore();
      }
    }
  }

  void _fetchProducts({int? index}) {
    final int currentIndex =
        index ?? ref.read(selectedProductsCategoryProvider);
    final categoriesAsync = ref.read(categoriesProvider);
    String? categoryId;

    if (categoriesAsync.hasValue) {
      final categories = categoriesAsync.value!;
      if (currentIndex > 0 && currentIndex <= categories.length) {
        categoryId = categories[currentIndex - 1].id;
      } else if (currentIndex == 0) {
        categoryId = 'All';
      }
    }

    ref
        .read(partnerProductsProvider.notifier)
        .getProducts(categoryId: categoryId, page: 1, isRefresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final isPartner =
        ref.watch(userTypeProvider) == UserType.partner ||
        GlobalVariables.isPartner;
    final selectedTab = ref.watch(selectedProductsTabProvider);

    final productsState = ref.watch(partnerProductsProvider);
    final categoryId = productsState.currentCategoryId;
    final bannerFilter = (categoryId != null && categoryId != 'All')
        ? BannerFilter(category: categoryId, page: 'products')
        : const BannerFilter(page: 'products');
    final banners = isPartner
        ? const <BannerModel>[]
        : (ref.watch(bannersProvider(bannerFilter)).value ?? []);
    final currentCategoryIndex = ref.watch(selectedProductsCategoryProvider);

    final servicesState = isPartner ? null : ref.watch(servicesListProvider);
    final partnerServicesState = isPartner
        ? ref.watch(partnerServicesProvider)
        : null;

    ref.listen<int>(selectedProductsCategoryProvider, (previous, next) {
      if (previous != next) {
        _lastFetchedCategoryIndex = next;
        _fetchProducts(index: next);
      }
    });

    final categoriesAsync = ref.read(categoriesProvider);
    String? selectedCategoryId;
    if (categoriesAsync.hasValue) {
      final categories = categoriesAsync.value!;
      if (currentCategoryIndex > 0 &&
          currentCategoryIndex <= categories.length) {
        selectedCategoryId = categories[currentCategoryIndex - 1].id;
      } else if (currentCategoryIndex == 0) {
        selectedCategoryId = 'All';
      }
    }

    if (_lastFetchedCategoryIndex != currentCategoryIndex &&
        productsState.currentCategoryId != selectedCategoryId) {
      _lastFetchedCategoryIndex = currentCategoryIndex;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _fetchProducts(index: currentCategoryIndex);
      });
    } else if (_lastFetchedCategoryIndex != currentCategoryIndex) {
      _lastFetchedCategoryIndex = currentCategoryIndex;
    }

    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final crossAxisCount = 1;
    final totalPadding =
        screenSize.responsivePadding(32) +
        screenSize.responsivePadding(16) * (crossAxisCount - 1);
    final itemWidth = (screenSize.width - totalPadding) / crossAxisCount;
    final itemHeight = screenSize.responsivePadding(isLandscape ? 220 : 240);
    final aspectRatio = itemWidth / itemHeight;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F4),
      appBar: AppBar(
        centerTitle: false,
        titleSpacing: 16,
        title: Text(
          'Products & Services',
          style: kSubHeadingM.copyWith(
            color: const Color(0xFF373737),
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFFF3F5F4),
        surfaceTintColor: const Color(0xFFF3F5F4),
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          if (isPartner)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: InteractiveFeedbackButton(
                  onPressed: () {
                    if (selectedTab == 0) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateProductPage(),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const CreateServicePage(),
                        ),
                      );
                    }
                  },
                  scaleFactor: 0.96,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.add_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add New',
                          style: GoogleFonts.urbanist(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            height: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () async {
            if (selectedTab == 0) {
              await ref.read(partnerProductsProvider.notifier).refresh();
            } else {
              if (isPartner) {
                await ref.read(partnerServicesProvider.notifier).getServices();
              } else {
                await ref.read(servicesListProvider.notifier).refresh();
              }
            }
          },
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: screenSize.responsivePadding(8)),
                    const ProductsServicesSegmentedTabs(),
                    SizedBox(height: screenSize.responsivePadding(16)),
                    if (selectedTab == 0) ...[
                      if (!isPartner) const ProductsFilterChips(),
                    ] else
                      const ServicesFilterChips(),
                    SizedBox(height: screenSize.responsivePadding(16)),
                  ],
                ),
              ),
              if (selectedTab == 0) ...[
                if (productsState.isLoading)
                  SliverPadding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(16),
                    ),
                    sliver: SliverGrid(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        mainAxisSpacing: screenSize.responsivePadding(16),
                        crossAxisSpacing: screenSize.responsivePadding(16),
                        childAspectRatio: aspectRatio,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) =>
                            CardShimmers.productCardShimmer(screenSize),
                        childCount: 6,
                      ),
                    ),
                  )
                else if (productsState.error != null ||
                    productsState.products.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        'No products found',
                        style: kSmallTitleL.copyWith(
                          fontSize: 14,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                  )
                else ...[
                  ...buildPaginatedGridSliversWithBanners(
                    items: productsState.products,
                    itemBuilder: (context, index, p) => ProductCard(
                      index: index,
                      name: p.title,
                      image: (p.images != null && p.images!.isNotEmpty)
                          ? p.images![0]
                          : '',
                      price: (p.price == null || p.price == 0)
                          ? null
                          : '₹ ${p.price! % 1 == 0 ? p.price!.toInt() : p.price}',
                      tags: p.tags,
                      rawProduct: p,
                    ),
                    banners: banners,
                    hasMore:
                        productsState.pagination != null &&
                        productsState.pagination!.page <
                            productsState.pagination!.pages,
                    screenSize: screenSize,
                    childAspectRatio: aspectRatio,
                    crossAxisCount: crossAxisCount,
                  ),
                  if (productsState.isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Center(
                          child: LoadingAnimation(loadingColor: kPrimaryColor),
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: SizedBox(height: screenSize.responsivePadding(24)),
                  ),
                ],
              ] else ...[
                if (partnerServicesState != null) ...[
                  if (partnerServicesState.isLoading)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(16),
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: screenSize.responsivePadding(16),
                          crossAxisSpacing: screenSize.responsivePadding(16),
                          childAspectRatio: aspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              CardShimmers.serviceCardShimmer(screenSize),
                          childCount: 4,
                        ),
                      ),
                    )
                  else if (partnerServicesState.services.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'No services uploaded yet. Tap "+ Create Service" to add one.',
                            style: kSmallTitleL.copyWith(
                              fontSize: 14,
                              color: const Color(0xFF6B7280),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(
                        screenSize.responsivePadding(16),
                        0,
                        screenSize.responsivePadding(16),
                        screenSize.responsivePadding(80),
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: screenSize.responsivePadding(16),
                          crossAxisSpacing: screenSize.responsivePadding(16),
                          childAspectRatio: aspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final s = partnerServicesState.services[index];
                          return ServiceCard(
                            service: s,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      CreateServicePage(existingService: s),
                                ),
                              );
                            },
                          );
                        }, childCount: partnerServicesState.services.length),
                      ),
                    ),
                ] else if (servicesState != null) ...[
                  if (servicesState.isLoading)
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(16),
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: screenSize.responsivePadding(16),
                          crossAxisSpacing: screenSize.responsivePadding(16),
                          childAspectRatio: aspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (context, index) =>
                              CardShimmers.serviceCardShimmer(screenSize),
                          childCount: 6,
                        ),
                      ),
                    )
                  else if (servicesState.services.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Text(
                          'No services found',
                          style: kSmallTitleL.copyWith(
                            fontSize: 14,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ),
                    )
                  else ...[
                    SliverPadding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(16),
                      ),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          mainAxisSpacing: screenSize.responsivePadding(16),
                          crossAxisSpacing: screenSize.responsivePadding(16),
                          childAspectRatio: aspectRatio,
                        ),
                        delegate: SliverChildBuilderDelegate((context, index) {
                          final s = servicesState.services[index];
                          return ServiceCard(service: s);
                        }, childCount: servicesState.services.length),
                      ),
                    ),
                    if (servicesState.isLoadingMore)
                      const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(
                            child: LoadingAnimation(
                              loadingColor: kPrimaryColor,
                            ),
                          ),
                        ),
                      ),
                    SliverToBoxAdapter(
                      child: SizedBox(height: screenSize.responsivePadding(24)),
                    ),
                  ],
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }
}
