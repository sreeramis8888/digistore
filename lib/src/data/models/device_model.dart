class DeviceModel {
  final String? id;
  final String? platform;
  final String? appVersion;
  final DateTime? lastActiveAt;
  final String? fcmToken;

  const DeviceModel({
    this.id,
    this.platform,
    this.appVersion,
    this.lastActiveAt,
    this.fcmToken,
  });

  factory DeviceModel.fromJson(Map<String, dynamic> json) {
    return DeviceModel(
      id: json['id'] as String?,
      platform: json['platform'] as String?,
      appVersion: json['appVersion'] as String?,
      lastActiveAt: json['lastActiveAt'] != null ? DateTime.tryParse(json['lastActiveAt'])?.toLocal() : null,
      fcmToken: json['fcmToken'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'platform': platform,
      'appVersion': appVersion,
      'lastActiveAt': lastActiveAt?.toIso8601String(),
      'fcmToken': fcmToken,
    };
  }
}
