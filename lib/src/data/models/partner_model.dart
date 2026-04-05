import 'business_details.dart';
import 'business_info.dart';
import 'coverage_areas.dart';

class PartnerModel {
  final String? id;
  final String? userId;
  final BusinessDetails? businessDetails;
  final BusinessInfo? businessInfo;
  final CoverageAreas? coverageAreas;
  final List<String>? serviceCategories;
  final double? incomeSharingPercentage;
  final String? verificationStatus;
  final bool? isActive;
  final bool? isFeatured;
  final bool? isPremium;
  final List<String>? tags;
  final int? totalLeads;
  final int? convertedLeads;
  final double? totalRevenue;
  final PaymentDetails? paymentDetails;
  final PartnerDocuments? documents;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const PartnerModel({
    this.id,
    this.userId,
    this.businessDetails,
    this.businessInfo,
    this.coverageAreas,
    this.serviceCategories,
    this.incomeSharingPercentage,
    this.verificationStatus,
    this.isActive,
    this.isFeatured,
    this.isPremium,
    this.tags,
    this.totalLeads,
    this.convertedLeads,
    this.totalRevenue,
    this.paymentDetails,
    this.documents,
    this.createdAt,
    this.updatedAt,
  });

  factory PartnerModel.fromJson(Map<String, dynamic> json) {
    return PartnerModel(
      id: json['_id'] as String?,
      userId: json['userId'] as String?,
      businessDetails: json['businessDetails'] != null
          ? BusinessDetails.fromJson(json['businessDetails'] as Map<String, dynamic>)
          : null,
      businessInfo: json['businessInfo'] != null
          ? BusinessInfo.fromJson(json['businessInfo'] as Map<String, dynamic>)
          : null,
      coverageAreas: json['coverageAreas'] != null
          ? CoverageAreas.fromJson(json['coverageAreas'] as Map<String, dynamic>)
          : null,
      serviceCategories: json['serviceCategories'] != null ? List<String>.from(json['serviceCategories']) : null,
      incomeSharingPercentage: (json['incomeSharingPercentage'] as num?)?.toDouble(),
      verificationStatus: json['verificationStatus'] as String?,
      isActive: json['isActive'] as bool?,
      isFeatured: json['isFeatured'] as bool?,
      isPremium: json['isPremium'] as bool?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      totalLeads: json['totalLeads'] as int?,
      convertedLeads: json['convertedLeads'] as int?,
      totalRevenue: (json['totalRevenue'] as num?)?.toDouble(),
      paymentDetails: json['paymentDetails'] != null
          ? PaymentDetails.fromJson(json['paymentDetails'] as Map<String, dynamic>)
          : null,
      documents: json['documents'] != null ? PartnerDocuments.fromJson(json['documents'] as Map<String, dynamic>) : null,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      updatedAt: json['updatedAt'] != null ? DateTime.tryParse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'businessDetails': businessDetails?.toJson(),
      'businessInfo': businessInfo?.toJson(),
      'coverageAreas': coverageAreas?.toJson(),
      'serviceCategories': serviceCategories,
      'incomeSharingPercentage': incomeSharingPercentage,
      'verificationStatus': verificationStatus,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isPremium': isPremium,
      'tags': tags,
      'totalLeads': totalLeads,
      'convertedLeads': convertedLeads,
      'totalRevenue': totalRevenue,
      'paymentDetails': paymentDetails?.toJson(),
      'documents': documents?.toJson(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class PaymentDetails {
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolderName;
  final String? upiId;

  const PaymentDetails({
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountHolderName,
    this.upiId,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      upiId: json['upiId'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'bankName': bankName,
      'accountNumber': accountNumber,
      'ifscCode': ifscCode,
      'accountHolderName': accountHolderName,
      'upiId': upiId,
    };
  }
}

class PartnerDocuments {
  final String? gstCertificate;
  final String? businessLicense;
  final String? panCard;

  const PartnerDocuments({
    this.gstCertificate,
    this.businessLicense,
    this.panCard,
  });

  factory PartnerDocuments.fromJson(Map<String, dynamic> json) {
    return PartnerDocuments(
      gstCertificate: json['gstCertificate'] as String?,
      businessLicense: json['businessLicense'] as String?,
      panCard: json['panCard'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gstCertificate': gstCertificate,
      'businessLicense': businessLicense,
      'panCard': panCard,
    };
  }
}
