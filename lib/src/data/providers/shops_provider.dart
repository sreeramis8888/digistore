import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return ShopsState(
      shops: shops ?? this.shops,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      pagination: pagination ?? this.pagination,
      category: clearCategory ? null : (category ?? this.category),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

bool isShopInCategory(ShopModel shop, String category) {
  final catLower = category.toLowerCase().trim();
  final type = shop.businessDetails?.businessType?.toLowerCase().trim() ?? '';
  final categories = (shop.serviceCategories ?? [])
      .map((c) => c.toLowerCase().trim())
      .toList();
  final tags = (shop.tags ?? []).map((t) => t.toLowerCase().trim()).toList();

  // Food / Restaurants / Cafes share the same home "Restaurants" filter group.
  if (_isFoodOrRestaurantCategory(catLower)) {
    return type.contains('restaurant') ||
        type.contains('cafe') ||
        type.contains('food') ||
        categories.any(
          (c) =>
              c.contains('restaurant') ||
              c.contains('cafe') ||
              c.contains('food'),
        ) ||
        tags.any(
          (t) =>
              t.contains('restaurant') ||
              t.contains('cafe') ||
              t.contains('food'),
        );
  }

  return type.contains(catLower) ||
      categories.any((c) => c.contains(catLower)) ||
      tags.any((t) => t.contains(catLower));
}

bool _isFoodOrRestaurantCategory(String categoryLower) {
  return categoryLower.contains('restaurant') ||
      categoryLower.contains('cafe') ||
      categoryLower.contains('food');
}

/// API category names to request for a selected shops filter.
/// Food + Restaurants are grouped so Explore Shops shows both business types.
List<String> apiCategoriesFor(String category) {
  if (_isFoodOrRestaurantCategory(category.toLowerCase().trim())) {
    return const ['Restaurants', 'Food'];
  }
  return [category];
}

Future<({List<ShopModel> shops, PaginationModel? pagination})>
    _fetchShopsForCategories({
  required ApiProvider api,
  required Map<String, String> baseQueryParams,
  required String? currentCategory,
}) async {
  final hasCategory = currentCategory != null &&
      currentCategory != 'All' &&
      currentCategory.isNotEmpty;

  if (!hasCategory) {
    final response = await api.get('/shops', queryParams: baseQueryParams);
    if (!response.success || response.data == null) {
      return (shops: <ShopModel>[], pagination: null);
    }
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    final pagination = PaginationModel.fromJson(
      response.data!['pagination'] as Map<String, dynamic>,
    );
    return (
      shops: data
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: pagination,
    );
  }

  final categories = apiCategoriesFor(currentCategory);
  final Map<String, ShopModel> byId = {};
  PaginationModel? pagination;

  for (final apiCategory in categories) {
    final params = Map<String, String>.from(baseQueryParams)
      ..['category'] = apiCategory;
    final response = await api.get('/shops', queryParams: params);
    if (!response.success || response.data == null) continue;

    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    pagination ??= PaginationModel.fromJson(
      response.data!['pagination'] as Map<String, dynamic>,
    );
    for (final e in data) {
      final shop = ShopModel.fromJson(e as Map<String, dynamic>);
      final id = shop.id;
      if (id != null) {
        byId.putIfAbsent(id, () => shop);
      } else {
        byId['anon_${byId.length}'] = shop;
      }
    }
  }

  var shops = byId.values.toList();

  // Fallback: uncategorized fetch + client filter (covers name mismatches).
  if (shops.isEmpty) {
    final fallbackParams = Map<String, String>.from(baseQueryParams)
      ..remove('category');
    final fallbackResp =
        await api.get('/shops', queryParams: fallbackParams);
    if (fallbackResp.success && fallbackResp.data != null) {
      final List<dynamic> fallbackData =
          fallbackResp.data!['data'] as List<dynamic>;
      pagination = PaginationModel.fromJson(
        fallbackResp.data!['pagination'] as Map<String, dynamic>,
      );
      shops = fallbackData
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .where((s) => isShopInCategory(s, currentCategory))
          .toList();
    }
  }

  return (shops: shops, pagination: pagination);
}

@Riverpod(keepAlive: true)
class Shops extends _$Shops {
  @override
  ShopsState build() {
    ref.watch(sessionProvider);
    ref.watch(userProvider);
    Future(() => getShops());
    return ShopsState();
  }

  Future<void> getShops({
    int page = 1,
    String? category,
    bool clearCategory = false,
    String? search,
  }) async {
    final currentCategory = clearCategory ? null : (category ?? state.category);
    final currentSearch = search ?? state.searchQuery;

    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        category: category,
        clearCategory: clearCategory,
        searchQuery: currentSearch,
        shops: (category != null || clearCategory || search != null) ? [] : state.shops,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(apiProvider);
    final user = ref.read(userProvider);
    final lat = user?.location?.coordinates?.lat;
    final lng = user?.location?.coordinates?.lng;

    if (lat == null || lng == null) {
      state = state.copyWith(isLoading: false, isLoadingMore: false, shops: []);
      return;
    }

    final queryParams = {
      'lat': lat.toString(),
      'lng': lng.toString(),
      'page': page.toString(),
      'limit': '20',
    };

    if (currentSearch.isNotEmpty) {
      queryParams['search'] = currentSearch;
    }

    final result = await _fetchShopsForCategories(
      api: api,
      baseQueryParams: queryParams,
      currentCategory: currentCategory,
    );

    if (result.pagination != null || result.shops.isNotEmpty) {
      if (page == 1) {
        state = state.copyWith(
          shops: result.shops,
          pagination: result.pagination,
          isLoading: false,
        );
      } else {
        final existingIds = state.shops.map((s) => s.id).whereType<String>().toSet();
        final merged = [
          ...state.shops,
          ...result.shops.where((s) => s.id == null || !existingIds.contains(s.id)),
        ];
        state = state.copyWith(
          shops: merged,
          pagination: result.pagination,
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(
        error: 'Failed to fetch shops',
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
    if (category == null) {
      if (state.category == null) return;
      getShops(page: 1, clearCategory: true);
    } else {
      if (state.category == category) return;
      getShops(page: 1, category: category);
    }
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
    Future(() => getShops());
    return ShopsState();
  }

  Future<void> getShops({
    int page = 1,
    String? category,
    bool clearCategory = false,
    String? search,
  }) async {
    final currentCategory = clearCategory ? null : (category ?? state.category);
    final currentSearch = search ?? state.searchQuery;

    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        category: category,
        clearCategory: clearCategory,
        searchQuery: currentSearch,
        shops: (category != null || clearCategory || search != null) ? [] : state.shops,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(apiProvider);
    final user = ref.read(userProvider);
    final lat = user?.location?.coordinates?.lat;
    final lng = user?.location?.coordinates?.lng;

    final queryParams = {'page': page.toString(), 'limit': '20'};

    if (lat != null && lng != null) {
      queryParams['lat'] = lat.toString();
      queryParams['lng'] = lng.toString();
    }

    if (currentSearch.isNotEmpty) {
      queryParams['search'] = currentSearch;
    }

    final result = await _fetchShopsForCategories(
      api: api,
      baseQueryParams: queryParams,
      currentCategory: currentCategory,
    );

    if (result.pagination != null || result.shops.isNotEmpty) {
      if (page == 1) {
        state = state.copyWith(
          shops: result.shops,
          pagination: result.pagination,
          isLoading: false,
        );
      } else {
        final existingIds =
            state.shops.map((s) => s.id).whereType<String>().toSet();
        final merged = [
          ...state.shops,
          ...result.shops
              .where((s) => s.id == null || !existingIds.contains(s.id)),
        ];
        state = state.copyWith(
          shops: merged,
          pagination: result.pagination,
          isLoadingMore: false,
        );
      }
    } else {
      state = state.copyWith(
        error: 'Failed to fetch shops',
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
    if (category == null) {
      if (state.category == null) return;
      getShops(page: 1, clearCategory: true);
    } else {
      if (state.category == category) return;
      getShops(page: 1, category: category);
    }
  }

  void updateSearch(String query) {
    if (state.searchQuery == query) return;
    getShops(page: 1, search: query);
  }
}

@Riverpod(keepAlive: true)
class FeaturedShops extends _$FeaturedShops {
  @override
  ShopsState build() {
    ref.watch(sessionProvider);
    Future(() => getShops());
    return ShopsState();
  }

  Future<void> getShops({
    int page = 1,
    String? search,
  }) async {
    final currentSearch = search ?? state.searchQuery;

    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        searchQuery: currentSearch,
        shops: search != null ? [] : state.shops,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(apiProvider);
    final user = ref.read(userProvider);
    final lat = user?.location?.coordinates?.lat;
    final lng = user?.location?.coordinates?.lng;

    final queryParams = {
      'page': page.toString(),
      'limit': '10',
    };

    if (lat != null && lng != null) {
      queryParams['lat'] = lat.toString();
      queryParams['lng'] = lng.toString();
    }

    if (currentSearch.isNotEmpty) {
      queryParams['search'] = currentSearch;
    }

    final response = await api.get('/shops/featured', queryParams: queryParams);

    if (response.success && response.data != null) {
      final List<dynamic> data = response.data!['data'] as List<dynamic>;
      final pagination = PaginationModel.fromJson(
        response.data!['pagination'] as Map<String, dynamic>,
      );
      final newShops = data
          .map((e) => ShopModel.fromJson(e as Map<String, dynamic>))
          .toList();

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

  void updateSearch(String query) {
    if (state.searchQuery == query) return;
    getShops(page: 1, search: query);
  }
}

@riverpod
Future<List<OfferModel>> shopOffers(Ref ref, String shopId) async {
  if (shopId.isEmpty) return [];
  final api = ref.read(apiProvider);
  final response = await api.get('/shops/$shopId/offers');
  if (response.success && response.data != null) {
    final data = response.data!['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

@riverpod
Future<List<ProductModel>> shopProducts(Ref ref, String shopId) async {
  if (shopId.isEmpty) return [];
  final api = ref.read(apiProvider);
  final response = await api.get('/shops/$shopId/products');
  if (response.success && response.data != null) {
    final data = response.data!['data'] as List<dynamic>? ?? [];
    return data
        .map((e) => ProductModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
  return [];
}

@riverpod
Future<ShopModel?> getShopByPartnerId(Ref ref, String partnerId) async {
  if (partnerId.isEmpty) return null;
  final api = ref.read(apiProvider);
  final response = await api.get('/shops/$partnerId');
  if (response.success && response.data != null) {
    final data = response.data!['data'];
    if (data != null) {
      return ShopModel.fromJson(data as Map<String, dynamic>);
    }
  }
  return null;
}

/// Total Food + Restaurants shops for the home restaurant banner.
/// Uses API pagination totals so the count is correct on first home load.
final restaurantShopsCountProvider = FutureProvider<int>((ref) async {
  ref.watch(sessionProvider);
  final user = ref.watch(userProvider);
  final api = ref.read(apiProvider);

  final queryParams = <String, String>{
    'page': '1',
    'limit': '1',
  };
  final lat = user?.location?.coordinates?.lat;
  final lng = user?.location?.coordinates?.lng;
  if (lat != null && lng != null) {
    queryParams['lat'] = lat.toString();
    queryParams['lng'] = lng.toString();
  }

  var total = 0;
  for (final category in apiCategoriesFor('Restaurants')) {
    final params = Map<String, String>.from(queryParams)
      ..['category'] = category;
    final response = await api.get('/shops', queryParams: params);
    if (!response.success || response.data == null) continue;
    final pagination = PaginationModel.fromJson(
      response.data!['pagination'] as Map<String, dynamic>? ?? const {},
    );
    total += pagination.total;
  }

  // Fallback if category endpoints return 0 (name mismatch on API).
  if (total == 0) {
    final result = await _fetchShopsForCategories(
      api: api,
      baseQueryParams: {
        ...queryParams,
        'limit': '100',
      },
      currentCategory: 'Restaurants',
    );
    total = result.shops.length;
  }

  return total;
});

