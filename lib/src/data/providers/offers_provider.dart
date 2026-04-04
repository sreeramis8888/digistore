import 'dart:developer';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/offer_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';

part 'offers_provider.g.dart';

@riverpod
Future<List<OfferModel>> offers(
  Ref ref, {
  String? categoryId,
  String? search,
  bool? isDealOfDay,
}) async {
  final api = ref.watch(apiProvider);
  final user = ref.watch(userProvider);

  final lat = user?.location?.coordinates?.lat;
  final lng = user?.location?.coordinates?.lng;

  if (lat == null || lng == null) {
    return []; // Return empty if location is missing
  }

  final queryParams = {'lat': lat.toString(), 'lng': lng.toString()};

  if (categoryId != null && categoryId != 'All' && categoryId.isNotEmpty) {
    queryParams['category'] = categoryId;
  }

  if (search != null && search.isNotEmpty) {
    queryParams['search'] = search;
  }

  if (isDealOfDay != null) {
    queryParams['isDealOfDay'] = isDealOfDay.toString();
  }
  final response = await api.get(
    '/offers',
    queryParams: queryParams,
    requireAuth: false,
  );

  if (response.success && response.data != null) {
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    return data
        .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
        .toList();
  } else {
    throw Exception(response.message ?? 'Failed to fetch offers');
  }
}
