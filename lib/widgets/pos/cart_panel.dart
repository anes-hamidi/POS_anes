import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/data/database.dart';
import 'package:myapp/screens/add_edit_customer_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../services/confirmation_dialog_service.dart';
import '../../services/sale_service.dart';
import 'cart_list.dart';
import 'customer_selector.dart';
import 'package:myapp/l10n/app_localizations.dart';

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
                  tooltip: AppLocalizations.of(context)!.addNewCustomer,
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
                      '${AppLocalizations.of(context)!.items} $totalItems',
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.secondary,
                      ),
                    ),
                    Text(
                      '${AppLocalizations.of(context)!.quantity} $totalQuantity',
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
                      AppLocalizations.of(context)!.totalAmount,
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
                        tooltip: AppLocalizations.of(context)!.clearCart,
                        onPressed: () async {
                          final confirmed = await context
                              .read<ConfirmationDialogService>()
                              .showConfirmationDialog(
                                context,
                                title: AppLocalizations.of(context)!.clearCart,
                                content:
                                    AppLocalizations.of(context)!.clearCartConfirmation,
                              );
                          if (confirmed == true) {
                            await cart.clearCart();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(AppLocalizations.of(context)!.cartCleared),
                                backgroundColor: Colors.orange,
                              ),
                            );
                          }
                        },
                      ),
Expanded(
  child: ElevatedButton.icon(
    icon: const Icon(Icons.point_of_sale_rounded, size: 28),
    label:  Text(AppLocalizations.of(context)!.completeSale),
   onPressed: cart.items.isEmpty
    ? null
    : () async {
        final confirmed = await context
            .read<ConfirmationDialogService>()
            .showConfirmationDialog(
              context,
              title: '${AppLocalizations.of(context)!.completeSale}?',
              content: AppLocalizations.of(context)!.completeSaleConfirmation,
            );

        if (confirmed != true) return;

        final confirmationService = context.read<ConfirmationDialogService>();
        final Customer? selectedCustomer =
            await confirmationService.askForCustomerOrContinue(context);

        if (selectedCustomer == null && !context.mounted) return; 
        // null = proceed without OR cancelled. If cancelled, just stop.

        // ✅ Step 2: Ask for save/print
        final selectedAction = await showDialog<String>(
          context: context,
          builder: (ctx) => AlertDialog(
            title:  Text(AppLocalizations.of(context)!.chooseAction),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  AppLocalizations.of(context)!.saveOrPrintPrompt,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.print, size: 40, color: Colors.green),
                          onPressed: () => Navigator.pop(ctx, 'print'),
                        ),
                        Text(
                          AppLocalizations.of(context)!.saveAndPrint,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    Column(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.save, size: 40, color: Colors.blue),
                          onPressed: () => Navigator.pop(ctx, 'save'),
                        ),
                        Text(
                          AppLocalizations.of(context)!.saveOnly,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child:  Text(AppLocalizations.of(context)!.cancel),
              ),
            ],
          ),
        );

        if (selectedAction == null) return;

        try {
          final saleService = context.read<SaleService>();

          if (selectedAction == 'print') {
            await saleService.createAndPrintInvoice(cart, context, selectedCustomer);
          } else {
            await saleService.createAndSaveSale(cart, context, selectedCustomer);
          }

          await cart.clearCart();
          // after await cart.clearCart();
if (context.mounted) {
  // ✅ Ask user if they want to record payment
  



  Navigator.pop(context); // close CartPanel
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        selectedAction == 'print'
            ? AppLocalizations.of(context)!.saleCompletedAndInvoicePrinted
            : AppLocalizations.of(context)!.saleCompletedWithoutPrinting,
      ),
      backgroundColor: Colors.green,
    ),
  );
}


          if (context.mounted) {
            Navigator.pop(context); // close CartPanel
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  selectedAction == 'print'
                      ? AppLocalizations.of(context)!.saleCompletedAndInvoicePrinted
                      : AppLocalizations.of(context)!.saleCompletedWithoutPrinting,
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '${AppLocalizations.of(context)!.errorCompletingSale}: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },

),

                )],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
