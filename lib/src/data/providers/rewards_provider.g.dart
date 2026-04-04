// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

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
    required ({int page, int limit, String? category}) super.argument,
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
    final argument = this.argument as ({int page, int limit, String? category});
    return rewards(
      ref,
      page: argument.page,
      limit: argument.limit,
      category: argument.category,
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

String _$rewardsHash() => r'504907c6f2201008f6d974cb8335010ada339f1b';

final class RewardsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedRewards>,
          ({int page, int limit, String? category})
        > {
  RewardsFamily._()
    : super(
        retry: null,
        name: r'rewardsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RewardsProvider call({int page = 1, int limit = 10, String? category}) =>
      RewardsProvider._(
        argument: (page: page, limit: limit, category: category),
        from: this,
      );

  @override
  String toString() => r'rewardsProvider';
}
