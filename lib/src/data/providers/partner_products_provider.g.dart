// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'partner_products_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(PartnerProducts)
final partnerProductsProvider = PartnerProductsProvider._();

final class PartnerProductsProvider
    extends $NotifierProvider<PartnerProducts, PartnerProductsState> {
  PartnerProductsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'partnerProductsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$partnerProductsHash();

  @$internal
  @override
  PartnerProducts create() => PartnerProducts();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PartnerProductsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PartnerProductsState>(value),
    );
  }
}

String _$partnerProductsHash() => r'7bd9898a7690bf8667e92f2b7d20618d5a5dcf36';

abstract class _$PartnerProducts extends $Notifier<PartnerProductsState> {
  PartnerProductsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<PartnerProductsState, PartnerProductsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<PartnerProductsState, PartnerProductsState>,
              PartnerProductsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
