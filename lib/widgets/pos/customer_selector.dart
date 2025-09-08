import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/database.dart';
import '../../providers/cart_provider.dart';
import '../../screens/add_edit_customer_screen.dart';

class CustomerSelector extends StatelessWidget {
  const CustomerSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final selectedCustomer = Provider.of<CartProvider>(context).selectedCustomer;

    return GestureDetector(
      onTap: () => _showCustomerSelectionDialog(context, db, selectedCustomer),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Theme.of(context).dividerColor, width: 1.5),
        ),
        child: Row(
          children: [
            Icon(
              selectedCustomer == null ? Icons.person_outline : Icons.person,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                selectedCustomer?.name ?? 'Walk-in Customer',
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(fontWeight: FontWeight.w600),
              ),
            ),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  void _showCustomerSelectionDialog(
      BuildContext context, AppDatabase db, Customer? selectedCustomer) {
    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          insetPadding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // 🔹 Title with Add Button
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 8, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Select a Customer',
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                    IconButton(
                      icon: const Icon(Icons.person_add_alt_1_rounded),
                      tooltip: 'Add New Customer',
                      onPressed: () async {
                        final added = await Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (ctx) => const AddEditCustomerScreen()),
                        );

                        // If a customer was added, refresh dialog
                        if (added == true) {
                          Navigator.of(ctx).pop(); // close and reopen
                          Future.delayed(const Duration(milliseconds: 150), () {
                            _showCustomerSelectionDialog(
                                context, db, selectedCustomer);
                          });
                        }
                      },
                    )
                  ],
                ),
              ),

              const Divider(),

              // 🔹 Customer List
              Expanded(
                child: StreamBuilder<List<Customer>>(
                  stream: db.watchAllCustomers(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final customers = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      itemCount: customers.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return ListTile(
                            leading: const Icon(Icons.person_outline),
                            title: const Text('Walk-in Customer'),
                            onTap: () {
                              Provider.of<CartProvider>(context, listen: false)
                                  .selectCustomer(null);
                              Navigator.of(ctx).pop();
                            },
                          );
                        }
                        final customer = customers[index - 1];
                        return ListTile(
                          leading: const Icon(Icons.person),
                          title: Text(customer.name),
                          subtitle: customer.email != null &&
                                  customer.email!.trim().isNotEmpty
                              ? Text(customer.email!)
                              : null,
                          selected: selectedCustomer?.id == customer.id,
                          selectedTileColor: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.08),
                          onTap: () {
                            Provider.of<CartProvider>(context, listen: false)
                                .selectCustomer(customer);
                            Navigator.of(ctx).pop();
                          },
                        );
                      },
                    );
                  },
                ),
              ),

              // 🔹 Cancel Button
              Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('Close'),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
