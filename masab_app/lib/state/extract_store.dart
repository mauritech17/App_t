import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'models.dart';

class ExtractState {
  final List<Snapshot> snapshots;
  final List<Item> allItems;
  final bool isExtracting;
  final String? lastError;

  ExtractState({
    this.snapshots = const [],
    this.allItems = const [],
    this.isExtracting = false,
    this.lastError,
  });

  ExtractState copyWith({
    List<Snapshot>? snapshots,
    List<Item>? allItems,
    bool? isExtracting,
    String? lastError,
  }) {
    return ExtractState(
      snapshots: snapshots ?? this.snapshots,
      allItems: allItems ?? this.allItems,
      isExtracting: isExtracting ?? this.isExtracting,
      lastError: lastError ?? this.lastError,
    );
  }
}

class ExtractNotifier extends StateNotifier<ExtractState> {
  ExtractNotifier() : super(ExtractState());

  void addSnapshot(Snapshot snapshot) {
    final newSnapshots = [...state.snapshots, snapshot];
    final newAllItems = <Item>[];
    
    for (final snap in newSnapshots) {
      newAllItems.addAll(snap.items);
    }
    
    state = state.copyWith(
      snapshots: newSnapshots,
      allItems: newAllItems,
    );
  }

  void clearSnapshots() {
    state = ExtractState();
  }

  void addSampleItem() {
    final sampleItem = Item(
      id: 'sample-${DateTime.now().millisecondsSinceEpoch}',
      name: 'Sample Product',
      description: 'This is a sample product for testing',
      price: Price(amount: 99.99, currency: 'USD'),
      imageUrl: 'https://via.placeholder.com/150',
      url: 'https://example.com/product',
    );
    
    final sampleSnapshot = Snapshot(
      type: 'product',
      domain: 'sample.com',
      url: 'https://sample.com/product',
      items: [sampleItem],
      timestamp: DateTime.now(),
    );
    
    addSnapshot(sampleSnapshot);
  }

  void setExtracting(bool extracting) {
    state = state.copyWith(isExtracting: extracting);
  }

  void setError(String? error) {
    state = state.copyWith(lastError: error);
  }
}

final extractProvider = StateNotifierProvider<ExtractNotifier, ExtractState>(
  (ref) => ExtractNotifier(),
);