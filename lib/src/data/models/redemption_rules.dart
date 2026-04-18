class RedemptionRules {
  final int? maxTotalRedemptions;
  final int? maxPerUser;
  final double? minPurchaseAmount;
  final List<String>? applicableDays;

  const RedemptionRules({
    this.maxTotalRedemptions,
    this.maxPerUser,
    this.minPurchaseAmount,
    this.applicableDays,
  });

  factory RedemptionRules.fromJson(Map<String, dynamic> json) {
    return RedemptionRules(
      maxTotalRedemptions: json['maxTotalRedemptions'] as int?,
      maxPerUser: json['maxPerUser'] as int?,
      minPurchaseAmount: (json['minPurchaseAmount'] as num?)?.toDouble(),
      applicableDays: json['applicableDays'] != null ? List<String>.from(json['applicableDays']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxTotalRedemptions': maxTotalRedemptions,
      'maxPerUser': maxPerUser,
      'minPurchaseAmount': minPurchaseAmount,
      'applicableDays': applicableDays,
    };
  }
}
