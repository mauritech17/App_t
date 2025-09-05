import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../state/extract_store.dart';
import '../state/models.dart';

class ResultsScreen extends ConsumerWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final extractState = ref.watch(extractProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extraction Results'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'copy_json',
                child: Row(
                  children: [
                    Icon(Icons.copy),
                    SizedBox(width: 8),
                    Text('Copy JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save_json',
                child: Row(
                  children: [
                    Icon(Icons.save),
                    SizedBox(width: 8),
                    Text('Save JSON'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear',
                child: Row(
                  children: [
                    Icon(Icons.clear_all),
                    SizedBox(width: 8),
                    Text('Clear All'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'sample',
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline),
                    SizedBox(width: 8),
                    Text('Add Sample'),
                  ],
                ),
              ),
            ],
            onSelected: (value) => _handleMenuAction(value, ref),
          ),
        ],
      ),
      body: extractState.items.isEmpty
          ? _buildEmptyState(ref)
          : _buildItemsList(extractState),
      bottomNavigationBar: extractState.items.isNotEmpty
          ? _buildBottomStats(extractState)
          : null,
    );
  }

  Widget _buildEmptyState(WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.inbox,
            size: 80,
            color: Colors.grey,
          ),
          const SizedBox(height: 16),
          const Text(
            'No extracted items yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Visit a store, navigate to a product or cart page,\nand use the extraction tools to collect data.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(extractProvider.notifier).sampleInsert();
            },
            icon: const Icon(Icons.add_circle_outline),
            label: const Text('Add Sample Item'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemsList(ExtractState extractState) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: extractState.items.length,
      itemBuilder: (context, index) {
        final item = extractState.items[index];
        return _buildItemCard(item, index);
      },
    );
  }

  Widget _buildItemCard(Item item, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () => _showItemDetails(item),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Item image
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: item.image != null
                    ? Image.network(
                        item.image!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildImagePlaceholder(),
                      )
                    : _buildImagePlaceholder(),
              ),
              const SizedBox(width: 12),
              
              // Item details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (item.price != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          '${item.price!.currency ?? 'USD'} ${item.price!.amount ?? 0}',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    if (item.qty != null && item.qty! > 1)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          'Qty: ${item.qty}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Chip(
                            label: Text(
                              item.sourceDomain ?? 'unknown',
                              style: const TextStyle(fontSize: 10),
                            ),
                            backgroundColor: Colors.blue.shade100,
                          ),
                          if (item.sourceMethod != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 4),
                              child: Chip(
                                label: Text(
                                  item.sourceMethod!,
                                  style: const TextStyle(fontSize: 10),
                                ),
                                backgroundColor: _getMethodColor(item.sourceMethod!),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              
              // Actions
              Column(
                children: [
                  IconButton(
                    onPressed: () => _copyItemJson(item),
                    icon: const Icon(Icons.copy, size: 18),
                    tooltip: 'Copy JSON',
                  ),
                  Text(
                    '#${index + 1}',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.shopping_bag,
        color: Colors.grey,
        size: 24,
      ),
    );
  }

  Widget _buildBottomStats(ExtractState extractState) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${extractState.items.length} Items',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${extractState.snapshots.length} Snapshots',
                style: const TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (extractState.lastOrigin != null)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Last: ${extractState.lastOrigin}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                if (extractState.debugMessage != null)
                  Text(
                    extractState.debugMessage!,
                    style: const TextStyle(
                      fontSize: 10,
                      fontStyle: FontStyle.italic,
                      color: Colors.green,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Color _getMethodColor(String method) {
    switch (method.toUpperCase()) {
      case 'JSONLD':
        return Colors.green.shade100;
      case 'DOM':
        return Colors.blue.shade100;
      case 'DOM_GENERIC':
        return Colors.orange.shade100;
      case 'META':
        return Colors.purple.shade100;
      case 'NETWORK':
        return Colors.red.shade100;
      case 'SAMPLE':
        return Colors.grey.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _handleMenuAction(String action, WidgetRef ref) {
    switch (action) {
      case 'copy_json':
        _copyAllJson(ref);
        break;
      case 'save_json':
        _saveJson(ref);
        break;
      case 'clear':
        _clearAll(ref);
        break;
      case 'sample':
        ref.read(extractProvider.notifier).sampleInsert();
        break;
    }
  }

  void _copyAllJson(WidgetRef ref) {
    final extractState = ref.read(extractProvider);
    final data = {
      'snapshots': extractState.snapshots.map((s) => s.toJson()).toList(),
      'items': extractState.items.map((i) => i.toJson()).toList(),
      'total_items': extractState.items.length,
      'total_snapshots': extractState.snapshots.length,
      'last_origin': extractState.lastOrigin,
      'exported_at': DateTime.now().toIso8601String(),
    };
    
    Clipboard.setData(
      ClipboardData(
        text: const JsonEncoder.withIndent('  ').convert(data),
      ),
    );
    
    Fluttertoast.showToast(
      msg: 'All data copied to clipboard!',
      backgroundColor: Colors.green,
    );
  }

  void _copyItemJson(Item item) {
    Clipboard.setData(
      ClipboardData(
        text: const JsonEncoder.withIndent('  ').convert(item.toJson()),
      ),
    );
    
    Fluttertoast.showToast(
      msg: 'Item JSON copied!',
      backgroundColor: Colors.blue,
    );
  }

  void _saveJson(WidgetRef ref) async {
    try {
      final extractState = ref.read(extractProvider);
      final data = {
        'snapshots': extractState.snapshots.map((s) => s.toJson()).toList(),
        'items': extractState.items.map((i) => i.toJson()).toList(),
        'total_items': extractState.items.length,
        'total_snapshots': extractState.snapshots.length,
        'last_origin': extractState.lastOrigin,
        'exported_at': DateTime.now().toIso8601String(),
      };
      
      final directory = await getApplicationDocumentsDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${directory.path}/talabiyah_extract_$timestamp.json');
      
      await file.writeAsString(
        const JsonEncoder.withIndent('  ').convert(data),
      );
      
      Fluttertoast.showToast(
        msg: 'JSON saved to Documents folder!',
        backgroundColor: Colors.green,
      );
      
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'Failed to save JSON: $e',
        backgroundColor: Colors.red,
      );
    }
  }

  void _clearAll(WidgetRef ref) {
    ref.read(extractProvider.notifier).clear();
    Fluttertoast.showToast(
      msg: 'All data cleared!',
      backgroundColor: Colors.orange,
    );
  }

  void _showItemDetails(Item item) {
    // TODO: Implement detailed item view if needed
    Fluttertoast.showToast(
      msg: 'Item details: ${item.title}',
      backgroundColor: Colors.blue,
    );
  }
}