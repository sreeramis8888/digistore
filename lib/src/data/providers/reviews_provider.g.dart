// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reviews_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Reviews)
final reviewsProvider = ReviewsFamily._();

final class ReviewsProvider
    extends $AsyncNotifierProvider<Reviews, PaginatedReviews> {
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
  Reviews create() => Reviews();

  @override
  bool operator ==(Object other) {
    return other is ReviewsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reviewsHash() => r'15dec4e59d39046b0b85a52610de9fead1083c9f';

final class ReviewsFamily extends $Family
    with
        $ClassFamilyOverride<
          Reviews,
          AsyncValue<PaginatedReviews>,
          PaginatedReviews,
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

abstract class _$Reviews extends $AsyncNotifier<PaginatedReviews> {
  late final _$args = ref.$arg as ({String? shopId, int page, int limit});
  String? get shopId => _$args.shopId;
  int get page => _$args.page;
  int get limit => _$args.limit;

  FutureOr<PaginatedReviews> build({
    String? shopId,
    int page = 1,
    int limit = 10,
  });
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PaginatedReviews>, PaginatedReviews>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaginatedReviews>, PaginatedReviews>,
              AsyncValue<PaginatedReviews>,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () =>
          build(shopId: _$args.shopId, page: _$args.page, limit: _$args.limit),
    );
  }
}
