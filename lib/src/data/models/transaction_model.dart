class TransactionModel {
  final String? id;
  final String? publicUserId;
  final String? type; // earned, redeemed, bonus, expired
  final int? amount;
  final int? balance;
  final String? description;
  final DateTime? createdAt;
  final TransactionSource? source;

  const TransactionModel({
    this.id,
    this.publicUserId,
    this.type,
    this.amount,
    this.balance,
    this.description,
    this.createdAt,
    this.source,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['_id'] as String?,
      publicUserId: json['publicUserId'] as String?,
      type: json['type'] as String?,
      amount: json['amount'] as int?,
      balance: json['balance'] as int?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null ? DateTime.tryParse(json['createdAt']) : null,
      source: json['source'] != null ? TransactionSource.fromJson(json['source'] as Map<String, dynamic>) : null,
    );
  }
}

class TransactionSource {
  final String? type;
  final String? refId;

  const TransactionSource({this.type, this.refId});

  factory TransactionSource.fromJson(Map<String, dynamic> json) {
    return TransactionSource(
      type: json['type'] as String?,
      refId: json['refId'] as String?,
    );
  }
}

class PaginatedTransactions {
  final List<TransactionModel> transactions;
  final int page;
  final int limit;
  final int total;
  final int pages;

  PaginatedTransactions({
    required this.transactions,
    required this.page,
    required this.limit,
    required this.total,
    required this.pages,
  });

  factory PaginatedTransactions.fromJson(Map<String, dynamic> json) {
    return PaginatedTransactions(
      transactions: (json['data'] as List? ?? [])
          .map((e) => TransactionModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      page: json['pagination']?['page'] as int? ?? 1,
      limit: json['pagination']?['limit'] as int? ?? 10,
      total: json['pagination']?['total'] as int? ?? 0,
      pages: json['pagination']?['pages'] as int? ?? 1,
    );
  }
}
