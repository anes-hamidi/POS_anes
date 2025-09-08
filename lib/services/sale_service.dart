import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/database.dart';
import '../providers/cart_provider.dart';

import 'pdf_service.dart';
import 'printer_service.dart';

class SaleService {
  final AppDatabase db;
  final PdfService pdfService;
  final PrinterService printerService;
  final Uuid _uuid = const Uuid();

  SaleService({
    required this.db,
    required this.pdfService,
    required this.printerService,
  });

  /// 🔢 Minimum quantity before alert
  static const int lowStockThreshold = 5;

  Future<void> createAndSaveSale(CartProvider cart, BuildContext context) async {
    final lowStockProducts = <String>[]; // collect names for alert
    final saleId = _uuid.v4();
    final saleDate = DateTime.now();

    final sale = SalesCompanion(
      id: Value(saleId),
      customerId: Value(cart.selectedCustomer?.id),
      saleDate: Value(saleDate),
      subtotal: Value(cart.subtotal),
      totalAmount: Value(cart.subtotal),
    );

    await db.into(db.sales).insert(sale);

    for (var cartItem in cart.items) {
      await db.into(db.saleItems).insert(SaleItemsCompanion(
        saleId: Value(saleId),
        productId: Value(cartItem.product.id),
        quantity: Value(cartItem.quantity),
        priceAtSale: Value(cartItem.product.price),
      ));

      final lowStock = await _decrementProductStock(cartItem.product.id, cartItem.quantity);
      if (lowStock != null) lowStockProducts.add(lowStock);
    }

    _showLowStockAlert(context, lowStockProducts);
  }

  Future<void> createAndPrintInvoice(CartProvider cart, BuildContext context) async {
  final lowStockProducts = <String>[];
  final saleId = _uuid.v4();
  final saleDate = DateTime.now();

  final sale = SalesCompanion(
    id: Value(saleId),
    customerId: Value(cart.selectedCustomer?.id),
    saleDate: Value(saleDate),
    subtotal: Value(cart.subtotal),
    totalAmount: Value(cart.subtotal),
  );

  await db.into(db.sales).insert(sale);

  for (var cartItem in cart.items) {
    await db.into(db.saleItems).insert(SaleItemsCompanion(
      saleId: Value(saleId),
      productId: Value(cartItem.product.id),
      quantity: Value(cartItem.quantity),
      priceAtSale: Value(cartItem.product.price),
    ));
    final lowStock = await _decrementProductStock(cartItem.product.id, cartItem.quantity);
    if (lowStock != null) lowStockProducts.add(lowStock);
  }

  final saleDetails = await db.getSaleWithDetails(saleId);

  try {
    final pdfData = await pdfService.generatePdf(saleDetails);
    await printerService.printInvoice(saleDetails, context);

    if (kDebugMode) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("✅ Invoice printed (or simulated in debug mode)")),
      );
    }
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("⚠ Could not print invoice: $e")),
    );
  }

  _showLowStockAlert(context, lowStockProducts);
}

  /// 🔽 Decrement stock, return product name if it's low
  Future<String?> _decrementProductStock(String productId, int qtySold) async {
    final product = await (db.select(db.products)..where((tbl) => tbl.id.equals(productId))).getSingleOrNull();

    if (product != null) {
      final newQty = (product.quantity ?? 0) - qtySold;
      await (db.update(db.products)..where((tbl) => tbl.id.equals(productId))).write(
        ProductsCompanion(quantity: Value(newQty < 0 ? 0 : newQty)),
      );

      if (newQty <= lowStockThreshold) {
        return "${product.name} (Left: ${newQty < 0 ? 0 : newQty})";
      }
    }
    return null;
  }

  /// 🔔 Show alert with all low-stock products
  void _showLowStockAlert(BuildContext context, List<String> lowStockProducts) {
    if (lowStockProducts.isEmpty || !context.mounted) return;

    final message = lowStockProducts.join("\n");

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("⚠ Low Stock Warning"),
        content: Text(message, style: const TextStyle(fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
