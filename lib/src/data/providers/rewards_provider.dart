import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/reward_model.dart';
import '../models/claimed_reward_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';

part 'rewards_provider.g.dart';

class RewardsState {
  final List<RewardModel> rewards;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final int page;
  final int pages;
  final String? category;

  RewardsState({
    this.rewards = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.page = 1,
    this.pages = 1,
    this.category,
  });

  RewardsState copyWith({
    List<RewardModel>? rewards,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    int? page,
    int? pages,
    String? category,
  }) {
    return RewardsState(
      rewards: rewards ?? this.rewards,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error ?? this.error,
      page: page ?? this.page,
      pages: pages ?? this.pages,
      category: category ?? this.category,
    );
  }
}

@Riverpod(keepAlive: true)
class RewardsList extends _$RewardsList {
  @override
  RewardsState build() {
    ref.watch(userProvider);
    Future.microtask(() => getRewards());
    return RewardsState();
  }

  Future<void> getRewards({int page = 1, String? category}) async {
    final currentCategory = category ?? state.category;

    if (page == 1) {
      state = state.copyWith(
        isLoading: true,
        error: null,
        category: currentCategory,
        rewards: category != null ? [] : state.rewards,
      );
    } else {
      state = state.copyWith(isLoadingMore: true, error: null);
    }

    try {
      final api = ref.read(apiProvider);
      final user = ref.read(userProvider);
      
      final queryParams = {
        'page': page.toString(),
        'limit': '10',
      };

      final coords = user?.location?.coordinates;
      if (coords != null) {
        queryParams['lat'] = coords.lat.toString();
        queryParams['lng'] = coords.lng.toString();
      }

      final tier = user?.currentTier?.name;
      if (tier != null) {
        queryParams['tier'] = tier;
      }

      if (currentCategory != null && currentCategory != 'All' && currentCategory.isNotEmpty) {
        queryParams['category'] = currentCategory;
      }

      final response = await api.get(
        '/rewards',
        queryParams: queryParams,
        requireAuth: false,
      );

      if (response.success && response.data != null) {
        final paginated = PaginatedRewards.fromJson(response.data!);
        
        if (page == 1) {
          state = state.copyWith(
            rewards: paginated.rewards,
            page: paginated.page,
            pages: paginated.pages,
            isLoading: false,
          );
        } else {
          state = state.copyWith(
            rewards: [...state.rewards, ...paginated.rewards],
            page: paginated.page,
            pages: paginated.pages,
            isLoadingMore: false,
          );
        }
      } else {
        state = state.copyWith(
          error: response.message ?? 'Failed to fetch rewards',
          isLoading: false,
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: e.toString(),
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> loadMore() async {
    if (state.isLoadingMore || state.page >= state.pages) return;
    await getRewards(page: state.page + 1);
  }

  Future<void> refresh() async {
    await getRewards(page: 1);
  }

  void updateCategory(String? category) {
    if (state.category == category) return;
    getRewards(page: 1, category: category);
  }
}

@riverpod
Future<PaginatedClaimedRewards> claimedRewards(
  Ref ref, {
  int page = 1,
  int limit = 10,
}) async {
  final api = ref.watch(apiProvider);
  
  final queryParams = {
    'page': page.toString(),
    'limit': limit.toString(),
  };

  final response = await api.get(
    '/rewards/my-coupons',
    queryParams: queryParams,
    requireAuth: true,
  );

  if (response.success && response.data != null) {
    return PaginatedClaimedRewards.fromJson(response.data!);
  } else {
    throw Exception(response.message ?? 'Failed to fetch claimed rewards');
  }
}


@Riverpod(keepAlive: true)
class RewardAction extends _$RewardAction {
  @override
  void build() {}

  Future<ApiResponse<Map<String, dynamic>>> redeemReward(String rewardId) async {
    final api = ref.read(apiProvider);
    final response = await api.post('/rewards/$rewardId/redeem', {});

    if (response.success) {
      await ref.read(userProvider.notifier).getProfile();
    }

    return response;
  }
}

@riverpod
Future<RewardModel?> getRewardById(Ref ref, String rewardId) async {
  if (rewardId.isEmpty) return null;
  final api = ref.watch(apiProvider);
  final response = await api.get('/rewards/$rewardId');
  if (response.success && response.data != null) {
    final data = response.data!['data'];
    if (data != null) {
      return RewardModel.fromJson(data as Map<String, dynamic>);
    }
  }
  return null;
}

