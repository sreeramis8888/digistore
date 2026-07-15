import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/banner_model.dart';
import '../../utils/safe_parser.dart';
import '../utils/global_variables.dart';
import 'api_provider.dart';
import 'user_type_provider.dart';

class BannerFilter {
  final String? page;
  final String? category;

  const BannerFilter({this.page, this.category});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BannerFilter &&
          runtimeType == other.runtimeType &&
          page == other.page &&
          category == other.category;

  @override
  int get hashCode => Object.hash(page, category);

  @override
  String toString() => 'BannerFilter(page: $page, category: $category)';
}

final bannersProvider = FutureProvider.family<List<BannerModel>, BannerFilter>((ref, filter) async {
  if (GlobalVariables.isPartner || ref.watch(userTypeProvider) == UserType.partner) {
    return [];
  }
  try {
    final api = ref.watch(apiProvider);
    final queryParams = <String, String>{};
    if (filter.page != null && filter.page!.isNotEmpty) {
      queryParams['page'] = filter.page!;
    }
    if (filter.category != null && filter.category!.isNotEmpty && filter.category != 'All') {
      queryParams['category'] = filter.category!;
    }

    final response = await api.get('/banners', queryParams: queryParams);
    if (response.success && response.data != null) {
      return parseBannersFromResponse(response.data!);
    }
  } catch (e, stack) {
    log('Error fetching banners for $filter: $e', stackTrace: stack);
  }
  return [];
});

List<BannerModel> parseBannersFromResponse(Map<String, dynamic> responseData) {
  dynamic rawList = responseData['data'];
  if (rawList is Map) {
    rawList = rawList['banners'] ?? rawList['all'] ?? rawList['data'] ?? rawList['list'];
    if (rawList is Map) {
      rawList = rawList['all'] ?? rawList['banners'] ?? rawList['data'];
    }
  } else if (rawList == null && responseData['banners'] != null) {
    rawList = responseData['banners'];
    if (rawList is Map) {
      rawList = rawList['all'] ?? rawList['banners'] ?? rawList['data'];
    }
  }
  return SafeParser.parseList(rawList, BannerModel.fromJson) ?? [];
}
