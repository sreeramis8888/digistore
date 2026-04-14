import 'package:digistore/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/partner_products_provider.dart';
import '../../components/shops/product_card.dart';
import '../../components/primary_button.dart';
import 'partner_product_page.dart';

class PartnerProductsPage extends ConsumerStatefulWidget {
  const PartnerProductsPage({super.key});

  @override
  ConsumerState<PartnerProductsPage> createState() =>
      _PartnerProductsPageState();
}

class _PartnerProductsPageState extends ConsumerState<PartnerProductsPage> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(partnerProductsProvider.notifier).loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final productsState = ref.watch(partnerProductsProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'Products',
          style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        surfaceTintColor: kWhite,
        elevation: 0,
        actions: [
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
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenSize.responsivePadding(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenSize.responsivePadding(16)),
              Container(
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F6F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    ref
                        .read(partnerProductsProvider.notifier)
                        .updateSearch(value);
                  },
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
              SizedBox(height: screenSize.responsivePadding(24)),
              Expanded(
                child: productsState.isLoading
                    ? const Center(child: LoadingAnimation())
                    : productsState.error != null
                    ? Center(child: Text(productsState.error!))
                    : productsState.products.isEmpty
                    ? const Center(child: Text('No products found'))
                    : RefreshIndicator(
                        onRefresh: () => ref
                            .read(partnerProductsProvider.notifier)
                            .refresh(),
                        child: GridView.builder(
                          controller: _scrollController,
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: EdgeInsets.only(
                            bottom: screenSize.responsivePadding(24),
                          ),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: screenSize.responsivePadding(
                                  16,
                                ),
                                crossAxisSpacing: screenSize.responsivePadding(
                                  16,
                                ),
                                childAspectRatio: 0.8,
                              ),
                          itemCount:
                              productsState.products.length +
                              (productsState.isLoadingMore ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == productsState.products.length) {
                              return const Center(child: LoadingAnimation());
                            }
                            final p = productsState.products[index];
                            return ProductCard(
                              index: index,
                              name: p.title,
                              image: (p.images != null && p.images!.isNotEmpty)
                                  ? p.images![0]
                                  : 'assets/png/shake.png',
                              price: '₹ ${p.price}',
                            );
                          },
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
