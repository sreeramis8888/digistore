import 'business_details.dart';
import 'business_info.dart';

class PartnerModel {
  final String? id;
  final BusinessDetails? businessDetails;
  final BusinessInfo? businessInfo;

  const PartnerModel({
    this.id,
    this.businessDetails,
    this.businessInfo,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['_id'] as String?,
      businessDetails: json['businessDetails'] != null
          ? BusinessDetails.fromJson(json['businessDetails'] as Map<String, dynamic>)
          : null,
      businessInfo:
          json['businessInfo'] != null ? BusinessInfo.fromJson(json['businessInfo'] as Map<String, dynamic>) : null,
    );
  }
}
