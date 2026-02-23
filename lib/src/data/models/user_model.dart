class UserModel {
  final String? id;
  final String? name;
  final String? email;
  final String? image;
  final String? phone;
  final String? fcm;
  final String? gender;
  final String? qrCode;
  final String? status;
  final DateTime? lastSeen;
  final bool online;
  final DateTime? dob;
  final bool isInstalled;
  final String? rejectReason;
  final CampusDetailModel? campus;
  final String? bio;
  final String? countryCode;
  final String? country;
  final String? districtCode;
  final DistrictDetailModel? district;
  final String? idNumber;
  final String? referralCode;
  final String? profession;
  final int? referralCount;
  final String? referralRewardStatus;
  final bool? referralDecisionTaken;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final int? totalCampaignsParticipated;
  final int? totalAmountDonated;
  final int? totalReferrals;
  final int? activeReferrals;

  final List<SubSchemaModel>? socialMedia;
  final List<String>? blockedUsers;
  final bool? isContactVisible;
  const UserModel({
    this.id,
    this.name,
    this.email,
    this.image,
    this.phone,
    this.fcm,
    this.gender,
    this.qrCode,
    this.bio,
    this.status,
    this.lastSeen,
    this.online = false,
    this.dob,
    this.isInstalled = false,
    this.rejectReason,
    this.campus,
    this.countryCode,
    this.country,
    this.districtCode,
    this.district,
    this.idNumber,
    this.referralCode,
    this.profession,
    this.referralCount,
    this.referralRewardStatus,
    this.referralDecisionTaken,
    this.createdAt,
    this.updatedAt,
    this.totalCampaignsParticipated,
    this.totalAmountDonated,
    this.totalReferrals,
    this.activeReferrals,
    this.socialMedia,
    this.blockedUsers,
    this.isContactVisible,
  });

  factory UserModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const UserModel();

    return UserModel(
      id: json['_id'] as String?,
      name: json['name'] as String?,
      email: json['email'] as String?,
      image: json['image'] as String?,
      bio: json['bio'] as String?,
      phone: json['phone'] as String?,
      fcm: json['fcm'] as String?,
      gender: json['gender'] as String?,
      qrCode: json['qr_code'] as String?,
      status: json['status'] as String?,

      lastSeen: json['last_seen'] != null
          ? DateTime.tryParse(json['last_seen'])
          : null,
      online: json['online'] ?? false,
      dob: json['dob'] != null ? DateTime.tryParse(json['dob']) : null,
      isInstalled: json['is_installed'] ?? false,
      rejectReason: json['reject_reason'] as String?,
      campus: json['campus'] is Map<String, dynamic>
          ? CampusDetailModel.fromJson(json['campus'] as Map<String, dynamic>)
          : null,
      countryCode: json['country_code'] as String?,
      country: json['country'] as String?,
      districtCode: json['district_code'] as String? ??
          (json['district'] is String ? json['district'] as String : null),
      district: json['district'] is Map<String, dynamic>
          ? DistrictDetailModel.fromJson(
              json['district'] as Map<String, dynamic>,
            )
          : null,
      idNumber: json['id_number'] as String?,
      referralCode: json['referral_code'] as String?,
      profession: json['profession'] as String?,
      referralCount: json['referral_count'] as int?,
      referralRewardStatus: json['referral_reward_status'] as String?,
      referralDecisionTaken: json['referral_decision_taken'] as bool?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'])
          : null,
      totalCampaignsParticipated: json["total_campaigns_participated"],
      totalAmountDonated: json["total_amount_donated"],
      totalReferrals: json["total_referrals"],
      activeReferrals: json["active_referrals"],
      socialMedia: json['social_media'] != null
          ? (json['social_media'] as List<dynamic>)
                .map(
                  (item) =>
                      SubSchemaModel.fromJson(item as Map<String, dynamic>),
                )
                .toList()
          : null,
      blockedUsers: json['blocked_users'] != null
          ? List<String>.from(json['blocked_users'])
          : null,
      isContactVisible: json['is_contact_visible'] as bool?,
    );
  }

  /// ---------- TO JSON ----------
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'email': email,
      'image': image,
      'bio': bio,
      'phone': phone,
      'fcm': fcm,

      'gender': gender,

      'qr_code': qrCode,
      'status': status,

      'last_seen': lastSeen?.toIso8601String(),
      'online': online,
      'dob': dob?.toIso8601String(),
      'is_installed': isInstalled,
      'reject_reason': rejectReason,
      'campus': campus?.toJson(),
      'country_code': countryCode,
      'country': country,
      'district_code': districtCode,
      'district': district?.toJson(),
      'id_number': idNumber,
      'referral_code': referralCode,
      'profession': profession,
      'referral_count': referralCount,
      'referral_reward_status': referralRewardStatus,
      'referral_decision_taken': referralDecisionTaken,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      "total_campaigns_participated": totalCampaignsParticipated,
      "total_amount_donated": totalAmountDonated,
      "total_referrals": totalReferrals,
      "active_referrals": activeReferrals,
      'social_media': socialMedia?.map((s) => s.toJson()).toList(),
      'blocked_users': blockedUsers,
      'is_contact_visible': isContactVisible,
    };
  }

  /// ---------- COPY WITH ----------
  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? image,
    String? phone,
    String? fcm,
    String? bio,
    String? otp,
    String? gender,
    String? password,
    String? qrCode,
    String? status,
    bool? isAdmin,
    String? adminRole,
    DateTime? lastSeen,
    bool? online,
    DateTime? dob,
    bool? isInstalled,
    String? rejectReason,
    CampusDetailModel? campus,
    String? countryCode,
    String? country,
    String? districtCode,
    DistrictDetailModel? district,
    String? idNumber,
    String? referralCode,
    String? profession,
    int? referralCount,
    String? referralRewardStatus,
    bool? referralDecisionTaken,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? totalCampaignsParticipated,
    int? totalAmountDonated,
    int? totalReferrals,
    int? activeReferrals,
    List<SubSchemaModel>? socialMedia,
    List<String>? blockedUsers,
    bool? isContactVisible,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      phone: phone ?? this.phone,
      fcm: fcm ?? this.fcm,
      gender: gender ?? this.gender,
      bio: bio ?? this.bio,

      qrCode: qrCode ?? this.qrCode,
      status: status ?? this.status,

      lastSeen: lastSeen ?? this.lastSeen,
      online: online ?? this.online,
      dob: dob ?? this.dob,
      isInstalled: isInstalled ?? this.isInstalled,
      rejectReason: rejectReason ?? this.rejectReason,
      campus: campus ?? this.campus,
      countryCode: countryCode ?? this.countryCode,
      country: country ?? this.country,
      districtCode: districtCode ?? this.districtCode,
      district: district ?? this.district,
      idNumber: idNumber ?? this.idNumber,
      referralCode: referralCode ?? this.referralCode,
      profession: profession ?? this.profession,
      referralCount: referralCount ?? this.referralCount,
      referralRewardStatus: referralRewardStatus ?? this.referralRewardStatus,
      referralDecisionTaken:
          referralDecisionTaken ?? this.referralDecisionTaken,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      totalCampaignsParticipated:
          totalCampaignsParticipated ?? this.totalCampaignsParticipated,
      totalAmountDonated: totalAmountDonated ?? this.totalAmountDonated,
      totalReferrals: totalReferrals ?? this.totalReferrals,
      activeReferrals: activeReferrals ?? this.activeReferrals,
      socialMedia: socialMedia ?? this.socialMedia,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      isContactVisible: isContactVisible ?? this.isContactVisible,
    );
  }
}

class CampusDetailModel {
  final String? id;
  final String? uid;
  final String? name;
  final DistrictDetailModel? district;

  const CampusDetailModel({this.id, this.uid, this.name, this.district});

  factory CampusDetailModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const CampusDetailModel();

    return CampusDetailModel(
      id: json['_id'] as String?,
      uid: json['uid'] as String?,
      name: json['name'] as String?,
      district: json['district'] != null
          ? DistrictDetailModel.fromJson(
              json['district'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'uid': uid,
      'name': name,
      'district': district?.toJson(),
    };
  }

  CampusDetailModel copyWith({
    String? id,
    String? uid,
    String? name,
    DistrictDetailModel? district,
  }) {
    return CampusDetailModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
      district: district ?? this.district,
    );
  }
}

class DistrictDetailModel {
  final String? id;
  final String? uid;
  final String? name;

  const DistrictDetailModel({this.id, this.uid, this.name});

  factory DistrictDetailModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const DistrictDetailModel();

    return DistrictDetailModel(
      id: json['_id'] as String?,
      uid: json['uid'] as String?,
      name: json['name'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'uid': uid, 'name': name};
  }

  DistrictDetailModel copyWith({String? id, String? uid, String? name}) {
    return DistrictDetailModel(
      id: id ?? this.id,
      uid: uid ?? this.uid,
      name: name ?? this.name,
    );
  }
}

class SubSchemaModel {
  final String? name;
  final String? url;

  const SubSchemaModel({this.name, this.url});

  factory SubSchemaModel.fromJson(Map<String, dynamic>? json) {
    if (json == null) return const SubSchemaModel();

    return SubSchemaModel(
      name: json['name'] as String?,
      url: json['url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'url': url};
  }

  SubSchemaModel copyWith({String? name, String? url}) {
    return SubSchemaModel(name: name ?? this.name, url: url ?? this.url);
  }
}
