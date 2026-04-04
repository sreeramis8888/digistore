import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/review_model.dart';
import 'api_provider.dart';

part 'reviews_provider.g.dart';

@riverpod
Future<PaginatedReviews> reviews(
  Ref ref, {
  String? shopId,
  int page = 1,
  int limit = 10,
}) async {
  if (shopId == null || shopId.isEmpty) {
    return PaginatedReviews(
      reviews: [],
      page: page,
      limit: limit,
      total: 0,
      pages: 0,
    );
  }

  final api = ref.watch(apiProvider);

  final response = await api.get(
    '/reviews/$shopId/reviews',
    requireAuth: false,
  );

  if (response.success && response.data != null) {
    return PaginatedReviews.fromJson(response.data!);
  } else {
    return PaginatedReviews(
      reviews: [],
      page: page,
      limit: limit,
      total: 0,
      pages: 0,
    );
  }
}
