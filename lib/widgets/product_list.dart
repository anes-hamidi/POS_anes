// product_list.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';
import '../screens/add_edit_product_screen.dart';
import '../services/confirmation_dialog_service.dart';

class ProductList extends StatelessWidget {
  final List<Product> products;
  const ProductList({super.key, required this.products});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final confirmationDialogService =
        Provider.of<ConfirmationDialogService>(context, listen: false);
    final NumberFormat currencyFormat =
        NumberFormat.currency(locale: 'en_AR', symbol: 'DA ');
    final colorScheme = Theme.of(context).colorScheme;

    Future<void> _showQuantityDialog(Product product) async {
      int tempQty = product.quantity;

      await showDialog(
        context: context,
        builder: (ctx) {
          return AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: Text('Adjust Quantity - ${product.name}'),
            content: StatefulBuilder(
              builder: (context, setState) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Current Qty: $tempQty',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 12),
                    Slider(
                      value: tempQty.toDouble(),
                      min: 0,
                      max: 500000, // You can make this dynamic based on stock limits
                      divisions: 500000,
                      label: tempQty.toString(),
                      onChanged: (value) {
                        setState(() => tempQty = value.round());
                      },
                    ),
                    TextField(
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Set Exact Quantity',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (val) {
                        final parsed = int.tryParse(val);
                        if (parsed != null && parsed >= 0) {
                          setState(() => tempQty = parsed);
                        }
                      },
                    ),
                  ],
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancel'),
              ),
              ElevatedButton.icon(
                onPressed: () async {
                  await db.update(db.products).replace(
                    product.copyWith(quantity: tempQty),
                  );
                  Navigator.pop(ctx);
                },
                icon: const Icon(Icons.save),
                label: const Text('Save'),
              ),
            ],
          );
        },
      );
    }

    return ListView.builder(
      itemCount: products.length,
      itemBuilder: (ctx, i) {
        final product = products[i];
        return Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            leading: CircleAvatar(
              radius: 26,
              backgroundImage: product.imageUrl != null
                  ? FileImage(File(product.imageUrl!))
                  : null,
              child: product.imageUrl == null
                  ? const Icon(Icons.inventory_2_outlined)
                  : null,
            ),
            title: Text(product.name,
                style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(
              '${currencyFormat.format(product.price)} • Qty: ${product.quantity}',
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
            onTap: () => _showQuantityDialog(product), // 👈 Tap opens quantity dialog
            trailing: PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AddEditProductScreen(product: product),
                    ),
                  );
                } else if (value == 'delete') {
                  final confirmed =
                      await confirmationDialogService.showConfirmationDialog(
                    context,
                    title: 'Delete Product',
                    content: 'Are you sure you want to delete ${product.name}?',
                  );
                  if (confirmed == true) {
                    await db.delete(db.products).delete(product);
                  }
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: colorScheme.error)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
