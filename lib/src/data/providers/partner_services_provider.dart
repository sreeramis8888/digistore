import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
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
    String? searchQuery,
  }) {
    return PartnerServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      currentCategory: currentCategory ?? this.currentCategory,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PartnerServicesNotifier extends Notifier<PartnerServicesState> {
  @override
  PartnerServicesState build() {
    Future.microtask(() => getServices());
    return const PartnerServicesState();
  }

  Future<void> getServices({String? category, String? search}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      currentCategory: category ?? state.currentCategory,
      searchQuery: search ?? state.searchQuery,
    );

    final api = ref.read(apiProvider);
    final queryParams = <String, String>{};
    if (state.currentCategory != null && state.currentCategory != 'All') {
      queryParams['category'] = state.currentCategory!;
    }
    if (state.searchQuery.isNotEmpty) {
      queryParams['search'] = state.searchQuery;
    }

    final res = await api.get('/services', queryParams: queryParams, requireAuth: true);

    if (res.success && res.data != null) {
      final dynamic rawList = res.data!['data'] ?? res.data!['services'];
      final List<ServiceModel> list = [];
      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map) {
            list.add(ServiceModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
      state = state.copyWith(services: list, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: res.message ?? 'Failed to load partner services');
    }
  }

  Future<ApiResponse<ServiceModel>> createService(Map<String, dynamic> data) async {
    final api = ref.read(apiProvider);
    final res = await api.post('/services', data, requireAuth: true);
    if (res.success && res.data != null) {
      final sData = res.data!['data'] ?? res.data!;
      final created = ServiceModel.fromJson(Map<String, dynamic>.from(sData as Map));
      state = state.copyWith(services: [created, ...state.services]);
      return ApiResponse.success(created);
    }
    return ApiResponse.error(res.message ?? 'Failed to create service');
  }

  Future<ApiResponse<ServiceModel>> updateService(String id, Map<String, dynamic> data) async {
    final api = ref.read(apiProvider);
    final res = await api.put('/services/$id', data, requireAuth: true);
    if (res.success && res.data != null) {
      final sData = res.data!['data'] ?? res.data!;
      final updated = ServiceModel.fromJson(Map<String, dynamic>.from(sData as Map));
      state = state.copyWith(
        services: state.services.map((s) => s.id == id ? updated : s).toList(),
      );
      return ApiResponse.success(updated);
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
