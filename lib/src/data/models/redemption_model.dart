import 'partner_model.dart';
import 'offer_model.dart';

class PublicUserModel {
  final String? id;
  final String? name;
  final String? phone;

  const PublicUserModel({
    this.id,
    this.name,
    this.phone,
  });

  factory PublicUserModel.fromJson(Map<String, dynamic> json) {
    return PublicUserModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
    );
  }
}

class RedemptionModel {
  final String? id;
  final PublicUserModel? publicUserId;
  final PartnerModel? partnerId;
  final OfferModel? offerId;
  final String? status;
  final double? saleAmount;
  final int? pointsEarned;
  final double? commissionPercent;
  final double? commissionAmount;
  final String? billImage;
  final String? otp;
  final bool? otpVerified;
  final String? initiatedBy;
  final DateTime? redeemedAt;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final bool? hasReview;

  const RedemptionModel({
    this.id,
    this.publicUserId,
    this.partnerId,
    this.offerId,
    this.status,
    this.saleAmount,
    this.pointsEarned,
    this.commissionPercent,
    this.commissionAmount,
    this.billImage,
    this.otp,
    this.otpVerified,
    this.initiatedBy,
    this.redeemedAt,
    this.createdAt,
    this.updatedAt,
    this.hasReview,
  });

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    return RedemptionModel(
      id: json['_id'] as String?,
      publicUserId: (json['publicUserId'] != null && json['publicUserId'] is Map)
          ? PublicUserModel.fromJson(
              json['publicUserId'] as Map<String, dynamic>)
          : null,
      partnerId: (json['partnerId'] != null && json['partnerId'] is Map)
          ? PartnerModel.fromJson(json['partnerId'] as Map<String, dynamic>)
          : null,
      offerId: (json['offerId'] != null && json['offerId'] is Map)
          ? OfferModel.fromJson(json['offerId'] as Map<String, dynamic>)
          : null,
      status: json['status'] as String?,
      saleAmount: (json['saleAmount'] as num?)?.toDouble(),
      pointsEarned: json['pointsEarned'] as int?,
      commissionPercent: (json['commissionPercent'] as num?)?.toDouble(),
      commissionAmount: (json['commissionAmount'] as num?)?.toDouble(),
      billImage: json['billImage'] as String?,
      otp: json['otp'] as String?,
      otpVerified: json['otpVerified'] as bool?,
      initiatedBy: json['initiatedBy'] as String?,
      redeemedAt: json['redeemedAt'] != null
          ? DateTime.tryParse(json['redeemedAt'])
          : null,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      hasReview: json['hasReview'] as bool?,
    );
  }
}

class MyRedemptionsResponse {
  final bool success;
  final List<RedemptionModel> data;
  final bool canSubmitReview;

  MyRedemptionsResponse({
    required this.success,
    required this.data,
    required this.canSubmitReview,
  });

  factory MyRedemptionsResponse.fromJson(Map<String, dynamic> json) {
    return MyRedemptionsResponse(
      success: json['success'] as bool? ?? false,
      data: (json['data'] as List? ?? [])
          .map((e) => RedemptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      canSubmitReview: json['canSubmitReview'] as bool? ?? false,
    );
  }
}

class PaginatedRedemptions {
  final List<RedemptionModel> redemptions;
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginatedRedemptions({
    required this.redemptions,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginatedRedemptions.fromJson(Map<String, dynamic> json) {
    return PaginatedRedemptions(
      redemptions: (json['data'] as List? ?? [])
          .map((e) => RedemptionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['pagination']?['page'] as int? ?? 1,
      limit: json['pagination']?['limit'] as int? ?? 10,
      total: json['pagination']?['total'] as int? ?? 0,
      pages: json['pagination']?['pages'] as int? ?? 1,
    );
  }
}
