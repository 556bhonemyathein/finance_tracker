import 'dart:io';

import 'package:finance_tracker/core/utils/result.dart';
import 'package:finance_tracker/features/reports/domain/report_exporter.dart';
import 'package:finance_tracker/shared/models/category.dart';
import 'package:finance_tracker/shared/models/enums.dart';
import 'package:finance_tracker/shared/models/transaction.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Fake `path_provider` so export can be tested without a device.
class _FakePathProvider extends PathProviderPlatform
    with MockPlatformInterfaceMixin {
  _FakePathProvider(this.directory);

  final String directory;

  @override
  Future<String?> getTemporaryPath() async => directory;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;

  final Map<String, Category> categories = <String, Category>{
    'cat-1': const Category(
      id: 'cat-1',
      name: 'Food & Drink',
      iconCodePoint: 0xe56c,
      colorValue: 0xFFF97316,
    ),
  };

  Transaction transaction({
    String note = 'Lunch',
    double amount = 12.5,
    TransactionType type = TransactionType.expense,
    List<String> tags = const <String>['work'],
  }) => Transaction(
    id: 'tx-1',
    type: type,
    amount: amount,
    date: DateTime(2026, 8, 5),
    categoryId: 'cat-1',
    note: note,
    tags: tags,
  );

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('pocketpilot-export-test');
    PathProviderPlatform.instance = _FakePathProvider(tempDir.path);
  });

  tearDown(() {
    if (tempDir.existsSync()) tempDir.deleteSync(recursive: true);
  });

  group('CSV export', () {
    test('writes a header and one row per transaction', () async {
      final Result<File> result = await const ReportExporter().toCsv(
        transactions: <Transaction>[transaction()],
        categories: categories,
        fileName: 'report',
      );

      final List<String> lines = result
          .getOrThrow()
          .readAsStringSync()
          .trim()
          .split('\n');

      expect(lines.first, startsWith('Date,Type,Category,Amount'));
      expect(lines, hasLength(2));
      expect(lines[1], contains('2026-08-05'));
      expect(lines[1], contains('Food & Drink'));
      expect(lines[1], contains('12.50'));
    });

    test('quotes fields containing a comma', () async {
      final Result<File> result = await const ReportExporter().toCsv(
        transactions: <Transaction>[transaction(note: 'Lunch, then coffee')],
        categories: categories,
        fileName: 'report',
      );

      final String csv = result.getOrThrow().readAsStringSync();
      expect(csv, contains('"Lunch, then coffee"'));
    });

    test('escapes embedded quotes by doubling them', () async {
      final Result<File> result = await const ReportExporter().toCsv(
        transactions: <Transaction>[transaction(note: 'The "usual"')],
        categories: categories,
        fileName: 'report',
      );

      final String csv = result.getOrThrow().readAsStringSync();
      // RFC 4180: a quote inside a quoted field is written twice.
      expect(csv, contains('"The ""usual"""'));
    });

    test('falls back to Uncategorised for a dangling category', () async {
      final Result<File> result = await const ReportExporter().toCsv(
        transactions: <Transaction>[transaction()],
        categories: const <String, Category>{},
        fileName: 'report',
      );

      expect(result.getOrThrow().readAsStringSync(), contains('Uncategorised'));
    });

    test('joins tags with a semicolon so they survive the comma delimiter', () async {
      final Result<File> result = await const ReportExporter().toCsv(
        transactions: <Transaction>[
          transaction(tags: const <String>['work', 'client']),
        ],
        categories: categories,
        fileName: 'report',
      );

      expect(result.getOrThrow().readAsStringSync(), contains('work; client'));
    });
  });

  group('PDF export', () {
    test('produces a non-empty PDF file', () async {
      final Result<File> result = await const ReportExporter().toPdf(
        transactions: <Transaction>[
          transaction(),
          transaction(type: TransactionType.income, amount: 1000),
        ],
        categories: categories,
        title: 'PocketPilot report',
        subtitle: 'August 2026',
        currencyCode: 'USD',
        fileName: 'report',
      );

      final File file = result.getOrThrow();
      expect(file.existsSync(), isTrue);

      final Uint8List bytes = file.readAsBytesSync();
      expect(bytes.length, greaterThan(1000));
      // Every PDF begins with the %PDF- magic number.
      expect(String.fromCharCodes(bytes.take(5)), '%PDF-');
    });
  });
}
