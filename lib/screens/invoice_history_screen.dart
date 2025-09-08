import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/screens/invoice_detaile_scree.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';
import '../services/printer_service.dart';

class InvoiceHistoryScreen extends StatefulWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  State<InvoiceHistoryScreen> createState() => _InvoiceHistoryScreenState();
}

class _InvoiceHistoryScreenState extends State<InvoiceHistoryScreen> {
  String searchQuery = '';
  DateTime selectedDate = DateTime.now(); // ✅ Default to today

  @override
  Widget build(BuildContext context) {
    final db = context.read<AppDatabase>();
    final printerService = context.read<PrinterService>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Invoice History"),
      ),
      body: Column(
        children: [
          _buildSearchAndFilterBar(),
          Expanded(
            child: FutureBuilder<List<SaleWithItemsAndCustomer>>(
              future: db.getAllSalesWithDetails(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text("Error: ${snapshot.error}"));
                }

                final sales = snapshot.data ?? [];

                // ✅ Filter by selected date
                final filteredByDate = sales.where((sale) {
                  final saleDate = DateTime(
                    sale.sale.saleDate.year,
                    sale.sale.saleDate.month,
                    sale.sale.saleDate.day,
                  );
                  final selected = DateTime(
                    selectedDate.year,
                    selectedDate.month,
                    selectedDate.day,
                  );
                  return saleDate == selected;
                }).toList();

                // ✅ Filter by search query
                final filteredSales = filteredByDate.where((sale) {
                  final query = searchQuery.toLowerCase();
                  return sale.sale.id.toLowerCase().contains(query) ||
                      (sale.customer?.name.toLowerCase().contains(query) ?? false);
                }).toList();

                if (filteredSales.isEmpty) {
                  return const Center(child: Text("No invoices found for selected filters."));
                }

                return ListView.separated(
                  itemCount: filteredSales.length,
                  separatorBuilder: (_, __) => const Divider(),
                  itemBuilder: (context, index) {
                    final saleDetails = filteredSales[index];
                    final sale = saleDetails.sale;

                    return ListTile(
                      title: Text("Invoice #${sale.id.substring(0, 8)}"),
                      subtitle: Text(
                        "Date: ${DateFormat.yMMMd().add_Hm().format(sale.saleDate)}\n"
                        "Total: ${sale.totalAmount.toStringAsFixed(2)} DA",
                      ),
                      isThreeLine: true,
                      trailing: IconButton(
                        icon: const Icon(Icons.print, color: Colors.blue),
                        tooltip: 'Print Invoice',
                        onPressed: () async {
                          try {
                            await printerService.printInvoice(saleDetails,context);
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
                                  content: Text("Error printing invoice: $e"),
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
                            builder: (_) => InvoiceDetailScreen(saleDetails: saleDetails),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search by invoice ID or customer',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                isDense: true,
              ),
              onChanged: (value) {
                setState(() => searchQuery = value);
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Filter by date',
            onPressed: () async {
              final pickedDate = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (pickedDate != null) {
                setState(() => selectedDate = pickedDate);
              }
            },
          ),
        ],
      ),
    );
  }
}
