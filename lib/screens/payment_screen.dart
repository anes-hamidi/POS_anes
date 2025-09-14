import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/CustomerWithSalesAndPayments.dart';
import 'package:myapp/models/SaleWithPayments.dart';
import 'package:myapp/providers/PrinterProvide.dart';
import 'package:myapp/services/printer_service.dart';
import 'package:provider/provider.dart';
import '../data/database.dart';

class PaymentsScreen extends StatefulWidget {
  const PaymentsScreen({Key? key}) : super(key: key);

  @override
  State<PaymentsScreen> createState() => _PaymentsScreenState();
}

class _PaymentsScreenState extends State<PaymentsScreen> {
  String? selectedCustomerId;
  CustomerWithSalesAndPayments? customerData;
  bool isLoading = false;

  final currencyFormat = NumberFormat.currency(symbol: "\$");

  Future<void> _loadCustomerData(BuildContext context, String customerId) async {
    setState(() => isLoading = true);
    final db = Provider.of<AppDatabase>(context, listen: false);
    final data = await db.getCustomerWithSalesAndPayments(customerId);
    setState(() {
      customerData = data;
      isLoading = false;
    });
  }

  Future<void> _showAddPaymentDialog(BuildContext context, SaleWithPayments sale) async {
    final db = Provider.of<AppDatabase>(context, listen: false);
    final amountController = TextEditingController();
    String method = "cash";

    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text("Record Payment - Sale #${sale.sale.id}"),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Balance Due: ${currencyFormat.format(sale.balance)}",
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: "Payment Amount",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: method,
                items: const [
                  DropdownMenuItem(value: "cash", child: Text("Cash")),
                  DropdownMenuItem(value: "card", child: Text("Card")),
                  DropdownMenuItem(value: "bank", child: Text("Bank Transfer")),
                ],
                onChanged: (value) {
                  if (value != null) method = value;
                },
                decoration: const InputDecoration(
                  labelText: "Payment Method",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
    ElevatedButton.icon(
  onPressed: () async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) return;

    try {
      await db.addPayment(
        saleId: sale.sale.id,
        amount: amount,
        method: method,
      );
      

      final printerProvider = Provider.of<PrinterProvider>(context, listen: false);
      if (printerProvider.isConnected) {
        final saleWithPayments = await db.getSaleWithPayments(sale.sale.id);
        await printerProvider.printerService.printPaymentReceipt(
          context,
          payment: saleWithPayments.payments.last, // ✅ just the amount paid
          customer: sale.customer, // ✅ from SaleWithPayments
          globalBalance: null,     // not global here
          lastSaleBalance: sale.balance - amount, // ✅ updated balance
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠ Printer not connected")),
        );
      }

      Navigator.pop(ctx);
      if (selectedCustomerId != null) {
        await _loadCustomerData(context, selectedCustomerId!);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  },
  icon: const Icon(Icons.save),
  label: const Text("Save Payment"),
),
     ],
      ),
    
      
      );
    
  }

  Widget _buildTotalsCard(CustomerWithSalesAndPayments customer) {
    return Card(
      margin: const EdgeInsets.all(12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTotalItem(Icons.shopping_cart, "Spend", customer.totalSpend, Colors.blue),
            _buildTotalItem(Icons.payments, "Paid", customer.totalPayments, Colors.green),
            _buildTotalItem(Icons.account_balance_wallet, "Balance", customer.balance, Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalItem(IconData icon, String label, double amount, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 6),
        Text(currencyFormat.format(amount), style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }

  Widget _buildSaleCard(SaleWithPayments sale) {
    final statusColor = {
      "complete": Colors.green,
      "partial": Colors.orange,
      "pending": Colors.red,
    }[sale.status] ?? Colors.grey;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        title: Text("Sale #${sale.sale.id} - ${currencyFormat.format(sale.sale.totalAmount)}"),
        subtitle: Row(
          children: [
            Chip(
              label: Text(sale.status),
              backgroundColor: statusColor.withOpacity(0.2),
              labelStyle: TextStyle(color: statusColor),
              visualDensity: VisualDensity.compact,
            ),
            const SizedBox(width: 8),
            Text("Paid: ${currencyFormat.format(sale.amountPaid)}"),
          ],
        ),
        children: [
          ...sale.items.map((item) => ListTile(
                leading: IconButton(
        icon: const Icon(Icons.receipt_long),
        tooltip: "Print Receipt",
        onPressed: () async {
          final printerProvider =
              Provider.of<PrinterProvider>(context, listen: false);

          if (printerProvider.isConnected) {
            try {
              await printerProvider.printerService.printPaymentReceipt(
                context,
                payment: sale.payments.last,         // selected payment
                customer: sale.customer,          // ✅ from SaleWithPayments
                globalBalance: null,              // not a global payment
                lastSaleBalance: sale.balance,    // ✅ remaining balance after this payment
              );
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("⚠ Print failed: $e")),
              );
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("⚠ Printer not connected")),
            );
          }
        },
      ),
     
                title: Text(item.product.name),
                subtitle: Text("Qty: ${item.saleItem.quantity}"),
                trailing: Text(currencyFormat.format(item.saleItem.priceAtSale)),
              )),
          const Divider(),
          ...sale.payments.map((p) => ListTile(
                leading: const Icon(Icons.payment),
                title: Text("${p.method} - ${currencyFormat.format(p.amount)}"),
                subtitle: Text(DateFormat("yyyy-MM-dd HH:mm").format(p.paymentDate.toLocal())),
              )),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton.icon(
                onPressed: () => _showAddPaymentDialog(context, sale),
                icon: const Icon(Icons.add),
                label: const Text("Add Payment"),
              ),
            ),
          ),

        ],
      ),
    );
  }
  // In _PaymentsScreenState

Future<void> _showGlobalPaymentDialog(BuildContext context) async {
  if (selectedCustomerId == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Select a customer first")),
    );
    return;
  }

  final db = Provider.of<AppDatabase>(context, listen: false);
  final amountController = TextEditingController();
  String method = "cash";

  await showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: const Text("Record Global Payment"),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Customer: ${customerData?.customer.name ?? ''}"),
            const SizedBox(height: 10),
            TextField(
              controller: amountController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: "Amount",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: method,
              items: const [
                DropdownMenuItem(value: "cash", child: Text("Cash")),
                DropdownMenuItem(value: "card", child: Text("Card")),
                DropdownMenuItem(value: "bank", child: Text("Bank Transfer")),
              ],
              onChanged: (value) {
                if (value != null) method = value;
              },
              decoration: const InputDecoration(
                labelText: "Payment Method",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text("Cancel"),
        ),ElevatedButton(
  onPressed: () async {
    final amount = double.tryParse(amountController.text) ?? 0.0;
    if (amount <= 0) return;

    try {
      await db.addGlobalPayment(
        customerId: selectedCustomerId!,
        amount: amount,
        method: method,
      );


      final printerProvider = Provider.of<PrinterProvider>(context, listen: false);
      if (printerProvider.isConnected) {
        final payment = await db.getSaleWithPayments(selectedCustomerId!);
        await printerProvider.printerService.printPaymentReceipt(
          context,
          payment: payment.payments.last, // ✅ just the amount paid
          customer: customerData?.customer,   // ✅ global customer
          globalBalance: customerData?.balance ?? 0, // ✅ updated balance
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("⚠ Printer not connected")),
        );
      }

      Navigator.pop(ctx);
      await _loadCustomerData(context, selectedCustomerId!);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  },
  child: const Text("Save"),
),

      ],
    ),
  );
}


  @override
  Widget build(BuildContext context) {
    final db = Provider.of<AppDatabase>(context);
    final printerProvider = Provider.of<PrinterProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Customer Payments"),
      actions: [
        Icon(
          printerProvider.isConnected
              ? Icons.print
              : Icons.print_disabled,
          color: printerProvider.isConnected ? Colors.green : Colors.red,
        ),
      ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: FutureBuilder<List<Customer>>(
              future: db.select(db.customers).get(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final customers = snapshot.data!;
                return DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: "Select Customer",
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  value: selectedCustomerId,
                  onChanged: (value) {
                    setState(() => selectedCustomerId = value);
                    if (value != null) {
                      _loadCustomerData(context, value);
                    }
                  },
                  items: customers
                      .map((c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name ?? "Unnamed"),
                          ))
                      .toList(),
                );
              },
            ),
          ),
          if (isLoading) const CircularProgressIndicator(),
          if (!isLoading && customerData != null)
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  if (selectedCustomerId != null) {
                    await _loadCustomerData(context, selectedCustomerId!);
                  }
                },
                child: ListView(
                  children: [
                    _buildTotalsCard(customerData!),
                    ...customerData!.sales.map(_buildSaleCard),
                  ],
                ),
              ),
            ),
        ],
      ),
       floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _showGlobalPaymentDialog(context),
      icon: const Icon(Icons.account_balance_wallet),
      label: const Text("Global Payment"),
    ),
    );
  }
}
