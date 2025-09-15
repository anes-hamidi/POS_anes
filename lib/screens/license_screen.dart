
import 'package:flutter/material.dart';
import 'package:myapp/services/license_service.dart';

class LicenseScreen extends StatefulWidget {
  const LicenseScreen({super.key});

  @override
  _LicenseScreenState createState() => _LicenseScreenState();
}

class _LicenseScreenState extends State<LicenseScreen> {
  final _licenseKeyController = TextEditingController();
  final _licenseService = LicenseService();
  bool _isLoading = false;

  void _activateLicense() async {
    setState(() {
      _isLoading = true;
    });

    final success = await _licenseService.activateLicense(_licenseKeyController.text);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid license key')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Activate License'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Your free trial has expired. Please enter a license key to continue.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _licenseKeyController,
              decoration: const InputDecoration(
                labelText: 'License Key',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            _isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _activateLicense,
                    child: const Text('Activate'),
                  ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                // Implement your logic to handle license key requests, 
                // e.g., opening a web page.
              },
              child: const Text('Request a License Key'),
            ),
          ],
        ),
      ),
    );
  }
}
