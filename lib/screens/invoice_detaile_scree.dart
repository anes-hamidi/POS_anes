import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/l10n/app_localizations.dart';
import '../data/database.dart';

class InvoiceDetailScreen extends StatelessWidget {
  final SaleWithItemsAndCustomer saleDetails;

  const InvoiceDetailScreen({super.key, required this.saleDetails});

  @override
  Widget build(BuildContext context) {
    final sale = saleDetails.sale;
    final customer = saleDetails.customer;
    final items = saleDetails.items;

    final totalItems = items.fold<int>(0, (sum, item) => sum + item.saleItem.quantity);

    return Scaffold(
      appBar: AppBar(title:Text(AppLocalizations.of(context)!.invoice),
),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _buildHeader(sale, context),
            const SizedBox(height: 12),
            if (customer != null) _buildCustomerInfo(customer, context),
            const SizedBox(height: 20),
            _buildItemsTable(items, context),
            const SizedBox(height: 20),
            _buildTotals(sale.totalAmount, totalItems, items.length, context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Sale sale, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.invoice,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("${AppLocalizations.of(context)!.invoice} #: ${sale.id.substring(0, 8)}"),
        Text(AppLocalizations.of(context)!.invoiceDate(DateFormat.yMMMd().format(sale.saleDate))),
        const Divider(),
      ],
    );
  }

  Widget _buildCustomerInfo(Customer customer, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(AppLocalizations.of(context)!.billedTo, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(customer.name),
        if (customer.phone != null) Text("${AppLocalizations.of(context)!.cphone}: ${customer.phone}"),
        if (customer.email != null) Text("${AppLocalizations.of(context)!.cemail}: ${customer.email}"),
        const Divider(),
      ],
    );
  }

  Widget _buildItemsTable(List<SaleItemWithProduct> items, BuildContext context) {
    return Table(
      border: TableBorder.all(color: Colors.grey.shade300),
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(1),
        2: FlexColumnWidth(1),
        3: FlexColumnWidth(1),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.grey.shade200),
          children: [
            Padding(padding: EdgeInsets.all(6), child: Text(AppLocalizations.of(context)!.item, style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(6), child: Text(AppLocalizations.of(context)!.qty, style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(6), child: Text(AppLocalizations.of(context)!.price, style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(6), child: Text(AppLocalizations.of(context)!.subtotal, style: TextStyle(fontWeight: FontWeight.bold))),
          ],
        ),
        for (var item in items)
          TableRow(
            children: [
              Padding(padding: const EdgeInsets.all(6), child: Text(item.product.name)),
              Padding(padding: const EdgeInsets.all(6), child: Text("${item.saleItem.quantity}")),
              Padding(padding: const EdgeInsets.all(6), child: Text("${item.saleItem.priceAtSale.toStringAsFixed(2)} DA")),
              Padding(padding: const EdgeInsets.all(6), child: Text("${(item.saleItem.priceAtSale * item.saleItem.quantity).toStringAsFixed(2)} DA")),
            ],
          ),
      ],
    );
  }

  Widget _buildTotals(double totalAmount, int totalItems, int totalProducts, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("${AppLocalizations.of(context)!.totalItems}: $totalItems"),
        Text("${AppLocalizations.of(context)!.products}: $totalProducts"),
        const Divider(),
        Text("${AppLocalizations.of(context)!.totalAmount}: ${totalAmount.toStringAsFixed(2)} DA",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }
}
