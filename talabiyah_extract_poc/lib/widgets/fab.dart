import 'package:flutter/material.dart';
import '../screens/results_screen.dart';

class TalabiyahFAB extends StatelessWidget {
  final VoidCallback onCollectProduct;
  final VoidCallback onCollectCart;
  final String? debugMessage;

  const TalabiyahFAB({
    super.key,
    required this.onCollectProduct,
    required this.onCollectCart,
    this.debugMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Debug overlay (optional)
        if (debugMessage != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              debugMessage!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        
        // Results button
        FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ResultsScreen(),
              ),
            );
          },
          label: const Text('Results'),
          icon: const Icon(Icons.list_alt),
          backgroundColor: Colors.green,
          heroTag: 'results',
        ),
        
        const SizedBox(height: 12),
        
        // Collect Cart button
        FloatingActionButton.extended(
          onPressed: onCollectCart,
          label: const Text('Collect Cart'),
          icon: const Icon(Icons.shopping_cart),
          backgroundColor: Colors.orange,
          heroTag: 'cart',
        ),
        
        const SizedBox(height: 12),
        
        // Collect Product button
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