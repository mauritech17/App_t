import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

class ExtractState {
  final String? lastOrigin;
  final List<Snapshot> snapshots;
  final List<Item> items;
  final bool isExtracting;
  final String? lastError;
  final String? debugMessage;

  ExtractState({
    this.lastOrigin,
    this.snapshots = const [],
    this.items = const [],
    this.isExtracting = false,
    this.lastError,
    this.debugMessage,
  });

  ExtractState copyWith({
    String? lastOrigin,
    List<Snapshot>? snapshots,
    List<Item>? items,
    bool? isExtracting,
    String? lastError,
    String? debugMessage,
  }) {
    return ExtractState(
      lastOrigin: lastOrigin ?? this.lastOrigin,
      snapshots: snapshots ?? this.snapshots,
      items: items ?? this.items,
      isExtracting: isExtracting ?? this.isExtracting,
      lastError: lastError ?? this.lastError,
      debugMessage: debugMessage ?? this.debugMessage,
    );
  }
}

class ExtractNotifier extends StateNotifier<ExtractState> {
  ExtractNotifier() : super(ExtractState());

  void addSnapshot(Snapshot snapshot) {
    final newSnapshots = [...state.snapshots, snapshot];
    final newItems = <Item>[];
    
    // Merge all items from all snapshots
    for (final snap in newSnapshots) {
      newItems.addAll(snap.items);
    }
    
    state = state.copyWith(
      lastOrigin: snapshot.origin,
      snapshots: newSnapshots,
      items: newItems,
      debugMessage: 'Added ${snapshot.items.length} items from ${snapshot.origin}',
    );
  }

  void clear() {
    state = ExtractState();
  }

  void sampleInsert() {
    final sampleItem = Item(
      title: 'Sample Product - Testing UI',
      url: 'https://example.com/sample-product',
      image: 'https://via.placeholder.com/200x200/4CAF50/white?text=Sample',
      sku: 'SAMPLE-001',
      options: {'Color': 'Blue', 'Size': 'M'},
      qty: 1,
      price: const Price(amount: 29.99, currency: 'AED'),
      estimatedWeightKg: 0.5,
      sourceDomain: 'example.com',
      sourceMethod: 'SAMPLE',
    );
    
    final sampleSnapshot = Snapshot(
      type: 'product',
      origin: 'example.com',
      collectedAt: DateTime.now(),
      items: [sampleItem],
      currency: 'AED',
      raw: {'debug': 'Sample data for testing UI'},
    );
    
    addSnapshot(sampleSnapshot);
  }

  void setExtracting(bool extracting) {
    state = state.copyWith(isExtracting: extracting);
  }

  void setError(String? error) {
    state = state.copyWith(lastError: error);
  }
  
  void setDebugMessage(String? message) {
    state = state.copyWith(debugMessage: message);
  }
}

final extractProvider = StateNotifierProvider<ExtractNotifier, ExtractState>(
  (ref) => ExtractNotifier(),
);