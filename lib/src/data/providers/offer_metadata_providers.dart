import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'api_provider.dart';

final subcategoriesProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(apiProvider);
  final response = await api.get('/offers/subcategories');
  
  if (response.success && response.data != null) {
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    return data.map((e) {
      if (e is Map) {
        return (e['name'] ?? e['title'] ?? '').toString();
      }
      return e.toString();
    }).where((element) => element.isNotEmpty).toList();
  } else {
    throw Exception(response.message ?? 'Failed to fetch subcategories');
  }
});

final membershipTiersProvider = FutureProvider<List<TierModel>>((ref) async {
  final api = ref.watch(apiProvider);
  final response = await api.get('/offers/membership-tiers');
  
  if (response.success && response.data != null) {
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    return data.map((e) => TierModel.fromJson(e as Map<String, dynamic>)).toList();
  } else {
    throw Exception(response.message ?? 'Failed to fetch membership tiers');
  }
});
