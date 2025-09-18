import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:myapp/providers/license_provider.dart';

class SubscriptionScreenA extends StatefulWidget {
  const SubscriptionScreenA({super.key});

  @override
  State<SubscriptionScreenA> createState() => _SubscriptionScreenAState();
}

class _SubscriptionScreenAState extends State<SubscriptionScreenA> {
  final _licenseController = TextEditingController();
  bool _isLoading = false;

  Future<void> _validateLicense(LicenseProvider provider) async {
    final key = _licenseController.text.trim();
    if (key.isEmpty) {
      _showMessage("⚠️ Please enter a license key.");
      return;
    }

    setState(() => _isLoading = true);
    final isValid = await provider.activateLicense(key);
    setState(() => _isLoading = false);

    if (isValid) {
      _showMessage("✅ License activated successfully!", success: true);
      Navigator.of(context).pushReplacementNamed("/dashboard");
    } else {
      _showMessage("❌ Invalid or expired license key.");
    }
  }

  void _showMessage(String msg, {bool success = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: success ? Colors.green : Colors.red,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _licenseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LicenseProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          appBar: AppBar(title: const Text("Activate Subscription")),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Enter your license key to activate your subscription:",
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),

                // License input
                TextField(
                  controller: _licenseController,
                  decoration: InputDecoration(
                    labelText: "License Key",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    prefixIcon: const Icon(Icons.vpn_key),
                  ),
                ),

                const SizedBox(height: 20),

                // Validate button
                _isLoading
                    ? const CircularProgressIndicator()
                    : ElevatedButton.icon(
                        onPressed: () => _validateLicense(provider),
                        icon: const Icon(Icons.check_circle),
                        label: const Text("Validate License"),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 50),
                        ),
                      ),

                const SizedBox(height: 20),

                // Free trial button
                if (!provider.isValid && !provider.isTrialActive)
                  TextButton(
                    onPressed: () async {
                      await provider.initialize(provider.userId ?? "");
                      Navigator.of(context).pushReplacementNamed("/dashboard");
                    },
                    child: const Text("Start Free Trial (7 days)"),
                  ),

                if (provider.isTrialActive)
                  Text(
                    "⏳ Trial active: ${provider.remainingTrialDays} days left",
                    style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
