import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/service_model.dart';
import 'api_provider.dart';

final partnerBookingDashboardProvider = FutureProvider.family<PartnerBookingDashboardModel?, String?>((ref, date) async {
  final api = ref.watch(apiProvider);
  final queryParams = <String, String>{};
  if (date != null && date.isNotEmpty) {
    queryParams['date'] = date;
  }
  final res = await api.get('/bookings/dashboard', queryParams: queryParams, requireAuth: true);
  if (res.success && res.data != null) {
    final dynamic data = res.data!['data'] ?? res.data!;
    if (data is Map) {
      return PartnerBookingDashboardModel.fromJson(Map<String, dynamic>.from(data));
    }
  }
  return null;
});

class PartnerBookingsState {
  final List<BookingModel> bookings;
  final bool isLoading;
  final String? error;
  final String selectedStatus;
  final String? selectedDate;
  final String searchQuery;

  const PartnerBookingsState({
    this.bookings = const [],
    this.isLoading = false,
    this.error,
    this.selectedStatus = 'all',
    this.selectedDate,
    this.searchQuery = '',
  });

  PartnerBookingsState copyWith({
    List<BookingModel>? bookings,
    bool? isLoading,
    String? error,
    String? selectedStatus,
    String? selectedDate,
    String? searchQuery,
  }) {
    return PartnerBookingsState(
      bookings: bookings ?? this.bookings,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      selectedStatus: selectedStatus ?? this.selectedStatus,
      selectedDate: selectedDate ?? this.selectedDate,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

class PartnerBookingsNotifier extends Notifier<PartnerBookingsState> {
  @override
  PartnerBookingsState build() {
    Future.microtask(() => fetchBookings());
    return const PartnerBookingsState();
  }

  Future<void> fetchBookings({String? status, String? date, String? search, int? limit}) async {
    state = state.copyWith(
      isLoading: true,
      error: null,
      selectedStatus: status ?? state.selectedStatus,
      selectedDate: date ?? state.selectedDate,
      searchQuery: search ?? state.searchQuery,
    );

    final api = ref.read(apiProvider);
    final queryParams = <String, String>{};
    if (state.selectedStatus != 'all') {
      queryParams['status'] = state.selectedStatus;
    }
    if (state.selectedDate != null && state.selectedDate!.isNotEmpty) {
      queryParams['date'] = state.selectedDate!;
    }
    if (state.searchQuery.isNotEmpty) {
      queryParams['search'] = state.searchQuery;
    }
    if (limit != null) {
      queryParams['limit'] = '$limit';
    }

    final res = await api.get('/bookings', queryParams: queryParams, requireAuth: true);
    if (res.success && res.data != null) {
      final dynamic rawList = res.data!['data'] ?? res.data!['bookings'];
      final List<BookingModel> list = [];
      if (rawList is List) {
        for (var item in rawList) {
          if (item is Map) {
            list.add(BookingModel.fromJson(Map<String, dynamic>.from(item)));
          }
        }
      }
      state = state.copyWith(bookings: list, isLoading: false);
    } else {
      state = state.copyWith(isLoading: false, error: res.message ?? 'Failed to load bookings');
    }
  }

  Future<ApiResponse<void>> updateBookingStatus(String bookingId, String newStatus) async {
    final api = ref.read(apiProvider);
    final res = await api.patch('/bookings/$bookingId/status', {'status': newStatus}, requireAuth: true);
    if (res.success) {
      fetchBookings();
      ref.invalidate(partnerHomeBookingRequestsProvider);
      return ApiResponse.success(null);
    }
    return ApiResponse.error(res.message ?? 'Failed to update status');
  }

  Future<ApiResponse<BookingModel>> issueWalkInToken(Map<String, dynamic> data) async {
    final api = ref.read(apiProvider);
    final res = await api.post('/bookings/walk-in', data, requireAuth: true);
    if (res.success && res.data != null) {
      final bData = res.data!['data'] ?? res.data!;
      final booking = BookingModel.fromJson(Map<String, dynamic>.from(bData as Map));
      fetchBookings();
      ref.invalidate(partnerHomeBookingRequestsProvider);
      return ApiResponse.success(booking);
    }
    return ApiResponse.error(res.message ?? 'Failed to issue walk-in token');
  }

  Future<ApiResponse<void>> blockSlot(Map<String, dynamic> data) async {
    final api = ref.read(apiProvider);
    final res = await api.post('/bookings/block-slot', data, requireAuth: true);
    return res.success ? ApiResponse.success(null) : ApiResponse.error(res.message ?? 'Failed to block slot');
  }

  Future<ApiResponse<void>> unblockSlot(Map<String, dynamic> data) async {
    final api = ref.read(apiProvider);
    final res = await api.post('/bookings/unblock-slot', data, requireAuth: true);
    return res.success ? ApiResponse.success(null) : ApiResponse.error(res.message ?? 'Failed to unblock slot');
  }

  Future<ApiResponse<void>> emergencyDelay({required String date, required int delayMinutes, required String reason}) async {
    final api = ref.read(apiProvider);
    final res = await api.post('/bookings/emergency-delay', {
      'date': date,
      'delayMinutes': delayMinutes,
      'reason': reason,
    }, requireAuth: true);
    return res.success ? ApiResponse.success(null) : ApiResponse.error(res.message ?? 'Failed to broadcast delay');
  }
}

final partnerBookingsProvider = NotifierProvider<PartnerBookingsNotifier, PartnerBookingsState>(() {
  return PartnerBookingsNotifier();
});

/// Independent list for partner home "Booking Requests" (not affected by bookings-page filters).
final partnerHomeBookingRequestsProvider = FutureProvider<List<BookingModel>>((ref) async {
  final api = ref.watch(apiProvider);
  final res = await api.get(
    '/bookings',
    queryParams: const {'limit': '3'},
    requireAuth: true,
  );
  if (res.success && res.data != null) {
    final dynamic rawList = res.data!['data'] ?? res.data!['bookings'];
    final List<BookingModel> list = [];
    if (rawList is List) {
      for (var item in rawList) {
        if (item is Map) {
          list.add(BookingModel.fromJson(Map<String, dynamic>.from(item)));
        }
      }
    }
    return list;
  }
  return [];
});

final partnerBlockedSlotsProvider = FutureProvider<List<BlockedSlotModel>>((ref) async {
  final api = ref.watch(apiProvider);
  final res = await api.get('/bookings/blocked-slots', requireAuth: true);
  if (res.success && res.data != null) {
    final dynamic list = res.data!['data'] ?? res.data!;
    if (list is List) {
      return list.map((e) => BlockedSlotModel.fromJson(Map<String, dynamic>.from(e as Map))).toList();
    }
  }
  return [];
});
