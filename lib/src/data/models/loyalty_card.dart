class LoyaltyCard {
  final String? name;
  final int? pointsBalance;
  final int? totalPointsEarned;
  final String? tier;
  final List<String>? tierBenefits;
  final int? remainingPointsToNextTier;
  final String? nextTier;

  const LoyaltyCard({
    this.name,
    this.pointsBalance,
    this.totalPointsEarned,
    this.tier,
    this.tierBenefits,
    this.remainingPointsToNextTier,
    this.nextTier,
  });

  factory LoyaltyCard.fromJson(Map<String, dynamic> json) {
    return LoyaltyCard(
      name: json['name'] as String?,
      pointsBalance: json['pointsBalance'] as int?,
      totalPointsEarned: json['totalPointsEarned'] as int?,
      tier: json['tier'] as String?,
      tierBenefits: json['tierBenefits'] != null
          ? List<String>.from(json['tierBenefits'])
          : null,
      remainingPointsToNextTier: json['remainingPointsToNextTier'] as int?,
      nextTier: json['nextTier'] as String?,
    );
  }
}
