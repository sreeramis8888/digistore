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

@ProviderFor(shopOffers)
final shopOffersProvider = ShopOffersFamily._();

final class ShopOffersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<OfferModel>>,
          List<OfferModel>,
          FutureOr<List<OfferModel>>
        >
    with $FutureModifier<List<OfferModel>>, $FutureProvider<List<OfferModel>> {
  ShopOffersProvider._({
    required ShopOffersFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shopOffersProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shopOffersHash();

  @override
  String toString() {
    return r'shopOffersProvider'
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
    return shopOffers(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopOffersProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shopOffersHash() => r'970bceebcedf871e6d2170335622649dd168545a';

final class ShopOffersFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<OfferModel>>, String> {
  ShopOffersFamily._()
    : super(
        retry: null,
        name: r'shopOffersProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ShopOffersProvider call(String shopId) =>
      ShopOffersProvider._(argument: shopId, from: this);

  @override
  String toString() => r'shopOffersProvider';
}

@ProviderFor(shopProducts)
final shopProductsProvider = ShopProductsFamily._();

final class ShopProductsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProductModel>>,
          List<ProductModel>,
          FutureOr<List<ProductModel>>
        >
    with
        $FutureModifier<List<ProductModel>>,
        $FutureProvider<List<ProductModel>> {
  ShopProductsProvider._({
    required ShopProductsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'shopProductsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shopProductsHash();

  @override
  String toString() {
    return r'shopProductsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ProductModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProductModel>> create(Ref ref) {
    final argument = this.argument as String;
    return shopProducts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ShopProductsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shopProductsHash() => r'c5a5fab48e7e345c22b91c94fda7b0097fb8d2a4';

final class ShopProductsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ProductModel>>, String> {
  ShopProductsFamily._()
    : super(
        retry: null,
        name: r'shopProductsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ShopProductsProvider call(String shopId) =>
      ShopProductsProvider._(argument: shopId, from: this);

  @override
  String toString() => r'shopProductsProvider';
}
