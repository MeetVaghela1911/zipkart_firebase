class Orders {
  String id;
  String name;
  String description;
  double price;
  int stock;
  String categoryId;
  String subcategory;
  String sellerId;
  List<String> images;
  DateTime timestamp;
  Map<String, dynamic> additionalAttributes;

  Orders({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    required this.subcategory,
    required this.sellerId,
    required this.images,
    required this.timestamp,
    required this.additionalAttributes,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'stock': stock,
      'categoryId': categoryId,
      'subcategory': subcategory,
      'images': images,
      'timestamp': timestamp.toIso8601String(),
      'additionalAttributes': additionalAttributes,
    };
  }

  factory Orders.fromMap(Map<String, dynamic> map, String id) {
    return Orders(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      categoryId: map['categoryId'] ?? '',
      subcategory: map['subcategory'] ?? '',
      sellerId: map['sellerId'] ?? '',
      images: List<String>.from(map['images'] ?? []),
      timestamp: DateTime.parse(map['timestamp'] ?? ''),
      additionalAttributes:
          Map<String, dynamic>.from(map['additionalAttributes'] ?? {}),
    );
  }
}
