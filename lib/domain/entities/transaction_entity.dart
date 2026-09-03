import 'category_entity.dart';

/// Domain entity Transaction — mirror `lib/database/tables/transactions.dart:4-12`
/// transactionType: 'income' | 'expense'
class TransactionEntity {
  final int id;
  final double amount;
  final String transactionType;
  final int? categoryId;
  final String? note;
  final DateTime transactionDate;
  final DateTime createdAt;
  final CategoryEntity? category; // joined

  const TransactionEntity({
    required this.id,
    required this.amount,
    required this.transactionType,
    this.categoryId,
    this.note,
    required this.transactionDate,
    required this.createdAt,
    this.category,
  });

  bool get isIncome => transactionType == 'income';
  bool get isExpense => transactionType == 'expense';

  String get displayCategory => category?.name ?? 'Lainnya';

  TransactionEntity copyWith({
    int? id,
    double? amount,
    String? transactionType,
    int? categoryId,
    String? note,
    DateTime? transactionDate,
    DateTime? createdAt,
    CategoryEntity? category,
  }) =>
      TransactionEntity(
        id: id ?? this.id,
        amount: amount ?? this.amount,
        transactionType: transactionType ?? this.transactionType,
        categoryId: categoryId ?? this.categoryId,
        note: note ?? this.note,
        transactionDate: transactionDate ?? this.transactionDate,
        createdAt: createdAt ?? this.createdAt,
        category: category ?? this.category,
      );
}

/// Filter value-object — mirror `TransactionFilter` di `lib/presentation/providers/transaction_provider.dart:6-44`
class TransactionFilterEntity {
  final String? search;
  final String? type;
  final int? categoryId;
  final DateTime? startDate;
  final DateTime? endDate;
  final int limit;
  final int offset;

  const TransactionFilterEntity({
    this.search,
    this.type,
    this.categoryId,
    this.startDate,
    this.endDate,
    this.limit = 50,
    this.offset = 0,
  });

  TransactionFilterEntity copyWith({
    String? search,
    String? type,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
    int? offset,
  }) =>
      TransactionFilterEntity(
        search: search ?? this.search,
        type: type ?? this.type,
        categoryId: categoryId ?? this.categoryId,
        startDate: startDate ?? this.startDate,
        endDate: endDate ?? this.endDate,
        limit: limit ?? this.limit,
        offset: offset ?? this.offset,
      );
}
