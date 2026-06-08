import 'dart:developer';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/offer_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';
import 'user_type_provider.dart';
import 'auth_provider.dart';

part 'offers_provider.g.dart';

const Map<String, String> offerTypeLabels = {
  "DO": "Discount Offer",
  "BG": "Buy 1 Get...",
  "DNP": "Discount on Next Purchase",
  "CO": "Combo Offer",
  "RC": "Redeemable Coupons",
  "LD": "Lucky Draw",
  "CP": "Combo Purchase",
  "LO": "Loyalty Offer",
  "LTO": "Limited Time Offer",
  "CS": "Clearance Sale",
};

class PaginatedOffers {
  final List<OfferModel> offers;
  final int page;
  final int totalPages;
  final int totalCount;
  final bool hasMore;
  final bool isLoading;
  final bool isFetchingMore;
  final String? error;
  final String? currentCategoryId;

  // Explore (no-location) section
  final List<OfferModel> exploreOffers;
  final int explorePage;
  final int exploreTotalPages;
  final bool exploreHasMore;
  final bool isExploreLoading;
  final bool isExploreFetchingMore;
  final String searchQuery;

  const PaginatedOffers({
    required this.offers,
    required this.page,
    required this.totalPages,
    required this.totalCount,
    this.hasMore = false,
    this.isLoading = false,
    this.isFetchingMore = false,
    this.error,
    this.currentCategoryId,
    this.exploreOffers = const [],
    this.explorePage = 1,
    this.exploreTotalPages = 0,
    this.exploreHasMore = false,
    this.isExploreLoading = false,
    this.isExploreFetchingMore = false,
    this.searchQuery = '',
  });

  const PaginatedOffers.empty()
    : offers = const [],
      page = 1,
      totalPages = 0,
      totalCount = 0,
      hasMore = false,
      isLoading = false,
      isFetchingMore = false,
      error = null,
      currentCategoryId = null,
      exploreOffers = const [],
      explorePage = 1,
      exploreTotalPages = 0,
      exploreHasMore = false,
      isExploreLoading = false,
      isExploreFetchingMore = false,
      searchQuery = '';

  PaginatedOffers copyWith({
    List<OfferModel>? offers,
    int? page,
    int? totalPages,
    int? totalCount,
    bool? hasMore,
    bool? isLoading,
    bool? isFetchingMore,
    String? Function()? error,
    String? Function()? currentCategoryId,
    List<OfferModel>? exploreOffers,
    int? explorePage,
    int? exploreTotalPages,
    bool? exploreHasMore,
    bool? isExploreLoading,
    bool? isExploreFetchingMore,
    String? searchQuery,
  }) {
    return PaginatedOffers(
      offers: offers ?? this.offers,
      page: page ?? this.page,
      totalPages: totalPages ?? this.totalPages,
      totalCount: totalCount ?? this.totalCount,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      error: error != null ? error() : this.error,
      currentCategoryId: currentCategoryId != null ? currentCategoryId() : this.currentCategoryId,
      exploreOffers: exploreOffers ?? this.exploreOffers,
      explorePage: explorePage ?? this.explorePage,
      exploreTotalPages: exploreTotalPages ?? this.exploreTotalPages,
      exploreHasMore: exploreHasMore ?? this.exploreHasMore,
      isExploreLoading: isExploreLoading ?? this.isExploreLoading,
      isExploreFetchingMore: isExploreFetchingMore ?? this.isExploreFetchingMore,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }
}

@riverpod
class Offers extends _$Offers {
  @override
  PaginatedOffers build() {
    ref.watch(sessionProvider);
    Future.microtask(() => fetchOffers());
    return const PaginatedOffers.empty();
  }

  Future<void> fetchOffers({
    String? categoryId,
    String? search,
    bool isRefresh = true,
  }) async {
    final currentSearch = search ?? state.searchQuery;
    final currentUserType = ref.read(userTypeProvider);

    if (isRefresh) {
      final isCategoryChange = categoryId != state.currentCategoryId;
      state = state.copyWith(
        isLoading: true,
        error: () => null,
        searchQuery: currentSearch,
        offers: isCategoryChange ? [] : state.offers,
        exploreOffers: isCategoryChange ? [] : state.exploreOffers,
        currentCategoryId: isCategoryChange
            ? () => categoryId
            : () => state.currentCategoryId,
      );
    } else {
      if (state.isFetchingMore) return;
      state = state.copyWith(isFetchingMore: true, error: () => null);
    }

    try {
      final api = ref.read(apiProvider);
      final user = ref.read(userProvider);

      final lat = user?.location?.coordinates?.lat;
      final lng = user?.location?.coordinates?.lng;

      final queryParams = <String, String>{
        'page': isRefresh ? '1' : (state.page + 1).toString(),
        'limit': '20',
      };

      if (lat != null && lng != null) {
        queryParams['lat'] = lat.toString();
        queryParams['lng'] = lng.toString();
      } else if (currentUserType == UserType.customer) {
        state = const PaginatedOffers.empty();
        return;
      }

      if (categoryId != null && categoryId != 'All' && categoryId.isNotEmpty) {
        queryParams['category'] = categoryId;
      }

      if (currentSearch.isNotEmpty) {
        queryParams['search'] = currentSearch;
      }

      if (user?.currentTier?.name != null) {
        queryParams['tier'] = user!.currentTier!.name!;
      }

      final response = await api.get('/offers', queryParams: queryParams);

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data!['data'] as List<dynamic>;
        final pagination = response.data!['pagination'];
        final newOffers = data
            .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final isHasMore = pagination['hasMore'] as bool? ?? ((pagination['page'] as int? ?? 1) < (pagination['pages'] as int? ?? 1));

        state = state.copyWith(
          offers: isRefresh ? newOffers : [...state.offers, ...newOffers],
          page: pagination['page'] as int? ?? 1,
          totalPages: pagination['pages'] as int? ?? 1,
          totalCount: pagination['total'] as int? ?? 0,
          hasMore: isHasMore,
          isLoading: false,
          isFetchingMore: false,
          error: () => null,
          currentCategoryId: () => categoryId,
        );
        log('fetchOffers success: newOffers.length=${newOffers.length}, currentCategoryId=$categoryId');
      } else {
        state = state.copyWith(isLoading: false, isFetchingMore: false, error: () => response.message);
      }
    } catch (e, stack) {
      log('Error fetching offers: $e', stackTrace: stack);
      state = state.copyWith(isLoading: false, isFetchingMore: false, error: () => 'Parsing error: $e');
    }

    if (isRefresh && currentUserType == UserType.customer) {
      fetchExploreOffers(categoryId: categoryId);
    }
  }

  Future<void> fetchExploreOffers({
    String? categoryId,
    bool isRefresh = true,
  }) async {
    if (isRefresh) {
      if (state.isExploreLoading) return;
      state = state.copyWith(isExploreLoading: true);
    } else {
      if (state.isExploreFetchingMore) return;
      state = state.copyWith(isExploreFetchingMore: true);
    }

    try {
      final api = ref.read(apiProvider);
      final user = ref.read(userProvider);

      // No lat/lng — fetch all offers regardless of location
      final queryParams = <String, String>{
        'page': isRefresh ? '1' : (state.explorePage + 1).toString(),
        'limit': '20',
      };

      if (categoryId != null && categoryId != 'All' && categoryId.isNotEmpty) {
        queryParams['category'] = categoryId;
      }

      if (state.searchQuery.isNotEmpty) {
        queryParams['search'] = state.searchQuery;
      }

      if (user?.currentTier?.name != null) {
        queryParams['tier'] = user!.currentTier!.name!;
      }

      final response = await api.get('/offers', queryParams: queryParams);

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data!['data'] as List<dynamic>;
        final pagination = response.data!['pagination'];
        final newOffers = data
            .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
            .toList();

        // Exclude offers already shown in the nearby section
        final nearbyIds = state.offers.map((o) => o.id).toSet();
        final filteredOffers = newOffers
            .where((o) => !nearbyIds.contains(o.id))
            .toList();

        final isExploreHasMore = pagination['hasMore'] as bool? ?? ((pagination['page'] as int? ?? 1) < (pagination['pages'] as int? ?? 1));

        state = state.copyWith(
          exploreOffers: isRefresh
              ? filteredOffers
              : [...state.exploreOffers, ...filteredOffers],
          explorePage: pagination['page'] as int? ?? 1,
          exploreTotalPages: pagination['pages'] as int? ?? 1,
          exploreHasMore: isExploreHasMore,
          isExploreLoading: false,
          isExploreFetchingMore: false,
        );
      } else {
        state = state.copyWith(isExploreLoading: false, isExploreFetchingMore: false);
      }
    } catch (e, stack) {
      log('Error fetching explore offers: $e', stackTrace: stack);
      state = state.copyWith(isExploreLoading: false, isExploreFetchingMore: false);
    }
  }

  void updateSearch(String query) {
    if (state.searchQuery == query) return;
    fetchOffers(search: query, isRefresh: true);
  }

  void addOffer(OfferModel offer) {
    state = state.copyWith(
      offers: [offer, ...state.offers],
      totalCount: state.totalCount + 1,
    );
  }

  void removeOfferLocally(String id) {
    state = state.copyWith(
      offers: state.offers.where((o) => o.id != id).toList(),
      totalCount: (state.totalCount > 0) ? state.totalCount - 1 : 0,
    );
  }

  void updateOfferLocally(OfferModel updatedOffer) {
    final index = state.offers.indexWhere((o) => o.id == updatedOffer.id);
    if (index != -1) {
      final newOffers = List<OfferModel>.from(state.offers);
      newOffers[index] = updatedOffer;
      state = state.copyWith(offers: newOffers);
    }
  }

  Future<void> deleteOffer(String id) async {
    final api = ref.read(apiProvider);
    final response = await api.delete('/offers/$id');
    if (response.success) {
      removeOfferLocally(id);
    } else {
      throw Exception(response.message ?? 'Failed to delete offer');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> generateRedemptionOtp(
    String offerId,
    String userPhone,
  ) async {
    try {
      final api = ref.read(publicApiProvider);
      final response = await api.post('/partner/offers/$offerId/generate-otp', {
        'userPhone': userPhone,
      });

      return response;
    } catch (e, stack) {
      log('Error generating redemption OTP: $e', stackTrace: stack);
      return ApiResponse.error('Failed to generate OTP: $e');
    }
  }

  Future<ApiResponse<Map<String, dynamic>>> verifyRedemptionOtp({
    required String offerId,
    required String userPhone,
    required String otp,
    double? saleAmount,
    String? billNo,
  }) async {
    try {
      final api = ref.read(publicApiProvider);
      final Map<String, dynamic> payload = {
        'userPhone': userPhone,
        'otp': otp,
      };
      if (saleAmount != null) {
        payload['saleAmount'] = saleAmount;
      }
      if (billNo != null) {
        payload['billNo'] = billNo;
      }

      final response = await api.post(
        '/partner/offers/$offerId/verify-otp',
        payload,
      );

      return response;
    } catch (e, stack) {
      log('Error verifying redemption OTP: $e', stackTrace: stack);
      return ApiResponse.error('Failed to verify OTP: $e');
    }
  }
}

@Riverpod(keepAlive: true)
Future<List<OfferModel>> activeDeals(Ref ref, {required String dealType}) async {
  final api = ref.watch(apiProvider);
  final response = await api.get(
    '/offers/deals/active',
    queryParams: {'dealType': dealType},
  );

  if (response.success && response.data != null) {
    final List<dynamic> data = response.data!['data'] as List<dynamic>;
    return data.map((e) => OfferModel.fromJson(e as Map<String, dynamic>)).toList();
  } else {
    throw Exception(response.message ?? 'Failed to fetch active deals');
  }
}
