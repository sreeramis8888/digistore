// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

@ProviderFor(transactions)
final transactionsProvider = TransactionsFamily._();

final class TransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedTransactions>,
          PaginatedTransactions,
          FutureOr<PaginatedTransactions>
        >
    with $FutureModifier<PaginatedTransactions>, $FutureProvider<PaginatedTransactions> {
  TransactionsProvider._({
    required TransactionsFamily super.from,
    required ({int limit, int page})
    super.argument,
  }) : super(
         retry: null,
         name: r'transactionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$transactionsHash();

  @override
  String toString() {
    return r'transactionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedTransactions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedTransactions> create(Ref ref) {
    final argument =
        this.argument as ({int limit, int page});
    return transactions(
      ref,
      limit: argument.limit,
      page: argument.page,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransactionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$transactionsHash() => r'transactions_hash_stub_456';

final class TransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedTransactions>,
          ({int limit, int page})
        > {
  TransactionsFamily._()
    : super(
        retry: null,
        name: r'transactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  TransactionsProvider call({
    int limit = 20,
    int page = 1,
  }) => TransactionsProvider._(
    argument: (limit: limit, page: page),
    from: this,
  );

  @override
  String toString() => r'transactionsProvider';
}

@ProviderFor(redemptions)
final redemptionsProvider = RedemptionsFamily._();

final class RedemptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedRedemptions>,
          PaginatedRedemptions,
          FutureOr<PaginatedRedemptions>
        >
    with $FutureModifier<PaginatedRedemptions>, $FutureProvider<PaginatedRedemptions> {
  RedemptionsProvider._({
    required RedemptionsFamily super.from,
    required ({int limit, int page})
    super.argument,
  }) : super(
         retry: null,
         name: r'redemptionsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$redemptionsHash();

  @override
  String toString() {
    return r'redemptionsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<PaginatedRedemptions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<PaginatedRedemptions> create(Ref ref) {
    final argument =
        this.argument as ({int limit, int page});
    return redemptions(
      ref,
      limit: argument.limit,
      page: argument.page,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is RedemptionsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$redemptionsHash() => r'redemptions_hash_stub_789';

final class RedemptionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedRedemptions>,
          ({int limit, int page})
        > {
  RedemptionsFamily._()
    : super(
        retry: null,
        name: r'redemptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  RedemptionsProvider call({
    int limit = 20,
    int page = 1,
  }) => RedemptionsProvider._(
    argument: (limit: limit, page: page),
    from: this,
  );

  @override
  String toString() => r'redemptionsProvider';
}
