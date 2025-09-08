import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/database.dart';

void showAddEditCustomerDialog(BuildContext context, [Customer? customer]) {
  final nameController = TextEditingController(text: customer?.name ?? '');
  final emailController = TextEditingController(text: customer?.email ?? '');
  final phoneController = TextEditingController(text: customer?.phone ?? '');
  final addressController = TextEditingController(
    text: customer?.address ?? '',
  );

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(customer == null ? 'Add Customer' : 'Edit Customer'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
              keyboardType: TextInputType.phone,
            ),
            TextField(
              controller: addressController,
              decoration: const InputDecoration(labelText: 'Address'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(ctx).pop(),
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            final db = Provider.of<AppDatabase>(context, listen: false);
            final customerCompanion = CustomersCompanion(
              id: customer != null
                  ? drift.Value(customer.id)
                  : drift.Value(const Uuid().v4()),
              name: drift.Value(nameController.text),
              email: drift.Value(emailController.text),
              phone: drift.Value(phoneController.text),
              address: drift.Value(addressController.text),
            );

            if (customer == null) {
              db.into(db.customers).insert(customerCompanion);
            } else {
              db.update(db.customers).replace(customerCompanion);
            }
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}
