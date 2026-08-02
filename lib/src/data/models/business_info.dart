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
      branches: json['branches'] != null
          ? (json['branches'] as List<dynamic>)
              .map((e) => BusinessBranch.fromJson(e as Map<String, dynamic>))
              .toList()
          : null,
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
  final String? id;
  final String? name;
  final String? address;
  final String? phone;
  final String? email;
  final String? contactPersonName;
  final String? contactPersonDesignation;
  final LocationPoint? location;
  final OperatingHours? operatingHours;
  final bool? isActive;
  final String? branchType;
  final bool? isPrimary;

  const BusinessBranch({
    this.id,
    this.name,
    this.address,
    this.phone,
    this.email,
    this.contactPersonName,
    this.contactPersonDesignation,
    this.location,
    this.operatingHours,
    this.isActive,
    this.branchType,
    this.isPrimary,
  });

  BusinessBranch copyWith({
    String? id,
    String? name,
    String? address,
    String? phone,
    String? email,
    String? contactPersonName,
    String? contactPersonDesignation,
    LocationPoint? location,
    OperatingHours? operatingHours,
    bool? isActive,
    String? branchType,
    bool? isPrimary,
  }) {
    return BusinessBranch(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      contactPersonName: contactPersonName ?? this.contactPersonName,
      contactPersonDesignation: contactPersonDesignation ?? this.contactPersonDesignation,
      location: location ?? this.location,
      operatingHours: operatingHours ?? this.operatingHours,
      isActive: isActive ?? this.isActive,
      branchType: branchType ?? this.branchType,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory BusinessBranch.fromJson(Map<String, dynamic> json) {
    String? phoneVal = json['phone'] as String?;
    if (phoneVal == null && json['phoneNumbers'] is List && (json['phoneNumbers'] as List).isNotEmpty) {
      phoneVal = (json['phoneNumbers'] as List).first as String?;
    }

    String? emailVal = json['email'] as String?;
    if (emailVal == null && json['emailAddresses'] is List && (json['emailAddresses'] as List).isNotEmpty) {
      emailVal = (json['emailAddresses'] as List).first as String?;
    }

    String? cName;
    String? cDesig;
    if (json['contactPerson'] is Map) {
      cName = json['contactPerson']['name'] as String?;
      cDesig = json['contactPerson']['designation'] as String?;
    } else if (json['contactPerson'] is String) {
      cName = json['contactPerson'] as String?;
    }

    OperatingHours? opHours;
    if (json['operatingHours'] is List) {
      final list = json['operatingHours'] as List;
      final map = <String, dynamic>{};
      for (final item in list) {
        if (item is Map<String, dynamic> && item['day'] != null) {
          map[item['day'].toString().toLowerCase()] = item;
        }
      }
      opHours = OperatingHours.fromJson(map);
    } else {
      opHours = SafeParser.parseObject(
        json['operatingHours'],
        OperatingHours.fromJson,
      );
    }

    return BusinessBranch(
      id: (json['_id'] ?? json['id']) as String?,
      name: (json['name'] ?? json['branchName']) as String?,
      address: (json['address'] ?? (json['location'] is Map ? json['location']['address'] : null)) as String?,
      phone: phoneVal,
      email: emailVal,
      contactPersonName: cName,
      contactPersonDesignation: cDesig,
      location: SafeParser.parseObject(
        json['location'],
        LocationPoint.fromJson,
      ),
      operatingHours: opHours,
      isActive: json['isActive'] as bool?,
      branchType: json['branchType'] as String?,
      isPrimary: json['isPrimary'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'contactPersonName': contactPersonName,
      'contactPersonDesignation': contactPersonDesignation,
      'location': location?.toJson(),
      'operatingHours': operatingHours?.toJson(),
      'isActive': isActive,
      'branchType': branchType,
      'isPrimary': isPrimary,
    };
  }
}
