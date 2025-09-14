// product_screen.dart
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:myapp/l10n/app_localizations.dart';
import 'package:provider/provider.dart';

import '../data/database.dart';
import '../widgets/product_list.dart';
import '../widgets/empty_state.dart';
import './add_edit_product_screen.dart';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:myapp/providers/PrinterProvide.dart';

class ProductScreen extends StatefulWidget {
  const ProductScreen({super.key});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final printerProvider = context.watch<PrinterProvider>();
    final loc = AppLocalizations.of(context)!; // ✅ shorthand for translations

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.products), // ✅ "Products"
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: loc.searchByNameCategoryOrSku, // ✅ localized tooltip
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(db: db),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: loc.scanBarcode, // ✅ "Scan barcode"
            onPressed: () => _scanBarcode(context, db),
          ),
          IconButton(
            icon: Icon(
              printerProvider.isConnected
                  ? Icons.print
                  : printerProvider.isConnecting
                      ? Icons.sync
                      : Icons.print_disabled,
              color: printerProvider.isConnected
                  ? Colors.green
                  : printerProvider.isConnecting
                      ? Colors.orange
                      : Colors.red,
            ),
            onPressed: () async {
              if (!printerProvider.isConnected &&
                  !printerProvider.isConnecting) {
                await printerProvider.getBondedDevices().then((devices) {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) {
                      return ListView(
                        children: devices
                            .map(
                              (device) => ListTile(
                                title: Text(device.name ?? loc.unknownDevice),
                                subtitle: Text(device.address ?? ''),
                                onTap: () async {
                                  Navigator.pop(context);
                                  await printerProvider.connectTo(device);
                                },
                              ),
                            )
                            .toList(),
                      );
                    },
                  );
                });
              }
            },
          ),
        ],
      ),
      body: StreamBuilder<List<Product>>(
        stream: db.select(db.products).watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('${loc.errorLoadingProducts}: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return EmptyState(
              title: loc.noProductsFound,
              message: loc.productNotFound, // or a new localized string "Tap + to add..."
            );
          }

          return ProductList(products: products);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const AddEditProductScreen()),
        ),
        icon: const Icon(Icons.add),
        label: Text(loc.addNewProduct), // ✅ "Add Product"
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context, AppDatabase db) async {
    final loc = AppLocalizations.of(context)!;

    try {
      final ScanResult result = await BarcodeScanner.scan();
      final String barcode = result.rawContent;

      if (barcode == '-1') return; // User cancelled

      final product = await (db.select(
        db.products,
      )..where((p) => p.barcode.equals(barcode))).getSingleOrNull();

      if (product != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} ${loc.productAdded}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.productNotFound),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${loc.scanError}: $e')));
    }
  }
}

class ProductSearchDelegate extends SearchDelegate {
  final AppDatabase db;
  ProductSearchDelegate({required this.db});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      if (query.isNotEmpty)
        IconButton(
          icon: const Icon(Icons.clear),
          tooltip: AppLocalizations.of(context)!.cancel, // ✅ localized
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      tooltip: AppLocalizations.of(context)!.close, // ✅ localized
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return StreamBuilder<List<Product>>(
      stream: (query.isEmpty)
          ? db.select(db.products).watch()
          : (db.select(db.products)..where((p) => p.name.like('%$query%'))).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data ?? [];
        if (products.isEmpty) {
          return Center(child: Text(loc.noProductsFound)); // ✅ localized
        }
        return ProductList(products: products);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
