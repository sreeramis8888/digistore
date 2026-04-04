class BannerModel {
  final String? id;
  final String? title;
  final String? image;
  final String? type;
  final String? linkType;
  final String? linkId;
  final String? externalUrl;
  final int? sortOrder;
  final bool? isActive;

  const BannerModel({
    this.id,
    this.title,
    this.image,
    this.type,
    this.linkType,
    this.linkId,
    this.externalUrl,
    this.sortOrder,
    this.isActive,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['_id'] as String?,
      title: json['title'] as String?,
      image: json['image'] as String?,
      type: json['type'] as String?,
      linkType: json['linkType'] as String?,
      linkId: json['linkId'] as String?,
      externalUrl: json['externalUrl'] as String?,
      sortOrder: json['sortOrder'] as int?,
      isActive: json['isActive'] as bool?,
    );
  }
}
