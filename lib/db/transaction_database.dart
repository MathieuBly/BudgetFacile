import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart'; // Import normal (sans alias)
import '../models/transaction.dart' as txn_model;

class TransactionDatabase {
  static final TransactionDatabase instance = TransactionDatabase._init();
  static Database? _database;

  TransactionDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('transactions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        date TEXT NOT NULL,
        category TEXT NOT NULL,
        isIncome INTEGER NOT NULL
      )
    ''');
  }

  Future<void> insertTransaction(txn_model.Transaction txn) async {
    final db = await instance.database;
    await db.insert('transactions', txn.toMap());
  }

  Future<List<txn_model.Transaction>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((map) => txn_model.Transaction.fromMap(map)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
  Future<void> deleteAllTransactions() async {
    final db = await instance.database;
    await db.delete('transactions');
  }
}
