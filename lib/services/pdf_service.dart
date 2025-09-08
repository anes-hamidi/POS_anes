import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:intl/intl.dart';
import '../data/database.dart';

class PdfService {
  final currencyFormatter = NumberFormat.currency(locale: 'en_AR', symbol: 'DA ');

  Future<Uint8List> generatePdf(SaleWithItemsAndCustomer saleDetails) async {
    final pdf = pw.Document();
    final sale = saleDetails.sale;
    final customer = saleDetails.customer;
    final items = saleDetails.items;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return [
            _buildHeader(sale),
            pw.SizedBox(height: 20),
            if (customer != null) _buildCustomerInfo(customer),
            pw.SizedBox(height: 30),
            pw.Text('Invoice Details', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
            pw.Divider(),
            _buildInvoiceTable(items),
            pw.Divider(),
            _buildTotals(sale),
            pw.SizedBox(height: 50),
            _buildFooter(),
          ];
        },
      ),
    );

    return pdf.save();
  }

  pw.Widget _buildHeader(Sale sale) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text('INVOICE', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold, color: PdfColors.blueGrey800)),
            pw.Text('Your Business Name', style: pw.TextStyle(fontSize: 16)),
            pw.Text('123 Business Rd, Business City'),
          ]
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('Invoice #${sale.id.toString().substring(0, 8)}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
            pw.Text('Date: ${DateFormat.yMMMd().format(sale.saleDate)}'),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCustomerInfo(Customer customer) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text('Bill To:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),
        pw.Text(customer.name),
        pw.Text(customer.email ?? ''),
        pw.Text(customer.phone ?? ''),
      ],
    );
  }

  pw.Widget _buildInvoiceTable(List<SaleItemWithProduct> items) {
    final headers = ['Item Description', 'Price', 'Qty', 'Total'];

    final data = items.map((item) {
      final saleItem = item.saleItem;
      final product = item.product;
      final total = saleItem.priceAtSale * saleItem.quantity;
      return [
        product.name,
        currencyFormatter.format(saleItem.priceAtSale),
        saleItem.quantity.toString(),
        currencyFormatter.format(total),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      border: null,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
      headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
      cellHeight: 30,
      cellAlignments: {
        0: pw.Alignment.centerLeft,
        1: pw.Alignment.centerRight,
        2: pw.Alignment.center,
        3: pw.Alignment.centerRight,
      },
    );
  }

  pw.Widget _buildTotals(Sale sale) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Subtotal: ', style: const pw.TextStyle(fontSize: 14)),
              pw.Text(currencyFormatter.format(sale.subtotal), style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14)),
            ]
          ),
          pw.SizedBox(height: 5),
          
          pw.Divider(),
           pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.end,
            children: [
              pw.Text('Total: ', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Text(currencyFormatter.format(sale.totalAmount), style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold, color: PdfColors.blue800)),
            ]
          ),
        ],
      ),
    );
  }

  pw.Widget _buildFooter() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 10),
        pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 16, fontStyle: pw.FontStyle.italic)),
        pw.SizedBox(height: 5),
        pw.Text('Your Business Name | contact@yourbusiness.com | +1 234 567 890'),
      ]
    );
  }
}
