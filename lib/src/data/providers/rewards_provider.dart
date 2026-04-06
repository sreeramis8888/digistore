import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/reward_model.dart';
import '../models/claimed_reward_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';

part 'rewards_provider.g.dart';

@riverpod
Future<PaginatedRewards> rewards(
  Ref ref, {
  int page = 1,
  int limit = 10,
  String? category,
}) async {
  final api = ref.watch(apiProvider);
  final user = ref.watch(userProvider);

  final queryParams = {
    'page': page.toString(),
    'limit': limit.toString(),
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

  if (category != null && category != 'All' && category.isNotEmpty) {
    queryParams['category'] = category;
  }

  final response = await api.get(
    '/rewards',
    queryParams: queryParams,
    requireAuth: false,
  );

  if (response.success && response.data != null) {
    return PaginatedRewards.fromJson(response.data!);
  } else {
    throw Exception(response.message ?? 'Failed to fetch rewards');
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
