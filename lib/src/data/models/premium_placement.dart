class PremiumPlacement {
  final String? position;
  final DateTime? startDate;
  final DateTime? endDate;

  const PremiumPlacement({
    this.position,
    this.startDate,
    this.endDate,
  });

  factory PremiumPlacement.fromJson(Map<String, dynamic> json) {
    return PremiumPlacement(
      position: json['position'] as String?,
      startDate: json['startDate'] != null ? DateTime.tryParse(json['startDate']) : null,
      endDate: json['endDate'] != null ? DateTime.tryParse(json['endDate']) : null,
    );
  }
}
