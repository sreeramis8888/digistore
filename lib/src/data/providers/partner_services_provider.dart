import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../utils/remove_nulls.dart';
import 'api_provider.dart';

class PartnerServicesState {
  final List<ServiceModel> services;
  final bool isLoading;
  final String? error;
  final String? currentCategory;
  final String searchQuery;

  const PartnerServicesState({
    this.services = const [],
    this.isLoading = false,
    this.error,
    this.currentCategory,
    this.searchQuery = '',
  });

  PartnerServicesState copyWith({
    List<ServiceModel>? services,
    bool? isLoading,
    String? error,
    String? currentCategory,
    bool clearCategory = false,
    String? searchQuery,
  }) {
    return PartnerServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentCategory: clearCategory ? null : (currentCategory ?? this.currentCategory),
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

List<dynamic> _extractServicesList(dynamic root) {
  if (root == null) return [];
  if (root is List) return root;
  if (root is Map) {
    if (root['services'] is List) return root['services'] as List;
    if (root['data'] is List) return root['data'] as List;
    if (root['data'] is Map) {
      final dataMap = root['data'] as Map;
      if (dataMap['services'] is List) return dataMap['services'] as List;
      if (dataMap['data'] is List) return dataMap['data'] as List;
      if (dataMap['items'] is List) return dataMap['items'] as List;
      if (dataMap['list'] is List) return dataMap['list'] as List;
      if (dataMap['results'] is List) return dataMap['results'] as List;
    }
    if (root['items'] is List) return root['items'] as List;
    if (root['list'] is List) return root['list'] as List;
    if (root['results'] is List) return root['results'] as List;
  }
  return [];
}

class PartnerServicesNotifier extends Notifier<PartnerServicesState> {
  @override
  PartnerServicesState build() {
    Future.microtask(() => getServices());
    return const PartnerServicesState();
  }

  void updateCategory(String? category) {
    getServices(category: category, isCategoryChange: true);
  }

  Future<void> getServices({
    String? category,
    String? search,
    bool isCategoryChange = false,
  }) async {
    final activeCategory = isCategoryChange ? category : (category ?? state.currentCategory);
    final activeSearch = search ?? state.searchQuery;

    state = state.copyWith(
      isLoading: true,
      error: null,
      currentCategory: activeCategory,
      clearCategory: isCategoryChange && (activeCategory == null || activeCategory == 'All'),
      searchQuery: activeSearch,
    );

    final api = ref.read(apiProvider);
    final queryParams = <String, String>{};
    if (activeCategory != null && activeCategory != 'All' && activeCategory.isNotEmpty) {
      queryParams['category'] = activeCategory;
    }
    if (activeSearch.isNotEmpty) {
      queryParams['search'] = activeSearch;
    }

    final res = await api.get('/services', queryParams: queryParams, requireAuth: true);

    if (res.success && res.data != null) {
      final rawList = _extractServicesList(res.data);
      final List<ServiceModel> list = [];
      for (var item in rawList) {
        if (item is Map) {
          try {
            list.add(ServiceModel.fromJson(Map<String, dynamic>.from(item)));
          } catch (_) {}
        }
      }
      state = state.copyWith(services: list, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: res.message ?? 'Failed to load partner services');
    }
  }

  Future<ApiResponse<ServiceModel>> createService(
    Map<String, dynamic> data, {
    List<http.MultipartFile>? files,
  }) async {
    final api = ref.read(apiProvider);
    final res = (files != null && files.isNotEmpty)
        ? await api.postMultipart(
            '/services',
            cleanMap(data).map((k, v) => MapEntry(
                  k,
                  v is List || v is Map ? jsonEncode(v) : v.toString(),
                )),
            files: files,
          )
        : await api.post('/services', data, requireAuth: true);

    if (res.success && res.data != null) {
      final sData = res.data!['data'] ?? res.data!;
      final rawService = (sData is Map && sData['service'] is Map)
          ? sData['service']
          : (sData is Map && sData['data'] is Map ? sData['data'] : sData);
      if (rawService is Map) {
        final created = ServiceModel.fromJson(Map<String, dynamic>.from(rawService));
        state = state.copyWith(services: [created, ...state.services]);
        return ApiResponse.success(created);
      }
    }
    return ApiResponse.error(res.message ?? 'Failed to create service');
  }

  Future<ApiResponse<ServiceModel>> updateService(
    String id,
    Map<String, dynamic> data, {
    List<http.MultipartFile>? files,
  }) async {
    final api = ref.read(apiProvider);
    final res = (files != null && files.isNotEmpty)
        ? await api.putMultipart(
            '/services/$id',
            cleanMap(data).map((k, v) => MapEntry(
                  k,
                  v is List || v is Map ? jsonEncode(v) : v.toString(),
                )),
            files: files,
          )
        : await api.put('/services/$id', data, requireAuth: true);

    if (res.success && res.data != null) {
      final sData = res.data!['data'] ?? res.data!;
      final rawService = (sData is Map && sData['service'] is Map)
          ? sData['service']
          : (sData is Map && sData['data'] is Map ? sData['data'] : sData);
      if (rawService is Map) {
        final updated = ServiceModel.fromJson(Map<String, dynamic>.from(rawService));
        state = state.copyWith(
          services: state.services.map((s) => s.id == id ? updated : s).toList(),
        );
        return ApiResponse.success(updated);
      }
    }
    return ApiResponse.error(res.message ?? 'Failed to update service');
  }

  Future<ApiResponse<void>> deleteService(String id) async {
    final api = ref.read(apiProvider);
    final res = await api.delete('/services/$id', requireAuth: true);
    if (res.success) {
      state = state.copyWith(
        services: state.services.where((s) => s.id != id).toList(),
      );
      return ApiResponse.success(null);
    }
    return ApiResponse.error(res.message ?? 'Failed to delete service');
  }

  Future<ApiResponse<void>> toggleServiceStatus(String id, bool isActive) async {
    final api = ref.read(apiProvider);
    final res = await api.patch('/services/$id/status', {'isActive': isActive}, requireAuth: true);
    if (res.success) {
      getServices();
      return ApiResponse.success(null);
    }
    return ApiResponse.error(res.message ?? 'Failed to update service status');
  }
}

final partnerServicesProvider = NotifierProvider<PartnerServicesNotifier, PartnerServicesState>(() {
  return PartnerServicesNotifier();
});
