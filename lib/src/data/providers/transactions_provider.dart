import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/transaction_model.dart';
import '../models/redemption_model.dart';
import 'api_provider.dart';

part 'transactions_provider.g.dart';

@riverpod
Future<PaginatedTransactions> transactions(
  Ref ref, {
  int page = 1,
  int limit = 20,
}) async {
  final api = ref.watch(apiProvider);

  final queryParams = {'page': page.toString(), 'limit': limit.toString()};

  final response = await api.get(
    '/transactions/points',
    queryParams: queryParams,
  );

  if (response.success && response.data != null) {
    return PaginatedTransactions.fromJson(response.data!);
  } else {
    throw Exception(response.message ?? 'Failed to fetch transactions');
  }
}

@riverpod
Future<PaginatedRedemptions> redemptions(
  Ref ref, {
  int page = 1,
  int limit = 20,
}) async {
  final api = ref.watch(apiProvider);

  final queryParams = {'page': page.toString(), 'limit': limit.toString()};

  final response = await api.get(
    '/transactions/redemptions',
    queryParams: queryParams,
  );

  if (response.success && response.data != null) {
    return PaginatedRedemptions.fromJson(response.data!);
  } else {
    throw Exception(response.message ?? 'Failed to fetch redemptions');
  }
}
