import 'package:myapp/l10n/app_localizations.dart';
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
Future<void> showQuantityDialog(Product product) async {
  final TextEditingController controller = TextEditingController();
  int baseQty = product.quantity;
  int addQty = 0;

  await showDialog(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          AppLocalizations.of(context)!.adjustQuantity(product.name),
        ),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      '$baseQty --> : ${baseQty + addQty}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                TextField(
                  controller: controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.setExactQuantity,
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val) ?? 0;
                    setState(() => addQty = parsed);
                  },
                ),

               
              ],
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              final newQty = baseQty + addQty;
              await db.update(db.products).replace(
                product.copyWith(quantity: newQty),
              );
              Navigator.pop(ctx);
            },
            icon: const Icon(Icons.save),
            label: Text(AppLocalizations.of(context)!.save),
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
          color: product.quantity < 2
              ? colorScheme.errorContainer
              : colorScheme.surface,


              
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
  title: Text(
    product.name,
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
  subtitle: Text(
    '${AppLocalizations.of(context)!.category}: ${product.category}\n'
    '${AppLocalizations.of(context)!.price}: ${currencyFormat.format(product.price)}\n'
    '${AppLocalizations.of(context)!.quantity}: ${product.quantity}',
    style: TextStyle(color: colorScheme.onSurfaceVariant),
  ),
  onTap: () => showQuantityDialog(product),

  // ✅ Trailing section with warning + popup menu
  trailing: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      if (product.quantity < 5) ...[
        const Icon(Icons.flag, color: Colors.red),
        const SizedBox(width: 8),
      ],
      PopupMenuButton<String>(
        onSelected: (value) async {
          if (value == AppLocalizations.of(context)!.edit) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => AddEditProductScreen(product: product),
              ),
            );
          } else if (value == AppLocalizations.of(context)!.delete) {
  final confirmed = await confirmationDialogService.showConfirmationDialog(
    context,
    title: AppLocalizations.of(context)!.deleteProduct,
    content: AppLocalizations.of(context)!
        .areYouSureDeleteProduct(product.name),
  );
if (confirmed == true) {
  // First remove child rows
  await (db.delete(db.saleItems)
        ..where((s) => s.productId.equals(product.id)))
      .go();

  // Now delete the product
  await (db.delete(db.products)
        ..where((p) => p.id.equals(product.id)))
      .go();
}


}
        },  
        itemBuilder: (context) => [
          PopupMenuItem(
            value: AppLocalizations.of(context)!.edit,
            child: Text(AppLocalizations.of(context)!.edit),
          ),
          PopupMenuItem(
            value: AppLocalizations.of(context)!.delete,
            child: Text(
              AppLocalizations.of(context)!.delete,
              style: TextStyle(color: colorScheme.error),
            ),
          ),
        ],
      ),
    ],
  ),
)
 );
      },
    );
  }
}
