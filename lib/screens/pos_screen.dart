import 'package:flutter/material.dart';
import 'package:myapp/providers/PrinterProvide.dart';
import 'package:provider/provider.dart';
import 'package:barcode_scan2/barcode_scan2.dart';
import '../widgets/printer_connection_dialog.dart';
import '../data/database.dart';
import '../providers/cart_provider.dart';
import '../widgets/pos/product_search_field.dart';
import '../widgets/pos/product_grid.dart';
import '../widgets/pos/cart_panel.dart';

class POSScreen extends StatefulWidget {
  const POSScreen({super.key});

  @override
  State<POSScreen> createState() => _POSScreenState();
}

class _POSScreenState extends State<POSScreen> {
  String _searchQuery = '';
  String _selectedCategory = 'All';
bool _showRanked = false;
  Future<void> _scanBarcode() async {
    try {
      final ScanResult result = await BarcodeScanner.scan();
      final String barcode = result.rawContent;

      if (!mounted || barcode == '-1') return; // User cancelled

      final db = context.read<AppDatabase>();
      final product = await (db.select(db.products)
            ..where((p) => p.barcode.equals(barcode)))
          .getSingleOrNull();

      if (product != null) {
        context.read<CartProvider>().addToCart(product.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${product.name} added to cart.'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error scanning barcode: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final printerProvider = context.watch<PrinterProvider>();
    final db = context.read<AppDatabase>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("POS Screen"),
        actions: [
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
                            .map((device) => ListTile(
                                  title: Text(device.name ?? 'Unknown'),
                                  subtitle: Text(device.address ?? ''),
                                  onTap: () async {
                                    Navigator.pop(context);
                                    await printerProvider.connectTo(device);
                                  },
                                ))
                            .toList(),
                      );
                    },
                  );
                });
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: 'Scan Barcode',
            onPressed: _scanBarcode,
          ),
          IconButton(
  icon: Icon(
    _showRanked ? Icons.star : Icons.star_border,
    color: _showRanked ? Colors.amber : Colors.grey,
  ),
  tooltip: _showRanked ? 'All' : 'Top',
  onPressed: () => setState(() => _showRanked = !_showRanked),
),
        ],
      ),

      // --- PRODUCT GRID BODY WITH SEARCH & FILTER --- //
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: ProductSearchField(
                    onSearchChanged: (query) =>
                        setState(() => _searchQuery = query),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedCategory,
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => _selectedCategory = value);
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'boisson', child: Text('boisson')),
                    DropdownMenuItem(value: 'jus', child: Text('jus')),
                    DropdownMenuItem(value: 'jus gaz', child: Text('jus gaz')),
                    DropdownMenuItem(value: 'canet', child: Text('canet')),
                    DropdownMenuItem(value: 'mini', child: Text('mini')),
                    DropdownMenuItem(value: 'All', child: Text('All')),
                  ],
                ),
              ],
            ),
          ),
        Expanded(
  child: _showRanked
      ? FutureBuilder<List<Map<String, dynamic>>>(
          future: db.getRankedProducts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error loading ranked products: ${snapshot.error}"),
              );
            }

            final ranked = snapshot.data ?? [];
            if (ranked.isEmpty) {
              return const Center(child: Text("No ranking data available."));
            }

            // Fetch full Product models by productId
            return FutureBuilder<List<Product>>(
              future: db.getProductsByIds(
                ranked.map((r) => r['productId'] as String).toList(),
              ),
              builder: (context, productSnapshot) {
                if (productSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final products = productSnapshot.data ?? [];
                // Sort by ranking order
                products.sort((a, b) {
                  final aScore = ranked
                      .firstWhere((p) => p['productId'] == a.id)['rankingScore'];
                  final bScore = ranked
                      .firstWhere((p) => p['productId'] == b.id)['rankingScore'];
                  return (bScore as num).compareTo(aScore as num);
                });
                final rankingMap = {
  for (var r in ranked) r['productId'] as String: r['rankingScore'] as num
};
return ProductGrid(
  products: products,
  rankingScores: rankingMap,
);

              },
            );
          },
        )
      : StreamBuilder<List<Product>>(
          stream: db.watchAllProducts(
            _searchQuery,
            _selectedCategory == 'All' ? null : _selectedCategory,
          ),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return Center(
                child: Text("Error loading products: ${snapshot.error}"),
              );
            }
            final products = snapshot.data ?? [];
            if (products.isEmpty) {
              return const Center(child: Text("No products found."));
            }
            return ProductGrid(products: products);
          },
        ),
),

        ],
      ),

      // --- FAB reacts ONLY to CartProvider changes --- //
  floatingActionButton: Consumer<CartProvider>(
  builder: (context, cartProvider, _) {
    if (cartProvider.items.isEmpty) {
      return const SizedBox.shrink(); // ✅ valid empty widget
    }
    return FloatingActionButton.extended(
      backgroundColor: Colors.blueAccent,
      onPressed: () => _showCartPanel(context),
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          const Icon(Icons.shopping_cart, size: 28),
          Positioned(
            right: -4,
            top: -4,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                cartProvider.totalQuantity.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
      label: Text('DA ${cartProvider.subtotal.toStringAsFixed(2)}'),
    );
  },
),
  );
  }

  void _showCartPanel(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CartPanel(),
        fullscreenDialog: true,
      ),
    );
  }
}
