// lib/services/printer_service.dart
import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import 'package:myapp/providers/settingProvider.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';

class PrinterService {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  final currencyFormatter =
      NumberFormat.currency(locale: 'en_AR', symbol: 'DA ', decimalDigits: 2);

  Future<void> printInvoice(
      SaleWithItemsAndCustomer saleDetails, BuildContext context) async {
    try {
      bool? isConnected = await _bluetooth.isConnected;

      if (kDebugMode) {
        print("🖨 PrinterService.printInvoice called");
        print("Printer connected: $isConnected");
      }

      if (isConnected != true) {
        throw Exception('No connected printer found.');
      }

      _bluetooth.printNewLine();
      _bluetooth.printCustom("******* INVOICE *********", 2, 1);

      await _printInvoiceContent(saleDetails, context);

      _bluetooth.printNewLine();
      _bluetooth.printCustom("Thank you for your business!", 1, 1);
      _bluetooth.printCustom("------------------------------", 1, 1);
      _bluetooth.printNewLine();

      _bluetooth.paperCut();
    } catch (e) {
      if (kDebugMode) {
        print("⚠ Printer Error: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Printer Error: $e")),
      );
    }
  }

  Future<void> _printInvoiceContent(
      SaleWithItemsAndCustomer saleDetails, BuildContext context) async {
    final sale = saleDetails.sale;
    final items = saleDetails.items;
    final customer = saleDetails.customer;

    // Access settings
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    // --- Header ---
    _bluetooth.printCustom(settings.businessName.toUpperCase(), 2, 1);
    if (settings.businessPhone.isNotEmpty) {
      _bluetooth.printCustom("Tel: ${settings.businessPhone}", 1, 1);
    }
    if (settings.businessAddress.isNotEmpty) {
      _bluetooth.printCustom(settings.businessAddress, 1, 1);
    }
    _bluetooth.printCustom("------------------------------", 1, 1);

    _bluetooth.printLeftRight(
      "Invoice: ${sale.id.substring(0, 8)}",
      DateFormat('yyyy-MM-dd HH:mm').format(sale.saleDate),
      1,
    );
    _bluetooth.printNewLine();

    // --- Customer ---
    if (customer != null) {
      _bluetooth.printCustom("BILL TO:", 1, 0);
      _bluetooth.printCustom(customer.name, 1, 0);
      if (customer.address?.isNotEmpty ?? false) {
        _bluetooth.printCustom("${customer.address}", 1, 0);
      }
      if (customer.phone?.isNotEmpty ?? false) {
        _bluetooth.printCustom("Tel: ${customer.phone}", 1, 0);
      }
      _bluetooth.printNewLine();
    }

    // --- Items ---
    _bluetooth.printCustom("Item            Qty   Price   Subtotal", 1, 0);
    _bluetooth.printCustom("------------------------------", 1, 1);

    int totalItems = 0;
    for (var item in items) {
      final qty = item.saleItem.quantity;
      final price = item.saleItem.priceAtSale;
      final subtotal = qty * price;
      totalItems += qty;

      // format product name
      String name = item.product.name;
 
      // fixed-width columns
      String line = name.padRight(14) +
          qty.toString().padLeft(3) +
          price.toStringAsFixed(2).padLeft(8) +
          subtotal.toStringAsFixed(2).padLeft(9);

      _bluetooth.printCustom(line, 1, 0);
    }

    _bluetooth.printCustom("------------------------------", 1, 1);

    // --- Totals ---
    _bluetooth.printLeftRight("Total Items:", totalItems.toString(), 1);
    _bluetooth.printLeftRight(
        '', sale.totalAmount.toString(), 2);
  }

}

extension PaymentReceiptPrinter on PrinterService {
  Future<void> printPaymentReceipt(
    BuildContext context, {
    required Payment payment,
    required Customer? customer,
    required double? globalBalance, // customer balance after payment
    double? lastSaleBalance,        // last sale balance (if applicable)
  }) async {
    try {
      bool? isConnected = await _bluetooth.isConnected;

      if (kDebugMode) {
        print("🖨 PrinterService.printPaymentReceipt called");
        print("Printer connected: $isConnected");
      }

      if (isConnected != true) {
        throw Exception('No connected printer found.');
      }

      final settings = Provider.of<SettingsProvider>(context, listen: false);

      _bluetooth.printNewLine();
      _bluetooth.printCustom("****** PAYMENT RECEIPT ******", 2, 1);

      // --- Business Info ---
      _bluetooth.printCustom(settings.businessName.toUpperCase(), 2, 1);
      if (settings.businessPhone.isNotEmpty) {
        _bluetooth.printCustom("Tel: ${settings.businessPhone}", 1, 1);
      }
      if (settings.businessAddress.isNotEmpty) {
        _bluetooth.printCustom(settings.businessAddress, 1, 1);
      }
      _bluetooth.printCustom("------------------------------", 1, 1);

      // --- Receipt Header ---
      _bluetooth.printLeftRight(
        "Receipt: ${payment.id}", // or generate receiptNo
        DateFormat('yyyy-MM-dd HH:mm').format(payment.paymentDate),
        1,
      );
      _bluetooth.printNewLine();

      // --- Customer ---
      if (customer != null) {
        _bluetooth.printCustom("RECEIVED FROM:", 1, 0);
        _bluetooth.printCustom(customer.name, 1, 0);
        if (customer.phone?.isNotEmpty ?? false) {
          _bluetooth.printCustom("Tel: ${customer.phone}", 1, 0);
        }
        _bluetooth.printNewLine();
      }

      // --- Payment Details ---
      _bluetooth.printCustom("PAYMENT DETAILS:", 1, 0);
      _bluetooth.printLeftRight("Method:", payment.method, 1);
      _bluetooth.printLeftRight(
        "Amount:",
        currencyFormatter.format(payment.amount),
        2,
      );
      if (lastSaleBalance != null) {
        _bluetooth.printLeftRight(
          "Last Sale Balance:",
          currencyFormatter.format(lastSaleBalance),
          1,
        );
      }
      if (globalBalance != null) {
        _bluetooth.printLeftRight(
          "Global Balance:",
          currencyFormatter.format(globalBalance),
          1,
        );
      }

      _bluetooth.printCustom("------------------------------", 1, 1);
      _bluetooth.printCustom("Thank you for your payment!", 1, 1);
      _bluetooth.printNewLine();

      _bluetooth.paperCut();
    } catch (e) {
      if (kDebugMode) {
        print("⚠ Printer Error: $e");
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Printer Error: $e")),
      );
    }
  }
}
