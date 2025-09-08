import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
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
      appBar: AppBar(title: const Text("Invoice Details")),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            _buildHeader(sale),
            const SizedBox(height: 12),
            if (customer != null) _buildCustomerInfo(customer),
            const SizedBox(height: 20),
            _buildItemsTable(items),
            const SizedBox(height: 20),
            _buildTotals(sale.totalAmount, totalItems, items.length),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(Sale sale) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("INVOICE", style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        Text("Invoice #: ${sale.id.substring(0, 8)}"),
        Text("Date: ${DateFormat.yMMMd().add_Hm().format(sale.saleDate)}"),
        const Divider(),
      ],
    );
  }

  Widget _buildCustomerInfo(Customer customer) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Billed To:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        Text(customer.name),
        if (customer.phone != null) Text("Phone: ${customer.phone}"),
        if (customer.email != null) Text("Email: ${customer.email}"),
        const Divider(),
      ],
    );
  }

  Widget _buildItemsTable(List<SaleItemWithProduct> items) {
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
          children: const [
            Padding(padding: EdgeInsets.all(6), child: Text("Item", style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(6), child: Text("Qty", style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(6), child: Text("Price", style: TextStyle(fontWeight: FontWeight.bold))),
            Padding(padding: EdgeInsets.all(6), child: Text("Subtotal", style: TextStyle(fontWeight: FontWeight.bold))),
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

  Widget _buildTotals(double totalAmount, int totalItems, int totalProducts) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text("Total Items: $totalItems"),
        Text("Products: $totalProducts"),
        const Divider(),
        Text("TOTAL: ${totalAmount.toStringAsFixed(2)} DA",
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
      ],
    );
  }
}
