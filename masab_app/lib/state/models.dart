class Price {
  final double amount;
  final String currency;
  final String? originalText;

  Price({
    required this.amount,
    required this.currency,
    this.originalText,
  });

  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
    'originalText': originalText,
  };

  factory Price.fromJson(Map<String, dynamic> json) => Price(
    amount: (json['amount'] as num).toDouble(),
    currency: json['currency'] as String,
    originalText: json['originalText'] as String?,
  );
}

class Item {
  final String? id;
  final String? name;
  final String? description;
  final Price? price;
  final String? imageUrl;
  final String? url;
  final Map<String, dynamic>? metadata;

  Item({
    this.id,
    this.name,
    this.description,
    this.price,
    this.imageUrl,
    this.url,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'description': description,
    'price': price?.toJson(),
    'imageUrl': imageUrl,
    'url': url,
    'metadata': metadata,
  };

  factory Item.fromJson(Map<String, dynamic> json) => Item(
    id: json['id'] as String?,
    name: json['name'] as String?,
    description: json['description'] as String?,
    price: json['price'] != null ? Price.fromJson(json['price']) : null,
    imageUrl: json['imageUrl'] as String?,
    url: json['url'] as String?,
    metadata: json['metadata'] as Map<String, dynamic>?,
  );
}

class Snapshot {
  final String type; // 'product' | 'cart'
  final String domain;
  final String url;
  final List<Item> items;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  Snapshot({
    required this.type,
    required this.domain,
    required this.url,
    required this.items,
    required this.timestamp,
    this.metadata,
  });

  Map<String, dynamic> toJson() => {
    'type': type,
    'domain': domain,
    'url': url,
    'items': items.map((item) => item.toJson()).toList(),
    'timestamp': timestamp.toIso8601String(),
    'metadata': metadata,
  };

  factory Snapshot.fromJson(Map<String, dynamic> json) => Snapshot(
    type: json['type'] as String,
    domain: json['domain'] as String,
    url: json['url'] as String,
    items: (json['items'] as List)
        .map((item) => Item.fromJson(item as Map<String, dynamic>))
        .toList(),
    timestamp: DateTime.parse(json['timestamp'] as String),
    metadata: json['metadata'] as Map<String, dynamic>?,
  );
}