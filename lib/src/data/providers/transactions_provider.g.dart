// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'transactions_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(transactions)
final transactionsProvider = TransactionsFamily._();

final class TransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<PaginatedTransactions>,
          PaginatedTransactions,
          FutureOr<PaginatedTransactions>
        >
    with
        $FutureModifier<PaginatedTransactions>,
        $FutureProvider<PaginatedTransactions> {
  TransactionsProvider._({
    required TransactionsFamily super.from,
    required ({int page, int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'transactionsProvider',
         isAutoDispose: false,
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
    final argument = this.argument as ({int page, int limit});
    return transactions(ref, page: argument.page, limit: argument.limit);
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

String _$transactionsHash() => r'3ccd9d1d6c15566ae4749c844fa9a0e66c777288';

final class TransactionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedTransactions>,
          ({int page, int limit})
        > {
  TransactionsFamily._()
    : super(
        retry: null,
        name: r'transactionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  TransactionsProvider call({int page = 1, int limit = 20}) =>
      TransactionsProvider._(argument: (page: page, limit: limit), from: this);

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
    with
        $FutureModifier<PaginatedRedemptions>,
        $FutureProvider<PaginatedRedemptions> {
  RedemptionsProvider._({
    required RedemptionsFamily super.from,
    required ({int page, int limit}) super.argument,
  }) : super(
         retry: null,
         name: r'redemptionsProvider',
         isAutoDispose: false,
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
    final argument = this.argument as ({int page, int limit});
    return redemptions(ref, page: argument.page, limit: argument.limit);
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

String _$redemptionsHash() => r'fd30b8ba0ef256cc9e4abcdbb4694db02d8c3507';

final class RedemptionsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<PaginatedRedemptions>,
          ({int page, int limit})
        > {
  RedemptionsFamily._()
    : super(
        retry: null,
        name: r'redemptionsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  RedemptionsProvider call({int page = 1, int limit = 20}) =>
      RedemptionsProvider._(argument: (page: page, limit: limit), from: this);

  @override
  String toString() => r'redemptionsProvider';
}
