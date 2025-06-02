import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../models/product.dart';
import '../models/order.dart';
import '../models/cart_item.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'al_waseet_pos.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        category TEXT NOT NULL,
        isAvailable INTEGER NOT NULL
      )
    ''');

    // Orders table
    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        dateTime TEXT NOT NULL,
        totalAmount REAL NOT NULL,
        orderType TEXT NOT NULL,
        customerName TEXT,
        customerPhone TEXT,
        customerAddress TEXT,
        paymentMethod TEXT NOT NULL
      )
    ''');

    // Order items table
    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        orderId INTEGER NOT NULL,
        productId INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        notes TEXT,
        FOREIGN KEY (orderId) REFERENCES orders (id) ON DELETE CASCADE,
        FOREIGN KEY (productId) REFERENCES products (id) ON DELETE RESTRICT
      )
    ''');

    // Insert some default products
    await _insertDefaultProducts(db);
  }

  Future<void> _insertDefaultProducts(Database db) async {
    List<Product> defaultProducts = [
      Product(id: 1, name: 'برجر لحم', price: 25.0, category: 'برجر'),
      Product(id: 2, name: 'برجر دجاج', price: 20.0, category: 'برجر'),
      Product(id: 3, name: 'بطاطس', price: 10.0, category: 'جانبي'),
      Product(id: 4, name: 'كولا', price: 5.0, category: 'مشروبات'),
      Product(id: 5, name: 'شاورما لحم', price: 22.0, category: 'شاورما'),
      Product(id: 6, name: 'شاورما دجاج', price: 18.0, category: 'شاورما'),
    ];

    for (var product in defaultProducts) {
      await db.insert('products', product.toMap());
    }
  }

  // Product operations
  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<Product>> getProductsByCategory(String category) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
    );
    return List.generate(maps.length, (i) => Product.fromMap(maps[i]));
  }

  Future<List<String>> getCategories() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      'SELECT DISTINCT category FROM products ORDER BY category',
    );
    return List.generate(maps.length, (i) => maps[i]['category'] as String);
  }

  Future<int> insertProduct(Product product) async {
    final db = await database;
    return await db.insert('products', product.toMap());
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
    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Order operations
  Future<int> insertOrder(Order order, List<CartItem> items) async {
    final db = await database;
    int orderId = 0;

    await db.transaction((txn) async {
      orderId = await txn.insert('orders', order.toMap());

      for (var item in items) {
        await txn.insert('order_items', {
          'orderId': orderId,
          'productId': item.product.id,
          'quantity': item.quantity,
          'notes': item.notes.join(', '),
        });
      }
    });

    return orderId;
  }

  Future<List<Order>> getOrders() async {
    final db = await database;
    final List<Map<String, dynamic>> orderMaps = await db.query('orders', orderBy: 'dateTime DESC');
    
    List<Order> orders = [];
    
    for (var orderMap in orderMaps) {
      int orderId = orderMap['id'];
      
      final List<Map<String, dynamic>> itemMaps = await db.query(
        'order_items',
        where: 'orderId = ?',
        whereArgs: [orderId],
      );
      
      List<CartItem> items = [];
      
      for (var itemMap in itemMaps) {
        final productMap = await db.query(
          'products',
          where: 'id = ?',
          whereArgs: [itemMap['productId']],
        );
        
        if (productMap.isNotEmpty) {
          Product product = Product.fromMap(productMap.first);
          List<String> notes = [];
          
          if (itemMap['notes'] != null && itemMap['notes'].toString().isNotEmpty) {
            notes = itemMap['notes'].toString().split(', ');
          }
          
          items.add(CartItem(
            product: product,
            quantity: itemMap['quantity'],
            notes: notes,
          ));
        }
      }
      
      orders.add(Order.fromMap(orderMap, items));
    }
    
    return orders;
  }

  Future<Order?> getOrderById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> orderMaps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (orderMaps.isEmpty) return null;
    
    final List<Map<String, dynamic>> itemMaps = await db.query(
      'order_items',
      where: 'orderId = ?',
      whereArgs: [id],
    );
    
    List<CartItem> items = [];
    
    for (var itemMap in itemMaps) {
      final productMap = await db.query(
        'products',
        where: 'id = ?',
        whereArgs: [itemMap['productId']],
      );
      
      if (productMap.isNotEmpty) {
        Product product = Product.fromMap(productMap.first);
        List<String> notes = [];
        
        if (itemMap['notes'] != null && itemMap['notes'].toString().isNotEmpty) {
          notes = itemMap['notes'].toString().split(', ');
        }
        
        items.add(CartItem(
          product: product,
          quantity: itemMap['quantity'],
          notes: notes,
        ));
      }
    }
    
    return Order.fromMap(orderMaps.first, items);
  }
}