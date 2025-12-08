import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/location.dart';
import '../models/person.dart';
import '../models/transaction.dart' as app_transaction;
import '../models/product.dart';
import '../models/stock_history.dart';
import '../models/operation.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('borc_defteri.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 3, // Foreign key support için versiyon artırıldı
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
      onConfigure: (db) async {
        // FOREIGN KEY constraints'leri aktif et (SQLite'ta varsayılan KAPALI!)
        await db.execute('PRAGMA foreign_keys = ON');
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Mekanlar tablosu
    await db.execute('''
      CREATE TABLE locations (
        id $idType,
        name $textType,
        created_at $textType
      )
    ''');

    // Kişiler tablosu
    await db.execute('''
      CREATE TABLE persons (
        id $idType,
        location_id $intType,
        name $textType,
        created_at $textType,
        FOREIGN KEY (location_id) REFERENCES locations (id) ON DELETE CASCADE
      )
    ''');

    // İşlemler tablosu
    await db.execute('''
      CREATE TABLE transactions (
        id $idType,
        person_id $intType,
        type $textType,
        amount $realType,
        description $textType,
        created_at $textType,
        FOREIGN KEY (person_id) REFERENCES persons (id) ON DELETE CASCADE
      )
    ''');

    // Ürünler tablosu
    await db.execute('''
      CREATE TABLE products (
        id $idType,
        name $textType,
        image_path $textType,
        quantity $intType,
        created_at $textType
      )
    ''');

    // Stok geçmişi tablosu
    await db.execute('''
      CREATE TABLE stock_histories (
        id $idType,
        product_id $intType,
        change_amount $intType,
        description $textType,
        created_at $textType,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE CASCADE
      )
    ''');

    // Veteriner işlemler tablosu
    await db.execute('''
      CREATE TABLE operations (
        id $idType,
        person_id $intType,
        operation_type $textType,
        description $textType,
        operation_date $textType,
        created_at $textType,
        FOREIGN KEY (person_id) REFERENCES persons (id) ON DELETE CASCADE
      )
    ''');
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Version 2: Operations tablosu ekleniyor
      const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
      const textType = 'TEXT NOT NULL';
      const intType = 'INTEGER NOT NULL';
      
      await db.execute('''
        CREATE TABLE operations (
          id $idType,
          person_id $intType,
          operation_type $textType,
          description $textType,
          operation_date $textType,
          created_at $textType,
          FOREIGN KEY (person_id) REFERENCES persons (id) ON DELETE CASCADE
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Version 3: Foreign key constraint fix
      // Tüm tabloları yeniden oluştur (foreign keys düzgün çalışsın diye)
      // Not: Bu upgrade eski verileri SİLECEK
      await db.execute('DROP TABLE IF EXISTS operations');
      await db.execute('DROP TABLE IF EXISTS transactions');
      await db.execute('DROP TABLE IF EXISTS stock_histories');
      await db.execute('DROP TABLE IF EXISTS persons');
      await db.execute('DROP TABLE IF EXISTS products');
      await db.execute('DROP TABLE IF EXISTS locations');
      
      // Tabloları yeniden oluştur
      await _createDB(db, 3);
    }
  }

  // ========== LOCATION İŞLEMLERİ ==========
  
  Future<int> insertLocation(Location location) async {
    final db = await database;
    return await db.insert('locations', location.toMap());
  }

  Future<List<Location>> getAllLocations() async {
    final db = await database;
    final result = await db.query('locations', orderBy: 'created_at DESC');
    return result.map((map) => Location.fromMap(map)).toList();
  }

  Future<int> deleteLocation(int id) async {
    final db = await database;
    return await db.delete('locations', where: 'id = ?', whereArgs: [id]);
  }

  // ========== PERSON İŞLEMLERİ ==========
  
  Future<int> insertPerson(Person person) async {
    final db = await database;
    return await db.insert('persons', person.toMap());
  }

  Future<List<Person>> getPersonsByLocation(int locationId) async {
    final db = await database;
    final result = await db.query(
      'persons',
      where: 'location_id = ?',
      whereArgs: [locationId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => Person.fromMap(map)).toList();
  }

  Future<int> deletePerson(int id) async {
    final db = await database;
    return await db.delete('persons', where: 'id = ?', whereArgs: [id]);
  }

  // ========== TRANSACTION İŞLEMLERİ ==========
  
  Future<int> insertTransaction(app_transaction.Transaction transaction) async {
    final db = await database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<app_transaction.Transaction>> getTransactionsByPerson(int personId) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'person_id = ?',
      whereArgs: [personId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => app_transaction.Transaction.fromMap(map)).toList();
  }

  Future<double> getTotalDebt(int personId) async {
    final transactions = await getTransactionsByPerson(personId);
    double total = 0;
    for (var t in transactions) {
      if (t.isDebt()) {
        total += t.amount;
      } else {
        total -= t.amount;
      }
    }
    return total;
  }

  Future<int> deleteTransaction(int id) async {
    final db = await database;
    return await db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<app_transaction.Transaction>> getTransactionsByPersonAndDateRange(
    int personId,
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'transactions',
      where: 'person_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [personId, startDate, endDate],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => app_transaction.Transaction.fromMap(map)).toList();
  }

  // ========== PRODUCT İŞLEMLERİ ==========
  
  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;
    final result = await db.query('products', orderBy: 'created_at DESC');
    return result.map((map) => Product.fromMap(map)).toList();
  }

  Future<Product?> getProduct(int id) async {
    final db = await database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);
    if (result.isEmpty) return null;
    return Product.fromMap(result.first);
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;
    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;
    return await db.delete('products', where: 'id = ?', whereArgs: [id]);
  }

  // ========== STOCK HISTORY İŞLEMLERİ ==========
  
  Future<int> insertStockHistory(StockHistory history) async {
    final db = await database;
    return await db.insert('stock_histories', history.toMap());
  }

  Future<List<StockHistory>> getStockHistoryByProduct(int productId) async {
    final db = await database;
    final result = await db.query(
      'stock_histories',
      where: 'product_id = ?',
      whereArgs: [productId],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => StockHistory.fromMap(map)).toList();
  }

  Future<List<StockHistory>> getStockHistoryByProductAndDateRange(
    int productId,
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'stock_histories',
      where: 'product_id = ? AND created_at >= ? AND created_at <= ?',
      whereArgs: [productId, startDate, endDate],
      orderBy: 'created_at DESC',
    );
    return result.map((map) => StockHistory.fromMap(map)).toList();
  }

  // ========== OPERATION İŞLEMLERİ ==========
  
  Future<int> insertOperation(Operation operation) async {
    final db = await database;
    return await db.insert('operations', operation.toMap());
  }

  Future<List<Operation>> getOperationsByPerson(int personId) async {
    final db = await database;
    final result = await db.query(
      'operations',
      where: 'person_id = ?',
      whereArgs: [personId],
      orderBy: 'operation_date DESC',
    );
    return result.map((map) => Operation.fromMap(map)).toList();
  }

  Future<List<Operation>> getOperationsByPersonAndDateRange(
    int personId,
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final result = await db.query(
      'operations',
      where: 'person_id = ? AND operation_date >= ? AND operation_date <= ?',
      whereArgs: [personId, startDate, endDate],
      orderBy: 'operation_date DESC',
    );
    return result.map((map) => Operation.fromMap(map)).toList();
  }

  Future<int> deleteOperation(int id) async {
    final db = await database;
    return await db.delete('operations', where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}
