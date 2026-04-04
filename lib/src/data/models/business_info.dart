class BusinessInfo {
  final String? businessLogo;
  final List<String>? businessImages;
  final String? description;
  final List<String>? specialties;
  final double? rating;
  final int? reviewCount;
  final String? contactPhone;
  final String? tagline;
  final String? coverImage;
  final Map<String, dynamic>? operatingHours;

  const BusinessInfo({
    this.businessLogo,
    this.businessImages,
    this.description,
    this.specialties,
    this.rating,
    this.reviewCount,
    this.contactPhone,
    this.tagline,
    this.coverImage,
    this.operatingHours,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      businessLogo: json['businessLogo'] as String?,
      businessImages: json['businessImages'] != null ? List<String>.from(json['businessImages']) : null,
      description: json['description'] as String?,
      specialties: json['specialties'] != null ? List<String>.from(json['specialties']) : null,
      rating: (json['rating'] as num?)?.toDouble(),
      reviewCount: json['reviewCount'] as int?,
      contactPhone: json['contactPhone'] as String?,
      tagline: json['tagline'] as String?,
      coverImage: json['coverImage'] as String?,
      operatingHours: json['operatingHours'] as Map<String, dynamic>?,
    );
  }
}
