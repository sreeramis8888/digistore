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
        isAutoDispose: false,
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

String _$offersHash() => r'7118aac532b71d325d95eefc21837327926cfe63';

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

@ProviderFor(ActiveDeals)
final activeDealsProvider = ActiveDealsFamily._();

final class ActiveDealsProvider
    extends $NotifierProvider<ActiveDeals, PaginatedOffers> {
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
  ActiveDeals create() => ActiveDeals();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PaginatedOffers value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PaginatedOffers>(value),
    );
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

String _$activeDealsHash() => r'ee97d6cd277d32e5f0e43d8660b8517f1f9c5b4e';

final class ActiveDealsFamily extends $Family
    with
        $ClassFamilyOverride<
          ActiveDeals,
          PaginatedOffers,
          PaginatedOffers,
          PaginatedOffers,
          String
        > {
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

abstract class _$ActiveDeals extends $Notifier<PaginatedOffers> {
  late final _$args = ref.$arg as String;
  String get dealType => _$args;

  PaginatedOffers build({required String dealType});
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
    element.handleCreate(ref, () => build(dealType: _$args));
  }
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
