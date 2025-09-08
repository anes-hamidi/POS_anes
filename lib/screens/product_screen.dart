// product_screen.dart
import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';
import '../widgets/common/themed_scaffold.dart';
import '../widgets/product_list.dart';
import '../widgets/empty_state.dart';
import './add_edit_product_screen.dart';

class ProductScreen extends StatelessWidget {
  const ProductScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);

    return ThemedScaffold(
      appBar: AppBar(
        title: const Text('Products'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(db: db),
              );
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
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final products = snapshot.data ?? [];
          if (products.isEmpty) {
            return const EmptyState(
              title: 'No Products Found',
              message: 'Tap the + button to add your first product.',
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
        label: const Text('Add Product'),
      ),
    );
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
          onPressed: () => query = '',
        ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return StreamBuilder<List<Product>>(
      stream: (query.isEmpty)
          ? db.select(db.products).watch()
          : (db.select(db.products)..where((p) => p.name.like('%$query%'))).watch(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
        final products = snapshot.data ?? [];
        return ProductList(products: products);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}
