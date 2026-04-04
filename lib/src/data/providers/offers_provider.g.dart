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
          AsyncValue<List<OfferModel>>,
          List<OfferModel>,
          FutureOr<List<OfferModel>>
        >
    with $FutureModifier<List<OfferModel>>, $FutureProvider<List<OfferModel>> {
  OffersProvider._({
    required OffersFamily super.from,
    required ({String? categoryId, String? search, bool? isDealOfDay})
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
  $FutureProviderElement<List<OfferModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OfferModel>> create(Ref ref) {
    final argument =
        this.argument
            as ({String? categoryId, String? search, bool? isDealOfDay});
    return offers(
      ref,
      categoryId: argument.categoryId,
      search: argument.search,
      isDealOfDay: argument.isDealOfDay,
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

String _$offersHash() => r'e83d6b33d080bafe6573db5647cc167811b50dce';

final class OffersFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<OfferModel>>,
          ({String? categoryId, String? search, bool? isDealOfDay})
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
  }) => OffersProvider._(
    argument: (
      categoryId: categoryId,
      search: search,
      isDealOfDay: isDealOfDay,
    ),
    from: this,
  );

  @override
  String toString() => r'offersProvider';
}
