import 'package:flutter/material.dart';
import 'package:myapp/providers/PrinterProvide.dart';
import 'package:provider/provider.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';

class PrinterSelectionDialog extends StatefulWidget {
  const PrinterSelectionDialog({super.key});

  @override
  State<PrinterSelectionDialog> createState() => _PrinterSelectionDialogState();
}

class _PrinterSelectionDialogState extends State<PrinterSelectionDialog> {
  BluetoothDevice? _selectedDevice;
  List<BluetoothDevice> _devices = [];

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  Future<void> _loadDevices() async {
    final provider = context.read<PrinterProvider>();
    _devices = await provider.getBondedDevices();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PrinterProvider>();

    return AlertDialog(
      title: const Text('Select Printer'),
      content: provider.isConnecting
          ? const Center(child: CircularProgressIndicator())
          : DropdownButton<BluetoothDevice>(
              hint: const Text('Choose Printer'),
              value: _selectedDevice,
              items: _devices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Text(device.name ?? ''),
                );
              }).toList(),
              onChanged: (device) {
                setState(() => _selectedDevice = device);
              },
            ),
      actions: [
        TextButton(
          onPressed: () async {
            if (_selectedDevice != null) {
              await provider.connectTo(_selectedDevice!);
              Navigator.pop(context);
            }
          },
          child: const Text('Connect'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}
