
import 'package:myapp/data/database.dart';

import 'package:myapp/data/database.dart';

class SaleWithPayments extends SaleWithItemsAndCustomer {
  final List<Payment> payments;
  double amountPaid;
  double balance;
  String status;

  SaleWithPayments({
    required super.sale,
    required super.customer,
    required super.items,
    required this.payments,
  })  : amountPaid = 0,
        balance = 0,
        status = 'pending' {
    // calculate derived values here
    final paid = payments.fold<double>(0, (sum, p) => sum + (p.amount ?? 0));
    amountPaid = paid;
    balance = sale.totalAmount - paid;

    if (paid == 0) {
      status = 'pending';
    } else if (paid < sale.totalAmount) {
      status = 'partial';
    } else if (paid == sale.totalAmount) {
      status = 'complete';
    } else {
      status = 'error';
    }
  }
}