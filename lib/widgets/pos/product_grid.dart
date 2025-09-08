import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:collection/collection.dart';
import '../../data/database.dart';
import '../../providers/cart_provider.dart';



class ProductGrid extends StatelessWidget {
  final List<Product> products;
  final Map<String, num>? rankingScores; // 🆕 optional ranking map

  const ProductGrid({
    super.key,
    required this.products,
    this.rankingScores,
});

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat.currency(
      locale: 'en_AR',
      symbol: 'DA ',
    );
    final colorScheme = Theme.of(context).colorScheme;
    final screenWidth = MediaQuery.of(context).size.width;

    // --- Responsive Grid Layout ---
    final double maxCrossAxisExtent;
    if (screenWidth > 1200) {
      maxCrossAxisExtent = 240;
    } else if (screenWidth > 800) {
      maxCrossAxisExtent = 220;
    } else if (screenWidth > 500) {
      maxCrossAxisExtent = 180;
    } else {
      maxCrossAxisExtent = 160;
    }

    final double spacing = (screenWidth > 800) ? 16.0 : 12.0;
    final double padding = (screenWidth > 800) ? 24.0 : 16.0;

    return GridView.builder(
      padding: EdgeInsets.all(padding),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: maxCrossAxisExtent,
        childAspectRatio: 0.75,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: products.length,
      itemBuilder: (ctx, i) {
        final product = products[i];
final rankingScore = rankingScores?[product.id];
final rankIndex = rankingScores != null
    ? rankingScores!.keys.toList().indexOf(product.id) + 1
    : null;
        // ✅ Use Selector per item — rebuild only this tile when qty changes
        return Selector<CartProvider, int>(
          selector: (_, cart) {
            final cartItem = cart.items.firstWhereOrNull(
              (item) => item.product.id == product.id,
            );
            return cartItem?.quantity ?? 0;
          },
          builder: (context, qty, child) {
            final availableStock = (product.quantity - qty).clamp(
              0,
              product.quantity,
            );

            return GestureDetector(
              onTap: () =>
                  context.read<CartProvider>().addToCart(product.id),
              child: KeyedSubtree(
                key: ValueKey('${product.id}-qty-$qty'),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: qty > 0
                          ? Colors.green
                          : Colors.grey.withOpacity(0.3),
                      width: qty > 0 ? 3 : 1,
                    ),
                    boxShadow: [
                      if (qty > 0)
                        BoxShadow(
                          color: Colors.green.withOpacity(0.35),
                          blurRadius: 12,
                          spreadRadius: 2,
                          offset: const Offset(0, 1),
                        )
                      else
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          spreadRadius: 1,
                          offset: const Offset(0, 1),
                        ),
                    ],
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: Stack(
                    children: [
                      if (rankIndex != null)
  Positioned(
    top: 6,
    left: 6,
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: rankIndex == 1
            ? Colors.amber[700]
            : rankIndex <= 3
                ? Colors.orange[600]
                : Colors.blueGrey.withOpacity(0.8),
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.star,
            size: 14,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            'Top $rankIndex',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    ),
  ),

                      // --- Product Image with Shimmer Effect ---
                      _ProductImageWithShimmer(
                        product: product,
                        colorScheme: colorScheme,
                      ),

                      // --- In Cart Badge ---
                      Positioned(
                        top: 8,
                        right: 8,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 400),
                          transitionBuilder: (child, anim) {
                            final scaleAnim =
                                Tween<double>(begin: 0.5, end: 1.0).animate(
                              CurvedAnimation(
                                parent: anim,
                                curve: Curves.elasticOut,
                              ),
                            );
                            return ScaleTransition(
                              scale: scaleAnim,
                              child: FadeTransition(
                                opacity: anim,
                                child: child,
                              ),
                            );
                          },
                          child: qty > 0
                              ? QuantityBadge(
                                  quantity: qty,
                                  onQuantityChanged: (newQty) {
                                    context
                                        .read<CartProvider>()
                                        .updateQuantity(product.id, newQty);
                                  },
                                )
                              : const SizedBox.shrink(),
                        ),
                      ),

                      // --- Gradient + Name + Price + Qty ---
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                Colors.black.withOpacity(0.9),
                                Colors.black.withOpacity(0.6),
                                Colors.black.withOpacity(0.0),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product.name,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withOpacity(0.5),
                                      blurRadius: 4,
                                      offset: Offset(1, 1),
                                    ),
                                  ],
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              _StockIndicator(
                                availableStock: availableStock,
                                initialStock: product.quantity,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    currencyFormatter.format(product.price),
                                    style: TextStyle(
                                      color: Colors.amber[300],
                                      fontWeight: FontWeight.w700,
                                      fontSize: 15,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.5),
                                          blurRadius: 4,
                                          offset: Offset(1, 1),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

class _ProductImageWithShimmer extends StatefulWidget {
  final Product product;
  final ColorScheme colorScheme;

  const _ProductImageWithShimmer({
    required this.product,
    required this.colorScheme,
  });

  @override
  __ProductImageWithShimmerState createState() =>
      __ProductImageWithShimmerState();
}

class __ProductImageWithShimmerState extends State<_ProductImageWithShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _imageLoaded = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(
          child: widget.product.imageUrl != null
              ? Image.file(
                  File(widget.product.imageUrl!),
                  fit: BoxFit.cover,
                  cacheWidth: 512,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFallbackIcon(widget.colorScheme),
                  frameBuilder:
                      (context, child, frame, wasSynchronouslyLoaded) {
                        if (frame == null && !_imageLoaded) {
                          return _ShimmerPlaceholder(animation: _controller);
                        } else if (!_imageLoaded) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            setState(() {
                              _imageLoaded = true;
                            });
                          });
                        }
                        return AnimatedOpacity(
                          opacity: _imageLoaded ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          child: child,
                        );
                      },
                )
              : _buildFallbackIcon(widget.colorScheme),
        ),
        if (!_imageLoaded)
          Positioned.fill(child: _ShimmerPlaceholder(animation: _controller)),
      ],
    );
  }

  Widget _buildFallbackIcon(ColorScheme colorScheme) {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        color: colorScheme.onSurface.withOpacity(0.4),
        size: 48,
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  final Animation<double> animation;

  const _ShimmerPlaceholder({required this.animation});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.grey[300]!, Colors.grey[100]!, Colors.grey[300]!],
              stops: [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

class _StockIndicator extends StatelessWidget {
  final int availableStock;
  final int initialStock;

  const _StockIndicator({
    required this.availableStock,
    required this.initialStock,
  });

  @override
  Widget build(BuildContext context) {
    final isLowStock =
        availableStock <= initialStock * 0.2 && availableStock > 0;

    return TweenAnimationBuilder<int>(
      key: ValueKey('stock-$availableStock'),
      tween: IntTween(begin: initialStock, end: availableStock),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeOut,
      builder: (context, value, child) {
        return Row(
          children: [
            Icon(
              Icons.inventory,
              size: 14,
              color: isLowStock ? Colors.orange : Colors.white70,
            ),
            SizedBox(width: 4),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 300),
              style: TextStyle(
                color: isLowStock ? Colors.orange : Colors.white70,
                fontSize: 12,
                fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text('Stock: $value'),
            ),
            if (isLowStock)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: AnimatedScale(
                  scale: 1.0,
                  duration: Duration(milliseconds: 1000),
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 12,
                    color: Colors.orange,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

class QuantityBadge extends StatefulWidget {
  final int quantity;
  final ValueChanged<int>
  onQuantityChanged; // 🔑 Callback to update qty in provider

  const QuantityBadge({
    required this.quantity,
    required this.onQuantityChanged,
    Key? key,
  }) : super(key: key);

  @override
  State<QuantityBadge> createState() => _QuantityBadgeState();
}

class _QuantityBadgeState extends State<QuantityBadge> {
  bool _isEditing = false;
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.quantity.toString());
  }

  @override
  void didUpdateWidget(covariant QuantityBadge oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity) {
      _controller.text = widget.quantity.toString(); // sync with provider
    }
  }

  void _submitQuantity() {
    final text = _controller.text.trim();
    final newQty = int.tryParse(text) ?? widget.quantity;
    widget.onQuantityChanged(newQty);
    setState(() => _isEditing = false);
  }
  

  @override
  Widget build(BuildContext context) {

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 400),
      transitionBuilder: (child, animation) {
        final scale = Tween<double>(
          begin: 0.5,
          end: 1.0,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.elasticOut));
        return ScaleTransition(scale: scale, child: child);
      },
      child: widget.quantity > 0
          ? GestureDetector(
              key: ValueKey('qty-${widget.quantity}-${_isEditing}'),
              onTap: () => setState(() => _isEditing = true),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.redAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: _isEditing
                    ? IntrinsicWidth(
                        child: TextField(
                          controller: _controller,
                          autofocus: true,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                          decoration: const InputDecoration(
                            isDense: true,
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onSubmitted: (_) => _submitQuantity(),
                          onTapOutside: (_) => _submitQuantity(),
                        ),
                      )
                    : Text(
                        '${widget.quantity}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
              ),
            )
          : const SizedBox.shrink(key: ValueKey('empty-qty')),
    );
  }
}
