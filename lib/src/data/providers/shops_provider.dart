import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/shop_model.dart';
import '../models/product_model.dart';
import '../models/offer_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';
import 'auth_provider.dart';

part 'shops_provider.g.dart';

class ShopsState {
  final List<ShopModel> shops;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final PaginationModel? pagination;
  final String? category;
  final String searchQuery;

  ShopsState({
    this.shops = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.pagination,
    this.category,
    this.searchQuery = '',
  });

  ShopsState copyWith({
    List<ShopModel>? shops,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    PaginationModel? pagination,
    String? category,
    String? searchQuery,
  }) {
    return ShopsState(
      shops: shops ?? this.shops,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
      category: category ?? this.category,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@Riverpod(keepAlive: true)
class Shops extends _$Shops {
  @override
  ShopsState build() {
    ref.watch(sessionProvider);
    ref.watch(userProvider);
    Future.microtask(() => getShops());
    return ShopsState();
  }

  Future<void> getShops({int page = 1, String? category, String? search}) async {
    final currentCategory = category ?? state.category;
    final currentSearch = search ?? state.searchQuery;

    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        category: category,
        searchQuery: currentSearch,
        shops: (category != null || search != null) ? [] : state.shops,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(apiProvider);
    final user = ref.read(userProvider);
    final lat = user?.location?.coordinates?.lat;
    final lng = user?.location?.coordinates?.lng;

    if (lat == null || lng == null) {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        shops: [],
      );
      return;
    }

    final queryParams = {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'page': page.toString(),
      'limit': '20',
    };

    if (currentCategory != null && currentCategory != 'All' && currentCategory.isNotEmpty) {
      queryParams['category'] = currentCategory;
    }

    if (currentSearch.isNotEmpty) {
      queryParams['search'] = currentSearch;
    }

    final response = await api.get('/shops', queryParams: queryParams, requireAuth: false);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data!['data'] as List<dynamic>;
      final pagination = PaginationModel.fromJson(response.data!['pagination'] as Map<String, dynamic>);
      final newShops = data.map((e) => ShopModel.fromJson(e as Map<String, dynamic>)).toList();

      if (page == 1) {
        state = state.copyWith(
          shops: newShops,
          pagination: pagination,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          shops: [...state.shops, ...newShops],
          pagination: pagination,
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(
        error: response.message ?? 'Failed to fetch shops',
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.pagination == null) return;
    if (state.pagination!.page >= state.pagination!.pages) return;
    await getShops(page: state.pagination!.page + 1);
  }

  Future<void> refresh() async {
    await getShops(page: 1);
  }

  void updateCategory(String? category) {
    if (state.category == category) return;
    getShops(page: 1, category: category);
  }

  void updateSearch(String query) {
    if (state.searchQuery == query) return;
    getShops(page: 1, search: query);
  }
}

@Riverpod(keepAlive: true)
class AllShops extends _$AllShops {
  @override
  ShopsState build() {
    ref.watch(sessionProvider);
    Future.microtask(() => getShops());
    return ShopsState();
  }

  Future<void> getShops({int page = 1, String? category, String? search}) async {
    final currentCategory = category ?? state.category;
    final currentSearch = search ?? state.searchQuery;

    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        category: category,
        searchQuery: currentSearch,
        shops: (category != null || search != null) ? [] : state.shops,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(apiProvider);
    final queryParams = {
      'page': page.toString(),
      'limit': '20',
    };

    if (currentCategory != null && currentCategory != 'All' && currentCategory.isNotEmpty) {
      queryParams['category'] = currentCategory;
    }

    if (currentSearch.isNotEmpty) {
      queryParams['search'] = currentSearch;
    }

    final response = await api.get('/shops', queryParams: queryParams, requireAuth: false);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data!['data'] as List<dynamic>;
      final pagination = PaginationModel.fromJson(response.data!['pagination'] as Map<String, dynamic>);
      final newShops = data.map((e) => ShopModel.fromJson(e as Map<String, dynamic>)).toList();

      if (page == 1) {
        state = state.copyWith(
          shops: newShops,
          pagination: pagination,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          shops: [...state.shops, ...newShops],
          pagination: pagination,
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(
        error: response.message ?? 'Failed to fetch shops',
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.pagination == null) return;
    if (state.pagination!.page >= state.pagination!.pages) return;
    await getShops(page: state.pagination!.page + 1);
  }

  Future<void> refresh() async {
    await getShops(page: 1);
  }

  void updateCategory(String? category) {
    if (state.category == category) return;
    getShops(page: 1, category: category);
  }

  void updateSearch(String query) {
    if (state.searchQuery == query) return;
    getShops(page: 1, search: query);
  }
}

@riverpod
Future<List<OfferModel>> shopOffers(Ref ref, String shopId) async {
  if (shopId.isEmpty) return [];
  final api = ref.read(apiProvider);
  final response = await api.get('/shops/$shopId/offers', requireAuth: false);
  if (response.success && response.data != null) {
    final data = response.data!['data'] as List<dynamic>? ?? [];
    return data.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}

@riverpod
Future<List<ProductModel>> shopProducts(Ref ref, String shopId) async {
  if (shopId.isEmpty) return [];
  final api = ref.read(apiProvider);
  final response = await api.get('/shops/$shopId/products', requireAuth: false);
  if (response.success && response.data != null) {
    final data = response.data!['data'] as List<dynamic>? ?? [];
    return data.map((e) => ProductModel.fromJson(e as Map<String, dynamic>)).toList();
  }
  return [];
}
