import 'partner_model.dart';
import 'offer_model.dart';

class RedemptionModel {
  final String? id;
  final String? publicUserId;
  final PartnerModel? partnerId;
  final OfferModel? offerId;
  final String? status;
  final int? saleAmount;
  final int? pointsEarned;
  final String? otp;
  final bool? otpVerified;
  final DateTime? redeemedAt;
  final DateTime? createdAt;

  const RedemptionModel({
    this.id,
    this.publicUserId,
    this.partnerId,
    this.offerId,
    this.status,
    this.saleAmount,
    this.pointsEarned,
    this.otp,
    this.otpVerified,
    this.redeemedAt,
    this.createdAt,
  });

  factory RedemptionModel.fromJson(Map<String, dynamic> json) {
    return RedemptionModel(
      id: json['_id'] as String?,
      publicUserId: json['publicUserId'] as String?,
      partnerId: json['partnerId'] != null ? PartnerModel.fromJson(json['partnerId'] as Map<String, dynamic>) : null,
      offerId: json['offerId'] != null ? OfferModel.fromJson(json['offerId'] as Map<String, dynamic>) : null,
      status: json['status'] as String?,
      saleAmount: json['saleAmount'] as int?,
      pointsEarned: json['pointsEarned'] as int?,
      otp: json['otp'] as String?,
      otpVerified: json['otpVerified'] as bool?,
      redeemedAt: json['redeemedAt'] != null ? DateTime.tryParse(json['redeemedAt']) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
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
