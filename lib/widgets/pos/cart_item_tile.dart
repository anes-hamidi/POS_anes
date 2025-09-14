import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:myapp/models/CartItem.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../data/database.dart';

class CartItemTile extends StatelessWidget {
  final CartItem item;

  const CartItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);
    final currencyFormatter = NumberFormat.currency(locale: 'en_AR', symbol: 'DA ');
    final colorScheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      elevation: 2,
      shadowColor: Colors.black.withOpacity(0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: LayoutBuilder(builder: (context, constraints) {
        // --- Responsive Calculations ---
        final bool isNarrow = constraints.maxWidth < 250;
        final double titleFontSize = isNarrow ? 13 : 15;
        final double priceFontSize = isNarrow ? 12 : 14;
        final double iconSize = isNarrow ? 18 : 22;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // --- Product Info ---
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      item.product.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontSize: titleFontSize,
                            fontWeight: FontWeight.w600,
                          ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currencyFormatter.format(item.product.price * item.quantity),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: priceFontSize,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // --- Quantity Controls ---
              _buildQuantityControls(context, cartProvider, iconSize, isNarrow),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildQuantityControls(
    BuildContext context,
    CartProvider cartProvider,
    double iconSize,
    bool isNarrow,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(Icons.remove_circle_outline, size: iconSize),
          onPressed: () => cartProvider.updateQuantity(item.product.id, item.quantity - 1),
          tooltip: 'Decrease Quantity',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: isNarrow ? 4 : 8),
          child: Text('${item.quantity}', style: Theme.of(context).textTheme.titleMedium),
        ),
        IconButton(
          icon: Icon(Icons.add_circle_outline, size: iconSize),
          onPressed: () => cartProvider.updateQuantity(item.product.id, item.quantity + 1),
          tooltip: 'Increase Quantity',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: isNarrow ? 2 : 8),
        IconButton(
          icon: Icon(Icons.delete_forever, size: iconSize, color: Colors.redAccent),
          onPressed: () => cartProvider.removeFromCart(item.product.id),
          tooltip: 'Remove from Cart',
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    );
  }
}
