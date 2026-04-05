class LocationPoint {
  final String? type;
  final List<double>? coordinates;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;

  const LocationPoint({
    this.type,
    this.coordinates,
    this.address,
    this.city,
    this.state,
    this.pincode,
  });

  factory LocationPoint.fromJson(Map<String, dynamic> json) {
    return LocationPoint(
      type: json['type'] as String?,
      coordinates: (json['coordinates'] as List?)?.map((e) => (e as num).toDouble()).toList(),
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'coordinates': coordinates,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
    };
  }
}
