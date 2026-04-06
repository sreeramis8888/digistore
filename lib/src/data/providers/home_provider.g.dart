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
          AsyncValue<HomeResponseState?>,
          HomeResponseState?,
          FutureOr<HomeResponseState?>
        >
    with
        $FutureModifier<HomeResponseState?>,
        $FutureProvider<HomeResponseState?> {
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
  $FutureProviderElement<HomeResponseState?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HomeResponseState?> create(Ref ref) {
    return homeData(ref);
  }
}

String _$homeDataHash() => r'6b3d2950eed3f4831ae2782861c9acf6ed3fbe2d';
