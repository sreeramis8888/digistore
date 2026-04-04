class CoverageAreas {
  final List<String>? districts;
  final List<String>? localBodies;

  const CoverageAreas({
    this.districts,
    this.localBodies,
  });

  factory CoverageAreas.fromJson(Map<String, dynamic> json) {
    return CoverageAreas(
      districts: json['districts'] != null ? List<String>.from(json['districts']) : null,
      localBodies: json['localBodies'] != null ? List<String>.from(json['localBodies']) : null,
    );
  }
}
