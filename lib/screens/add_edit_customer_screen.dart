import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';
import 'package:drift/drift.dart' as drift;
import '../widgets/common/themed_scaffold.dart';

class AddEditCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddEditCustomerScreen({super.key, this.customer});

  @override
  State<AddEditCustomerScreen> createState() => _AddEditCustomerScreenState();
}

class _AddEditCustomerScreenState extends State<AddEditCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  String? _email;
  String? _phone;
  String? _address;

  @override
  void initState() {
    super.initState();
    _name = widget.customer?.name ?? '';
    _email = widget.customer?.email;
    _phone = widget.customer?.phone;
    _address = widget.customer?.address;
  }

  void _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final db = Provider.of<AppDatabase>(context, listen: false);
      
      final customerData = CustomersCompanion(
        
        name: drift.Value(_name),
        email: drift.Value(_email),
        phone: drift.Value(_phone),
        address: drift.Value(_address),
      );

      if (widget.customer == null) {
        // Add new customer
        final newCustomer = customerData.copyWith(id: drift.Value(DateTime.now().toIso8601String()));
        await db.addCustomer(newCustomer);
      } else {
        // Update existing customer
        final updatedCustomer = customerData.copyWith(id: drift.Value(widget.customer!.id));
        await db.updateCustomer(updatedCustomer);
      }
      if (mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ThemedScaffold(
      appBar: AppBar(
        title: Text(widget.customer == null ? 'Add Customer' : 'Edit Customer'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(labelText: 'Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a name.';
                  }
                  return null;
                },
                onSaved: (value) {
                  _name = value!;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _email,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                onSaved: (value) {
                  _email = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _phone,
                decoration: const InputDecoration(labelText: 'Phone'),
                keyboardType: TextInputType.phone,
                onSaved: (value) {
                  _phone = value;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                initialValue: _address,
                decoration: const InputDecoration(labelText: 'Address'),
                onSaved: (value) {
                  _address = value;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveForm,
                child: const Text('Save Customer'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
