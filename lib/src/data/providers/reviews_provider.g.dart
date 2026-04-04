// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(reviews)
final reviewsProvider = ReviewsFamily._();

final class ReviewsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedReviews>,
          PaginatedReviews,
          FutureOr<PaginatedReviews>
        >
    with $FutureModifier<PaginatedReviews>, $FutureProvider<PaginatedReviews> {
  ReviewsProvider._({
    required ReviewsFamily super.from,
    required ({String? shopId, int page, int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'reviewsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reviewsHash();

  @override
  String toString() {
    return r'reviewsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedReviews> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedReviews> create(Ref ref) {
    final argument = this.argument as ({String? shopId, int page, int limit});
    return reviews(
      ref,
      shopId: argument.shopId,
      page: argument.page,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewsHash() => r'69f5c931b476114d1cb2e32e63b718cba8596b5b';

final class ReviewsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedReviews>,
          ({String? shopId, int page, int limit})
        > {
  ReviewsFamily._()
    : super(
        retry: null,
        name: r'reviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReviewsProvider call({String? shopId, int page = 1, int limit = 10}) =>
      ReviewsProvider._(
        argument: (shopId: shopId, page: page, limit: limit),
        from: this,
      );

  @override
  String toString() => r'reviewsProvider';
}
