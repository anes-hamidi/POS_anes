import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';

part 'database.g.dart';

// Initialize logger
final _logger = Logger('AppDatabase');

// --- Data Classes for Joins ---
class SaleItemWithProduct {
  final SaleItem saleItem;
  final Product product;

  SaleItemWithProduct({required this.saleItem, required this.product});
}

class SaleWithItemsAndCustomer {
  final Sale sale;
  final Customer? customer;
  final List<SaleItemWithProduct> items;

  SaleWithItemsAndCustomer({
    required this.sale,
    this.customer,
    required this.items,
  });
}

// Define tables
@DataClassName('Product')
class Products extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get description => text().nullable()();
  RealColumn get price => real()();
  TextColumn get imageUrl => text().nullable().named('imageUrl')();
  TextColumn get barcode => text().nullable()();
  TextColumn get category => text().nullable()();
  RealColumn get cost => real()();
  IntColumn get quantity => integer()();
  RealColumn get rankingScore => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Customer')
class Customers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();
  TextColumn get address => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Supplier')
class Suppliers extends Table {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 255)();
  TextColumn get contactPerson => text().nullable()();
  TextColumn get email => text().nullable()();
  TextColumn get phone => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Sale')
class Sales extends Table {
  TextColumn get id => text()();
  TextColumn get customerId => text().nullable().references(Customers, #id)();
  DateTimeColumn get saleDate => dateTime()();
  RealColumn get totalAmount => real()();
  RealColumn get subtotal => real()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SaleItem')
class SaleItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get saleId => text().references(Sales, #id)();
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();
  RealColumn get priceAtSale => real()();
}

@DataClassName('CartItemData')
class CartItems extends Table {
  TextColumn get productId => text().references(Products, #id)();
  IntColumn get quantity => integer()();

  @override
  Set<Column> get primaryKey => {productId};
}

@DriftDatabase(tables: [Products, Customers, Suppliers, Sales, SaleItems, CartItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;
    @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from == 1) {
        await m.createTable(cartItems);
        await m.addColumn(sales, sales.customerId);
      }
    },
    beforeOpen: (details) async {
      // Validate database integrity before opening
      await customStatement('PRAGMA foreign_keys = ON');
      if (details.wasCreated) {
        _logger.info('Database created successfully');
      } 
      // Perform manual integrity check before opening
      final integrityOk = await manuallyCheckDatabaseIntegrity();
      if (!integrityOk) {
        _logger.severe('Database integrity check failed on open!');
        // Handle the failure appropriately, e.g., by showing an error message to the user
        // or attempting to repair the database.
      }
    },
  );

Future<List<Map<String, dynamic>>> getRankedProducts() async {
  try {
    // Step 1: Get most sold products
    final mostSold = await getMostSoldProducts();

    // Step 2: Get highest profit products
    final highestProfit = await getHighestProfitProducts();

    // Step 3: Combine both rankings (most sold + highest profit)
    final combinedRanking = <Map<String, dynamic>>[];

    for (var soldProduct in mostSold) {
      final productId = soldProduct['productId'];
      final soldQuantity = soldProduct['totalQuantitySold'];

      // Step 4: Find the corresponding profit data for this product
      final profitData = highestProfit.firstWhere(
        (p) => p['productId'] == productId,
        orElse: () => {'totalProfit': 0.0},  // Default to 0 profit if not found
      );

      final totalProfit = profitData['totalProfit'];

      // Step 5: Calculate a ranking score (adjust weights as necessary)
      final rankingScore = (0.5 * soldQuantity) + (0.5 * totalProfit);

      // Step 6: Add to combined ranking list
      combinedRanking.add({
        'productId': productId,
        'totalQuantitySold': soldQuantity,
        'totalProfit': totalProfit,
        'rankingScore': rankingScore,
      });
    }

    // Step 7: Sort products by ranking score (descending order)
    combinedRanking.sort((a, b) => b['rankingScore'].compareTo(a['rankingScore']));

    return combinedRanking;
  } catch (e, stackTrace) {
    _logger.severe('Error ranking products', e, stackTrace);
    return [];
  }
}

  // Get most sold products by quantity
Future<List<Map<String, dynamic>>> getMostSoldProducts() async {
  try {
    // Using raw SQL query to group by productId and sum quantity
    final results = await customSelect(
      'SELECT productId, SUM(quantity) AS totalQuantitySold FROM sale_items GROUP BY productId ORDER BY totalQuantitySold DESC',
      readsFrom: {saleItems},  // Declare the tables we're reading from
    ).get();

    // Map the results to the correct format
    return results.map((row) {
      return {
        'productId': row.read<String>('productId'),
        'totalQuantitySold': row.read<int>('totalQuantitySold'),
      };
    }).toList();
  } catch (e, stackTrace) {
    _logger.severe('Error getting most sold products', e, stackTrace);
    return [];
  }
}

  // Get highest profit products based on price and cost
Future<List<Map<String, dynamic>>> getHighestProfitProducts() async {
  try {
    final results = await customSelect(
      '''SELECT si.productId, 
                SUM((si.priceAtSale - p.cost) * si.quantity) AS totalProfit 
         FROM sale_items si
         INNER JOIN products p ON p.id = si.productId
         GROUP BY si.productId
         ORDER BY totalProfit DESC''',
      readsFrom: {saleItems, products},  // Declare the tables we're reading from
    ).get();

    return results.map((row) {
      return {
        'productId': row.read<String>('productId'),
        'totalProfit': row.read<double>('totalProfit'),
      };
    }).toList();
  } catch (e, stackTrace) {
    _logger.severe('Error getting highest profit products', e, stackTrace);
    return [];
  }
}

Future<List<Product>> getProductsByIds(List<String> ids) async {
  if (ids.isEmpty) return [];
  return (select(products)..where((p) => p.id.isIn(ids))).get();
}
  // Methods for Products
 Stream<List<Product>> watchAllProducts(String searchQuery, [String? category]) {
  try {
    final query = select(products);

    // ✅ Dynamic WHERE clauses
    final List<Expression<bool>> filters = [];

    // 🔎 Search filter (name OR barcode)
    if (searchQuery.isNotEmpty) {
      filters.add(
        products.name.like('%$searchQuery%') |
        products.barcode.equals(searchQuery),
      );
    }

    // 🏷 Category filter (optional)
    if (category != null && category.isNotEmpty) {
      filters.add(products.category.equals(category));
    }

    // ✅ Apply all filters safely
    if (filters.isNotEmpty) {
      query.where((tbl) => filters.reduce((a, b) => a & b));
    }

    // 🔄 Sort by name or something meaningful
    query.orderBy([
      (p) => OrderingTerm.asc(p.name),
    ]);

    return query.watch();
  } catch (e, stackTrace) {
    _logger.severe('Error in watchAllProducts', e, stackTrace);
    return Stream.value([]); // Prevents crashes
  }
}

  // add getAllProducts
  Future<List<Product>> getAllProducts() async {
    try {
      return await select(products).get();
    } catch (e, stackTrace) {
      _logger.severe('Error fetching all products', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  Future<void> addProduct(ProductsCompanion product) async {
    try {
      await into(products).insert(product);
    } catch (e, stackTrace) {
      _logger.severe('Error adding product', e, stackTrace);
      rethrow; // Re-throw to let UI handle the error
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      // First check if product exists in any sales
      final saleItemsWithProduct = await (select(saleItems)..where((s) => s.productId.equals(id))).get();
      
      if (saleItemsWithProduct.isNotEmpty) {
        // Product is referenced in sales, don't delete but mark as unavailable
        await (update(products)..where((p) => p.id.equals(id)))
            .write(const ProductsCompanion(quantity: Value(0)));
        _logger.info('Product $id is referenced in sales, quantity set to 0 instead of deletion');
      } else {
        // Safe to delete
        await (delete(products)..where((p) => p.id.equals(id))).go();
      }
    } catch (e, stackTrace) {
      _logger.severe('Error deleting product', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateProduct(ProductsCompanion product) async {
    try {
      await update(products).replace(product);
    } catch (e, stackTrace) {
      _logger.severe('Error updating product', e, stackTrace);
      rethrow;
    }
  }
  // invoice count
  
  // getSalesWithDetailsByCustomer
  Future<List<SaleWithItemsAndCustomer>> getSalesWithDetailsByCustomer(String customerId) async {
    try {
      final salesList = await (select(sales)..where((s) => s.customerId.equals(customerId))).get();
      return Future.wait(salesList.map((sale) => getSaleWithDetails(sale.id)));
    } catch (e, stackTrace) {
      _logger.severe('Error fetching sales for customer $customerId', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  // Methods for Sales
  Stream<List<SaleWithItemsAndCustomer>> watchAllSalesWithDetails() {
    try {
      final salesStream = (select(sales)..orderBy([(s) => OrderingTerm(expression: s.saleDate, mode: OrderingMode.desc)])).watch();

      return salesStream.asyncMap((salesList) {
        return Future.wait(salesList.map((sale) => getSaleWithDetails(sale.id)));
      }).handleError((error, stackTrace) {
        _logger.severe('Error in watchAllSalesWithDetails', error, stackTrace);
        return <SaleWithItemsAndCustomer>[]; // Return empty list on error
      });
    } catch (e, stackTrace) {
      _logger.severe('Error setting up sales stream', e, stackTrace);
      return Stream.value([]);
    }
  }
  // Add getAllSalesWithDetails
  Future<List<SaleWithItemsAndCustomer>> getAllSalesWithDetails() async {
    try {
      final allSales = await select(sales).get();
      return Future.wait(allSales.map((sale) => getSaleWithDetails(sale.id)));
    } catch (e, stackTrace) {
      _logger.severe('Error fetching all sales with details', e, stackTrace);
      return []; // Return empty list on error
    }
  }

  Future<SaleWithItemsAndCustomer> getSaleWithDetails(String saleId) async {
    try {
      final sale = await (select(sales)..where((s) => s.id.equals(saleId))).getSingle();
      
      final customer = sale.customerId == null
          ? null
          : await (select(customers)..where((c) => c.id.equals(sale.customerId!))).getSingleOrNull();

      final itemsQuery = select(saleItems).join([
        innerJoin(products, products.id.equalsExp(saleItems.productId)),
      ])
        ..where(saleItems.saleId.equals(saleId));

      final itemRows = await itemsQuery.get();
      final items = itemRows.map((row) {
        return SaleItemWithProduct(
          saleItem: row.readTable(saleItems),
          product: row.readTable(products),
        );
      }).toList();

      return SaleWithItemsAndCustomer(
        sale: sale,
        customer: customer,
        items: items,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error getting sale details for $saleId', e, stackTrace);
      rethrow;
    }
  }

  // Methods for Customers
  Stream<List<Customer>> watchAllCustomers() {
    try {
      return select(customers).watch();
    } catch (e, stackTrace) {
      _logger.severe('Error watching customers', e, stackTrace);
      return Stream.value([]);
    }
  }

  Future<void> addCustomer(CustomersCompanion customer) async {
    try {
      await into(customers).insert(customer);
    } catch (e, stackTrace) {
      _logger.severe('Error adding customer', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCustomer(CustomersCompanion customer) async {
    try {
      await update(customers).replace(customer);
    } catch (e, stackTrace) {
      _logger.severe('Error updating customer', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteCustomer(String id) async {
    try {
      // Check if customer has any sales before deleting
      final customerSales = await (select(sales)..where((s) => s.customerId.equals(id))).get();
      
      if (customerSales.isNotEmpty) {
        throw Exception('Cannot delete customer with existing sales. Consider archiving instead.');
      }
      
      await (delete(customers)..where((c) => c.id.equals(id))).go();
    } catch (e, stackTrace) {
      _logger.severe('Error deleting customer', e, stackTrace);
      rethrow;
    }
  }

  // Methods for cart
  Stream<List<CartItem>> get allCartItemsStream {
    try {
      return select(cartItems).join([
        innerJoin(products, products.id.equalsExp(cartItems.productId))
      ]).watch().map((rows) {
        return rows.map((row) {
          return CartItem(
              product: row.readTable(products),
              quantity: row.readTable(cartItems).quantity);
        }).toList();
      }).handleError((error, stackTrace) {
        _logger.severe('Error in cart items stream', error, stackTrace);
        return <CartItem>[];
      });
    } catch (e, stackTrace) {
      _logger.severe('Error setting up cart stream', e, stackTrace);
      return Stream.value([]);
    }
  }

  Future<void> clearCart() async {
    try {
      await delete(cartItems).go();
    } catch (e, stackTrace) {
      _logger.severe('Error clearing cart', e, stackTrace);
      rethrow;
    }
  }

  Future<void> addToCart(String productId, int quantity) async {
    try {
      await into(cartItems).insert(
          CartItemsCompanion.insert(productId: productId, quantity: quantity),
          mode: InsertMode.insertOrReplace,
      );
    } catch (e, stackTrace) {
      _logger.severe('Error adding to cart', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateCartItemQuantity(String productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeCartItem(productId);
      } else {
        await (update(cartItems)..where((c) => c.productId.equals(productId)))
            .write(CartItemsCompanion(quantity: Value(quantity)));
      }
    } catch (e, stackTrace) {
      _logger.severe('Error updating cart item quantity', e, stackTrace);
      rethrow;
    }
  }

  Future<void> removeCartItem(String productId) async {
    try {
      await (delete(cartItems)..where((c) => c.productId.equals(productId))).go();
    } catch (e, stackTrace) {
      _logger.severe('Error removing cart item', e, stackTrace);
      rethrow;
    }
  }

  // Database maintenance methods
  Future<void> backupDatabase(String backupPath) async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final originalFile = File(p.join(dbFolder.path, 'db.sqlite'));
      final backupFile = File(backupPath);
      
      if (await originalFile.exists()) {
        await originalFile.copy(backupFile.path);
        _logger.info('Database backup created at $backupPath');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error backing up database', e, stackTrace);
      rethrow;
    }
  }

  Future<void> compactDatabase() async {
    try {
      await customStatement('VACUUM');
      _logger.info('Database compaction completed');
    } catch (e, stackTrace) {
      _logger.severe('Error compacting database', e, stackTrace);
    }
  }

  // Add a method to check database integrity
  Future<bool> checkDatabaseIntegrity() async {
    try {
      await customStatement('PRAGMA integrity_check');
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error checking database integrity', e, stackTrace);
      return false;
    }
  }

  // Add a method to manually check database integrity
  Future<bool> manuallyCheckDatabaseIntegrity() async {
    try {
      await customStatement('PRAGMA integrity_check');
      _logger.info('Manual database integrity check passed.');
      return true;
    } catch (e, stackTrace) {
      _logger.severe('Error checking database integrity', e, stackTrace);
      return false;
    }
  }
}

class CartItem {
  final Product product;
  int quantity;

  CartItem({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    try {
      final dbFolder = await getApplicationDocumentsDirectory();
      final file = File(p.join(dbFolder.path, 'db.sqlite'));
      
      // Create directory if it doesn't exist
      if (!await dbFolder.exists()) {
        await dbFolder.create(recursive: true);
      }
      
      return NativeDatabase(
        file, 
        logStatements: true, // Only in debug mode
      );
    } catch (e, stackTrace) {
      _logger.severe('Error opening database connection', e, stackTrace);
      rethrow;
    }
  });
}