// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shops_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(shops)
final shopsProvider = ShopsFamily._();

final class ShopsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedShops>,
          PaginatedShops,
          FutureOr<PaginatedShops>
        >
    with $FutureModifier<PaginatedShops>, $FutureProvider<PaginatedShops> {
  ShopsProvider._({
    required ShopsFamily super.from,
    required ({String? category, String? search, int page, int limit})
    super.argument,
  }) : super(
         retry: null,
         name: r'shopsProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$shopsHash();

  @override
  String toString() {
    return r'shopsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedShops> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedShops> create(Ref ref) {
    final argument =
        this.argument
            as ({String? category, String? search, int page, int limit});
    return shops(
      ref,
      category: argument.category,
      search: argument.search,
      page: argument.page,
      limit: argument.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is ShopsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$shopsHash() => r'd7837f4400e88835cca5b44edefc1f5f565c2274';

final class ShopsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedShops>,
          ({String? category, String? search, int page, int limit})
        > {
  ShopsFamily._()
    : super(
        retry: null,
        name: r'shopsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  ShopsProvider call({
    String? category,
    String? search,
    int page = 1,
    int limit = 20,
  }) => ShopsProvider._(
    argument: (category: category, search: search, page: page, limit: limit),
    from: this,
  );

  @override
  String toString() => r'shopsProvider';
}
