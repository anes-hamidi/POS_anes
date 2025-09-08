import 'package:drift/drift.dart' as drift;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../data/database.dart';

void showAddEditSupplierDialog(BuildContext context, [Supplier? supplier]) {
  final nameController = TextEditingController(text: supplier?.name ?? '');
  final contactPersonController = TextEditingController(text: supplier?.contactPerson ?? '');
  final emailController = TextEditingController(text: supplier?.email ?? '');
  final phoneController = TextEditingController(text: supplier?.phone ?? '');

  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(supplier == null ? 'Add Supplier' : 'Edit Supplier'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: contactPersonController,
              decoration: const InputDecoration(labelText: 'Contact Person'),
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
            final supplierCompanion = SuppliersCompanion(
              id: supplier != null ? drift.Value(supplier.id) : drift.Value(const Uuid().v4()),
              name: drift.Value(nameController.text),
              contactPerson: drift.Value(contactPersonController.text),
              email: drift.Value(emailController.text),
              phone: drift.Value(phoneController.text),
            );

            if (supplier == null) {
              db.into(db.suppliers).insert(supplierCompanion);
            } else {
              db.update(db.suppliers).replace(supplierCompanion);
            }
            Navigator.of(ctx).pop();
          },
        ),
      ],
    ),
  );
}
