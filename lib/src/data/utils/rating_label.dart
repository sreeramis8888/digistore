/// Shared shop/service rating display helpers.
///
/// A missing or zero rating must never show as "0.0" — that reads as a real
/// score. Prefer "NEW" in compact chips/cards and "No Ratings" in overviews.
class RatingLabel {
  RatingLabel._();

  static bool hasRating(num? rating, {int? reviewCount}) {
    if (reviewCount != null && reviewCount <= 0) return false;
    if (rating == null || rating <= 0) return false;
    return true;
  }

  /// Compact label for cards/chips ("4.5" or "NEW").
  static String compact(num? rating, {int? reviewCount}) {
    if (!hasRating(rating, reviewCount: reviewCount)) return 'NEW';
    return rating!.toDouble().toStringAsFixed(1);
  }

  /// Longer label for detail/overview surfaces ("4.5" or "No Ratings").
  static String detailed(num? rating, {int? reviewCount}) {
    if (!hasRating(rating, reviewCount: reviewCount)) return 'No Ratings';
    return rating!.toDouble().toStringAsFixed(1);
  }

  /// Parses a string rating (e.g. from card props) into the compact label.
  static String fromString(String? raw, {int? reviewCount}) {
    if (raw == null || raw.trim().isEmpty) {
      return compact(null, reviewCount: reviewCount);
    }
    final parsed = double.tryParse(raw.trim());
    if (parsed == null) {
      final lower = raw.trim().toLowerCase();
      if (lower == 'new') return 'NEW';
      if (lower == 'no ratings' || lower == 'no rating') return 'No Ratings';
      return compact(null, reviewCount: reviewCount);
    }
    return compact(parsed, reviewCount: reviewCount);
  }
}
