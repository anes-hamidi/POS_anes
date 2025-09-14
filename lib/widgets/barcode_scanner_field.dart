import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/barcode_service.dart';
import '../l10n/app_localizations.dart';

class BarcodeScannerField extends StatelessWidget {
  final TextEditingController controller;

  const BarcodeScannerField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final barcodeService = Provider.of<BarcodeService>(context, listen: false);

    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: AppLocalizations.of(context)!.scanBarcode,
        border: const OutlineInputBorder(),
        suffixIcon: IconButton(
          icon: const Icon(Icons.qr_code_scanner),
          onPressed: () async {
            try {
              final barcode = await barcodeService.scanBarcode();
              controller.text = barcode;
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(e.toString())),
              );
            }
          },
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return AppLocalizations.of(context)!.enterValidBarcode;
        }
        return null;
      },
    );
  }
}
