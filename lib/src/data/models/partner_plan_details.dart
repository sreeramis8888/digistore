class PartnerPlanDetails {
  final String? subscriptionStatus;
  final DateTime? planExpiryDate;
  final bool? hasUsedTrial;
  final PlanInfo? planInfo;
  final CurrentPlan? currentPlan;
  final PlanLimits? limits;

  PartnerPlanDetails({
    this.subscriptionStatus,
    this.planExpiryDate,
    this.hasUsedTrial,
    this.planInfo,
    this.currentPlan,
    this.limits,
  });

  factory PartnerPlanDetails.fromJson(Map<String, dynamic> json) {
    return PartnerPlanDetails(
      subscriptionStatus: json['subscriptionStatus'] as String?,
      planExpiryDate: json['planExpiryDate'] != null
          ? DateTime.tryParse(json['planExpiryDate'] as String)?.toLocal()
          : null,
      hasUsedTrial: json['hasUsedTrial'] as bool?,
      planInfo: json['planInfo'] != null
          ? PlanInfo.fromJson(json['planInfo'] as Map<String, dynamic>)
          : null,
      currentPlan: json['currentPlan'] != null
          ? CurrentPlan.fromJson(json['currentPlan'] as Map<String, dynamic>)
          : null,
      limits: json['limits'] != null
          ? PlanLimits.fromJson(json['limits'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'subscriptionStatus': subscriptionStatus,
      'planExpiryDate': planExpiryDate?.toIso8601String(),
      'hasUsedTrial': hasUsedTrial,
      'planInfo': planInfo?.toJson(),
      'currentPlan': currentPlan?.toJson(),
      'limits': limits?.toJson(),
    };
  }
}

class PlanInfo {
  final String? currentPlanId;
  final String? subscriptionStatus;
  final DateTime? planExpiryDate;
  final bool? isExpired;
  final int? daysRemaining;

  PlanInfo({
    this.currentPlanId,
    this.subscriptionStatus,
    this.planExpiryDate,
    this.isExpired,
    this.daysRemaining,
  });

  factory PlanInfo.fromJson(Map<String, dynamic> json) {
    return PlanInfo(
      currentPlanId: json['currentPlanId'] as String?,
      subscriptionStatus: json['subscriptionStatus'] as String?,
      planExpiryDate: json['planExpiryDate'] != null
          ? DateTime.tryParse(json['planExpiryDate'] as String)?.toLocal()
          : null,
      isExpired: json['isExpired'] as bool?,
      daysRemaining: json['daysRemaining'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPlanId': currentPlanId,
      'subscriptionStatus': subscriptionStatus,
      'planExpiryDate': planExpiryDate?.toIso8601String(),
      'isExpired': isExpired,
      'daysRemaining': daysRemaining,
    };
  }
}

class CurrentPlan {
  final String? id;
  final String? partnerId;
  final String? userId;
  final PlanId? planId;
  final PlanSnapshot? planSnapshot;
  final String? subscriptionType;
  final DateTime? startDate;
  final DateTime? endDate;
  final bool? autoRenew;
  final int? renewalCount;
  final String? status;
  final String? adminNotes;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool? isActive;
  final int? daysRemaining;
  final String? statusText;
  final bool? isExpired;

  CurrentPlan({
    this.id,
    this.partnerId,
    this.userId,
    this.planId,
    this.planSnapshot,
    this.subscriptionType,
    this.startDate,
    this.endDate,
    this.autoRenew,
    this.renewalCount,
    this.status,
    this.adminNotes,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.daysRemaining,
    this.statusText,
    this.isExpired,
  });

  factory CurrentPlan.fromJson(Map<String, dynamic> json) {
    return CurrentPlan(
      id: json['_id'] as String? ?? json['id'] as String?,
      partnerId: json['partnerId'] as String?,
      userId: json['userId'] as String?,
      planId: json['planId'] != null
          ? PlanId.fromJson(json['planId'] as Map<String, dynamic>)
          : null,
      planSnapshot: json['planSnapshot'] != null
          ? PlanSnapshot.fromJson(json['planSnapshot'] as Map<String, dynamic>)
          : null,
      subscriptionType: json['subscriptionType'] as String?,
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'] as String)?.toLocal()
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'] as String)?.toLocal()
          : null,
      autoRenew: json['autoRenew'] as bool?,
      renewalCount: json['renewalCount'] as int?,
      status: json['status'] as String?,
      adminNotes: json['adminNotes'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)?.toLocal()
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String)?.toLocal()
          : null,
      isActive: json['isActive'] as bool?,
      daysRemaining: json['daysRemaining'] as int?,
      statusText: json['statusText'] as String?,
      isExpired: json['isExpired'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'partnerId': partnerId,
      'userId': userId,
      'planId': planId?.toJson(),
      'planSnapshot': planSnapshot?.toJson(),
      'subscriptionType': subscriptionType,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'autoRenew': autoRenew,
      'renewalCount': renewalCount,
      'status': status,
      'adminNotes': adminNotes,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isActive': isActive,
      'daysRemaining': daysRemaining,
      'statusText': statusText,
      'isExpired': isExpired,
    };
  }
}

class PlanId {
  final PlanFeatures? features;
  final PlanLimits? limits;
  final String? id;
  final String? name;
  final String? displayName;
  final String? type;

  PlanId({
    this.features,
    this.limits,
    this.id,
    this.name,
    this.displayName,
    this.type,
  });

  factory PlanId.fromJson(Map<String, dynamic> json) {
    return PlanId(
      features: json['features'] != null
          ? PlanFeatures.fromJson(json['features'] as Map<String, dynamic>)
          : null,
      limits: json['limits'] != null
          ? PlanLimits.fromJson(json['limits'] as Map<String, dynamic>)
          : null,
      id: json['_id'] as String? ?? json['id'] as String?,
      name: json['name'] as String?,
      displayName: json['displayName'] as String?,
      type: json['type'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'features': features?.toJson(),
      'limits': limits?.toJson(),
      'id': id,
      'name': name,
      'displayName': displayName,
      'type': type,
    };
  }
}

class PlanSnapshot {
  final String? name;
  final String? displayName;
  final String? type;
  final String? description;
  final PlanFeatures? features;
  final PlanLimits? limits;
  final double? basePrice;
  final double? sellingPrice;
  final double? gstPercentage;
  final double? finalPrice;
  final String? isTrial;
  final int? trialDays;

  PlanSnapshot({
    this.name,
    this.displayName,
    this.type,
    this.description,
    this.features,
    this.limits,
    this.basePrice,
    this.sellingPrice,
    this.gstPercentage,
    this.finalPrice,
    this.isTrial,
    this.trialDays,
  });

  factory PlanSnapshot.fromJson(Map<String, dynamic> json) {
    return PlanSnapshot(
      name: json['name'] as String?,
      displayName: json['displayName'] as String?,
      type: json['type'] as String?,
      description: json['description'] as String?,
      features: json['features'] != null
          ? PlanFeatures.fromJson(json['features'] as Map<String, dynamic>)
          : null,
      limits: json['limits'] != null
          ? PlanLimits.fromJson(json['limits'] as Map<String, dynamic>)
          : null,
      basePrice: (json['basePrice'] as num?)?.toDouble(),
      sellingPrice: (json['sellingPrice'] as num?)?.toDouble(),
      gstPercentage: (json['gstPercentage'] as num?)?.toDouble(),
      finalPrice: (json['finalPrice'] as num?)?.toDouble(),
      isTrial: json['isTrial'] as String?,
      trialDays: json['trialDays'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'displayName': displayName,
      'type': type,
      'description': description,
      'features': features?.toJson(),
      'limits': limits?.toJson(),
      'basePrice': basePrice,
      'sellingPrice': sellingPrice,
      'gstPercentage': gstPercentage,
      'finalPrice': finalPrice,
      'isTrial': isTrial,
      'trialDays': trialDays,
    };
  }
}

class PlanFeatures {
  final int? hexCount;
  final int? coverageAreaKm2;
  final int? branchLimit;
  final int? serviceCategories;
  final int? subcategoriesPerCategory;
  final bool? isAllKeralaAllowed;

  PlanFeatures({
    this.hexCount,
    this.coverageAreaKm2,
    this.branchLimit,
    this.serviceCategories,
    this.subcategoriesPerCategory,
    this.isAllKeralaAllowed,
  });

  factory PlanFeatures.fromJson(Map<String, dynamic> json) {
    return PlanFeatures(
      hexCount: json['hexCount'] as int?,
      coverageAreaKm2: json['coverageAreaKm2'] as int?,
      branchLimit: json['branchLimit'] as int?,
      serviceCategories: json['serviceCategories'] as int?,
      subcategoriesPerCategory: json['subcategoriesPerCategory'] as int?,
      isAllKeralaAllowed: json['isAllKeralaAllowed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hexCount': hexCount,
      'coverageAreaKm2': coverageAreaKm2,
      'branchLimit': branchLimit,
      'serviceCategories': serviceCategories,
      'subcategoriesPerCategory': subcategoriesPerCategory,
      'isAllKeralaAllowed': isAllKeralaAllowed,
    };
  }
}

class PlanLimits {
  final int? maxLeads;
  final int? maxRedemptions;
  final int? maxOffers;
  final int? analyticsRetentionDays;
  final int? hexCount;
  final int? coverageAreaKm2;
  final int? branchLimit;
  final int? serviceCategoriesLimit;
  final int? subcategoriesPerCategoryLimit;
  final bool? isAllKeralaAllowed;

  PlanLimits({
    this.maxLeads,
    this.maxRedemptions,
    this.maxOffers,
    this.analyticsRetentionDays,
    this.hexCount,
    this.coverageAreaKm2,
    this.branchLimit,
    this.serviceCategoriesLimit,
    this.subcategoriesPerCategoryLimit,
    this.isAllKeralaAllowed,
  });

  factory PlanLimits.fromJson(Map<String, dynamic> json) {
    return PlanLimits(
      maxLeads: json['maxLeads'] as int?,
      maxRedemptions: json['maxRedemptions'] as int?,
      maxOffers: json['maxOffers'] as int?,
      analyticsRetentionDays: json['analyticsRetentionDays'] as int?,
      hexCount: json['hexCount'] as int?,
      coverageAreaKm2: json['coverageAreaKm2'] as int?,
      branchLimit: json['branchLimit'] as int?,
      serviceCategoriesLimit: json['serviceCategoriesLimit'] as int?,
      subcategoriesPerCategoryLimit:
          json['subcategoriesPerCategoryLimit'] as int?,
      isAllKeralaAllowed: json['isAllKeralaAllowed'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxLeads': maxLeads,
      'maxRedemptions': maxRedemptions,
      'maxOffers': maxOffers,
      'analyticsRetentionDays': analyticsRetentionDays,
      'hexCount': hexCount,
      'coverageAreaKm2': coverageAreaKm2,
      'branchLimit': branchLimit,
      'serviceCategoriesLimit': serviceCategoriesLimit,
      'subcategoriesPerCategoryLimit': subcategoriesPerCategoryLimit,
      'isAllKeralaAllowed': isAllKeralaAllowed,
    };
  }
}
