class ReviewModel {
  final String? id;
  final String? userId;
  final String? shopId;
  final String? userName;
  final String? userPhoto;
  final num? rating;
  final String? comment;
  final DateTime? createdAt;

  const ReviewModel({
    this.id,
    this.userId,
    this.shopId,
    this.userName,
    this.userPhoto,
    this.rating,
    this.comment,
    this.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    final userData = json['publicUserId'] ?? json['userId'];
    return ReviewModel(
      id: json['_id'] as String?,
      userId: userData is Map ? userData['_id'] as String? : userData as String?,
      shopId: json['partnerId'] as String? ?? json['shopId'] as String?,
      userName: userData is Map ? userData['name'] as String? : json['userName'] as String?,
      userPhoto: userData is Map ? userData['profileImage'] as String? : json['userPhoto'] as String?,
      rating: json['rating'] as num?,
      comment: json['comment'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
    );
  }
}

class PaginatedReviews {
  final List<ReviewModel> reviews;
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginatedReviews({
    required this.reviews,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  PaginatedReviews copyWith({
    List<ReviewModel>? reviews,
    int? page,
    int? limit,
    int? total,
    int? pages,
  }) {
    return PaginatedReviews(
      reviews: reviews ?? this.reviews,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      pages: pages ?? this.pages,
    );
  }

  factory PaginatedReviews.fromJson(Map<String, dynamic> json) {
    return PaginatedReviews(
      reviews: (json['data'] as List? ?? [])
          .map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['pagination']?['page'] as int? ?? 1,
      limit: json['pagination']?['limit'] as int? ?? 10,
      total: json['pagination']?['total'] as int? ?? 0,
      pages: json['pagination']?['pages'] as int? ?? 1,
    );
  }
}
