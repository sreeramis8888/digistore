import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import 'api_provider.dart';
import 'category_provider.dart';
import 'partner_provider.dart';

/// All subcategories across every main category (legacy / rare use).
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
  return allSubs.toList()..sort();
});

/// Subcategories that belong to a specific main business category only.
/// Never falls back to the full cross-category list when a parent is provided.
final categorySubcategoriesProvider =
    FutureProvider.family<List<String>, String?>((ref, categoryNameOrId) async {
      final cats = await ref.watch(categoriesProvider.future);
      if (categoryNameOrId == null || categoryNameOrId.trim().isEmpty) {
        return const <String>[];
      }

      final target = categoryNameOrId.trim().toLowerCase();
      final matched = cats
          .where(
            (c) =>
                (c.id != null && c.id!.toLowerCase() == target) ||
                (c.name != null && c.name!.toLowerCase() == target) ||
                (c.slug != null && c.slug!.toLowerCase() == target),
          )
          .firstOrNull;

      if (matched == null || matched.subcategories == null) {
        return const <String>[];
      }

      final Set<String> subs = {};
      for (final s in matched.subcategories!) {
        if (s.trim().isNotEmpty) subs.add(s.trim());
      }
      return subs.toList()..sort();
    });

/// Subcategories the partner has selected on their profile only.
/// Used by Create Service / Create Offer dropdowns — never the full catalog.
final partnerSelectedSubcategoriesProvider = Provider<List<String>>((ref) {
  final partner = ref.watch(partnerProvider);
  final selected = partner?.serviceCategories ?? const <String>[];
  final cleaned = selected
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toSet()
      .toList()
    ..sort();
  return cleaned;
});

/// @Deprecated Prefer [partnerSelectedSubcategoriesProvider].
/// Kept as AsyncValue-compatible alias for existing watch sites.
final partnerBusinessSubcategoriesProvider = FutureProvider<List<String>>((
  ref,
) async {
  return ref.watch(partnerSelectedSubcategoriesProvider);
});

final membershipTiersProvider = FutureProvider<List<TierModel>>((ref) async {
  final api = ref.watch(apiProvider);
  final response = await api.get('/offers/membership-tiers');

  if (response.success && response.data != null) {
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => TierModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception(response.message ?? 'Failed to fetch membership tiers');
  }
});
