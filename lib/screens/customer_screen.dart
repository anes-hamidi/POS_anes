import 'package:flutter/material.dart';
import 'package:myapp/data/database.dart';
import 'package:myapp/screens/customerProfile.dart';
import 'package:myapp/widgets/common/themed_scaffold.dart';
import 'package:provider/provider.dart';
import '../widgets/add_edit_customer_dialog.dart';
import '../widgets/empty_state.dart';
import '../widgets/entity_list.dart';
import '../services/confirmation_dialog_service.dart';

class CustomerScreen extends StatelessWidget {
  const CustomerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final confirmationDialogService = Provider.of<ConfirmationDialogService>(context, listen: false);

    return ThemedScaffold(
      appBar: AppBar(
        title: const Text('Manage Customers'),
      ),
      body: StreamBuilder<List<Customer>>(
        stream: db.select(db.customers).watch(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final customers = snapshot.data ?? [];
          if (customers.isEmpty) {
            return const EmptyState(
              title: 'No Customers Found',
              message: 'Get started by adding your first customer.',
            );
          }
          return EntityList<Customer>(
            items: customers,
            getTitle: (customer) => customer.name,
            getSubtitle: (customer) => customer.email ?? '',
            onTap: (customer) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomerProfileScreen(customer: customer),
                ),
              );
            },
            onEdit: (customer) => showAddEditCustomerDialog(context, customer),
            onDelete: (customer) async {
              final confirmed = await confirmationDialogService.showConfirmationDialog(
                context,
                title: 'Delete Customer',
                content: 'Are you sure you want to delete ${customer.name}?',
              );
              if (confirmed == true) {
                db.delete(db.customers).where((tbl) => tbl.id.equals(customer.id));
              }
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showAddEditCustomerDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Customer'),
      ),
    );
  }
}
