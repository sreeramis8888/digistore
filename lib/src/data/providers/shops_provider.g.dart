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

String _$shopsHash() => r'dc413ffc644ccacc25b1d0c3a379dc9d5dd99425';

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

String _$allShopsHash() => r'f01786f30dc7ae289d2df2e99f3017d9680963a2';

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

@ProviderFor(FeaturedShops)
final featuredShopsProvider = FeaturedShopsProvider._();

final class FeaturedShopsProvider
    extends $NotifierProvider<FeaturedShops, ShopsState> {
  FeaturedShopsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredShopsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredShopsHash();

  @$internal
  @override
  FeaturedShops create() => FeaturedShops();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ShopsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ShopsState>(value),
    );
  }
}

String _$featuredShopsHash() => r'075b5a112c2bad145cbd5b3eb38b5de9dd5de75b';

abstract class _$FeaturedShops extends $Notifier<ShopsState> {
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

String _$shopOffersHash() => r'e81dc7c89322818bcf51460cf1ddd0e3c60afd4e';

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

String _$shopProductsHash() => r'0f6c3cc9df01a64bf952a075e41f79a3f5aa9dd5';

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

@ProviderFor(getShopByPartnerId)
final getShopByPartnerIdProvider = GetShopByPartnerIdFamily._();

final class GetShopByPartnerIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<ShopModel?>,
          ShopModel?,
          FutureOr<ShopModel?>
        >
    with $FutureModifier<ShopModel?>, $FutureProvider<ShopModel?> {
  GetShopByPartnerIdProvider._({
    required GetShopByPartnerIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getShopByPartnerIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getShopByPartnerIdHash();

  @override
  String toString() {
    return r'getShopByPartnerIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ShopModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ShopModel?> create(Ref ref) {
    final argument = this.argument as String;
    return getShopByPartnerId(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetShopByPartnerIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getShopByPartnerIdHash() =>
    r'e91a4ab33d53afb581c4b03d044093acdd9e6e24';

final class GetShopByPartnerIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ShopModel?>, String> {
  GetShopByPartnerIdFamily._()
    : super(
        retry: null,
        name: r'getShopByPartnerIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetShopByPartnerIdProvider call(String partnerId) =>
      GetShopByPartnerIdProvider._(argument: partnerId, from: this);

  @override
  String toString() => r'getShopByPartnerIdProvider';
}
