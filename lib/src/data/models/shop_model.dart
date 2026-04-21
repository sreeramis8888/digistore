class ShopModel {
  final String? id;
  final BusinessDetails? businessDetails;
  final List<String>? serviceCategories;
  final CoverageAreas? coverageAreas;
  final BusinessInfo? businessInfo;
  final bool? isFeatured;
  final List<String>? tags;
  final bool? isOpenNow;

  const ShopModel({
    this.id,
    this.businessDetails,
    this.serviceCategories,
    this.coverageAreas,
    this.businessInfo,
    this.isFeatured,
    this.tags,
    this.isOpenNow,
  });

  factory ShopModel.fromJson(Map<String, dynamic> json) {
    return ShopModel(
      id: json['_id'] as String?,
      businessDetails: json['businessDetails'] != null
          ? BusinessDetails.fromJson(json['businessDetails'] as Map<String, dynamic>)
          : null,
      serviceCategories: json['serviceCategories'] != null
          ? List<String>.from(json['serviceCategories'])
          : null,
      coverageAreas: json['coverageAreas'] != null
          ? CoverageAreas.fromJson(json['coverageAreas'] as Map<String, dynamic>)
          : null,
      businessInfo: json['businessInfo'] != null
          ? BusinessInfo.fromJson(json['businessInfo'] as Map<String, dynamic>)
          : null,
      isFeatured: json['isFeatured'] as bool?,
      tags: json['tags'] != null ? List<String>.from(json['tags']) : null,
      isOpenNow: json['isOpenNow'] as bool?,
    );
  }
}

class BusinessDetails {
  final String? businessName;
  final String? businessType;
  final String? registrationNumber;
  final String? gstNumber;

  const BusinessDetails({
    this.businessName,
    this.businessType,
    this.registrationNumber,
    this.gstNumber,
  });

  factory BusinessDetails.fromJson(Map<String, dynamic> json) {
    return BusinessDetails(
      businessName: json['businessName'] as String?,
      businessType: json['businessType'] as String?,
      registrationNumber: json['registrationNumber'] as String?,
      gstNumber: json['gstNumber'] as String?,
    );
  }
}

class CoverageAreas {
  final List<String>? districts;
  final List<String>? cities;

  const CoverageAreas({this.districts, this.cities});

  factory CoverageAreas.fromJson(Map<String, dynamic> json) {
    return CoverageAreas(
      districts: json['districts'] != null ? List<String>.from(json['districts']) : null,
      cities: json['cities'] != null ? List<String>.from(json['cities']) : null,
    );
  }
}

class BusinessInfo {
  final String? businessLogo;
  final List<String>? businessImages;
  final String? description;
  final num? rating;
  final int? totalReviews;
  final StoreLocation? storeLocation;
  final String? contactPhone;
  final String? contactEmail;
  final OperatingHours? operatingHours;
  final List<String>? specialties;
  final SocialLinks? socialLinks;

  const BusinessInfo({
    this.businessLogo,
    this.businessImages,
    this.description,
    this.rating,
    this.totalReviews,
    this.storeLocation,
    this.contactPhone,
    this.contactEmail,
    this.operatingHours,
    this.specialties,
    this.socialLinks,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      businessLogo: json['businessLogo'] as String?,
      businessImages: json['businessImages'] != null ? List<String>.from(json['businessImages']) : null,
      description: json['description'] as String?,
      rating: json['rating'] as num?,
      totalReviews: json['totalReviews'] as int?,
      storeLocation: json['storeLocation'] != null
          ? StoreLocation.fromJson(json['storeLocation'] as Map<String, dynamic>)
          : null,
      contactPhone: json['contactPhone'] as String?,
      contactEmail: json['contactEmail'] as String?,
      operatingHours: json['operatingHours'] != null
          ? OperatingHours.fromJson(json['operatingHours'] as Map<String, dynamic>)
          : null,
      specialties: json['specialties'] != null ? List<String>.from(json['specialties']) : null,
      socialLinks: json['socialLinks'] != null 
          ? SocialLinks.fromJson(json['socialLinks'] as Map<String, dynamic>) 
          : null,
    );
  }
}

class SocialLinks {
  final String? instagram;
  final String? facebook;
  final String? youtube;

  const SocialLinks({
    this.instagram,
    this.facebook,
    this.youtube,
  });

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      instagram: json['instagram'] as String?,
      facebook: json['facebook'] as String?,
      youtube: json['youtube'] as String?,
    );
  }
}

class StoreLocation {
  final String? type;
  final List<double>? coordinates;
  final String? address;
  final String? city;
  final String? state;
  final String? pincode;

  const StoreLocation({
    this.type,
    this.coordinates,
    this.address,
    this.city,
    this.state,
    this.pincode,
  });

  factory StoreLocation.fromJson(Map<String, dynamic> json) {
    return StoreLocation(
      type: json['type'] as String?,
      coordinates: json['coordinates'] != null ? List<double>.from(json['coordinates'].map((e) => (e as num).toDouble())) : null,
      address: json['address'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      pincode: json['pincode'] as String?,
    );
  }
}

class OperatingHours {
  final DayStatus? monday;
  final DayStatus? tuesday;
  final DayStatus? wednesday;
  final DayStatus? thursday;
  final DayStatus? friday;
  final DayStatus? saturday;
  final DayStatus? sunday;

  const OperatingHours({
    this.monday,
    this.tuesday,
    this.wednesday,
    this.thursday,
    this.friday,
    this.saturday,
    this.sunday,
  });

  factory OperatingHours.fromJson(Map<String, dynamic> json) {
    return OperatingHours(
      monday: json['monday'] != null ? DayStatus.fromJson(json['monday'] as Map<String, dynamic>) : null,
      tuesday: json['tuesday'] != null ? DayStatus.fromJson(json['tuesday'] as Map<String, dynamic>) : null,
      wednesday: json['wednesday'] != null ? DayStatus.fromJson(json['wednesday'] as Map<String, dynamic>) : null,
      thursday: json['thursday'] != null ? DayStatus.fromJson(json['thursday'] as Map<String, dynamic>) : null,
      friday: json['friday'] != null ? DayStatus.fromJson(json['friday'] as Map<String, dynamic>) : null,
      saturday: json['saturday'] != null ? DayStatus.fromJson(json['saturday'] as Map<String, dynamic>) : null,
      sunday: json['sunday'] != null ? DayStatus.fromJson(json['sunday'] as Map<String, dynamic>) : null,
    );
  }
}

class DayStatus {
  final bool? isOpen;
  final String? open;
  final String? close;

  const DayStatus({this.isOpen, this.open, this.close});

  factory DayStatus.fromJson(Map<String, dynamic> json) {
    return DayStatus(
      isOpen: json['isOpen'] as bool?,
      open: json['open'] as String?,
      close: json['close'] as String?,
    );
  }
}
