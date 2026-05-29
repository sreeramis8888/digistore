import 'package:setgo/src/utils/safe_parser.dart';

import 'reward_model.dart';

class ClaimedRewardModel {
  final String? id;
  final RewardModel? rewardId;
  final String? publicUserId;
  final int? pointsSpent;
  final String? status;
  final DateTime? validUntil;
  final String? partnerId;
  final DateTime? redeemedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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
      rewardId: SafeParser.parseObject(json['rewardId'], RewardModel.fromJson),
      publicUserId: json['publicUserId'] as String?,
      pointsSpent: json['pointsSpent'] as int?,
      status: json['status'] as String?,
      validUntil: json['validUntil'] != null
          ? DateTime.tryParse(json['validUntil'])?.toLocal()
          : null,
      partnerId: json['partnerId'] as String?,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'])?.toLocal()
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])?.toLocal()
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])?.toLocal()
          : null,
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
      rewards:
          SafeParser.parseList(json['data'], ClaimedRewardModel.fromJson) ?? [],
      page: json['pagination']?['page'] as int? ?? 1,
      limit: json['pagination']?['limit'] as int? ?? 10,
      total: json['pagination']?['total'] as int? ?? 0,
      pages: json['pagination']?['pages'] as int? ?? 1,
    );
  }
}
