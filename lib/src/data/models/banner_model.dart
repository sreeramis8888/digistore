class BannerModel {
  final String? id;
  final String? title;
  final String? description;
  final String? mediaType; // 'video' or 'image'
  final String? image; // maps to 'imageUrl' or 'image'
  final String? videoUrl;
  final String? thumbnailUrl;
  final String? type;
  final String? linkType;
  final String? linkId;
  final String? externalUrl;
  final String? deepLink;
  final String? backgroundColor;
  final String? textColor;
  final String? buttonText;
  final String? buttonColor;
  final bool? videoAutoplay;
  final bool? videoLoop;
  final bool? videoMuted;
  final bool? videoControls;
  final String? altText;
  final int? sortOrder;
  final bool? isActive;

  const BannerModel({
    this.id,
    this.title,
    this.description,
    this.mediaType,
    this.image,
    this.videoUrl,
    this.thumbnailUrl,
    this.type,
    this.linkType,
    this.linkId,
    this.externalUrl,
    this.deepLink,
    this.backgroundColor,
    this.textColor,
    this.buttonText,
    this.buttonColor,
    this.videoAutoplay,
    this.videoLoop,
    this.videoMuted,
    this.videoControls,
    this.altText,
    this.sortOrder,
    this.isActive,
  });

  /// Returns the thumbnail URL to show. For videos, we fall back to [image] (which maps to [imageUrl]) if [thumbnailUrl] is null.
  String? get effectiveThumbnailUrl => thumbnailUrl ?? image;

  /// Helper to check if the banner is a video banner.
  bool get isVideo => mediaType == 'video' && videoUrl != null && videoUrl!.isNotEmpty;

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      description: json['description'] as String?,
      mediaType: json['mediaType'] as String?,
      image: (json['imageUrl'] ?? json['image']) as String?,
      videoUrl: json['videoUrl'] as String?,
      thumbnailUrl: json['thumbnailUrl'] as String?,
      type: json['type'] as String?,
      linkType: json['linkType'] as String?,
      linkId: json['linkId'] as String?,
      externalUrl: json['externalUrl'] as String?,
      deepLink: json['deepLink'] as String?,
      backgroundColor: json['backgroundColor'] as String?,
      textColor: json['textColor'] as String?,
      buttonText: json['buttonText'] as String?,
      buttonColor: json['buttonColor'] as String?,
      videoAutoplay: json['videoAutoplay'] as bool?,
      videoLoop: json['videoLoop'] as bool?,
      videoMuted: json['videoMuted'] as bool?,
      videoControls: json['videoControls'] as bool?,
      altText: json['altText'] as String?,
      sortOrder: json['sortOrder'] as int?,
      isActive: json['isActive'] as bool?,
    );
  }
}
