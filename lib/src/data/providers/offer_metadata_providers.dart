import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'api_provider.dart';
import 'category_provider.dart';

final subcategoriesProvider = FutureProvider<List<String>>((ref) async {
  final cats = await ref.watch(categoriesProvider.future);
  final Set<String> allSubs = {};
  for (final cat in cats) {
    if (cat.subcategories != null) {
      for (final s in cat.subcategories!) {
        if (s.trim().isNotEmpty) allSubs.add(s.trim());
      }
    }
  }
  return allSubs.toList();
});

final categorySubcategoriesProvider = FutureProvider.family<List<String>, String?>((ref, categoryNameOrId) async {
  final cats = await ref.watch(categoriesProvider.future);
  if (categoryNameOrId == null || categoryNameOrId.trim().isEmpty) {
    final Set<String> allSubs = {};
    for (final cat in cats) {
      if (cat.subcategories != null) {
        for (final s in cat.subcategories!) {
          if (s.trim().isNotEmpty) allSubs.add(s.trim());
        }
      }
    }
    return allSubs.toList();
  }

  final target = categoryNameOrId.trim().toLowerCase();
  final matched = cats.where((c) =>
    (c.id != null && c.id!.toLowerCase() == target) ||
    (c.name != null && c.name!.toLowerCase() == target) ||
    (c.slug != null && c.slug!.toLowerCase() == target)
  ).firstOrNull;

  if (matched != null && matched.subcategories != null && matched.subcategories!.isNotEmpty) {
    return matched.subcategories!;
  }

  final Set<String> allSubs = {};
  for (final cat in cats) {
    if (cat.subcategories != null) {
      for (final s in cat.subcategories!) {
        if (s.trim().isNotEmpty) allSubs.add(s.trim());
      }
    }
  }
  return allSubs.toList();
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
