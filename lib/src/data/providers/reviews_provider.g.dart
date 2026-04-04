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
    required ({int limit, int page, String? shopId})
    super.argument,
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
    final argument =
        this.argument as ({int limit, int page, String? shopId});
    return reviews(
      ref,
      shopId: argument.shopId,
      limit: argument.limit,
      page: argument.page,
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

String _$reviewsHash() => r'f4951d44db12c70c6da964a9108b5c2a8bffb8f4';

final class ReviewsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedReviews>,
          ({int limit, int page, String? shopId})
        > {
  ReviewsFamily._()
    : super(
        retry: null,
        name: r'reviewsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ReviewsProvider call({
    String? shopId,
    int limit = 10,
    int page = 1,
  }) => ReviewsProvider._(
    argument: (limit: limit, page: page, shopId: shopId),
    from: this,
  );

  @override
  String toString() => r'reviewsProvider';
}
