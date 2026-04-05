class CoverageAreas {
  final List<String>? districts;
  final List<String>? cities;
  final List<String>? states;
  final List<String>? localBodies;

  const CoverageAreas({
    this.districts,
    this.cities,
    this.states,
    this.localBodies,
  });

  factory CoverageAreas.fromJson(Map<String, dynamic> json) {
    return CoverageAreas(
      districts: json['districts'] != null ? List<String>.from(json['districts']) : null,
      cities: json['cities'] != null ? List<String>.from(json['cities']) : null,
      states: json['states'] != null ? List<String>.from(json['states']) : null,
      localBodies: json['localBodies'] != null ? List<String>.from(json['localBodies']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'districts': districts,
      'cities': cities,
      'states': states,
      'localBodies': localBodies,
    };
  }
}
