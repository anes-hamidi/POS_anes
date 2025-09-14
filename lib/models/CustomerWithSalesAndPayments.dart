import 'package:myapp/data/database.dart';
import 'package:myapp/models/SaleWithPayments.dart';

class CustomerWithSalesAndPayments {
  final Customer customer;
  final List<SaleWithPayments> sales;
  final double totalSpend;
  final double totalPayments;
  final double advanceBalance;

  CustomerWithSalesAndPayments({
    required this.customer,
    required this.sales,
    required this.totalSpend,
    required this.totalPayments,
    required this.advanceBalance,
  });

  double get balance => totalSpend - totalPayments;

}