import 'package:flutter/material.dart';
import 'package:myapp/data/database.dart';
import 'package:myapp/providers/cart_provider.dart';
import 'package:myapp/screens/add_edit_customer_screen.dart';
import 'package:provider/provider.dart';

class ConfirmationDialogService {
  Future<bool?> showConfirmationDialog(
    BuildContext context, {
    required String title,
    required String content,
    String confirmText = 'Yes',
    String cancelText = 'No',
  }) {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: <Widget>[
          TextButton(
            child: Text(cancelText),
            onPressed: () => Navigator.of(ctx).pop(false),
          ),
          TextButton(
            child: Text(confirmText),
            onPressed: () => Navigator.of(ctx).pop(true),
          ),
        ],
      ),
    );
  }
}extension CustomerDialog on ConfirmationDialogService {
  Future<Customer?> askForCustomerOrContinue(BuildContext context) async {
    final cart = context.read<CartProvider>();
    final existingCustomer = cart.selectedCustomer;

    if (existingCustomer != null) {
      // ✅ already selected
      return existingCustomer;
    }

    // ❌ no customer selected → ask user
    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("No Customer Selected"),
        content: const Text(
          "Do you want to continue without a customer or create one?",
        ),
        actions: <Widget>[
          TextButton(
            child: const Text("Cancel"),
            onPressed: () => Navigator.of(ctx).pop(0),
          ),
          TextButton(
            child: const Text("Without Customer"),
            onPressed: () => Navigator.of(ctx).pop(1),
          ),
          TextButton(
            child: const Text("Create Customer"),
            onPressed: () => Navigator.of(ctx).pop(2),
          ),
        ],
      ),
    );

    if (result == 1) {
      // proceed without customer
      return null;
    } else if (result == 2) {
      // open form → return newly created
      final newCustomer = await Navigator.of(context).push<Customer>(
        MaterialPageRoute(builder: (_) => const AddEditCustomerScreen()),
      );

      if (newCustomer != null) {
        // 👌 update CartProvider selection
        cart.selectCustomer(newCustomer);
      }

      return newCustomer;
    }

    return null; // cancelled
  }
}
