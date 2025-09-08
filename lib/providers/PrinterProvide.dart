// lib/providers/printer_provider.dart
import 'package:flutter/foundation.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import '../services/printer_service.dart';
class PrinterProvider extends ChangeNotifier {
  final PrinterService printerService;
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  BluetoothDevice? _connectedDevice;
  bool _isConnecting = false;

  static const _prefKey = 'connected_printer_mac';

  PrinterProvider({required this.printerService}) {
    _tryReconnect();
  }

  BluetoothDevice? get connectedDevice => _connectedDevice;
  bool get isConnected => _connectedDevice != null;
  bool get isConnecting => _isConnecting;

  Future<void> _tryReconnect() async {
    _isConnecting = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMac = prefs.getString(_prefKey);
      if (savedMac == null) return;

      final devices = await getBondedDevices();
      final device = devices.firstWhere(
        (d) => d.address == savedMac,
        orElse: () => throw Exception('Saved printer not found'),
      );

      await connectTo(device, save: false); // silent reconnect
    } catch (e) {
      if (kDebugMode) print('Auto-reconnect failed: $e');
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> connectTo(BluetoothDevice device, {bool save = true}) async {
    _isConnecting = true;
    notifyListeners();

    try {
      await _bluetooth.connect(device);
      _connectedDevice = device;

      if (save) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, device.address ?? '');
      }
    } finally {
      _isConnecting = false;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
    } catch (_) {}
    _connectedDevice = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);

    notifyListeners();
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

  Future<void> printInvoice(SaleWithItemsAndCustomer saleDetails, BuildContext context) async {
    if (!isConnected) throw Exception('No printer connected.');
    await printerService.printInvoice(saleDetails, context);
  }
}
