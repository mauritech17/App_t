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
        title: const Text('Talabiyah Extract PoC'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          if (extractState.lastOrigin != null)
            Chip(
              label: Text(extractState.lastOrigin!),
              backgroundColor: Colors.green.shade100,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Advanced Product & Cart Extractor',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Select a store to extract product or cart data using advanced JavaScript injection and multi-method extraction.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            
            // Store buttons
            _buildStoreButton(
              context,
              'Open Shein',
              'https://www.shein.com/',
              Icons.shopping_bag,
              Colors.black,
              'Fashion & Lifestyle',
            ),
            const SizedBox(height: 16),
            
            _buildStoreButton(
              context,
              'Open Noon',
              'https://www.noon.com/uae-en/',
              Icons.wb_sunny,
              Colors.orange,
              'Electronics & More',
            ),
            const SizedBox(height: 16),
            
            _buildStoreButton(
              context,
              'Open Amazon.ae',
              'https://www.amazon.ae/',
              Icons.shopping_cart,
              Colors.orange.shade800,
              'Everything Store',
            ),
            
            const SizedBox(height: 40),
            
            // Results and debug section
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Extracted Items: ${extractState.items.length}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          'Snapshots: ${extractState.snapshots.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                    if (extractState.debugMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          extractState.debugMessage!,
                          style: const TextStyle(
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const ResultsScreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.list_alt),
                            label: const Text('View Results'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              ref.read(extractProvider.notifier).sampleInsert();
                            },
                            icon: const Icon(Icons.add_circle_outline),
                            label: const Text('Add Sample'),
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
    );
  }

  Widget _buildStoreButton(
    BuildContext context,
    String title,
    String url,
    IconData icon,
    Color color,
    String subtitle,
  ) {
    return ElevatedButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewScreen(
              initialUrl: url,
              title: title,
            ),
          ),
        );
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Row(
        children: [
          Icon(icon, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios),
        ],
      ),
    );
  }
}