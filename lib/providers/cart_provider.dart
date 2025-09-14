import 'dart:async';
import 'package:flutter/material.dart';
import 'package:myapp/models/CartItem.dart';
import '../data/database.dart';

class CartProvider extends ChangeNotifier {
  final AppDatabase _database;
  late final StreamSubscription<List<CartItem>> _cartSubscription;
  List<CartItem> _items = [];
  Customer? _selectedCustomer;
  int get totalQuantity => _items.fold(0, (sum, item) => sum + item.quantity);

  CartProvider(this._database) {
    _cartSubscription = _database.allCartItemsStream.listen((items) {
      _items = items;

      notifyListeners();
    });
  }

  List<CartItem> get items => _items;
  Customer? get selectedCustomer => _selectedCustomer;

  double get subtotal => _items.fold(
    0.0,
    (sum, item) => sum + (item.product.price * item.quantity),
  );
  //get status of the sale
  



  void selectCustomer(Customer? customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }
  

  Future<void> addToCart(String productId) async {
    for (var item in _items) {
      if (item.product.id == productId) {
        await _database.updateCartItemQuantity(productId, item.quantity + 1);
        return;
      }
    }
    await _database.addToCart(productId, 1);
  }

  Future<void> updateQuantity(String productId, int quantity) async {
    if (quantity > 0) {
      await _database.updateCartItemQuantity(productId, quantity);
    } else {
      await removeFromCart(productId);
    }
  }

  Future<void> removeFromCart(String productId) async {
    await _database.removeCartItem(productId);
  }

  Future<void> clearCart() async {
    await _database.clearCart();
    _selectedCustomer = null;
  }
// get sale status


  Future<SaleWithItemsAndCustomer?> getSaleDetails() async {
    if (_items.isEmpty) return null;

    final sale = Sale(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      customerId: _selectedCustomer?.id,
      saleDate: DateTime.now(),
      totalAmount: subtotal,
      subtotal: subtotal,
      status: 'pending',
    );

    List<SaleItemWithProduct> saleItemsWithProduct = [];
    for (var item in _items) {
      final saleItem = SaleItem(
        id: (DateTime.now().millisecondsSinceEpoch + item.product.id.hashCode),
        saleId: sale.id,
        productId: item.product.id,
        quantity: item.quantity,
        priceAtSale: item.product.price,
      );
      saleItemsWithProduct.add(
        SaleItemWithProduct(saleItem: saleItem, product: item.product),
      );
    }

    return SaleWithItemsAndCustomer(
      sale: sale,
      items: saleItemsWithProduct,
      customer: _selectedCustomer,
    );
  }

  @override
  void dispose() {
    _cartSubscription.cancel(); // ✅ cancel subscription
    super.dispose();
  }
}
