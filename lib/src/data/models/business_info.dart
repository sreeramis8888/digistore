import 'package:setgo/src/utils/safe_parser.dart';
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
  final String? ownerName;
  final String? email;

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
    this.ownerName,
    this.email,
  });

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    return BusinessInfo(
      businessLogo: json['businessLogo'] as String?,
      coverImage: json['coverImage'] as String?,
      businessImages: json['businessImages'] != null
          ? List<String>.from(json['businessImages'])
          : null,
      description: json['description'] as String?,
      tagline: json['tagline'] as String?,
      specialties: json['specialties'] != null
          ? List<String>.from(json['specialties'])
          : null,
      yearsOfExperience: json['yearsOfExperience'] as int?,
      rating: (json['rating'] as num?)?.toDouble(),
      totalReviews: json['reviewCount'] as int? ?? json['totalReviews'] as int?,
      contactPhone: json['contactPhone'] as String?,
      otpPhone: json['otpPhone'] as String?,
      whatsappNumber: json['whatsappNumber'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      storeLocation: SafeParser.parseObject(
        json['storeLocation'],
        LocationPoint.fromJson,
      ),
      operatingHours: SafeParser.parseObject(
        json['operatingHours'],
        OperatingHours.fromJson,
      ),
      socialLinks: SafeParser.parseObject(
        json['socialLinks'],
        SocialLinks.fromJson,
      ),
      videoUrl: json['videoUrl'] as String?,
      achievements: json['achievements'] != null
          ? List<String>.from(json['achievements'])
          : null,
      faqs: SafeParser.parseList(json['faqs'], BusinessFAQ.fromJson),
      branches: SafeParser.parseList(json['branches'], BusinessBranch.fromJson),
      ownerName: json['ownerName'] as String?,
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessLogo': businessLogo,
      'coverImage': coverImage,
      'businessImages': businessImages,
      'description': description,
      'tagline': tagline,
      'specialties': specialties,
      'yearsOfExperience': yearsOfExperience,
      'rating': rating,
      'totalReviews': totalReviews,
      'contactPhone': contactPhone,
      'otpPhone': otpPhone,
      'whatsappNumber': whatsappNumber,
      'websiteUrl': websiteUrl,
      'storeLocation': storeLocation?.toJson(),
      'operatingHours': operatingHours?.toJson(),
      'socialLinks': socialLinks?.toJson(),
      'videoUrl': videoUrl,
      'achievements': achievements,
      'faqs': faqs?.map((e) => e.toJson()).toList(),
      'branches': branches?.map((e) => e.toJson()).toList(),
      'ownerName': ownerName,
      'email': email,
    };
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
      monday: SafeParser.parseObject(json['monday'], DayStatus.fromJson),
      tuesday: SafeParser.parseObject(json['tuesday'], DayStatus.fromJson),
      wednesday: SafeParser.parseObject(json['wednesday'], DayStatus.fromJson),
      thursday: SafeParser.parseObject(json['thursday'], DayStatus.fromJson),
      friday: SafeParser.parseObject(json['friday'], DayStatus.fromJson),
      saturday: SafeParser.parseObject(json['saturday'], DayStatus.fromJson),
      sunday: SafeParser.parseObject(json['sunday'], DayStatus.fromJson),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'monday': monday?.toJson(),
      'tuesday': tuesday?.toJson(),
      'wednesday': wednesday?.toJson(),
      'thursday': thursday?.toJson(),
      'friday': friday?.toJson(),
      'saturday': saturday?.toJson(),
      'sunday': sunday?.toJson(),
    };
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

  Map<String, dynamic> toJson() {
    return {'isOpen': isOpen, 'open': open, 'close': close};
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

  Map<String, dynamic> toJson() {
    return {'instagram': instagram, 'facebook': facebook, 'youtube': youtube};
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

  Map<String, dynamic> toJson() {
    return {'question': question, 'answer': answer};
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
      location: SafeParser.parseObject(
        json['location'],
        LocationPoint.fromJson,
      ),
      operatingHours: SafeParser.parseObject(
        json['operatingHours'],
        OperatingHours.fromJson,
      ),
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'location': location?.toJson(),
      'operatingHours': operatingHours?.toJson(),
      'isActive': isActive,
    };
  }
}
