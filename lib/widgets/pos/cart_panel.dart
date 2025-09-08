import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/add_edit_customer_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/confirmation_dialog_service.dart';
import '../../services/sale_service.dart';
import 'cart_list.dart';
import 'customer_selector.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: const Text('🛒 Cart'),
        centerTitle: true,
        elevation: 0,
      ),
      body: Column(
        children: [
          // ✅ Customer selector with "Add New" option
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                const Expanded(child: CustomerSelector()),

                // ➕ Quick Add Customer Button
                IconButton(
                  icon: const Icon(Icons.person_add_alt_1),
                  tooltip: 'Add New Customer',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddEditCustomerScreen(),
                        fullscreenDialog: true,
                      ),
                    );
                  },
                ),],
            ),
          ),

          // ✅ Cart List
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: CartList(),
              ),
            ),
          ),

          // ✅ Bottom summary panel
          const CartSummary(),
        ],
      ),
    );
  }
}

class CartSummary extends StatelessWidget {
  const CartSummary({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter =
        NumberFormat.currency(locale: 'en_AR', symbol: 'DA ');
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Consumer<CartProvider>(
      builder: (context, cart, child) {
        final totalItems = cart.items.length;
        final totalQuantity = cart.items.fold<int>(
            0, (sum, item) => sum + (item.quantity));

        return SafeArea(
          top: false,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                // 🔢 Info Row: Items + Qty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Items: $totalItems',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.secondary,
                      ),
                    ),
                    Text(
                      'Qty: $totalQuantity',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.secondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ✅ Total Row with animated value
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Total:',
                      style: textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    TweenAnimationBuilder<double>(
                      tween: Tween<double>(
                        begin: 0,
                        end: cart.subtotal,
                      ),
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      builder: (context, value, child) {
                        return Text(
                          currencyFormatter.format(value),
                          style: textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        );
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // ✅ Action Row
                Row(
                  children: [
                    if (cart.items.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.red),
                        tooltip: 'Clear Cart',
                        onPressed: () async {
                          final confirmed = await context
                              .read<ConfirmationDialogService>()
                              .showConfirmationDialog(
                                context,
                                title: 'Clear Cart?',
                                content:
                                    'Are you sure you want to remove all items?',
                              );
                          if (confirmed == true) {
                            await cart.clearCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cart cleared'),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),

                    Expanded(
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.point_of_sale_rounded, size: 28),
                        label: const Text('Complete Sale'),
                        onPressed: cart.items.isEmpty
    ? null
    : () async {
        final confirmed = await context
            .read<ConfirmationDialogService>()
            .showConfirmationDialog(
              context,
              title: 'Complete Sale?',
              content:
                  'This will finalize the sale. Do you want to proceed?',
            );

        if (confirmed == true) {
          // ✅ Show custom choice dialog
          final selectedAction = await showDialog<String>(
            context: context,
            builder: (ctx) => AlertDialog(
              title: const Text('Choose Action'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Would you like to print an invoice or just save the sale?",
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      // 🖨 Print Invoice Button
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.print, size: 40, color: Colors.green),
                            onPressed: () => Navigator.pop(ctx, 'print'),
                          ),
                          const Text("Save & Print", style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      // 💾 Save Only Button
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.save, size: 40, color: Colors.blue),
                            onPressed: () => Navigator.pop(ctx, 'save'),
                          ),
                          const Text("Save Only", style: TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          );

          if (selectedAction != null) {
            try {
              final saleService = context.read<SaleService>();

              if (selectedAction == 'print') {
                // Save and print
                await saleService.createAndPrintInvoice(cart, context);
              } else {
                // Save without printing
                await saleService.createAndSaveSale(cart ,context );
              }

              await cart.clearCart();

              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(selectedAction == 'print'
                        ? 'Sale completed & invoice printed!'
                        : 'Sale completed without printing.'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Error completing sale: $e'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
      },

                      )
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
