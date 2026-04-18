import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/product_model.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

part 'partner_products_provider.g.dart';

class PartnerProductsState {
  final List<ProductModel> products;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PaginationModel? pagination;
  final String searchQuery;

  PartnerProductsState({
    this.products = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.pagination,
    this.searchQuery = '',
  });

  PartnerProductsState copyWith({
    List<ProductModel>? products,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PaginationModel? pagination,
    String? searchQuery,
  }) {
    return PartnerProductsState(
      products: products ?? this.products,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@Riverpod(keepAlive: true)
class PartnerProducts extends _$PartnerProducts {
  @override
  PartnerProductsState build() {
    ref.watch(sessionProvider);
    // Initial fetch
    Future.microtask(() => getProducts());
    return PartnerProductsState();
  }

  Future<void> getProducts({int page = 1, String? search}) async {
    final currentSearch = search ?? state.searchQuery;
    
    if (page == 1) {
      state = state.copyWith(
        isLoading: true, 
        error: null, 
        searchQuery: currentSearch,
        products: search != null ? [] : state.products,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(apiProvider);
    final queryParams = {
      'page': page.toString(),
      'limit': '20',
    };
    if (currentSearch.isNotEmpty) {
      queryParams['search'] = currentSearch;
    }

    final response = await api.get('/products', queryParams: queryParams);

    if (response.success && response.data != null) {
      final productResponse = ProductResponse.fromJson(response.data!);
      if (page == 1) {
        state = state.copyWith(
          products: productResponse.data,
          pagination: productResponse.pagination,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          products: [...state.products, ...productResponse.data],
          pagination: productResponse.pagination,
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(
        error: response.message ?? 'Failed to load products',
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.pagination == null) return;
    if (state.pagination!.page >= state.pagination!.pages) return;

    await getProducts(page: state.pagination!.page + 1);
  }

  Future<void> refresh() async {
    await getProducts(page: 1);
  }

  void updateSearch(String query) {
    if (state.searchQuery == query) return;
    getProducts(page: 1, search: query);
  }
  void addProduct(ProductModel product) {
    state = state.copyWith(
      products: [product, ...state.products],
      pagination: state.pagination?.copyWith(
        total: (state.pagination?.total ?? 0) + 1,
      ),
    );
  }

  void updateProductLocally(ProductModel updatedProduct) {
    final index = state.products.indexWhere((p) => p.id == updatedProduct.id);
    if (index != -1) {
      final newProducts = List<ProductModel>.from(state.products);
      newProducts[index] = updatedProduct;
      state = state.copyWith(products: newProducts);
    }
  }

  void removeProductLocally(String id) {
    state = state.copyWith(
      products: state.products.where((p) => p.id != id).toList(),
      pagination: state.pagination?.copyWith(
        total: (state.pagination?.total ?? 1) - 1,
      ),
    );
  }

  Future<void> deleteProduct(String id) async {
    final api = ref.read(apiProvider);
    final response = await api.delete('/products/$id');
    if (response.success) {
      removeProductLocally(id);
    } else {
      throw Exception(response.message ?? 'Failed to delete product');
    }
  }
}


