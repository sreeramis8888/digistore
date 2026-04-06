import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/redemption_model.dart';
import '../models/product_model.dart'; // For PaginationModel
import 'api_provider.dart';

class PartnerHistoryData {
  final int totalCustomers;
  final double commissionAmount;
  final double totalSalesViaSetgo;
  final List<RedemptionModel> redemptions;
  final PaginationModel? pagination;

  PartnerHistoryData({
    this.totalCustomers = 0,
    this.commissionAmount = 0,
    this.totalSalesViaSetgo = 0,
    this.redemptions = const [],
    this.pagination,
  });

  factory PartnerHistoryData.fromJson(Map<String, dynamic> json) {
    return PartnerHistoryData(
      totalCustomers: json['totalCustomers'] as int? ?? 0,
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble() ?? 0,
      totalSalesViaSetgo: (json['totalSalesViaSetgo'] as num?)?.toDouble() ?? 0,
      redemptions: (json['redemptions'] as List? ?? [])
          .map((e) => RedemptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'] as Map<String, dynamic>)
          : null,
    );
  }
}

class PartnerHistoryState {
  final PartnerHistoryData? data;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;

  PartnerHistoryState({
    this.data,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
  });

  PartnerHistoryState copyWith({
    PartnerHistoryData? data,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
  }) {
    return PartnerHistoryState(
      data: data ?? this.data,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
    );
  }
}

class PartnerHistoryNotifier extends Notifier<PartnerHistoryState> {
  @override
  PartnerHistoryState build() {
    Future.microtask(() => getHistory());
    return PartnerHistoryState();
  }

  Future<void> getHistory({int page = 1}) async {
    if (page == 1) {
      state = state.copyWith(isLoading: true, error: null);
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    final api = ref.read(apiProvider);
    final response = await api.get(
      '/history',
      queryParams: {
        'page': page.toString(),
        'limit': '20',
      },
    );

    if (response.success && response.data != null) {
      final historyData = PartnerHistoryData.fromJson(response.data!['data']);
      if (page == 1) {
        state = state.copyWith(
          data: historyData,
          isLoading: false,
        );
      } else {
        final currentData = state.data;
        if (currentData != null) {
          state = state.copyWith(
            data: PartnerHistoryData(
              totalCustomers: historyData.totalCustomers,
              commissionAmount: historyData.commissionAmount,
              totalSalesViaSetgo: historyData.totalSalesViaSetgo,
              redemptions: [...currentData.redemptions, ...historyData.redemptions],
              pagination: historyData.pagination,
            ),
            isLoadingMore: false,
          );
        }
      }
    } else {
      state = state.copyWith(
        error: response.message ?? 'Failed to load history',
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.data?.pagination == null) return;
    if (state.data!.pagination!.page >= state.data!.pagination!.pages) return;

    await getHistory(page: state.data!.pagination!.page + 1);
  }

  Future<void> refresh() async {
    await getHistory(page: 1);
  }
}

final partnerHistoryProvider =
    NotifierProvider<PartnerHistoryNotifier, PartnerHistoryState>(PartnerHistoryNotifier.new);
