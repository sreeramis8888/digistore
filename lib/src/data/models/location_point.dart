class LocationPoint {
  final String? type;
  final List<double>? coordinates;

  const LocationPoint({
    this.type,
    this.coordinates,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List?)?.map((e) => (e as num).toDouble()).toList(),
    );
  }
}
