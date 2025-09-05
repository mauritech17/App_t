import 'package:flutter/material.dart';

class CustomFAB extends StatelessWidget {
  final VoidCallback onCollectProduct;
  final VoidCallback onCollectCart;
  final VoidCallback onViewResults;

  const CustomFAB({
    super.key,
    required this.onCollectProduct,
    required this.onCollectCart,
    required this.onViewResults,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton.extended(
          onPressed: onViewResults,
          label: const Text('Results'),
          icon: const Icon(Icons.list),
          backgroundColor: Colors.green,
          heroTag: 'results',
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          onPressed: onCollectCart,
          label: const Text('Collect Cart'),
          icon: const Icon(Icons.shopping_cart),
          backgroundColor: Colors.orange,
          heroTag: 'cart',
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          onPressed: onCollectProduct,
          label: const Text('Collect Product'),
          icon: const Icon(Icons.shopping_bag),
          backgroundColor: Colors.blue,
          heroTag: 'product',
        ),
      ],
    );
  }
}