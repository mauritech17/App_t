class Price {
  final double? amount;
  final String? currency;
  
  const Price({this.amount, this.currency});
  
  Map<String, dynamic> toJson() => {
    'amount': amount,
    'currency': currency,
  };
  
  static Price fromJson(Map<String, dynamic> json) => Price(
    amount: json['amount']?.toDouble(),
    currency: json['currency'],
  );
}

class Item {
  final String title;
  final String url;
  final String? image;
  final String? sku;
  final Map<String, String>? options;
  final int? qty;
  final Price? price;
  final double? estimatedWeightKg;
  final String? sourceDomain;
  final String? sourceMethod;
  
  const Item({
    required this.title,
    required this.url,
    this.image,
    this.sku,
    this.options,
    this.qty,
    this.price,
    this.estimatedWeightKg,
    this.sourceDomain,
    this.sourceMethod,
  });
  
  Map<String, dynamic> toJson() => {
    'title': title,
    'url': url,
    'image': image,
    'sku': sku,
    'options': options,
    'qty': qty,
    'price': price?.toJson(),
    'estimatedWeightKg': estimatedWeightKg,
    'sourceDomain': sourceDomain,
    'sourceMethod': sourceMethod,
  };
  
  static Item fromJson(Map<String, dynamic> json) => Item(
    title: json['title'] ?? '',
    url: json['url'] ?? '',
    image: json['image'],
    sku: json['sku'],
    options: json['options']?.cast<String, String>(),
    qty: json['qty'],
    price: json['price'] != null ? Price.fromJson(json['price']) : null,
    estimatedWeightKg: json['estimatedWeightKg']?.toDouble(),
    sourceDomain: json['sourceDomain'],
    sourceMethod: json['sourceMethod'],
  );
}

class Snapshot {
  final String type; // 'product' | 'cart_snapshot'
  final String origin;
  final DateTime collectedAt;
  final List<Item> items;
  final double? subtotal;
  final String? currency;
  final Map<String, dynamic>? raw;
  
  const Snapshot({
    required this.type,
    required this.origin,
    required this.collectedAt,
    required this.items,
    this.subtotal,
    this.currency,
    this.raw,
  });
  
  Map<String, dynamic> toJson() => {
    'type': type,
    'origin': origin,
    'collected_at': collectedAt.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
    'subtotal': subtotal,
    'currency': currency,
    'raw': raw,
  };
  
  static Snapshot fromJson(Map<String, dynamic> json) => Snapshot(
    type: json['type'] ?? '',
    origin: json['origin'] ?? '',
    collectedAt: DateTime.tryParse(json['collected_at'] ?? '') ?? DateTime.now(),
    items: (json['items'] as List? ?? [])
        .map((item) => Item.fromJson(item as Map<String, dynamic>))
        .toList(),
    subtotal: json['subtotal']?.toDouble(),
    currency: json['currency'],
    raw: json['raw'],
  );
}