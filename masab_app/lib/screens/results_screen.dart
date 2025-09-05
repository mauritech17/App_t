import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import '../state/extract_store.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extractState = ref.watch(extractProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extracted Products'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            onPressed: () {
              ref.read(extractProvider.notifier).clearSnapshots();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All items cleared!')),
              );
            },
            icon: const Icon(Icons.clear_all),
            tooltip: 'Clear All',
          ),
        ],
      ),
      body: extractState.allItems.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No products extracted yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Visit a store and extract products to see them here',
                    style: TextStyle(color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: extractState.allItems.length,
              itemBuilder: (context, index) {
                final item = extractState.allItems[index];
                return Card(
                  margin: const EdgeInsets.all(8),
                  child: ListTile(
                    leading: item.imageUrl != null
                        ? Image.network(
                            item.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.image_not_supported),
                          )
                        : const Icon(Icons.shopping_bag),
                    title: Text(
                      item.name ?? 'Unnamed Product',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.price != null)
                          Text(
                            '${item.price!.currency} ${item.price!.amount}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        if (item.description != null)
                          Text(
                            item.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                    trailing: PopupMenuButton(
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'json',
                          child: Row(
                            children: [
                              Icon(Icons.code),
                              SizedBox(width: 8),
                              Text('Copy JSON'),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) {
                        if (value == 'json') {
                          Clipboard.setData(
                            ClipboardData(
                              text: const JsonEncoder.withIndent('  ')
                                  .convert(item.toJson()),
                            ),
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('JSON copied to clipboard!')),
                          );
                        }
                      },
                    ),
                  ),
                );
              },
            ),
      bottomNavigationBar: extractState.allItems.isNotEmpty
          ? Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final jsonData = {
                          'snapshots': extractState.snapshots
                              .map((s) => s.toJson())
                              .toList(),
                          'totalItems': extractState.allItems.length,
                          'extractedAt': DateTime.now().toIso8601String(),
                        };
                        
                        Clipboard.setData(
                          ClipboardData(
                            text: const JsonEncoder.withIndent('  ')
                                .convert(jsonData),
                          ),
                        );
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('All data copied to clipboard!')),
                        );
                      },
                      icon: const Icon(Icons.copy),
                      label: const Text('Copy All JSON'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        ref.read(extractProvider.notifier).addSampleItem();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Sample item added!')),
                        );
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      label: const Text('Add Sample'),
                    ),
                  ),
                ],
              ),
            )
          : null,
    );
  }
}