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
import 'partner/partner_product_page.dart';
import '../../data/providers/user_type_provider.dart';
import '../../data/router/nav_router.dart';
import '../../data/providers/category_provider.dart';
import '../components/products/products_filter_chips.dart';
import 'dart:async';

class ProductsPage extends ConsumerStatefulWidget {
  const ProductsPage({super.key});

  @override
  ConsumerState<ProductsPage> createState() =>
      _ProductsPageState();
}

class _ProductsPageState extends ConsumerState<ProductsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  int? _lastFetchedCategoryIndex;
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
    final isPartner = ref.watch(userTypeProvider) == UserType.partner;
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
              Expanded(
                child: productsState.isLoading
                    ? GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        padding: EdgeInsets.only(
                          bottom: screenSize.responsivePadding(24),
                          left: screenSize.responsivePadding(16),
                          right: screenSize.responsivePadding(16),
                        ),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: screenSize.responsivePadding(16),
                          crossAxisSpacing: screenSize.responsivePadding(16),
                          childAspectRatio: 0.8,
                        ),
                        itemCount: 6,
                        itemBuilder: (context, index) {
                          return CardShimmers.productCardShimmer(screenSize);
                        },
                      )
                    : productsState.error != null
                    ? Center(child: Text(productsState.error!))
                    : productsState.products.isEmpty
                    ? const Center(child: Text('No products found'))
                    : RefreshIndicator(
                        color: kPrimaryColor,
                        onRefresh: () => ref
                            .read(partnerProductsProvider.notifier)
                            .refresh(),
                        child: CustomScrollView(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          slivers: [
                            SliverPadding(
                              padding: EdgeInsets.only(
                                bottom: screenSize.responsivePadding(24),
                                left: screenSize.responsivePadding(16),
                                right: screenSize.responsivePadding(16),
                              ),
                              sliver: SliverGrid(
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 2,
                                  mainAxisSpacing:
                                      screenSize.responsivePadding(16),
                                  crossAxisSpacing:
                                      screenSize.responsivePadding(16),
                                  childAspectRatio: 0.8,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) {
                                    final p = productsState.products[index];
                                    return ProductCard(
                                      index: index,
                                      name: p.title,
                                      image: (p.images != null &&
                                              p.images!.isNotEmpty)
                                          ? p.images![0]
                                          : '',
                                      price: (p.price == null || p.price == 0)
                                          ? null
                                          : '₹ ${p.price}',
                                      tags: p.tags,
                                      rawProduct: p,
                                    );
                                  },
                                  childCount: productsState.products.length,
                                ),
                              ),
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
                        ),
                      ),
              ),
            ],
          ),
      ),
    );
  }
}
