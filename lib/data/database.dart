import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:myapp/models/CartItem.dart';
import 'package:myapp/models/CustomerWithSalesAndPayments.dart';
import 'package:myapp/models/SaleWithPayments.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:logging/logging.dart';
import 'package:csv/csv.dart';
import 'package:archive/archive.dart';

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

  /// ✅ Soft delete instead of hard delete
  BoolColumn get isDeleted =>
      boolean().withDefault(const Constant(false))();

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
  TextColumn get saleId =>
    text().nullable().references(Sales, #id, onDelete: KeyAction.cascade)();

    TextColumn get status => text().withDefault(const Constant('pending'))(); 



  // no direct payment columns, handled via Payments

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

@DataClassName('Payment')
class Payments extends Table {
  IntColumn get id => integer().autoIncrement()();

  TextColumn get saleId => text().references(Sales, #id, onDelete: KeyAction.cascade)();

  RealColumn get amount => real()(); // positive = payment, negative = refund

  DateTimeColumn get paymentDate => dateTime().withDefault(currentDateAndTime)();

  TextColumn get method => text().withLength(min: 1, max: 50)(); 
  // e.g. "cash", "card", "bank", "wallet"

  TextColumn get status => text().withDefault(const Constant('pending'))(); 
  // values: "pending", "complete", "partial", "failed", "refunded"

  IntColumn get parentPaymentId => integer().nullable().references(Payments, #id)(); 
  // for refunds or adjustments

  TextColumn get reference => text().nullable()(); 
  // external txn id (bank ref, pos slip, etc.)
}

@DriftDatabase(
  tables: [
    Products,
    Customers,
    Suppliers,
    Sales,
    SaleItems,
    CartItems,
    Payments,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(cartItems);
            await m.addColumn(sales, sales.customerId);
          }
          if (from < 3) {
            await m.createTable(payments);
            await m.addColumn(products, products.isDeleted);
            await customStatement(
                'UPDATE products SET is_deleted = 0 WHERE is_deleted IS NULL;');
          }
          if (from < 4) {
          await m.addColumn(payments, payments.parentPaymentId);


          }
          if (from < 5) {
            await m.addColumn(payments, payments.reference);
          }
          if (from < 6) {
            await m.addColumn(sales, sales.saleId);
            await m.addColumn(sales, sales.status);
          }
        },

        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
          if (details.wasCreated) {
            _logger.info('Database created successfully');
          }
          final integrityOk = await manuallyCheckDatabaseIntegrity();
          if (!integrityOk) {
            _logger.severe('Database integrity check failed on open!');
          }
        },
      );

  // ✅ Ranked products
  Future<List<Product>> getRankedProducts() async {
    try {
      final query = select(products)
        ..where((p) =>
            p.rankingScore.isNotNull() &
            p.rankingScore.isBiggerThanValue(0) &
            p.isDeleted.equals(false))
        ..orderBy([
          (p) => OrderingTerm(
              expression: p.rankingScore, mode: OrderingMode.desc),
        ]);
      return query.get();
    } catch (e, stackTrace) {
      _logger.severe('Error ranking products', e, stackTrace);
      return [];
    }
  }

  // ✅ Filter by IDs
  Future<List<Product>> getProductsByIds(List<String> ids) async {
    if (ids.isEmpty) return [];
    return (select(products)
          ..where((p) => p.id.isIn(ids) & p.isDeleted.equals(false)))
        .get();
  }

  // ✅ Watch all products with filters
  Stream<List<Product>> watchAllProducts(String searchQuery,
      [String? category]) {
    try {
      final query = select(products)
        ..where((p) => p.isDeleted.equals(false));

      final filters = <Expression<bool>>[];

      if (searchQuery.isNotEmpty) {
        filters.add(products.name.like('%$searchQuery%') |
            products.barcode.equals(searchQuery));
      }
      if (category != null && category.isNotEmpty) {
        filters.add(products.category.equals(category));
      }

      if (filters.isNotEmpty) {
        query.where((tbl) => filters.reduce((a, b) => a & b));
      }

      query.orderBy([(p) => OrderingTerm.asc(p.name)]);
      return query.watch();
    } catch (e, stackTrace) {
      _logger.severe('Error in watchAllProducts', e, stackTrace);
      return Stream.value([]);
    }
  }

  // ✅ All products (non-deleted)
  Future<List<Product>> getAllProducts() async {
    try {
      return await (select(products)
            ..where((p) => p.isDeleted.equals(false)))
          .get();
    } catch (e, stackTrace) {
      _logger.severe('Error fetching all products', e, stackTrace);
      return [];
    }
  }

  // ✅ Add product
  Future<void> addProduct(ProductsCompanion product) async {
    try {
      await into(products).insert(product);
    } catch (e, stackTrace) {
      _logger.severe('Error adding product', e, stackTrace);
      rethrow;
    }
  }

  // ✅ Soft-delete logic
  Future<void> deleteProduct(String id) async {
    try {
      // Check if product is referenced
      final saleItemsWithProduct =
          await (select(saleItems)..where((s) => s.productId.equals(id))).get();

      if (saleItemsWithProduct.isNotEmpty) {
        // Mark as deleted instead of removing
        await (update(products)..where((p) => p.id.equals(id))).write(
          const ProductsCompanion(
            isDeleted: Value(true),
            quantity: Value(0),
          ),
        );
        _logger.info(
            'Product $id marked as deleted (referenced in sales items)');
      } else {
        // Safe to delete physically if not referenced
        await (delete(products)..where((p) => p.id.equals(id))).go();
      }
    } catch (e, stackTrace) {
      _logger.severe('Error deleting product', e, stackTrace);
      rethrow;
    }
  }

  // ✅ Update product
  Future<void> updateProduct(ProductsCompanion product) async {
    try {
      await update(products).replace(product);
    } catch (e, stackTrace) {
      _logger.severe('Error updating product', e, stackTrace);
      rethrow;
    }
  }


  // getSalesWithDetailsByCustomer
  Future<List<SaleWithItemsAndCustomer>> getSalesWithDetailsByCustomer(
    String customerId,
  ) async {
    try {
      final salesList = await (select(
        sales,
      )..where((s) => s.customerId.equals(customerId))).get();
      return Future.wait(salesList.map((sale) => getSaleWithDetails(sale.id)));
    } catch (e, stackTrace) {
      _logger.severe(
        'Error fetching sales for customer $customerId',
        e,
        stackTrace,
      );
      return []; // Return empty list on error
    }
  }

  // Methods for Sales
  Stream<List<SaleWithItemsAndCustomer>> watchAllSalesWithDetails() {
    try {
      final salesStream =
          (select(sales)..orderBy([
                (s) => OrderingTerm(
                  expression: s.saleDate,
                  mode: OrderingMode.desc,
                ),
              ]))
              .watch();

      return salesStream
          .asyncMap((salesList) {
            return Future.wait(
              salesList.map((sale) => getSaleWithDetails(sale.id)),
            );
          })
          .handleError((error, stackTrace) {
            _logger.severe(
              'Error in watchAllSalesWithDetails',
              error,
              stackTrace,
            );
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
      final sale = await (select(
        sales,
      )..where((s) => s.id.equals(saleId))).getSingle();

      final customer = sale.customerId == null
          ? null
          : await (select(
              customers,
            )..where((c) => c.id.equals(sale.customerId!))).getSingleOrNull();

      final itemsQuery = select(saleItems).join([
        innerJoin(products, products.id.equalsExp(saleItems.productId)),
      ])..where(saleItems.saleId.equals(saleId));

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
      final customerSales = await (select(
        sales,
      )..where((s) => s.customerId.equals(id))).get();

      if (customerSales.isNotEmpty) {
        throw Exception(
          'Cannot delete customer with existing sales. Consider archiving instead.',
        );
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
      return select(cartItems)
          .join([
            innerJoin(products, products.id.equalsExp(cartItems.productId)),
          ])
          .watch()
          .map((rows) {
            return rows.map((row) {
              return CartItem(
                product: row.readTable(products),
                quantity: row.readTable(cartItems).quantity,
              );
            }).toList();
          })
          .handleError((error, stackTrace) {
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
      await (delete(
        cartItems,
      )..where((c) => c.productId.equals(productId))).go();
    } catch (e, stackTrace) {
      _logger.severe('Error removing cart item', e, stackTrace);
      rethrow;
    }
  }
Future<File> backupDatabaseAsZip(String backupZipPath) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();

      // Get list of real tables (skip sqlite_ internal tables)
      final tables = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      ).get();

      final tmpDir = await Directory(
        p.join(
          docDir.path,
          'tmp_backup_${DateTime.now().millisecondsSinceEpoch}',
        ),
      ).create(recursive: true);

      for (final row in tables) {
        final tableName = row.data['name'] as String;

        // Select all rows of the table (quote tableName)
        final results = await customSelect('SELECT * FROM "$tableName"').get();
        if (results.isEmpty) continue;

        // Columns from first row's keys
        final columns = results.first.data.keys.toList();

        // Build CSV (header + rows)
        final csvRows = <List<dynamic>>[];
        csvRows.add(columns);
        for (final r in results) {
          csvRows.add(columns.map((c) => r.data[c]).toList());
        }

        final csvString = const ListToCsvConverter().convert(csvRows);
        final csvFile = File(p.join(tmpDir.path, '$tableName.csv'));
        await csvFile.writeAsString(csvString);
      }

      // Create ZIP archive
      final encoder = ZipEncoder();
      final archive = Archive();

      await for (final fse in tmpDir.list(recursive: false)) {
        if (fse is File && fse.path.endsWith('.csv')) {
          final data = await fse.readAsBytes();
          archive.addFile(ArchiveFile(p.basename(fse.path), data.length, data));
        }
      }

      final zipData = encoder.encode(archive);
      final zipFile = File(backupZipPath);
      await zipFile.writeAsBytes(zipData);

      // cleanup
      await tmpDir.delete(recursive: true);

      _logger.info('Database exported to zip: $backupZipPath');
      return zipFile;
    } catch (e, st) {
      _logger.severe('Error backing up database to zip', e, st);
      rethrow;
    }
  }

  /// Restore DB from the provided zip file (containing CSVs). This uses a transaction,
  /// verifies table names and uses positional parameters for inserts (no 'variables:' named param).
  Future<void> restoreDatabaseFromZip(String backupZipPath) async {
    try {
      final docDir = await getApplicationDocumentsDirectory();
      final tmpDir = await Directory(
        p.join(
          docDir.path,
          'tmp_restore_${DateTime.now().millisecondsSinceEpoch}',
        ),
      ).create(recursive: true);

      // --- 1. unzip to temp folder ---
      final bytes = await File(backupZipPath).readAsBytes();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        if (file.isFile) {
          final outPath = p.join(tmpDir.path, file.name);
          final outFile = File(outPath);
          await outFile.create(recursive: true);
          await outFile.writeAsBytes(file.content as List<int>);
        }
      }

      // --- 2. fetch valid table names ---
      final tableRows = await customSelect(
        "SELECT name FROM sqlite_master WHERE type='table' AND name NOT LIKE 'sqlite_%';",
      ).get();
      final validTables = tableRows
          .map((r) => r.data['name'] as String)
          .toSet();

      // --- 3. define restore order (children first) ---
      // Put your actual child→parent order here:
      final manualOrder = <String>[
        'sales_items',
        'payments',
        'sales',
        'products',
        'customers',
        // add more if needed
      ];
      // Keep only existing tables:
      final restoreOrder = manualOrder.where(validTables.contains).toList();

      // Also include any tables not listed manually at the end
      final leftoverTables = validTables
          .where((t) => !restoreOrder.contains(t))
          .toList();
      restoreOrder.addAll(leftoverTables);

      // --- 4. disable FK globally before transaction ---
      await customStatement('PRAGMA foreign_keys = OFF;');

      // --- 5. restore data inside transaction ---
      await transaction(() async {
        for (final tableName in restoreOrder) {
          final csvFile = tmpDir.listSync().firstWhere(
            (f) => p.basenameWithoutExtension(f.path) == tableName,
            orElse: () => File(''),
          );

          if (csvFile is! File || !(csvFile).existsSync()) {
            _logger.warning('No CSV file found for $tableName, skipping.');
            continue;
          }

          final csvString = await (csvFile).readAsString();
          final parsed = const CsvToListConverter().convert(csvString);
          if (parsed.isEmpty) continue;

          final header = parsed.first.cast<String>();
          final dataRows = parsed.skip(1).toList();

          // delete old data
          _logger.info('Clearing $tableName');
          await customStatement('DELETE FROM "$tableName";');

          if (dataRows.isEmpty) continue;

          // build insert statement
          final escapedCols = header
              .map((c) => '"${c.replaceAll('"', '""')}"')
              .join(',');
          final placeholders = List.filled(header.length, '?').join(',');
          final insertSql =
              'INSERT INTO "$tableName" ($escapedCols) VALUES ($placeholders)';

          // insert rows
          for (final row in dataRows) {
            await customStatement(insertSql, row);
          }
          _logger.info('Imported ${dataRows.length} rows into $tableName');
        }
      });

      // --- 6. re-enable FK + vacuum ---
      await customStatement('PRAGMA foreign_keys = ON;');
      await customStatement('VACUUM;');

      // --- 7. clean up temp dir ---
      await tmpDir.delete(recursive: true);

      _logger.info('✅ Database restored from zip: $backupZipPath');
    } catch (e, st) {
      _logger.severe('❌ Error restoring database from zip', e, st);
      rethrow;
    }
  }
// ==================== PAYMENTS ====================
  
  Future<void> addGlobalPayment({
    required String customerId,
    required double amount,
    required String method,
    String? reference,
  }) async {
    return transaction(() async {
      double remaining = amount;

      // 1. Get all pending or partial sales (FIFO by date)
      final salesList = await (select(sales)
            ..where((s) =>
                s.customerId.equals(customerId) &
                (s.status.equals("pending") | s.status.equals("partial")))
            ..orderBy([(s) => OrderingTerm.asc(s.saleDate)]))
          .get();

      for (final sale in salesList) {
        if (remaining <= 0) break;

        final paid = await getTotalPaidForSale(sale.id);
        final balance = sale.totalAmount - paid;

        if (balance <= 0) continue;

        if (remaining >= balance) {
          // Pay full balance → mark complete
          await into(payments).insert(
            PaymentsCompanion.insert(
              saleId: sale.id,
              amount: balance,
              method: method,
              status: const Value("complete"),
              reference: Value(reference),
            ),
          );
          remaining -= balance;
        } else {
          // Pay partial
          await into(payments).insert(
            PaymentsCompanion.insert(
              saleId: sale.id,
              amount: remaining,
              method: method,
              status: const Value("partial"),
              reference: Value(reference),
            ),
          );
          remaining = 0;
        }
      }

      // 2. If extra left → record as advance
      if (remaining > 0) {
        await into(payments).insert(
          PaymentsCompanion.insert(
            saleId: customerId, // ⚠️ if you want to link to customer, or make saleId nullable
            amount: remaining,
            method: method,
            status: const Value("advance"),
            reference: Value(reference),
          ),
        );
      }
    });
  }// ==================== PAYMENTS ====================
  
Future<void> addPayment({
  required String saleId,
  required double amount,
  required String method,
  String? reference,
  int? parentPaymentId,
}) async {
  return transaction(() async {
    final sale =
        await (select(sales)..where((s) => s.id.equals(saleId))).getSingle();

    final totalPaid = await getTotalPaidForSale(saleId);
    final newTotal = totalPaid + amount;

    // Validate payments
    if (amount > 0 && newTotal > sale.totalAmount) {
      // Instead of error: record the extra as advance/credit
      final overpayment = newTotal - sale.totalAmount;

      // Record payment up to the sale balance
      final appliedAmount = amount - overpayment;

      if (appliedAmount > 0) {
        await into(payments).insert(
          PaymentsCompanion.insert(
            saleId: saleId,
            amount: appliedAmount,
            method: method,
            status: Value('complete'),
            reference: Value(reference),
            parentPaymentId: Value(parentPaymentId),
          ),
        );
      }

      // Store remaining as advance payment (no sale linked)
      await into(payments).insert(
        PaymentsCompanion.insert(
          saleId: saleId, // optional: link to sale or leave null if schema allows
          amount: overpayment,
          method: method,
          status: Value('advance'),
          reference: Value(reference),
          parentPaymentId: Value(parentPaymentId),
        ),
      );
      return;
    }

    if (amount < 0 && totalPaid + amount < 0) {
      throw Exception("Refund exceeds paid amount");
    }

    // Determine status
    final status = newTotal == sale.totalAmount
        ? 'complete'
        : (newTotal > 0 ? 'partial' : 'pending');

    await into(payments).insert(
      PaymentsCompanion.insert(
        saleId: saleId,
        amount: amount,
        method: method,
        status: Value(status),
        reference: Value(reference),
        parentPaymentId: Value(parentPaymentId),
      ),
    );
  });
}

// ==================== HELPERS ====================

Future<List<Payment>> getPaymentsForSale(String saleId) =>
    (select(payments)..where((p) => p.saleId.equals(saleId))).get();

Future<double> getTotalPaidForSale(String saleId) async {
  final query = payments.selectOnly()
    ..addColumns([payments.amount.sum()])
    ..where(payments.saleId.equals(saleId) & payments.status.isNotIn(['failed', 'refunded']));
  final row = await query.getSingle();
  return row.read(payments.amount.sum()) ?? 0.0;
}

Future<double> getBalanceForSale(String saleId) async {
  final sale =
      await (select(sales)..where((s) => s.id.equals(saleId))).getSingle();
  final paid = await getTotalPaidForSale(saleId);
  return sale.totalAmount - paid;
}

// ==================== CUSTOMER LEVEL ====================

Future<CustomerWithSalesAndPayments> getCustomerWithSalesAndPayments(
    String customerId) async {
  final customer = await (select(customers)
        ..where((c) => c.id.equals(customerId)))
      .getSingle();

  final salesList =
      await (select(sales)..where((s) => s.customerId.equals(customerId))).get();

  final salesWithPayments = <SaleWithPayments>[];
  double totalSpend = 0;
  double totalPayments = 0;

  for (final sale in salesList) {
    final saleWithPayments = await getSaleWithPayments(sale.id);
    salesWithPayments.add(saleWithPayments);

    totalSpend += sale.totalAmount;
    totalPayments += saleWithPayments.amountPaid;
  }

  // Get customer advance balance
  final advance = await getCustomerAdvance(customerId);

  return CustomerWithSalesAndPayments(
    customer: customer,
    sales: salesWithPayments,
    totalSpend: totalSpend,
    totalPayments: totalPayments,
    advanceBalance: advance,
  );
}

Future<SaleWithPayments> getSaleWithPayments(String saleId) async {
  final base = await getSaleWithDetails(saleId);
  final paymentList = await getPaymentsForSale(saleId);

  final amountPaid = paymentList.fold<double>(
    0,
    (sum, p) => sum + (p.status != 'failed' ? p.amount : 0),
  );

  final balance = base.sale.totalAmount - amountPaid;

  return SaleWithPayments(
    sale: base.sale,
    customer: base.customer,
    items: base.items,
    payments: paymentList,
  
  );
}

// ==================== ADVANCE HANDLING ====================

Future<double> getCustomerAdvance(String customerId) async {
  final query = payments.selectOnly()
    ..addColumns([payments.amount.sum()])
    ..where(payments.status.equals('advance'));
  final row = await query.getSingle();
  return row.read(payments.amount.sum()) ?? 0.0;
}

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
