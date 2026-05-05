// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shops_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Shops)
final shopsProvider = ShopsProvider._();

final class ShopsProvider extends $NotifierProvider<Shops, ShopsState> {
  ShopsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'shopsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$shopsHash();

  @$internal
  @override
  Shops create() => Shops();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShopsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShopsState>(value),
    );
  }
}

String _$shopsHash() => r'0da796440f71f6764222c53af3cd613359c812dc';

abstract class _$Shops extends $Notifier<ShopsState> {
  ShopsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ShopsState, ShopsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShopsState, ShopsState>,
              ShopsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(AllShops)
final allShopsProvider = AllShopsProvider._();

final class AllShopsProvider extends $NotifierProvider<AllShops, ShopsState> {
  AllShopsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'allShopsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$allShopsHash();

  @$internal
  @override
  AllShops create() => AllShops();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShopsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShopsState>(value),
    );
  }
}

String _$allShopsHash() => r'b940d1cbc95822f414b694eaebacc79ff3428ea1';

abstract class _$AllShops extends $Notifier<ShopsState> {
  ShopsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<ShopsState, ShopsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ShopsState, ShopsState>,
              ShopsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
