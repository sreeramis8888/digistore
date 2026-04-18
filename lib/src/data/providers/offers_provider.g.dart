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

String _$offersHash() => r'5f9df92f25c0f92057775f5949bc426268549fae';

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
