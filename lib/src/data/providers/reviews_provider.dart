import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/review_model.dart';
import '../models/redemption_model.dart';
import 'api_provider.dart';

part 'reviews_provider.g.dart';

@riverpod
class Reviews extends _$Reviews {
  @override
  Future<PaginatedReviews> build({
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

    final response = await api.get('/reviews/shop/$shopId', requireAuth: false);

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

  void addReviewLocally(ReviewModel review) {
    state.whenData((currentData) {
      state = AsyncData(
        currentData.copyWith(
          reviews: [review, ...currentData.reviews],
          total: currentData.total + 1,
        ),
      );
    });
  }
}

class ReviewsActionNotifier extends Notifier<AsyncValue<void>> {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<MyRedemptionsResponse?> getShopRedemptions(String shopId) async {
    try {
      final api = ref.read(apiProvider);
      final response = await api.get('/shops/$shopId/my-redemptions');
      if (response.success && response.data != null) {
        return MyRedemptionsResponse.fromJson(response.data!);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> submitReview({
    required String partnerId,
    required double rating,
    required String comment,
    required List<File> images,
    required String redemptionId,
  }) async {
    state = const AsyncLoading();
    try {
      final api = ref.read(apiProvider);

      final body = {
        'partnerId': partnerId,
        'rating': rating.toString(),
        'comment': comment,
        'redemptionId': redemptionId,
      };

      List<http.MultipartFile>? files;
      if (images.isNotEmpty) {
        files = await Future.wait(
          images.map(
            (f) => http.MultipartFile.fromPath(
              'images',
              f.path,
              contentType: MediaType.parse(
                lookupMimeType(f.path) ?? 'image/jpeg',
              ),
            ),
          ),
        );
      }

      final response = await api.postMultipart('/reviews', body, files: files);

      if (response.success) {
        state = const AsyncData(null);
        return true;
      } else {
        throw Exception(response.message ?? 'Failed to submit review');
      }
    } catch (e) {
      state = AsyncError(e, StackTrace.current);
      return false;
    }
  }
}

final reviewsActionProvider =
    NotifierProvider<ReviewsActionNotifier, AsyncValue<void>>(
      ReviewsActionNotifier.new,
    );
