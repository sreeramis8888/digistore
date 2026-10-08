import 'package:setgo/src/utils/safe_parser.dart';
import '../utils/name_case.dart';
import 'location_point.dart';

/// Image or video entry in `businessInfo.businessImages` (and related media).
class BusinessMediaItem {
  final String url;
  final String mediaType; // 'image' | 'video'
  final String? thumbnailUrl;

  const BusinessMediaItem({
    required this.url,
    this.mediaType = 'image',
    this.thumbnailUrl,
  });

  bool get isVideo => mediaType.toLowerCase() == 'video';

  String get displayUrl =>
      isVideo ? (thumbnailUrl?.isNotEmpty == true ? thumbnailUrl! : url) : url;

  static bool looksLikeVideo(String url) {
    final path = url.toLowerCase().split('?').first;
    return path.endsWith('.mp4') ||
        path.endsWith('.mov') ||
        path.endsWith('.webm') ||
        path.endsWith('.m3u8') ||
        path.endsWith('.mkv') ||
        path.endsWith('.avi');
  }

  factory BusinessMediaItem.fromUrl(String url) {
    final trimmed = url.trim();
    return BusinessMediaItem(
      url: trimmed,
      mediaType: looksLikeVideo(trimmed) ? 'video' : 'image',
    );
  }

  factory BusinessMediaItem.fromJson(dynamic json) {
    if (json is String) {
      return BusinessMediaItem.fromUrl(json);
    }
    if (json is Map) {
      final map = Map<String, dynamic>.from(json);
      final explicitType = (map['mediaType'] ?? map['type'] ?? '')
          .toString()
          .trim()
          .toLowerCase();
      final videoUrl = (map['videoUrl'] ?? '').toString().trim();
      final imageUrl = (map['imageUrl'] ?? map['image'] ?? map['src'] ?? '')
          .toString()
          .trim();
      final url = (map['url'] ?? '').toString().trim();

      final resolvedUrl = url.isNotEmpty
          ? url
          : (videoUrl.isNotEmpty
                ? videoUrl
                : (imageUrl.isNotEmpty ? imageUrl : ''));

      final thumb = (map['thumbnailUrl'] ?? map['thumbnail'] ?? map['poster'])
          ?.toString()
          .trim();

      final isVideo =
          explicitType == 'video' ||
          (explicitType.isEmpty &&
              (videoUrl.isNotEmpty || looksLikeVideo(resolvedUrl)));

      return BusinessMediaItem(
        url: resolvedUrl,
        mediaType: isVideo ? 'video' : 'image',
        thumbnailUrl: (thumb != null && thumb.isNotEmpty) ? thumb : null,
      );
    }
    return BusinessMediaItem.fromUrl(json.toString());
  }

  Map<String, dynamic> toJson() {
    if (!isVideo && thumbnailUrl == null) {
      // Keep legacy string entries for image-only galleries.
      return {'url': url, 'mediaType': 'image'};
    }
    return {
      'url': url,
      'mediaType': mediaType,
      if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)
        'thumbnailUrl': thumbnailUrl,
    };
  }

  /// API payload value: plain URL for images, object when video metadata exists.
  dynamic toApiValue() {
    if (isVideo || (thumbnailUrl != null && thumbnailUrl!.isNotEmpty)) {
      return toJson();
    }
    return url;
  }
}

class BusinessInfo {
  final String? businessLogo;
  final String? coverImage;
  final List<BusinessMediaItem>? businessImages;
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
  /// Shop detail banner video (API: `bannerVideoUrl`).
  final String? bannerVideoUrl;
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
    this.bannerVideoUrl,
    this.achievements,
    this.faqs,
    this.branches,
    this.ownerName,
    this.email,
  });

  String? get _resolvedBannerVideo {
    final banner = bannerVideoUrl?.trim();
    if (banner != null && banner.isNotEmpty) return banner;
    final legacy = videoUrl?.trim();
    if (legacy != null && legacy.isNotEmpty) return legacy;
    return null;
  }

  /// Cover image + banner video for the shop-detail hero (swipeable).
  List<BusinessMediaItem> get heroMedia {
    final items = <BusinessMediaItem>[];
    final seen = <String>{};

    void add(BusinessMediaItem? item) {
      if (item == null) return;
      final url = item.url.trim();
      if (url.isEmpty || seen.contains(url)) return;
      seen.add(url);
      items.add(item);
    }

    final cover = coverImage?.trim();
    if (cover != null && cover.isNotEmpty) {
      add(BusinessMediaItem.fromUrl(cover));
    }

    final bannerVideo = _resolvedBannerVideo;
    if (bannerVideo != null) {
      add(
        BusinessMediaItem(
          url: bannerVideo,
          mediaType: 'video',
          thumbnailUrl: coverImage?.trim().isNotEmpty == true
              ? coverImage!.trim()
              : null,
        ),
      );
    }

    return items;
  }

  /// Cover + banner video + gallery, de-duplicated, for shop media UI.
  List<BusinessMediaItem> get galleryMedia {
    final items = <BusinessMediaItem>[];
    final seen = <String>{};

    void add(BusinessMediaItem? item) {
      if (item == null) return;
      final url = item.url.trim();
      if (url.isEmpty || seen.contains(url)) return;
      seen.add(url);
      items.add(item);
    }

    for (final item in heroMedia) {
      add(item);
    }
    for (final item in businessImages ?? const <BusinessMediaItem>[]) {
      add(item);
    }
    return items;
  }

  factory BusinessInfo.fromJson(Map<String, dynamic> json) {
    List<BusinessMediaItem>? media;
    final rawImages = json['businessImages'];
    if (rawImages is List) {
      media = rawImages
          .map(BusinessMediaItem.fromJson)
          .where((e) => e.url.trim().isNotEmpty)
          .toList();
      if (media.isEmpty) media = null;
    }

    return BusinessInfo(
      businessLogo: json['businessLogo'] as String?,
      coverImage: json['coverImage'] as String?,
      businessImages: media,
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
      bannerVideoUrl:
          (json['bannerVideoUrl'] ?? json['banner_video_url']) as String?,
      achievements: json['achievements'] != null
          ? List<String>.from(json['achievements'])
          : null,
      faqs: SafeParser.parseList(json['faqs'], BusinessFAQ.fromJson),
      branches: json['branches'] != null
          ? (json['branches'] as List<dynamic>)
                .map((e) => BusinessBranch.fromJson(e as Map<String, dynamic>))
                .toList()
          : null,
      ownerName: NameCase.maybe(json['ownerName']?.toString()),
      email: json['email'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'businessLogo': businessLogo,
      'coverImage': coverImage,
      'businessImages': businessImages?.map((e) => e.toApiValue()).toList(),
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
      'bannerVideoUrl': bannerVideoUrl,
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

  /// Backend "main" branch is the shop itself, not a selectable outlet.
  bool get isMainBranch =>
      (branchType ?? '').trim().toLowerCase() == 'main';

  /// Whether the shop-detail Branches picker should be visible.
  /// Hide when empty, or when the only location is the main branch.
  static bool shouldShowBranchPicker(List<BusinessBranch> branches) {
    if (branches.isEmpty) return false;
    if (branches.length == 1 && branches.first.isMainBranch) return false;
    return true;
  }

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
      contactPersonDesignation:
          contactPersonDesignation ?? this.contactPersonDesignation,
      location: location ?? this.location,
      operatingHours: operatingHours ?? this.operatingHours,
      isActive: isActive ?? this.isActive,
      branchType: branchType ?? this.branchType,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  factory BusinessBranch.fromJson(Map<String, dynamic> json) {
    String? phoneVal = json['phone'] as String?;
    if (phoneVal == null &&
        json['phoneNumbers'] is List &&
        (json['phoneNumbers'] as List).isNotEmpty) {
      phoneVal = (json['phoneNumbers'] as List).first as String?;
    }

    String? emailVal = json['email'] as String?;
    if (emailVal == null &&
        json['emailAddresses'] is List &&
        (json['emailAddresses'] as List).isNotEmpty) {
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
      name: NameCase.maybe((json['name'] ?? json['branchName'])?.toString()),
      address:
          (json['address'] ??
                  (json['location'] is Map
                      ? json['location']['address']
                      : null))
              as String?,
      phone: phoneVal,
      email: emailVal,
      contactPersonName: NameCase.maybe(cName),
      contactPersonDesignation: cDesig,
      location: SafeParser.parseObject(
        json['location'],
        LocationPoint.fromJson,
      ),
      operatingHours: opHours,
      isActive: json['isActive'] as bool?,
      branchType: (json['branchType'] ?? json['type']) as String?,
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
