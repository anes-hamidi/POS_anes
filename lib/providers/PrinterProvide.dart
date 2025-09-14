// lib/providers/printer_provider.dart
import 'package:flutter/foundation.dart';
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database.dart';
import '../services/printer_service.dart';

enum PrinterConnectionState { disconnected, connecting, connected }

class PrinterProvider extends ChangeNotifier {
  final PrinterService printerService;
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;

  BluetoothDevice? _connectedDevice;
  PrinterConnectionState _state = PrinterConnectionState.disconnected;

  static const _prefKey = 'connected_printer_mac';

  PrinterProvider({required this.printerService}) {
    _listenToConnectionChanges();
    _tryReconnect();
  }

  BluetoothDevice? get connectedDevice => _connectedDevice;
  PrinterConnectionState get state => _state;

  bool get isConnected => _state == PrinterConnectionState.connected;
  bool get isConnecting => _state == PrinterConnectionState.connecting;

  void _setState(PrinterConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      notifyListeners();
    }
  }

  

  void _listenToConnectionChanges() {
    _bluetooth.onStateChanged().listen((val) async {
      if (kDebugMode) print("🔄 Printer state changed: $val");

      switch (val) {
        case BlueThermalPrinter.CONNECTED:
          _setState(PrinterConnectionState.connected);
          break;
        case BlueThermalPrinter.DISCONNECTED:
          _connectedDevice = null;
          _setState(PrinterConnectionState.disconnected);
          break;
        case BlueThermalPrinter.DISCONNECT_REQUESTED:
          _setState(PrinterConnectionState.connecting);
          break;
        default:
          break;
      }
    });
  }

  Future<void> _tryReconnect() async {
    _setState(PrinterConnectionState.connecting);

    try {
      final prefs = await SharedPreferences.getInstance();
      final savedMac = prefs.getString(_prefKey);
      if (savedMac == null) return;

      final devices = await getBondedDevices();
      final device = devices.firstWhere(
        (d) => d.address == savedMac,
        orElse: () => throw Exception('Saved printer not found'),
      );

      await connectTo(device, save: false);
    } catch (e) {
      if (kDebugMode) print('Auto-reconnect failed: $e');
    } finally {
      if (!isConnected) _setState(PrinterConnectionState.disconnected);
    }
  }

  Future<void> connectTo(BluetoothDevice device, {bool save = true}) async {
    _setState(PrinterConnectionState.connecting);
    try {
      await _bluetooth.connect(device);
      _connectedDevice = device;

      if (save) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefKey, device.address ?? '');
      }

    } finally {
      if (await _bluetooth.isConnected == true) {
        _setState(PrinterConnectionState.connected);
      } else {
        _setState(PrinterConnectionState.disconnected);
      }
    }
  }

  Future<void> disconnect() async {
    try {
      await _bluetooth.disconnect();
    } catch (_) {}
    _connectedDevice = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);

    _setState(PrinterConnectionState.disconnected);
  }

  Future<List<BluetoothDevice>> getBondedDevices() async {
    return await _bluetooth.getBondedDevices();
  }

  Future<void> printInvoice(SaleWithItemsAndCustomer saleDetails, context) async {
    if (!isConnected) throw Exception('No printer connected.');
    await printerService.printInvoice(saleDetails, context);
  }
}
