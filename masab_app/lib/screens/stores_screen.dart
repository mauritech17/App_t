import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../state/extract_store.dart';
import 'results_screen.dart';
import 'webview_screen.dart';

class StoresScreen extends ConsumerWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extractState = ref.watch(extractProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Masab App - Product Extractor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select a store to extract product data:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            _buildStoreButton(
              context,
              'Open Shein',
              'https://shein.com',
              Icons.shopping_bag,
              Colors.black,
            ),
            const SizedBox(height: 16),
            _buildStoreButton(
              context,
              'Open Noon',
              'https://noon.com',
              Icons.wb_sunny,
              Colors.orange,
            ),
            const SizedBox(height: 16),
            _buildStoreButton(
              context,
              'Open Amazon.ae',
              'https://amazon.ae',
              Icons.shopping_cart,
              Colors.orange.shade800,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ResultsScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.list),
              label: Text('View Results (${extractState.allItems.length} items)'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(extractProvider.notifier).addSampleItem();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Sample item added!')),
                );
              },
              icon: const Icon(Icons.add_circle_outline),
              label: const Text('Add Sample Item'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStoreButton(
    BuildContext context,
    String title,
    String url,
    IconData icon,
    Color color,
  ) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              url: url,
              title: title,
            ),
          ),
        );
      },
      icon: Icon(icon),
      label: Text(title),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
      ),
    );
  }
}