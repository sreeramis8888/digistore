import 'package:flutter_test/flutter_test.dart';
import 'package:setgo/src/data/utils/rating_label.dart';

void main() {
  group('RatingLabel', () {
    test('compact avoids 0.0', () {
      expect(RatingLabel.compact(0), 'NEW');
      expect(RatingLabel.compact(null), 'NEW');
      expect(RatingLabel.fromString('0.0'), 'NEW');
      expect(RatingLabel.fromString(''), 'NEW');
    });

    test('compact shows score when rated', () {
      expect(RatingLabel.compact(4.56), '4.6');
      expect(RatingLabel.fromString('4.2'), '4.2');
    });

    test('no reviews means unrated when count provided', () {
      expect(RatingLabel.compact(4.5, reviewCount: 0), 'NEW');
      expect(RatingLabel.hasRating(4.5, reviewCount: 0), isFalse);
      expect(RatingLabel.detailed(4.5, reviewCount: 0), 'No Ratings');
    });

    test('detailed label for overview', () {
      expect(RatingLabel.detailed(null), 'No Ratings');
      expect(RatingLabel.detailed(3.2, reviewCount: 5), '3.2');
    });
  });
}
