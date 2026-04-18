import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/shop_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';

import 'auth_provider.dart';

part 'shops_provider.g.dart';

class PaginatedShops {
  final List<ShopModel> shops;
  final int page;
  final int totalPages;
  final int totalCount;

  const PaginatedShops({
    required this.shops,
    required this.page,
    required this.totalPages,
    required this.totalCount,
  });
}

@Riverpod(keepAlive: true)
Future<PaginatedShops> shops(
  Ref ref, {
  String? category,
  String? search,
  int page = 1,
  int limit = 20,
}) async {
  // Watch session to ensure clean state on logout
  ref.watch(sessionProvider);
  
  final api = ref.watch(apiProvider);
  final user = ref.watch(userProvider);

  final lat = user?.location?.coordinates?.lat;
  final lng = user?.location?.coordinates?.lng;

  if (lat == null || lng == null) {
    return const PaginatedShops(
      shops: [],
      page: 1,
      totalPages: 0,
      totalCount: 0,
    );
  }

  final queryParams = {
    'lat': lat.toString(),
    'lng': lng.toString(),
    'page': page.toString(),
    'limit': limit.toString(),
  };

  if (category != null && category != 'All' && category.isNotEmpty) {
    queryParams['category'] = category;
  }

  if (search != null && search.isNotEmpty) {
    queryParams['search'] = search;
  }

  final response = await api.get('/shops',
   queryParams: queryParams,
   requireAuth: false);

  if (response.success && response.data != null) {
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    final pagination = response.data!['pagination'];
    
    return PaginatedShops(
      shops: data.map((e) => ShopModel.fromJson(e as Map<String, dynamic>)).toList(),
      page: pagination['page'] as int? ?? 1,
      totalPages: pagination['pages'] as int? ?? 1,
      totalCount: pagination['total'] as int? ?? 0,
    );
  } else {
    throw Exception(response.message ?? 'Failed to fetch shops');
  }
}
