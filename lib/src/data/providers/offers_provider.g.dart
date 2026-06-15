// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'offers_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Offers)
final offersProvider = OffersProvider._();

final class OffersProvider extends $NotifierProvider<Offers, PaginatedOffers> {
  OffersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'offersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$offersHash();

  @$internal
  @override
  Offers create() => Offers();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedOffers value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedOffers>(value),
    );
  }
}

String _$offersHash() => r'4b192f6482c645e5632c512c7c98b0623ee77e61';

abstract class _$Offers extends $Notifier<PaginatedOffers> {
  PaginatedOffers build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PaginatedOffers, PaginatedOffers>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PaginatedOffers, PaginatedOffers>,
              PaginatedOffers,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(activeDeals)
final activeDealsProvider = ActiveDealsFamily._();

final class ActiveDealsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OfferModel>>,
          List<OfferModel>,
          FutureOr<List<OfferModel>>
        >
    with $FutureModifier<List<OfferModel>>, $FutureProvider<List<OfferModel>> {
  ActiveDealsProvider._({
    required ActiveDealsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeDealsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeDealsHash();

  @override
  String toString() {
    return r'activeDealsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<OfferModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<OfferModel>> create(Ref ref) {
    final argument = this.argument as String;
    return activeDeals(ref, dealType: argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveDealsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeDealsHash() => r'94d557cdbda81db11a47757b860d6de1286b69dc';

final class ActiveDealsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OfferModel>>, String> {
  ActiveDealsFamily._()
    : super(
        retry: null,
        name: r'activeDealsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ActiveDealsProvider call({required String dealType}) =>
      ActiveDealsProvider._(argument: dealType, from: this);

  @override
  String toString() => r'activeDealsProvider';
}

@ProviderFor(getOfferById)
final getOfferByIdProvider = GetOfferByIdFamily._();

final class GetOfferByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<OfferModel?>,
          OfferModel?,
          FutureOr<OfferModel?>
        >
    with $FutureModifier<OfferModel?>, $FutureProvider<OfferModel?> {
  GetOfferByIdProvider._({
    required GetOfferByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getOfferByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getOfferByIdHash();

  @override
  String toString() {
    return r'getOfferByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<OfferModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OfferModel?> create(Ref ref) {
    final argument = this.argument as String;
    return getOfferById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetOfferByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getOfferByIdHash() => r'73bee4da3a2de4dce95fc7869366b86cec1ebc25';

final class GetOfferByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<OfferModel?>, String> {
  GetOfferByIdFamily._()
    : super(
        retry: null,
        name: r'getOfferByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetOfferByIdProvider call(String offerId) =>
      GetOfferByIdProvider._(argument: offerId, from: this);

  @override
  String toString() => r'getOfferByIdProvider';
}
