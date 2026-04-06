import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/offer_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';
import 'user_type_provider.dart';

part 'offers_provider.g.dart';

class PaginatedOffers {
  final List<OfferModel> offers;
  final int page;
  final int totalPages;
  final int totalCount;

  const PaginatedOffers({
    required this.offers,
    required this.page,
    required this.totalPages,
    required this.totalCount,
  });

  const PaginatedOffers.empty()
      : offers = const [],
        page = 1,
        totalPages = 0,
        totalCount = 0;
}

@riverpod
Future<PaginatedOffers> offers(
  Ref ref, {
  String? categoryId,
  String? search,
  bool? isDealOfDay,
  int page = 1,
  int limit = 20,
}) async {
  final api = ref.watch(apiProvider);
  final user = ref.watch(userProvider);
  final userType = ref.watch(userTypeProvider);

  final lat = user?.location?.coordinates?.lat;
  final lng = user?.location?.coordinates?.lng;

  final queryParams = <String, String>{
    'page': page.toString(),
    'limit': limit.toString(),
  };

  if (lat != null && lng != null) {
    queryParams['lat'] = lat.toString();
    queryParams['lng'] = lng.toString();
  } else if (userType == UserType.customer) {
    // For regular users, location is required for marketplace offers
    log(name: 'OffersProvider', 'Returning empty because location is null for regular user');
    return const PaginatedOffers.empty();
  }

  if (categoryId != null && categoryId != 'All' && categoryId.isNotEmpty) {
    queryParams['category'] = categoryId;
  }

  if (search != null && search.isNotEmpty) {
    queryParams['search'] = search;
  }

  if (isDealOfDay != null) {
    queryParams['isDealOfDay'] = isDealOfDay.toString();
  }

  if (user?.currentTier?.name != null) {
    queryParams['tier'] = user!.currentTier!.name!;
  }

  final response = await api.get('/offers', queryParams: queryParams, requireAuth: true);

  if (response.success && response.data != null) {
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    final pagination = response.data!['pagination'];

    return PaginatedOffers(
      offers: data.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList(),
      page: pagination['page'] as int? ?? 1,
      totalPages: pagination['pages'] as int? ?? 1,
      totalCount: pagination['total'] as int? ?? 0,
    );
  } else {
    throw Exception(response.message ?? 'Failed to fetch offers');
  }
}
