import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../models/transaction.dart';

class DatabaseService {
  DatabaseService._();
  static final DatabaseService instance = DatabaseService._();
  Database? _database;

  Future<Database> get database async => _database ??= await _open();

  Future<Database> _open() async {
    final String path = join(await getDatabasesPath(), 'paroisse_tresorerie.db');
    return openDatabase(path, version: 1, onCreate: (Database db, int version) async {
      await db.execute('''
        CREATE TABLE transactions(
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          type TEXT NOT NULL, amount INTEGER NOT NULL, date TEXT NOT NULL,
          category TEXT NOT NULL, description TEXT NOT NULL,
          party TEXT, reference TEXT, payment_method TEXT NOT NULL,
          is_anonymous INTEGER NOT NULL DEFAULT 0
        )
      ''');
    });
  }

  Future<List<CashTransaction>> allTransactions() async {
    final Database db = await database;
    final List<Map<String, Object?>> rows = await db.query('transactions', orderBy: 'date DESC, id DESC');
    return rows.map(CashTransaction.fromMap).toList();
  }

  Future<void> save(CashTransaction transaction) async {
    final Database db = await database;
    if (transaction.id == null) {
      await db.insert('transactions', transaction.toMap()..remove('id'));
    } else {
      await db.update('transactions', transaction.toMap()..remove('id'), where: 'id = ?', whereArgs: <Object>[transaction.id!]);
    }
  }

  Future<void> delete(int id) async {
    final Database db = await database;
    await db.delete('transactions', where: 'id = ?', whereArgs: <Object>[id]);
  }

  Future<String> databasePath() async => join(await getDatabasesPath(), 'paroisse_tresorerie.db');

  /// Ferme la base avant de la copier ou de la remplacer par une sauvegarde.
  Future<void> close() async {
    await _database?.close();
    _database = null;
  }
}
