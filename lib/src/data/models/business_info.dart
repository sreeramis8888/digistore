import 'location_point.dart';

class BusinessInfo {
  final String? businessLogo;
  final String? coverImage;
  final List<String>? businessImages;
  final String? description;
  final String? tagline;
  final List<String>? specialties;
  final int? yearsOfExperience;
  final double? rating;
  final int? totalReviews;
  final String? contactPhone;
  final String? otpPhone;
  final String? whatsappNumber;
  final String? websiteUrl;
  final LocationPoint? storeLocation;
  final OperatingHours? operatingHours;
  final SocialLinks? socialLinks;
  final String? videoUrl;
  final List<String>? achievements;
  final List<BusinessFAQ>? faqs;
  final List<BusinessBranch>? branches;

  const BusinessInfo({
    this.businessLogo,
    this.coverImage,
    this.businessImages,
    this.description,
    this.tagline,
    this.specialties,
    this.yearsOfExperience,
    this.rating,
    this.totalReviews,
    this.contactPhone,
    this.otpPhone,
    this.whatsappNumber,
    this.websiteUrl,
    this.storeLocation,
    this.operatingHours,
    this.socialLinks,
    this.videoUrl,
    this.achievements,
    this.faqs,
    this.branches,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      businessLogo: json['businessLogo'] as String?,
      coverImage: json['coverImage'] as String?,
      businessImages: json['businessImages'] != null ? List<String>.from(json['businessImages']) : null,
      description: json['description'] as String?,
      tagline: json['tagline'] as String?,
      specialties: json['specialties'] != null ? List<String>.from(json['specialties']) : null,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalReviews: json['totalReviews'] as int?,
      contactPhone: json['contactPhone'] as String?,
      otpPhone: json['otpPhone'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      storeLocation: json['storeLocation'] != null ? LocationPoint.fromJson(json['storeLocation'] as Map<String, dynamic>) : null,
      operatingHours: json['operatingHours'] != null ? OperatingHours.fromJson(json['operatingHours'] as Map<String, dynamic>) : null,
      socialLinks: json['socialLinks'] != null ? SocialLinks.fromJson(json['socialLinks'] as Map<String, dynamic>) : null,
      videoUrl: json['videoUrl'] as String?,
      achievements: json['achievements'] != null ? List<String>.from(json['achievements']) : null,
      faqs: (json['faqs'] as List?)?.map((e) => BusinessFAQ.fromJson(e as Map<String, dynamic>)).toList(),
      branches: (json['branches'] as List?)?.map((e) => BusinessBranch.fromJson(e as Map<String, dynamic>)).toList(),
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

class SocialLinks {
  final String? instagram;
  final String? facebook;
  final String? youtube;

  const SocialLinks({this.instagram, this.facebook, this.youtube});

  factory SocialLinks.fromJson(Map<String, dynamic> json) {
    return SocialLinks(
      instagram: json['instagram'] as String?,
      facebook: json['facebook'] as String?,
      youtube: json['youtube'] as String?,
    );
  }
}

class BusinessFAQ {
  final String? question;
  final String? answer;

  const BusinessFAQ({this.question, this.answer});

  factory BusinessFAQ.fromJson(Map<String, dynamic> json) {
    return BusinessFAQ(
      question: json['question'] as String?,
      answer: json['answer'] as String?,
    );
  }
}

class BusinessBranch {
  final String? name;
  final String? address;
  final String? phone;
  final LocationPoint? location;
  final OperatingHours? operatingHours;
  final bool? isActive;

  const BusinessBranch({
    this.name,
    this.address,
    this.phone,
    this.location,
    this.operatingHours,
    this.isActive,
  });

  factory BusinessBranch.fromJson(Map<String, dynamic> json) {
    return BusinessBranch(
      name: json['name'] as String?,
      address: json['address'] as String?,
      phone: json['phone'] as String?,
      location: json['location'] != null ? LocationPoint.fromJson(json['location'] as Map<String, dynamic>) : null,
      operatingHours: json['operatingHours'] != null ? OperatingHours.fromJson(json['operatingHours'] as Map<String, dynamic>) : null,
      isActive: json['isActive'] as bool?,
    );
  }
}
