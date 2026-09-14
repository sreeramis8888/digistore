import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/service_model.dart';
import 'api_provider.dart';
import 'auth_provider.dart';

final selectedProductsTabProvider = StateProvider<int>((ref) => 0); // 0: Products, 1: Services
final selectedServicesCategoryProvider = StateProvider<int>((ref) => 0);

final serviceCategoriesProvider = FutureProvider<List<String>>((ref) async {
  final api = ref.watch(publicApiProvider);
  final res = await api.get('/services/categories', requireAuth: false);
  if (res.success && res.data != null) {
    dynamic raw = res.data!['data'] ?? res.data!['categories'] ?? res.data;
    if (raw is Map) {
      raw = raw['categories'] ?? raw['data'] ?? raw['items'];
    }
    if (raw is List) {
      final list = raw.map((e) {
        if (e is Map) return (e['name'] ?? e['category'] ?? e['title'] ?? '').toString();
        return e.toString();
      }).where((s) => s.trim().isNotEmpty).toList();
      if (list.isNotEmpty) return list;
    }
  }
  return ['Hair', 'Facial', 'Massage', 'Spa', 'Auto', 'Daily needs', 'Fashion', 'Home services'];
});

class ServicesState {
  final List<ServiceModel> services;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final int pages;
  final String? currentCategory;
  final String searchQuery;

  const ServicesState({
    this.services = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.pages = 1,
    this.currentCategory,
    this.searchQuery = '',
  });

  ServicesState copyWith({
    List<ServiceModel>? services,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    int? pages,
    String? currentCategory,
    String? searchQuery,
  }) {
    return ServicesState(
      services: services ?? this.services,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      page: page ?? this.page,
      pages: pages ?? this.pages,
      currentCategory: currentCategory ?? this.currentCategory,
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

class ServicesNotifier extends Notifier<ServicesState> {
  @override
  ServicesState build() {
    ref.watch(sessionProvider);
    Future.microtask(() => getServices());
    return const ServicesState();
  }

  Future<void> getServices({
    int page = 1,
    String? category,
    String? search,
    bool isRefresh = false,
  }) async {
    final activeCategory = category ?? state.currentCategory;
    final activeSearch = search ?? state.searchQuery;

    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        currentCategory: activeCategory,
        searchQuery: activeSearch,
        services: isRefresh ? [] : state.services,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(publicApiProvider);
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': '20',
    };

    if (activeCategory != null && activeCategory != 'All' && activeCategory.isNotEmpty) {
      queryParams['category'] = activeCategory;
    }
    if (activeSearch.isNotEmpty) {
      queryParams['search'] = activeSearch;
    }

    final res = await api.get('/services', queryParams: queryParams, requireAuth: false);

    if (res.success && res.data != null) {
      final dynamic rawList = _extractServicesList(res.data);
      final List<ServiceModel> fetched = [];
      for (var item in rawList) {
        if (item is Map) {
          try {
            fetched.add(ServiceModel.fromJson(Map<String, dynamic>.from(item)));
          } catch (e) {
            if (kDebugMode) {
              print('Error parsing ServiceModel: $e for item: $item');
            }
          }
        }
      }

      int totalPages = 1;
      if (res.data is Map) {
        final Map map = res.data as Map;
        final dynamic innerData = map['data'];
        final dynamic pagination = map['pagination'] ?? (innerData is Map ? innerData['pagination'] : null);
        if (pagination is Map) {
          final dynamic rawPages = pagination['pages'] ?? pagination['totalPages'];
          if (rawPages is num) {
            totalPages = rawPages.toInt();
          } else if (rawPages != null) {
            totalPages = int.tryParse(rawPages.toString()) ?? 1;
          }
        }
      }

      if (page == 1) {
        state = state.copyWith(
          services: fetched,
          isLoading: false,
          page: 1,
          pages: totalPages,
        );
      } else {
        state = state.copyWith(
          services: [...state.services, ...fetched],
          isLoadingMore: false,
          page: page,
          pages: totalPages,
        );
      }
    } else {
      state = state.copyWith(
        isLoading: false,
        isLoadingMore: false,
        error: res.message ?? 'Failed to load services',
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || state.page >= state.pages) return;
    await getServices(page: state.page + 1);
  }

  Future<void> refresh() async {
    await getServices(page: 1, isRefresh: true);
  }

  void updateSearch(String query) {
    if (query == state.searchQuery) return;
    getServices(page: 1, search: query, isRefresh: true);
  }

  void updateCategory(String? category) {
    getServices(page: 1, category: category, isRefresh: true);
  }
}

final servicesListProvider = NotifierProvider<ServicesNotifier, ServicesState>(() {
  return ServicesNotifier();
});

// Partner store specific services
final storeServicesProvider = FutureProvider.family<List<ServiceModel>, String>((ref, partnerId) async {
  final api = ref.watch(publicApiProvider);
  final res = await api.get('/services/partner/$partnerId', requireAuth: false);
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
    return list;
  }
  return [];
});

// Booking slots family provider
final bookingSlotsFamily = FutureProvider.family<SlotsResponseModel?, Map<String, dynamic>>((ref, params) async {
  final api = ref.watch(publicApiProvider);
  final partnerId = params['partnerId']?.toString() ?? '';
  final serviceId = (params['serviceIds'] is List && (params['serviceIds'] as List).isNotEmpty)
      ? params['serviceIds'][0].toString()
      : (params['serviceId']?.toString() ?? '');
  final date = params['date']?.toString() ?? '';

  final res = await api.get(
    '/bookings/slots',
    queryParams: {
      if (serviceId.isNotEmpty) 'serviceId': serviceId,
      if (partnerId.isNotEmpty) 'partnerId': partnerId,
      if (date.isNotEmpty) 'date': date,
    },
    requireAuth: false,
  );
  if (res.success && res.data != null) {
    final data = res.data!['data'] ?? res.data!;
    if (data is Map) {
      return SlotsResponseModel.fromJson(Map<String, dynamic>.from(data));
    }
  }
  return null;
});

final bookingSlotsProvider = FutureProvider.family<SlotsResponseModel?, ({String serviceId, String partnerId, String date})>(
  (ref, params) async {
    final api = ref.watch(publicApiProvider);
    final res = await api.get(
      '/bookings/slots',
      queryParams: {
        'serviceId': params.serviceId,
        'partnerId': params.partnerId,
        'date': params.date,
      },
      requireAuth: false,
    );
    if (res.success && res.data != null) {
      final data = res.data!['data'] ?? res.data!;
      if (data is Map) {
        return SlotsResponseModel.fromJson(Map<String, dynamic>.from(data));
      }
    }
    return null;
  },
);

// Customer bookings provider with status filter family
final customerBookingsProvider = FutureProvider.family<List<BookingModel>, String>((ref, statusFilter) async {
  final api = ref.watch(apiProvider);
  final queryParams = <String, String>{};
  if (statusFilter.isNotEmpty && statusFilter.toLowerCase() != 'all') {
    final s = statusFilter.toLowerCase();
    if (s == 'past') {
      queryParams['status'] = 'COMPLETED';
    } else {
      queryParams['status'] = statusFilter.toUpperCase();
    }
  }
  final res = await api.get('/bookings/my-bookings', queryParams: queryParams);
  if (res.success && res.data != null) {
    final rawList = _extractServicesList(res.data);
    final List<BookingModel> list = [];
    for (var item in rawList) {
      if (item is Map) {
        try {
          list.add(BookingModel.fromJson(Map<String, dynamic>.from(item)));
        } catch (_) {}
      }
    }
    return list;
  }
  return [];
});

class BookingService {
  static Future<ApiResponse<BookingModel>> createBooking({
    required ApiProvider api,
    String? partnerId,
    List<String>? serviceIds,
    String? bookingDate,
    String? startTime,
    String? notes,
    Map<String, dynamic>? bookingData,
  }) async {
    final payload = bookingData ?? {
      'partnerId': partnerId,
      'serviceIds': serviceIds,
      'bookingDate': bookingDate,
      'date': bookingDate,
      'startTime': startTime,
      'timeSlot': startTime,
      if (notes != null && notes.isNotEmpty) 'notes': notes,
    };
    final res = await api.post('/bookings', payload);
    if (res.success && res.data != null) {
      final data = res.data!['data'] ?? res.data!;
      if (data is Map) {
        final booking = BookingModel.fromJson(Map<String, dynamic>.from(data));
        return ApiResponse.success(booking);
      }
    }
    return ApiResponse.error(res.message ?? 'Failed to complete booking');
  }

  static Future<ApiResponse<bool>> cancelBooking({
    required ApiProvider api,
    required String bookingId,
    String? reason,
  }) async {
    final res = await api.post('/bookings/$bookingId/cancel', {
      if (reason != null && reason.isNotEmpty) 'reason': reason,
    });
    if (res.success) {
      return ApiResponse.success(true);
    }
    return ApiResponse.error(res.message ?? 'Failed to cancel booking');
  }
}
