import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../errors/app_exception.dart';
import '../utils/app_logger.dart';
import 'entities/category_entity.dart';
import 'entities/transaction_entity.dart';
import 'entities/user_entity.dart';

/// Owns the single Isar instance for the process.
///
/// Isar is expensive to open and must not be opened twice, so the instance is
/// created once during boot and then handed to repositories through Riverpod.
/// Nothing else in the app calls `Isar.open`.
class IsarService {
  IsarService._(this.isar);

  final Isar isar;

  /// Opens (or reuses) the database. Called once from `main()` before
  /// `runApp`, so every repository can assume a ready database.
  static Future<IsarService> open({String name = 'pocketpilot'}) async {
    try {
      final Isar? existing = Isar.getInstance(name);
      if (existing != null) return IsarService._(existing);

      final directory = await getApplicationDocumentsDirectory();
      final Isar isar = await Isar.open(
        <CollectionSchema<dynamic>>[
          TransactionEntitySchema,
          CategoryEntitySchema,
          UserEntitySchema,
        ],
        directory: directory.path,
        name: name,
        inspector: false,
      );
      AppLogger.i('Isar opened at ${directory.path}');
      return IsarService._(isar);
    } catch (error, stackTrace) {
      AppLogger.e('Failed to open Isar', error, stackTrace);
      throw CacheException('Could not open the local database', cause: error);
    }
  }

  /// In-memory-ish instance for tests: a real Isar in a temp directory.
  static Future<IsarService> openForTest(String directory) async {
    final Isar isar = await Isar.open(
      <CollectionSchema<dynamic>>[
        TransactionEntitySchema,
        CategoryEntitySchema,
        UserEntitySchema,
      ],
      directory: directory,
      name: 'test-${DateTime.now().microsecondsSinceEpoch}',
      inspector: false,
    );
    return IsarService._(isar);
  }

  IsarCollection<TransactionEntity> get transactions => isar.transactionEntitys;

  IsarCollection<CategoryEntity> get categories => isar.categoryEntitys;

  IsarCollection<UserEntity> get users => isar.userEntitys;

  /// Wipes every collection — backs "Delete account" and "Restore backup".
  Future<void> clear() => isar.writeTxn(isar.clear);

  Future<void> close() => isar.close();
}
