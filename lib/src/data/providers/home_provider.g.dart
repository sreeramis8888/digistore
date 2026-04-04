// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(homeData)
final homeDataProvider = HomeDataProvider._();

final class HomeDataProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeData?>,
          HomeData?,
          FutureOr<HomeData?>
        >
    with $FutureModifier<HomeData?>, $FutureProvider<HomeData?> {
  HomeDataProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeDataProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeDataHash();

  @$internal
  @override
  $FutureProviderElement<HomeData?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<HomeData?> create(Ref ref) {
    return homeData(ref);
  }
}

String _$homeDataHash() => r'761eb0c41a5ef0332007e9b8d4e598901e93c655';
