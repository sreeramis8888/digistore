import 'package:setgo/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../../data/providers/partner_products_provider.dart';
import '../components/shops/product_card.dart';
import '../components/primary_button.dart';
import '../components/shimmers/card_shimmers.dart';
import 'partner/create_product.dart';
import '../../data/providers/user_type_provider.dart';
import '../../data/router/nav_router.dart';
import '../../data/providers/category_provider.dart';
import '../components/products/products_filter_chips.dart';
import 'dart:async';
import '../../data/providers/banners_provider.dart';
import '../../data/models/banner_model.dart';
import '../components/common/paginated_banner_grid.dart';
import '../../data/utils/global_variables.dart';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() =>
      _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  int _lastFetchedCategoryIndex = -1;
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

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(partnerProductsProvider.notifier).loadMore();
    }
  }

  void _fetchProducts({int? index}) {
    final int currentIndex = index ?? ref.read(selectedProductsCategoryProvider);
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

    ref.read(partnerProductsProvider.notifier).getProducts(categoryId: categoryId, page: 1, isRefresh: true);
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      ref.read(partnerProductsProvider.notifier).updateSearch(query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final productsState = ref.watch(partnerProductsProvider);
    final isPartner = ref.watch(userTypeProvider) == UserType.partner || GlobalVariables.isPartner;
    final categoryId = productsState.currentCategoryId;
    final bannerFilter = (categoryId != null && categoryId != 'All')
        ? BannerFilter(category: categoryId, page: 'products')
        : const BannerFilter(page: 'products');
    final banners = isPartner
        ? const <BannerModel>[]
        : (ref.watch(bannersProvider(bannerFilter)).value ?? []);
    final currentCategoryIndex = ref.watch(selectedProductsCategoryProvider);

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

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Products',
          style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        actions: [
          if (isPartner)
            Center(
              child: Padding(
                padding: EdgeInsets.only(right: screenSize.responsivePadding(16)),
                child: PrimaryButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CreateProductPage(),
                      ),
                    );
                  },
                  width: screenSize.responsivePadding(140),
                  height: screenSize.responsivePadding(38),
                  text: 'Create Product',
                  textSize: 14,
                  backgroundColor: kPrimaryColor,
                  textColor: kWhite,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: () => ref.read(partnerProductsProvider.notifier).refresh(),
          child: CustomScrollView(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isPartner) ...[
                      const ProductsFilterChips(),
                      SizedBox(height: screenSize.responsivePadding(16)),
                    ],
                    if (isPartner) SizedBox(height: screenSize.responsivePadding(16)),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(16),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F6F8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: TextField(
                          controller: _searchController,
                          onChanged: _onSearchChanged,
                          decoration: InputDecoration(
                            hintText: "Search for 'products'",
                            hintStyle: kSmallerTitleM.copyWith(
                              color: const Color(0xFF99A1AF),
                            ),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Color(0xFF99A1AF),
                              size: 20,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: screenSize.responsivePadding(16),
                              vertical: screenSize.responsivePadding(14),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenSize.responsivePadding(24)),
                  ],
                ),
              ),
              if (productsState.isLoading)
                SliverPadding(
                  padding: EdgeInsets.only(
                    bottom: screenSize.responsivePadding(24),
                    left: screenSize.responsivePadding(16),
                    right: screenSize.responsivePadding(16),
                  ),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2,
                      mainAxisSpacing: screenSize.responsivePadding(16),
                      crossAxisSpacing: screenSize.responsivePadding(16),
                      childAspectRatio: MediaQuery.of(context).orientation == Orientation.landscape ? 1.0 : 0.8,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return CardShimmers.productCardShimmer(screenSize);
                      },
                      childCount: 6,
                    ),
                  ),
                )
              else if (productsState.error != null)
                SliverFillRemaining(child: Center(child: Text(productsState.error!)))
              else if (productsState.products.isEmpty)
                const SliverFillRemaining(child: Center(child: Text('No products found')))
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
                        : '₹ ${p.price}',
                    tags: p.tags,
                    rawProduct: p,
                  ),
                  banners: banners,
                  hasMore: productsState.pagination != null &&
                      productsState.pagination!.page < productsState.pagination!.pages,
                  screenSize: screenSize,
                  childAspectRatio: MediaQuery.of(context).orientation == Orientation.landscape ? 1.0 : 0.8,
                  crossAxisCount: MediaQuery.of(context).orientation == Orientation.landscape ? 4 : 2,
                ),
                if (productsState.isLoadingMore)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: screenSize.responsivePadding(24),
                      ),
                      child: const Center(
                        child: LoadingAnimation(
                          loadingColor: kPrimaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
