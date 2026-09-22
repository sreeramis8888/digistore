import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'api_provider.dart';
import 'user_provider.dart';

class GlobalSearchOverview {
  final String query;
  final int offersCount;
  final int shopsCount;
  final int servicesCount;
  final int productsCount;
  final int categoriesCount;
  final List<Map<String, dynamic>> offers;
  final List<Map<String, dynamic>> shops;
  final List<Map<String, dynamic>> services;
  final List<Map<String, dynamic>> products;
  final List<Map<String, dynamic>> categories;

  const GlobalSearchOverview({
    required this.query,
    this.offersCount = 0,
    this.shopsCount = 0,
    this.servicesCount = 0,
    this.productsCount = 0,
    this.categoriesCount = 0,
    this.offers = const [],
    this.shops = const [],
    this.services = const [],
    this.products = const [],
    this.categories = const [],
  });

  bool get isEmpty =>
      offers.isEmpty &&
      shops.isEmpty &&
      services.isEmpty &&
      products.isEmpty &&
      categories.isEmpty;
}

class GlobalSearchPaged {
  final String query;
  final String type;
  final List<Map<String, dynamic>> results;
  final int total;
  final int page;
  final int pages;
  final bool isLoadingMore;

  const GlobalSearchPaged({
    required this.query,
    required this.type,
    this.results = const [],
    this.total = 0,
    this.page = 1,
    this.pages = 1,
    this.isLoadingMore = false,
  });

  bool get hasMore => page < pages;

  GlobalSearchPaged copyWith({
    List<Map<String, dynamic>>? results,
    int? total,
    int? page,
    int? pages,
    bool? isLoadingMore,
  }) {
    return GlobalSearchPaged(
      query: query,
      type: type,
      results: results ?? this.results,
      total: total ?? this.total,
      page: page ?? this.page,
      pages: pages ?? this.pages,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}

Map<String, String> _geoParams(Ref ref) {
  final user = ref.read(userProvider);
  final lat = user?.location?.coordinates?.lat;
  final lng = user?.location?.coordinates?.lng;
  final params = <String, String>{};
  if (lat != null && lng != null) {
    params['lat'] = lat.toString();
    params['lng'] = lng.toString();
  }
  return params;
}

List<Map<String, dynamic>> _asMapList(dynamic raw) {
  if (raw is! List) return const [];
  return raw
      .whereType<Map>()
      .map((e) => Map<String, dynamic>.from(e))
      .toList();
}

/// Overview search (`type=all`) — all domains for home search results.
final globalSearchOverviewProvider =
    FutureProvider.family<GlobalSearchOverview, String>((ref, query) async {
  final q = query.trim();
  if (q.isEmpty) {
    return const GlobalSearchOverview(query: '');
  }

  final api = ref.read(apiProvider);
  final params = <String, String>{
    'q': q,
    'type': 'all',
    'limit': '10',
    ..._geoParams(ref),
  };

  final response = await api.get('/search', queryParams: params);
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Search failed');
  }

  final data = response.data!['data'];
  if (data is! Map) {
    return GlobalSearchOverview(query: q);
  }

  final summary = data['summary'] is Map
      ? Map<String, dynamic>.from(data['summary'] as Map)
      : <String, dynamic>{};

  return GlobalSearchOverview(
    query: q,
    offersCount: (summary['offersCount'] as num?)?.toInt() ?? 0,
    shopsCount: (summary['shopsCount'] as num?)?.toInt() ?? 0,
    servicesCount: (summary['servicesCount'] as num?)?.toInt() ?? 0,
    productsCount: (summary['productsCount'] as num?)?.toInt() ?? 0,
    categoriesCount: (summary['categoriesCount'] as num?)?.toInt() ?? 0,
    offers: _asMapList(data['offers']),
    shops: _asMapList(data['shops']),
    services: _asMapList(data['services']),
    products: _asMapList(data['products']),
    categories: _asMapList(data['categories']),
  );
});

/// Paginated search for a single type (`offers` | `shops` | `services` | `products`).
final globalSearchPagedProvider = FutureProvider.family<GlobalSearchPaged,
    ({String query, String type})>((ref, args) async {
  final q = args.query.trim();
  final type = args.type;
  if (q.isEmpty) {
    return GlobalSearchPaged(query: q, type: type);
  }

  // Categories have no dedicated paged type — reuse overview slice.
  if (type == 'categories') {
    final overview = await ref.watch(globalSearchOverviewProvider(q).future);
    return GlobalSearchPaged(
      query: q,
      type: type,
      results: overview.categories,
      total: overview.categoriesCount,
      page: 1,
      pages: 1,
    );
  }

  final api = ref.read(apiProvider);
  final params = <String, String>{
    'q': q,
    'type': type,
    'page': '1',
    'limit': '20',
    ..._geoParams(ref),
  };

  final response = await api.get('/search', queryParams: params);
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Search failed');
  }

  final body = response.data!;
  final data = body['data'];
  final pagination = body['pagination'] is Map
      ? Map<String, dynamic>.from(body['pagination'] as Map)
      : <String, dynamic>{};

  final results = data is Map
      ? _asMapList(data['results'])
      : _asMapList(data);

  return GlobalSearchPaged(
    query: q,
    type: type,
    results: results,
    total: (data is Map ? data['total'] as num? : null)?.toInt() ??
        results.length,
    page: (pagination['page'] as num?)?.toInt() ?? 1,
    pages: (pagination['pages'] as num?)?.toInt() ?? 1,
  );
});

/// Loads next page for a typed search list.
Future<GlobalSearchPaged> fetchGlobalSearchPage(
  WidgetRef ref, {
  required String query,
  required String type,
  required int page,
  GlobalSearchPaged? previous,
}) async {
  if (type == 'categories') {
    return previous ??
        GlobalSearchPaged(query: query.trim(), type: type);
  }

  final api = ref.read(apiProvider);
  final user = ref.read(userProvider);
  final lat = user?.location?.coordinates?.lat;
  final lng = user?.location?.coordinates?.lng;
  final params = <String, String>{
    'q': query.trim(),
    'type': type,
    'page': page.toString(),
    'limit': '20',
  };
  if (lat != null && lng != null) {
    params['lat'] = lat.toString();
    params['lng'] = lng.toString();
  }

  final response = await api.get('/search', queryParams: params);
  if (!response.success || response.data == null) {
    throw Exception(response.message ?? 'Search failed');
  }

  final body = response.data!;
  final data = body['data'];
  final pagination = body['pagination'] is Map
      ? Map<String, dynamic>.from(body['pagination'] as Map)
      : <String, dynamic>{};

  final pageResults = data is Map
      ? _asMapList(data['results'])
      : _asMapList(data);

  final merged = [
    ...(previous?.results ?? const <Map<String, dynamic>>[]),
    ...pageResults,
  ];

  return GlobalSearchPaged(
    query: query.trim(),
    type: type,
    results: merged,
    total: (data is Map ? data['total'] as num? : null)?.toInt() ??
        merged.length,
    page: (pagination['page'] as num?)?.toInt() ?? page,
    pages: (pagination['pages'] as num?)?.toInt() ?? page,
  );
}

/// Trending keywords for empty search landing.
final searchTrendingKeywordsProvider =
    FutureProvider<List<String>>((ref) async {
  final api = ref.read(apiProvider);
  final response = await api.get('/search/trending', requireAuth: false);
  if (!response.success || response.data == null) return const [];
  final data = response.data!['data'];
  if (data is! Map) return const [];
  final keywords = data['popularKeywords'];
  if (keywords is! List) return const [];
  return keywords.map((e) => e.toString()).where((e) => e.isNotEmpty).toList();
});

/// Normalize a search offer item into OfferDetailPage args.
Map<String, dynamic> offerArgsFromSearchItem(Map<String, dynamic> item) {
  final partner = item['partner'];
  final partnerMap = partner is Map
      ? {
          '_id': partner['_id'],
          'id': partner['_id'],
          'businessDetails': {
            'businessName': partner['name'],
          },
          'businessInfo': {
            'businessLogo': partner['logo'],
          },
        }
      : partner;

  return {
    ...item,
    'id': item['_id'] ?? item['id'],
    '_id': item['_id'] ?? item['id'],
    'partnerId': partnerMap ?? item['partnerId'],
    'shopName': partner is Map ? partner['name'] : null,
    'shopLogo': partner is Map ? partner['logo'] : null,
  };
}

/// Normalize a search product item into ProductDetailsPage args.
Map<String, dynamic> productArgsFromSearchItem(Map<String, dynamic> item) {
  final partner = item['partner'];
  return {
    ...item,
    'id': item['_id'] ?? item['id'],
    '_id': item['_id'] ?? item['id'],
    'name': item['title'] ?? item['name'],
    'title': item['title'] ?? item['name'],
    'partnerId': partner is Map
        ? {
            '_id': partner['_id'],
            'id': partner['_id'],
            'businessDetails': {
              'businessName': partner['name'],
            },
          }
        : (item['partnerId'] ?? partner),
  };
}
