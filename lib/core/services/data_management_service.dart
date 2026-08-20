import 'dart:io';

import 'package:excel/excel.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../database/app_database.dart';

class DataManagementService {
  DataManagementService(this._database);

  final AppDatabase _database;

  Future<void> exportToExcel() async {
    final accounts = await _database.select(_database.accounts).get();
    final categories = await _database.select(_database.categories).get();
    final transactions = await _database.select(_database.transactions).get();
    final transfers = await _database.select(_database.transfers).get();

    final workbook = Excel.createExcel();
    _writeAccounts(workbook['Accounts'], accounts);
    _writeCategories(workbook['Categories'], categories);
    _writeTransactions(workbook['Transactions'], transactions);
    _writeTransfers(workbook['Transfers'], transfers);
    workbook.delete('Sheet1');

    final metadata = workbook['Metadata'];
    metadata.appendRow([TextCellValue('formatVersion'), TextCellValue('1')]);
    metadata.appendRow([
      TextCellValue('exportedAt'),
      TextCellValue(DateTime.now().toUtc().toIso8601String()),
    ]);

    final bytes = workbook.save();
    if (bytes == null) {
      throw StateError('تعذر إنشاء ملف Excel');
    }

    final directory = await getTemporaryDirectory();
    final fileName = 'pocket-backup-${_dateStamp(DateTime.now())}.xlsx';
    final file = File(path.join(directory.path, fileName));
    await file.writeAsBytes(bytes, flush: true);

    await SharePlus.instance.share(
      ShareParams(files: [XFile(file.path)], subject: 'Pocket backup'),
    );
  }

  Future<void> resetAllData() async {
    await _database.transaction(() async {
      await _database.delete(_database.transactions).go();
      await _database.delete(_database.transfers).go();
      await _database.delete(_database.categories).go();
      await _database.delete(_database.accounts).go();
    });
  }

  void _writeAccounts(Sheet sheet, List<Account> accounts) {
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('name'),
      TextCellValue('type'),
      TextCellValue('openingBalance'),
      TextCellValue('currentBalance'),
      TextCellValue('color'),
      TextCellValue('icon'),
      TextCellValue('isArchived'),
      TextCellValue('createdAt'),
    ]);
    for (final account in accounts) {
      sheet.appendRow([
        IntCellValue(account.id),
        TextCellValue(account.name),
        TextCellValue(account.type),
        DoubleCellValue(account.openingBalance),
        DoubleCellValue(account.currentBalance),
        IntCellValue(account.color),
        TextCellValue(account.icon),
        BoolCellValue(account.isArchived),
        DateTimeCellValue.fromDateTime(account.createdAt),
      ]);
    }
  }

  void _writeCategories(Sheet sheet, List<Category> categories) {
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('name'),
      TextCellValue('type'),
      TextCellValue('color'),
      TextCellValue('icon'),
      TextCellValue('isSystem'),
      TextCellValue('createdAt'),
    ]);
    for (final category in categories) {
      sheet.appendRow([
        IntCellValue(category.id),
        TextCellValue(category.name),
        TextCellValue(category.type),
        IntCellValue(category.color),
        TextCellValue(category.icon),
        BoolCellValue(category.isSystem),
        DateTimeCellValue.fromDateTime(category.createdAt),
      ]);
    }
  }

  void _writeTransactions(Sheet sheet, List<Transaction> transactions) {
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('accountId'),
      TextCellValue('categoryId'),
      TextCellValue('type'),
      TextCellValue('amount'),
      TextCellValue('note'),
      TextCellValue('transactionDate'),
      TextCellValue('createdAt'),
      TextCellValue('updatedAt'),
    ]);
    for (final transaction in transactions) {
      sheet.appendRow([
        IntCellValue(transaction.id),
        IntCellValue(transaction.accountId),
        IntCellValue(transaction.categoryId),
        TextCellValue(transaction.type),
        DoubleCellValue(transaction.amount),
        TextCellValue(transaction.note ?? ''),
        DateTimeCellValue.fromDateTime(transaction.transactionDate),
        DateTimeCellValue.fromDateTime(transaction.createdAt),
        DateTimeCellValue.fromDateTime(transaction.updatedAt),
      ]);
    }
  }

  void _writeTransfers(Sheet sheet, List<Transfer> transfers) {
    sheet.appendRow([
      TextCellValue('id'),
      TextCellValue('fromAccountId'),
      TextCellValue('toAccountId'),
      TextCellValue('amount'),
      TextCellValue('note'),
      TextCellValue('transferDate'),
      TextCellValue('createdAt'),
    ]);
    for (final transfer in transfers) {
      sheet.appendRow([
        IntCellValue(transfer.id),
        IntCellValue(transfer.fromAccountId),
        IntCellValue(transfer.toAccountId),
        DoubleCellValue(transfer.amount),
        TextCellValue(transfer.note ?? ''),
        DateTimeCellValue.fromDateTime(transfer.transferDate),
        DateTimeCellValue.fromDateTime(transfer.createdAt),
      ]);
    }
  }

  String _dateStamp(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
