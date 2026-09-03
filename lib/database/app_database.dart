import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart' as drift_flutter;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'tables/categories.dart';
import 'tables/transactions.dart';
import 'tables/budgets.dart';
import 'tables/savings_goals.dart';
import 'tables/savings_contributions.dart';
import 'tables/app_settings.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  Categories,
  Transactions,
  Budgets,
  SavingsGoals,
  SavingsContributions,
  AppSettings,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.e);

  static QueryExecutor _openConnection() {
    if (kIsWeb) {
      return drift_flutter.driftDatabase(
        name: 'money_tracker.db',
        web: drift_flutter.DriftWebOptions(
          sqlite3Wasm: Uri.parse('sqlite3.wasm'),
          driftWorker: Uri.parse('drift_worker.dart.js'),
        ),
      );
    }
    return drift_flutter.driftDatabase(name: 'money_tracker.db');
  }

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (Migrator m) async {
          await m.createAll();
          await _createIndexes();
          await _seedDefaults();
        },
        onUpgrade: (migrator, from, to) async {
          if (from < 2) {
            await _createIndexes();
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  Future<void> _createIndexes() async {
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_transactionDate ON transactions(transaction_date)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_categoryId ON transactions(category_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_transactionType ON transactions(transaction_type)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_transactions_date_type ON transactions(transaction_date, transaction_type)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_budgets_month_year ON budgets(month, year)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_budgets_categoryId ON budgets(category_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_savings_contributions_goalId ON savings_contributions(goal_id)');
    await customStatement(
        'CREATE INDEX IF NOT EXISTS idx_categories_type ON categories(type)');
  }

  // Transactions with category join
  Stream<List<TransactionWithCategory>> watchTransactions({
    String? search,
    String? type,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) {
    final query = select(transactions).join([
      leftOuterJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]);

    if (search != null && search.isNotEmpty) {
      query.where(
          (transactions.note.like('%$search%') | categories.name.like('%$search%')));
    }
    if (type != null) {
      query.where(transactions.transactionType.equals(type));
    }
    if (categoryId != null) {
      query.where(transactions.categoryId.equals(categoryId));
    }
    if (startDate != null) {
      query.where(transactions.transactionDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(transactions.transactionDate.isSmallerOrEqualValue(endDate));
    }
    query.orderBy([OrderingTerm.desc(transactions.transactionDate)]);
    query.limit(limit, offset: offset);

    return query.watch().map((rows) => rows.map((row) {
          return TransactionWithCategory(
            transaction: row.readTable(transactions),
            category: row.readTableOrNull(categories),
          );
        }).toList());
  }

  Future<List<TransactionWithCategory>> getTransactions({
    String? search,
    String? type,
    int? categoryId,
    DateTime? startDate,
    DateTime? endDate,
    int limit = 50,
    int offset = 0,
  }) async {
    final query = select(transactions).join([
      leftOuterJoin(categories, categories.id.equalsExp(transactions.categoryId)),
    ]);
    if (search != null && search.isNotEmpty) {
      query.where(
          (transactions.note.like('%$search%') | categories.name.like('%$search%')));
    }
    if (type != null) {
      query.where(transactions.transactionType.equals(type));
    }
    if (categoryId != null) {
      query.where(transactions.categoryId.equals(categoryId));
    }
    if (startDate != null) {
      query.where(transactions.transactionDate.isBiggerOrEqualValue(startDate));
    }
    if (endDate != null) {
      query.where(transactions.transactionDate.isSmallerOrEqualValue(endDate));
    }
    query.orderBy([OrderingTerm.desc(transactions.transactionDate)]);
    query.limit(limit, offset: offset);
    final rows = await query.get();
    return rows
        .map((row) => TransactionWithCategory(
              transaction: row.readTable(transactions),
              category: row.readTableOrNull(categories),
            ))
        .toList();
  }

  Future<double> getTotalIncome(DateTime from, DateTime to) async {
    final q = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.transactionType.equals('income') &
          transactions.transactionDate.isBetweenValues(from, to));
    final row = await q.getSingle();
    return row.read(transactions.amount.sum()) ?? 0;
  }

  Future<double> getTotalExpense(DateTime from, DateTime to) async {
    final q = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.transactionType.equals('expense') &
          transactions.transactionDate.isBetweenValues(from, to));
    final row = await q.getSingle();
    return row.read(transactions.amount.sum()) ?? 0;
  }

  Future<double> getBalance() async {
    final incomeQ = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.transactionType.equals('income'));
    final expenseQ = selectOnly(transactions)
      ..addColumns([transactions.amount.sum()])
      ..where(transactions.transactionType.equals('expense'));
    final income = (await incomeQ.getSingle()).read(transactions.amount.sum()) ?? 0;
    final expense = (await expenseQ.getSingle()).read(transactions.amount.sum()) ?? 0;
    return income - expense;
  }

  Stream<List<Category>> watchCategories() => select(categories).watch();
  Stream<List<Category>> watchCategoriesByType(String type) =>
      (select(categories)..where((c) => c.type.equals(type))).watch();

  Future<int> insertCategory(CategoriesCompanion c) => into(categories).insert(c);
  Future<bool> updateCategory(Category c) => update(categories).replace(c);
  Future<int> deleteCategory(int id) => (delete(categories)..where((c) => c.id.equals(id))).go();

  Future<int> insertTransaction(TransactionsCompanion t) => into(transactions).insert(t);
  Future<bool> updateTransaction(Transaction t) => update(transactions).replace(t);
  Future<int> deleteTransaction(int id) => (delete(transactions)..where((t) => t.id.equals(id))).go();

  Stream<List<Budget>> watchBudgets() => select(budgets).watch();
  Future<int> insertBudget(BudgetsCompanion b) => into(budgets).insert(b, mode: InsertMode.insertOrReplace);
  Future<int> deleteBudget(int id) => (delete(budgets)..where((b) => b.id.equals(id))).go();
  Future<bool> updateBudget(Budget b) => update(budgets).replace(b);

  Stream<List<SavingsGoal>> watchSavingsGoals() => select(savingsGoals).watch();
  Future<int> insertSavingsGoal(SavingsGoalsCompanion g) => into(savingsGoals).insert(g);
  Future<bool> updateSavingsGoal(SavingsGoal g) => update(savingsGoals).replace(g);
  Future<int> deleteSavingsGoal(int id) => (delete(savingsGoals)..where((g) => g.id.equals(id))).go();

  Stream<List<SavingsContribution>> watchContributions(int goalId) =>
      (select(savingsContributions)..where((c) => c.goalId.equals(goalId))..orderBy([(c) => OrderingTerm.desc(c.date)])).watch();

  Future<int> insertContribution(SavingsContributionsCompanion c) => into(savingsContributions).insert(c);

  Future<AppSetting?> getSettings() async {
    final list = await select(appSettings).get();
    if (list.isEmpty) {
      final id = await into(appSettings).insert(const AppSettingsCompanion(
        currency: Value('IDR'),
        isDarkMode: Value(false),
        language: Value('id'),
      ));
      return AppSetting(id: id, currency: 'IDR', isDarkMode: false, language: 'id', lastBackup: null);
    }
    return list.first;
  }

  Stream<AppSetting?> watchSettings() {
    return select(appSettings).watchSingleOrNull();
  }

  Future<void> updateSettings(AppSettingsCompanion companion) async {
    final existing = await select(appSettings).getSingleOrNull();
    if (existing == null) {
      await into(appSettings).insert(companion);
    } else {
      await (update(appSettings)..where((t) => t.id.equals(existing.id))).write(companion);
    }
  }

  Future<void> _seedDefaults() async {
    final existing = await select(categories).get();
    if (existing.isNotEmpty) return;

    // Income categories
    final incomeCats = [
      CategoriesCompanion.insert(name: 'Gaji', type: 'income', color: '#006E1C', icon: 'payments'),
      CategoriesCompanion.insert(name: 'Freelance', type: 'income', color: '#00731E', icon: 'work'),
      CategoriesCompanion.insert(name: 'Bonus', type: 'income', color: '#005313', icon: 'card_giftcard'),
      CategoriesCompanion.insert(name: 'Lainnya', type: 'income', color: '#454652', icon: 'more_horiz'),
    ];
    // Expense categories
    final expenseCats = [
      CategoriesCompanion.insert(name: 'Makanan', type: 'expense', color: '#8C0005', icon: 'restaurant'),
      CategoriesCompanion.insert(name: 'Transportasi', type: 'expense', color: '#24389C', icon: 'directions_car'),
      CategoriesCompanion.insert(name: 'Belanja', type: 'expense', color: '#B51010', icon: 'shopping_bag'),
      CategoriesCompanion.insert(name: 'Hiburan', type: 'expense', color: '#930005', icon: 'movie'),
      CategoriesCompanion.insert(name: 'Tagihan', type: 'expense', color: '#3F51B5', icon: 'receipt'),
      CategoriesCompanion.insert(name: 'Kesehatan', type: 'expense', color: '#006E1C', icon: 'favorite'),
      CategoriesCompanion.insert(name: 'Pendidikan', type: 'expense', color: '#293CA0', icon: 'school'),
      CategoriesCompanion.insert(name: 'Lainnya', type: 'expense', color: '#757684', icon: 'category'),
    ];

    for (final c in [...incomeCats, ...expenseCats]) {
      await into(categories).insert(c);
    }

    // 2026-09-03: tidak ada data contoh (transaksi/anggaran/target).
    // User mulai dari kosong dan mengisi data asli sendiri.
    // Kategori default di atas tetap di-seed agar dropdown tidak kosong.

    await into(appSettings).insert(const AppSettingsCompanion(
      currency: Value('IDR'),
      isDarkMode: Value(false),
      language: Value('id'),
    ));
  }
}

class TransactionWithCategory {
  final Transaction transaction;
  final Category? category;
  TransactionWithCategory({required this.transaction, this.category});
}
