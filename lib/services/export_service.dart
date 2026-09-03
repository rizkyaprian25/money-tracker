import 'dart:convert';
import 'package:drift/drift.dart';
import 'package:excel/excel.dart' as ex;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:intl/intl.dart';
// ignore: unnecessary_import - Uint8List used explicitly di beberapa method
// ignore_for_file: unused_import
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import '../database/app_database.dart';
import '../core/utils/currency_formatter.dart';
import 'platform/file_helper.dart' as file_helper;

class ExportService {
  final AppDatabase db;
  ExportService(this.db);

  Future<String> exportJson() async {
    final transactions = await db.select(db.transactions).get();
    final categories = await db.select(db.categories).get();
    final budgets = await db.select(db.budgets).get();
    final goals = await db.select(db.savingsGoals).get();
    final contributions = await db.select(db.savingsContributions).get();
    List<RecurringTransaction> recurring = [];
    try {
      recurring = await db.select(db.recurringTransactions).get();
    } catch (_) {}

    final data = {
      'exportDate': DateTime.now().toIso8601String(),
      'version': 1,
      'categories': categories.map((c) => {
            'id': c.id,
            'name': c.name,
            'type': c.type,
            'color': c.color,
            'icon': c.icon,
          }).toList(),
      'transactions': transactions.map((t) => {
            'id': t.id,
            'amount': t.amount,
            'transactionType': t.transactionType,
            'categoryId': t.categoryId,
            'note': t.note,
            'transactionDate': t.transactionDate.toIso8601String(),
            'createdAt': t.createdAt.toIso8601String(),
          }).toList(),
      'budgets': budgets.map((b) => {
            'id': b.id,
            'categoryId': b.categoryId,
            'amount': b.amount,
            'month': b.month,
            'year': b.year,
          }).toList(),
      'savingsGoals': goals.map((g) => {
            'id': g.id,
            'name': g.name,
            'targetAmount': g.targetAmount,
            'currentAmount': g.currentAmount,
            'icon': g.icon,
            'color': g.color,
            'imagePath': g.imagePath,
            'deadline': g.deadline?.toIso8601String(),
          }).toList(),
      'contributions': contributions.map((c) => {
            'id': c.id,
            'goalId': c.goalId,
            'amount': c.amount,
            'date': c.date.toIso8601String(),
            'note': c.note,
          }).toList(),
      // v1.1: aturan berulang ikut di-backup (nextDate mentah)
      'recurring': recurring.map((r) => {
            'amount': r.amount,
            'transactionType': r.transactionType,
            'categoryId': r.categoryId,
            'note': r.note,
            'frequency': r.frequency,
            'nextDate': r.nextDate.toIso8601String(),
            'isActive': r.isActive,
          }).toList(),
    };

    final jsonStr = jsonEncode(data);
    final bytes = Uint8List.fromList(utf8.encode(jsonStr));
    final fileName = 'money_tracker_backup_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.json';
    return file_helper.saveBytes(fileName, bytes, mimeType: 'application/json');
  }

  Future<String> exportPdf() async {
    final transactions = await db.getTransactions(limit: 1000);
    final totalIncome = await db.getTotalIncome(DateTime(2000), DateTime.now());
    final totalExpense = await db.getTotalExpense(DateTime(2000), DateTime.now());
    final balance = totalIncome - totalExpense;

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(
              level: 0,
              child: pw.Text('Money Tracker Personal - Laporan',
                  style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold))),
          pw.Paragraph(text: 'Tanggal cetak: ${DateFormat('d MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())}'),
          pw.SizedBox(height: 12),
          pw.Row(mainAxisAlignment: pw.MainAxisAlignment.spaceBetween, children: [
            _pdfStat('Total Pemasukan', CurrencyFormatter.format(totalIncome)),
            _pdfStat('Total Pengeluaran', CurrencyFormatter.format(totalExpense)),
            _pdfStat('Saldo', CurrencyFormatter.format(balance)),
          ]),
          pw.SizedBox(height: 20),
          pw.Text('Daftar Transaksi', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
          pw.SizedBox(height: 8),
          pw.TableHelper.fromTextArray(
            headers: ['Tanggal', 'Kategori', 'Catatan', 'Tipe', 'Jumlah'],
            data: transactions.map((e) {
              return [
                DateFormat('d/M/yyyy').format(e.transaction.transactionDate),
                e.category?.name ?? '-',
                e.transaction.note ?? '-',
                e.transaction.transactionType,
                CurrencyFormatter.format(e.transaction.amount),
              ];
            }).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo),
            cellHeight: 22,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.centerLeft,
              2: pw.Alignment.centerLeft,
              3: pw.Alignment.center,
              4: pw.Alignment.centerRight,
            },
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    final fileName = 'money_tracker_report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf';
    return file_helper.saveBytes(fileName, bytes, mimeType: 'application/pdf');
  }

  pw.Widget _pdfStat(String label, String value) {
    return pw.Column(children: [
      pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
      pw.Text(value, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 12)),
    ]);
  }

  Future<String> exportExcel() async {
    final excel = ex.Excel.createExcel();
    // Transactions sheet
    final sheet = excel['Transactions'];
    // Header row
    sheet.appendRow([
      ex.TextCellValue('ID'),
      ex.TextCellValue('Tanggal'),
      ex.TextCellValue('Kategori'),
      ex.TextCellValue('Catatan'),
      ex.TextCellValue('Tipe'),
      ex.TextCellValue('Jumlah'),
    ]);
    final transactions = await db.getTransactions(limit: 2000);
    for (final t in transactions) {
      sheet.appendRow([
        ex.IntCellValue(t.transaction.id),
        ex.TextCellValue(DateFormat('yyyy-MM-dd').format(t.transaction.transactionDate)),
        ex.TextCellValue(t.category?.name ?? ''),
        ex.TextCellValue(t.transaction.note ?? ''),
        ex.TextCellValue(t.transaction.transactionType),
        ex.DoubleCellValue(t.transaction.amount),
      ]);
    }

    // Categories sheet
    final catSheet = excel['Categories'];
    catSheet.appendRow([
      ex.TextCellValue('ID'),
      ex.TextCellValue('Nama'),
      ex.TextCellValue('Tipe'),
      ex.TextCellValue('Warna'),
      ex.TextCellValue('Icon'),
    ]);
    final cats = await db.select(db.categories).get();
    for (final c in cats) {
      catSheet.appendRow([
        ex.IntCellValue(c.id),
        ex.TextCellValue(c.name),
        ex.TextCellValue(c.type),
        ex.TextCellValue(c.color),
        ex.TextCellValue(c.icon),
      ]);
    }

    // Budgets sheet
    final bSheet = excel['Budgets'];
    bSheet.appendRow([
      ex.TextCellValue('ID'),
      ex.TextCellValue('CategoryId'),
      ex.TextCellValue('Jumlah'),
      ex.TextCellValue('Bulan'),
      ex.TextCellValue('Tahun'),
    ]);
    final budgets = await db.select(db.budgets).get();
    for (final b in budgets) {
      bSheet.appendRow([
        ex.IntCellValue(b.id),
        b.categoryId != null ? ex.IntCellValue(b.categoryId!) : ex.TextCellValue('-'),
        ex.DoubleCellValue(b.amount),
        ex.IntCellValue(b.month),
        ex.IntCellValue(b.year),
      ]);
    }

    // Remove default sheet
    excel.delete('Sheet1');

    final bytes = Uint8List.fromList(excel.encode()!);
    final fileName = 'money_tracker_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.xlsx';
    return file_helper.saveBytes(fileName, bytes, mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
  }

  Future<void> shareFile(String path) async {
    if (kIsWeb) {
      // On web file already downloaded via saveBytes, nothing to share
      return;
    }
    // share_plus 11: API lama Share.shareXFiles deprecated -> SharePlus.instance.
    await SharePlus.instance.share(ShareParams(files: [XFile(path)]));
  }

    Future<String?> pickAndSave(String sourcePath, String fileName) async {
    if (kIsWeb) {
      return sourcePath;
    }
    try {
      final result = await FilePicker.platform.saveFile(
        dialogTitle: 'Simpan File',
        fileName: fileName,
      );
      return result;
    } catch (e) {
      await shareFile(sourcePath);
      return null;
    }
  }

  Future<bool> importJson(String jsonPath) async {
    try {
      final content = await file_helper.readFileAsString(jsonPath);
      return importJsonString(content);
    } catch (e) {
      return false;
    }
  }

  /// Web-compatible import from raw JSON string or bytes.
  Future<bool> importJsonBytes(Uint8List bytes) async {
    try {
      final content = utf8.decode(bytes);
      return importJsonString(content);
    } catch (e) {
      return false;
    }
  }

  Future<bool> importJsonString(String content) async {
    try {
      final data = jsonDecode(content) as Map<String, dynamic>;

      await db.transaction(() async {
        await db.delete(db.savingsContributions).go();
        await db.delete(db.savingsGoals).go();
        await db.delete(db.budgets).go();
        await db.delete(db.transactions).go();
        await db.delete(db.categories).go();

        // Fase 3: petakan ID lama -> ID baru. DELETE tidak mereset
        // sqlite_sequence (AUTOINCREMENT), jadi insert ulang dapat ID baru
        // yang berbeda dari backup. Tanpa mapping, FK categoryId/goalId rusak.
        final catIdMap = <int, int>{};
        final cats = data['categories'] as List? ?? [];
        for (final c in cats) {
          final oldId = c['id'] as int?;
          final newId = await db.into(db.categories).insert(CategoriesCompanion.insert(
            name: c['name'] as String,
            type: c['type'] as String,
            color: c['color'] as String,
            icon: c['icon'] as String,
          ));
          if (oldId != null) catIdMap[oldId] = newId;
        }

        final txs = data['transactions'] as List? ?? [];
        for (final t in txs) {
          final oldCatId = t['categoryId'] as int?;
          await db.into(db.transactions).insert(TransactionsCompanion.insert(
            amount: (t['amount'] as num).toDouble(),
            transactionType: t['transactionType'] as String,
            // Kategori yang sudah dihapus di device asal -> NULL (ikut FK SET NULL)
            categoryId: Value(oldCatId == null ? null : catIdMap[oldCatId]),
            note: Value(t['note'] as String?),
            transactionDate: DateTime.parse(t['transactionDate'] as String),
            createdAt: Value(DateTime.tryParse(t['createdAt'] as String? ?? '') ?? DateTime.now()),
          ));
        }

        final budgets = data['budgets'] as List? ?? [];
        for (final b in budgets) {
          final oldCatId = b['categoryId'] as int?;
          await db.into(db.budgets).insert(BudgetsCompanion.insert(
            categoryId: Value(oldCatId == null ? null : catIdMap[oldCatId]),
            amount: (b['amount'] as num).toDouble(),
            month: b['month'] as int,
            year: b['year'] as int,
          ));
        }

        final goalIdMap = <int, int>{};
        final goals = data['savingsGoals'] as List? ?? [];
        for (final g in goals) {
          final oldId = g['id'] as int?;
          final newId = await db.into(db.savingsGoals).insert(SavingsGoalsCompanion.insert(
            name: g['name'] as String,
            targetAmount: (g['targetAmount'] as num).toDouble(),
            currentAmount: Value((g['currentAmount'] as num?)?.toDouble() ?? 0.0),
            icon: Value(g['icon'] as String?),
            color: Value(g['color'] as String?),
            imagePath: Value(g['imagePath'] as String?),
            deadline: Value(g['deadline'] != null ? DateTime.tryParse(g['deadline'] as String) : null),
          ));
          if (oldId != null) goalIdMap[oldId] = newId;
        }

        final contribs = data['contributions'] as List? ?? [];
        for (final c in contribs) {
          // FK goalId NOT NULL: lewati kontribusi yang goal-nya tak ada di backup
          final newGoalId = goalIdMap[c['goalId'] as int];
          if (newGoalId == null) continue;
          await db.into(db.savingsContributions).insert(SavingsContributionsCompanion.insert(
            goalId: newGoalId,
            amount: (c['amount'] as num).toDouble(),
            date: DateTime.parse(c['date'] as String),
            note: Value(c['note'] as String?),
          ));
        }

        // v1.1: restore aturan berulang (abaikan bila backup lama tak punya key)
        final recurring = data['recurring'] as List? ?? [];
        for (final r in recurring) {
          try {
            final oldCatId = r['categoryId'] as int?;
            await db.into(db.recurringTransactions).insert(RecurringTransactionsCompanion.insert(
              amount: (r['amount'] as num).toDouble(),
              transactionType: r['transactionType'] as String,
              categoryId: Value(oldCatId == null ? null : catIdMap[oldCatId]),
              note: Value(r['note'] as String?),
              frequency: Value(r['frequency'] as String? ?? 'monthly'),
              nextDate: DateTime.parse(r['nextDate'] as String),
              isActive: Value(r['isActive'] as bool? ?? true),
            ));
          } catch (_) {}
        }
      });
      return true;
    } catch (e) {
      return false;
    }
  }
}
