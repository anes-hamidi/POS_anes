import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/invoice_detaile_scree.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';
import '../services/printer_service.dart';
import '../widgets/add_edit_customer_dialog.dart';

class CustomerProfileScreen extends StatelessWidget {
  final Customer customer;
  const CustomerProfileScreen({super.key, required this.customer});

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final printerService = context.read<PrinterService>();

    return Scaffold(
      appBar: AppBar(
        title: Text(customer.name),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () => showAddEditCustomerDialog(context, customer),
          ),
        ],
      ),
      body: FutureBuilder<List<SaleWithItemsAndCustomer>>(
        future: db.getSalesWithDetailsByCustomer(customer.id),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final sales = snapshot.data ?? [];

          // ✅ Calculate counters
          final totalInvoices = sales.length;
          final totalSpending =
              sales.fold(0.0, (sum, s) => sum + s.sale.totalAmount);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _buildCustomerInfoCard(),
              const SizedBox(height: 12),

              // ✅ Counters Row
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Total Invoices",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            "$totalInvoices",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Text(
                            "Total Spending",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          Text(
                            "${totalSpending.toStringAsFixed(2)} DA",
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 16),
              Text("Invoices", style: Theme.of(context).textTheme.titleLarge),
              const Divider(),

              if (sales.isEmpty)
                const Center(child: Text("No invoices found for this customer.")),
              ...sales.map((saleDetails) {
                final sale = saleDetails.sale;
                return Card(
                  child: ListTile(
                    title: Text("Invoice #${sale.id.substring(0, 8)}"),
                    subtitle: Text(
                      "Date: ${DateFormat.yMMMd().add_Hm().format(sale.saleDate)}\n"
                      "Total: ${sale.totalAmount.toStringAsFixed(2)} DA",
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.print, color: Colors.blue),
                      onPressed: () async {
                        try {
                          await printerService.printInvoice(saleDetails, context);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Invoice sent to printer."),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text("Error printing: $e"),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      },
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              InvoiceDetailScreen(saleDetails: saleDetails),
                        ),
                      );
                    },
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCustomerInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              customer.name,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (customer.phone != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.phone, size: 16),
                const SizedBox(width: 4),
                Text(customer.phone!)
              ]),
            ],
            if (customer.email != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.email, size: 16),
                const SizedBox(width: 4),
                Text(customer.email!)
              ]),
            ],
            if (customer.address != null) ...[
              const SizedBox(height: 4),
              Row(children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Expanded(child: Text(customer.address!))
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
