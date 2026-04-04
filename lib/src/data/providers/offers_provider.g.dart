// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(offers)
final offersProvider = OffersFamily._();

final class OffersProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedOffers>,
          PaginatedOffers,
          FutureOr<PaginatedOffers>
        >
    with $FutureModifier<PaginatedOffers>, $FutureProvider<PaginatedOffers> {
  OffersProvider._({
    required OffersFamily super.from,
    required ({
      String? categoryId,
      String? search,
      bool? isDealOfDay,
      int page,
      int limit,
    })
    super.argument,
  }) : super(
         retry: null,
         name: r'offersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$offersHash();

  @override
  String toString() {
    return r'offersProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedOffers> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedOffers> create(Ref ref) {
    final argument =
        this.argument
            as ({
              String? categoryId,
              String? search,
              bool? isDealOfDay,
              int page,
              int limit,
            });
    return offers(
      ref,
      categoryId: argument.categoryId,
      search: argument.search,
      isDealOfDay: argument.isDealOfDay,
      page: argument.page,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is OffersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$offersHash() => r'96025115dc2b183ea1b7641baad615c3b6753a9c';

final class OffersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedOffers>,
          ({
            String? categoryId,
            String? search,
            bool? isDealOfDay,
            int page,
            int limit,
          })
        > {
  OffersFamily._()
    : super(
        retry: null,
        name: r'offersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  OffersProvider call({
    String? categoryId,
    String? search,
    bool? isDealOfDay,
    int page = 1,
    int limit = 20,
  }) => OffersProvider._(
    argument: (
      categoryId: categoryId,
      search: search,
      isDealOfDay: isDealOfDay,
      page: page,
      limit: limit,
    ),
    from: this,
  );

  @override
  String toString() => r'offersProvider';
}
