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

String _$offersHash() => r'85b047ceb27b693367a72f961836a1ce379856f9';

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
         isAutoDispose: true,
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

String _$activeDealsHash() => r'd3c6d9aa2e81df13f8940677cc93d1bffc6f3670';

final class ActiveDealsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OfferModel>>, String> {
  ActiveDealsFamily._()
    : super(
        retry: null,
        name: r'activeDealsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ActiveDealsProvider call({required String dealType}) =>
      ActiveDealsProvider._(argument: dealType, from: this);

  @override
  String toString() => r'activeDealsProvider';
}
