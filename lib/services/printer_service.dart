import 'package:blue_thermal_printer/blue_thermal_printer.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../data/database.dart';

class PrinterService {
  final BlueThermalPrinter _bluetooth = BlueThermalPrinter.instance;
  final currencyFormatter = NumberFormat.currency(locale: 'en_AR', symbol: 'DA ');
Future<void> printInvoice(SaleWithItemsAndCustomer saleDetails, BuildContext context) async {
  final sale = saleDetails.sale;
  final items = saleDetails.items;
  final customer = saleDetails.customer;

  try {
    bool? isConnected = await _bluetooth.isConnected;

    if (kDebugMode) {
      print("🖨 PrinterService.printInvoice called");
      print("Printer connected: $isConnected");
    }

    if (isConnected != true) {
      throw Exception('No connected printer found.');
    }

    await _printInvoiceContent(saleDetails, context);

    _bluetooth.printCustom("----------------------------------", 1, 1);
    _bluetooth.printCustom("   Thank you for your business!", 1, 1);
    _bluetooth.printCustom("----------------------------------", 1, 1);
    _bluetooth.paperCut();

  } catch (e) {
    if (kDebugMode) {
      // snackbar with the error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("⚠ Printer Error: $e")),
      );

      print("⚠ Printer Error: $e");
     
    }
  }
}

Future<void> _printInvoiceContent(SaleWithItemsAndCustomer saleDetails, BuildContext context) async {
  final sale = saleDetails.sale;
  final items = saleDetails.items;
  final customer = saleDetails.customer;

  // --- Header ---
  _bluetooth.printCustom("INVOICE", 3, 1);
  _bluetooth.printCustom("anesPOS", 2, 1);
  _bluetooth.printCustom("Tel: 0673336972", 1, 1);
  _bluetooth.printNewLine();

  // Invoice info
  _bluetooth.printLeftRight("Invoice #: ${sale.id.substring(0, 8)}",
      "Date: ${DateFormat('yyyy-MM-dd HH:mm').format(sale.saleDate)}", 1);
  _bluetooth.printNewLine();

  // Customer info
  if (customer != null) {
    _bluetooth.printCustom("Bill To:", 1, 0);
    _bluetooth.printCustom("${customer.name}", 1, 0);
    if (customer.address != null) _bluetooth.printCustom("${customer.address}", 1, 0);
    if (customer.phone != null) _bluetooth.printCustom("Tel: ${customer.phone}", 1, 0);
    _bluetooth.printNewLine();
  }


  // --- Items Table ---
  _bluetooth.printCustom("-------------|--------|----------|----------", 1, 1);
  _bluetooth.printCustom("Item         |  QTY   |   PRICE  |  SUBTOTAL", 1, 0);
  _bluetooth.printCustom("-------------|--------|----------|----------", 1, 1);

  int totalItems = 0;
  for (var item in items) {
    final qty = item.saleItem.quantity;
    final price = item.saleItem.priceAtSale;
    final subtotal = qty * price;
    totalItems += qty;

    // Define column widths
    const itemNameWidth = 15;
    const qtyWidth = 5;
    const priceWidth = 10;
    const subtotalWidth = 15;

    // Format item name
    String name = item.product.name.length > itemNameWidth
        ? item.product.name.substring(0, itemNameWidth)
        : item.product.name.padRight(itemNameWidth);

    // Format quantity, price, and subtotal
    String qtyStr = qty.toString().padLeft(qtyWidth);
    String priceStr = currencyFormatter.format(price).padLeft(priceWidth);
    String subtotalStr = currencyFormatter.format(subtotal).padLeft(subtotalWidth);

    // Print item details with padding
    _bluetooth.printCustom("${name.padRight(itemNameWidth)} ${qtyStr.padLeft(qtyWidth)} ${priceStr.padLeft(priceWidth)} ${subtotalStr.padLeft(subtotalWidth)}", 1, 0);
  }

  _bluetooth.printCustom("-------------------------------", 1, 1);

  // --- Totals ---
  int totalProducts = items.length;
  _bluetooth.printLeftRight("Total Items:", totalItems.toString(), 1);
  _bluetooth.printLeftRight("Total Products:", totalProducts.toString(), 1);
  _bluetooth.printLeftRight("TOTAL:", currencyFormatter.format(sale.totalAmount), 1);
}

}
