// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(rewards)
final rewardsProvider = RewardsFamily._();

final class RewardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedRewards>,
          PaginatedRewards,
          FutureOr<PaginatedRewards>
        >
    with $FutureModifier<PaginatedRewards>, $FutureProvider<PaginatedRewards> {
  RewardsProvider._({
    required RewardsFamily super.from,
    required ({String? category, int limit, int page})
    super.argument,
  }) : super(
         retry: null,
         name: r'rewardsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rewardsHash();

  @override
  String toString() {
    return r'rewardsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedRewards> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedRewards> create(Ref ref) {
    final argument =
        this.argument as ({String? category, int limit, int page});
    return rewards(
      ref,
      category: argument.category,
      limit: argument.limit,
      page: argument.page,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RewardsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rewardsHash() => r'rewards_hash_stub_123';

final class RewardsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedRewards>,
          ({String? category, int limit, int page})
        > {
  RewardsFamily._()
    : super(
        retry: null,
        name: r'rewardsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RewardsProvider call({
    String? category,
    int limit = 10,
    int page = 1,
  }) => RewardsProvider._(
    argument: (category: category, limit: limit, page: page),
    from: this,
  );

  @override
  String toString() => r'rewardsProvider';
}
