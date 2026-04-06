import 'reward_model.dart';

class ClaimedRewardModel {
  final String? id;
  final RewardModel? rewardId;
  final String? publicUserId;
  final int? pointsSpent;
  final String? status;
  final String? validUntil;
  final String? partnerId;
  final String? redeemedAt;
  final String? createdAt;
  final String? updatedAt;
  final String? couponCode;

  const ClaimedRewardModel({
    this.id,
    this.rewardId,
    this.publicUserId,
    this.pointsSpent,
    this.status,
    this.validUntil,
    this.partnerId,
    this.redeemedAt,
    this.createdAt,
    this.updatedAt,
    this.couponCode,
  });

  factory ClaimedRewardModel.fromJson(Map<String, dynamic> json) {
    return ClaimedRewardModel(
      id: json['_id'] as String?,
      rewardId: json['rewardId'] != null 
          ? RewardModel.fromJson(json['rewardId'] as Map<String, dynamic>) 
          : null,
      publicUserId: json['publicUserId'] as String?,
      pointsSpent: json['pointsSpent'] as int?,
      status: json['status'] as String?,
      validUntil: json['validUntil'] as String?,
      partnerId: json['partnerId'] as String?,
      redeemedAt: json['redeemedAt'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      couponCode: json['couponCode'] as String?,
    );
  }
}

class PaginatedClaimedRewards {
  final List<ClaimedRewardModel> rewards;
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginatedClaimedRewards({
    required this.rewards,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginatedClaimedRewards.fromJson(Map<String, dynamic> json) {
    return PaginatedClaimedRewards(
      rewards: (json['data'] as List? ?? [])
          .map((e) => ClaimedRewardModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['pagination']?['page'] as int? ?? 1,
      limit: json['pagination']?['limit'] as int? ?? 10,
      total: json['pagination']?['total'] as int? ?? 0,
      pages: json['pagination']?['pages'] as int? ?? 1,
    );
  }
}
