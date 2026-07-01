import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/offer_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';

class CategoryOffersState {
  final List<OfferModel> offers;
  final bool isLoading;
  final bool isFetchingMore;
  final bool hasMore;
  final int page;
  final String? error;

  const CategoryOffersState({
    this.offers = const [],
    this.isLoading = true,
    this.isFetchingMore = false,
    this.hasMore = true,
    this.page = 1,
    this.error,
  });

  CategoryOffersState copyWith({
    List<OfferModel>? offers,
    bool? isLoading,
    bool? isFetchingMore,
    bool? hasMore,
    int? page,
    String? Function()? error,
  }) {
    return CategoryOffersState(
      offers: offers ?? this.offers,
      isLoading: isLoading ?? this.isLoading,
      isFetchingMore: isFetchingMore ?? this.isFetchingMore,
      hasMore: hasMore ?? this.hasMore,
      page: page ?? this.page,
      error: error != null ? error() : this.error,
    );
  }
}

class CategoryOffersNotifier extends StateNotifier<CategoryOffersState> {
  final Ref ref;
  final String? categoryId;

  CategoryOffersNotifier(this.ref, this.categoryId)
      : super(const CategoryOffersState()) {
    fetchOffers(isRefresh: true);
  }

  Future<void> fetchOffers({bool isRefresh = true}) async {
    if (isRefresh) {
      state = state.copyWith(
        isLoading: true,
        error: () => null,
        offers: [],
      );
    } else {
      if (state.isFetchingMore || !state.hasMore) return;
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
      }

      if (categoryId != null && categoryId != 'All' && categoryId!.isNotEmpty) {
        queryParams['category'] = categoryId!;
      }

      final response = await api.get('/offers', queryParams: queryParams);

      if (response.success && response.data != null) {
        final List<dynamic> data = response.data!['data'] as List<dynamic>;
        final pagination =
            response.data!['pagination'] as Map<String, dynamic>?;
        final newOffers = data
            .map((e) => OfferModel.fromJson(e as Map<String, dynamic>))
            .toList();

        final bool isHasMore = pagination != null
            ? ((pagination['page'] as int? ?? 1) <
                (pagination['pages'] as int? ?? 1))
            : (newOffers.length >= 20);

        state = state.copyWith(
          offers: isRefresh ? newOffers : [...state.offers, ...newOffers],
          isLoading: false,
          isFetchingMore: false,
          hasMore: isHasMore,
          page: isRefresh ? 1 : state.page + 1,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          isFetchingMore: false,
          error: () => response.message ?? 'Failed to load offers',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isFetchingMore: false,
        error: () => 'Failed to fetch category offers: $e',
      );
    }
  }
}

final categoryOffersProvider = StateNotifierProvider.family<
    CategoryOffersNotifier, CategoryOffersState, String?>((ref, categoryId) {
  return CategoryOffersNotifier(ref, categoryId);
});
