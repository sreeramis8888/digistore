// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rewards_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(RewardsList)
final rewardsListProvider = RewardsListProvider._();

final class RewardsListProvider
    extends $NotifierProvider<RewardsList, RewardsState> {
  RewardsListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rewardsListProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rewardsListHash();

  @$internal
  @override
  RewardsList create() => RewardsList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RewardsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RewardsState>(value),
    );
  }
}

String _$rewardsListHash() => r'ac2e1e54eac3d3ddf16de2455ff9eca583719eb6';

abstract class _$RewardsList extends $Notifier<RewardsState> {
  RewardsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RewardsState, RewardsState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RewardsState, RewardsState>,
              RewardsState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(claimedRewards)
final claimedRewardsProvider = ClaimedRewardsFamily._();

final class ClaimedRewardsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedClaimedRewards>,
          PaginatedClaimedRewards,
          FutureOr<PaginatedClaimedRewards>
        >
    with
        $FutureModifier<PaginatedClaimedRewards>,
        $FutureProvider<PaginatedClaimedRewards> {
  ClaimedRewardsProvider._({
    required ClaimedRewardsFamily super.from,
    required ({int page, int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'claimedRewardsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$claimedRewardsHash();

  @override
  String toString() {
    return r'claimedRewardsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedClaimedRewards> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedClaimedRewards> create(Ref ref) {
    final argument = this.argument as ({int page, int limit});
    return claimedRewards(ref, page: argument.page, limit: argument.limit);
  }

  @override
  bool operator ==(Object other) {
    return other is ClaimedRewardsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$claimedRewardsHash() => r'18c8330cfc7dbd59fb099bf4b3e924aacde3ed0d';

final class ClaimedRewardsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedClaimedRewards>,
          ({int page, int limit})
        > {
  ClaimedRewardsFamily._()
    : super(
        retry: null,
        name: r'claimedRewardsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  ClaimedRewardsProvider call({int page = 1, int limit = 10}) =>
      ClaimedRewardsProvider._(
        argument: (page: page, limit: limit),
        from: this,
      );

  @override
  String toString() => r'claimedRewardsProvider';
}

@ProviderFor(RewardAction)
final rewardActionProvider = RewardActionProvider._();

final class RewardActionProvider extends $NotifierProvider<RewardAction, void> {
  RewardActionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rewardActionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rewardActionHash();

  @$internal
  @override
  RewardAction create() => RewardAction();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$rewardActionHash() => r'f1751de3ddbfec99b94a4333e3d8c63101ecd55f';

abstract class _$RewardAction extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(getRewardById)
final getRewardByIdProvider = GetRewardByIdFamily._();

final class GetRewardByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<RewardModel?>,
          RewardModel?,
          FutureOr<RewardModel?>
        >
    with $FutureModifier<RewardModel?>, $FutureProvider<RewardModel?> {
  GetRewardByIdProvider._({
    required GetRewardByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'getRewardByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$getRewardByIdHash();

  @override
  String toString() {
    return r'getRewardByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<RewardModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<RewardModel?> create(Ref ref) {
    final argument = this.argument as String;
    return getRewardById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is GetRewardByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$getRewardByIdHash() => r'bebdd7559f607a6f9f9a353e3ae9eb359634f649';

final class GetRewardByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<RewardModel?>, String> {
  GetRewardByIdFamily._()
    : super(
        retry: null,
        name: r'getRewardByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  GetRewardByIdProvider call(String rewardId) =>
      GetRewardByIdProvider._(argument: rewardId, from: this);

  @override
  String toString() => r'getRewardByIdProvider';
}
