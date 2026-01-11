import 'package:cloud_firestore/cloud_firestore.dart';

/// Product Model
///
/// Represents a product in the e-commerce system.
/// Updated to support Cloud Firestore with proper serialization.
///
/// Firestore collection: 'products'
class Product {
  String id;
  String name;
  String description;
  double price;
  double? salePrice; // Sale price if product is on sale
  int stock;
  String categoryId;
  String subCategoryId; // Changed from 'subcategory' to match Firestore schema
  String sellerId;
  String? sellerName; // Display name of the seller
  List<String> images; // Firebase Storage URLs
  bool isActive; // Product visibility
  bool isFeatured; // Featured on home page
  bool isApproved; // Admin approval status
  String createdByRole; // 'admin' or 'seller'
  String? rejectionReason; // If rejected, why
  DateTime createdAt;

  // Extended features (Delivery, Returns, Warranty, Badges)
  bool isFreeDelivery;
  String? returnPolicy; // e.g., '10 Days Returnable', 'No Returns'
  String? warrantyPolicy; // e.g., '1 Year Warranty'
  bool isTopBrand;
  bool isAssured; // e.g., 'Fast Delivery', 'Quality Checked'

  // Social Proof (Manual or Computed)
  double rating;
  int reviewCount;
  int recentSalesCount; // e.g., 50 (for '50+ bought in past month')

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.salePrice,
    required this.stock,
    required this.categoryId,
    required this.subCategoryId,
    required this.sellerId,
    this.sellerName,
    required this.images,
    required this.isActive,
    required this.isFeatured,
    this.isApproved = false,
    this.createdByRole = 'admin',
    this.rejectionReason,
    required this.createdAt,
    // Defaults for new fields
    this.isFreeDelivery = false,
    this.returnPolicy,
    this.warrantyPolicy,
    this.isTopBrand = false,
    this.isAssured = false,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.recentSalesCount = 0,
  });

  /// Convert Product to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'stock': stock,
      'categoryId': categoryId,
      'subCategoryId': subCategoryId,
      'sellerId': sellerId,
      'sellerName': sellerName,
      'images': images,
      'isActive': isActive,
      'isFeatured': isFeatured,
      'isApproved': isApproved,
      'createdByRole': createdByRole,
      'rejectionReason': rejectionReason,
      'createdAt': FieldValue.serverTimestamp(),
      'isFreeDelivery': isFreeDelivery,
      'returnPolicy': returnPolicy,
      'warrantyPolicy': warrantyPolicy,
      'isTopBrand': isTopBrand,
      'isAssured': isAssured,
      'rating': rating,
      'reviewCount': reviewCount,
      'recentSalesCount': recentSalesCount,
    };
  }

  /// Legacy toJson for backward compatibility
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'salePrice': salePrice,
      'stock': stock,
      'categoryId': categoryId,
      'subcategory': subCategoryId, // Map to old field name
      'images': images,
      'isApproved': isApproved,
      'timestamp': createdAt.toIso8601String(),
    };
  }

  /// Create Product from Firestore document
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return Product(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      salePrice: (data['salePrice'] as num?)?.toDouble(),
      stock: data['stock'] as int? ?? 0,
      categoryId: data['categoryId'] as String? ?? '',
      subCategoryId: data['subCategoryId'] as String? ?? '',
      sellerId: data['sellerId'] as String? ?? '',
      sellerName: data['sellerName'] as String?,
      images: List<String>.from(data['images'] ?? []),
      isActive: data['isActive'] as bool? ?? true,
      isFeatured: data['isFeatured'] as bool? ?? false,
      isApproved: data['isApproved'] as bool? ?? false,
      createdByRole: data['createdByRole'] as String? ?? 'admin',
      rejectionReason: data['rejectionReason'] as String?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      // New fields mapping with defaults
      isFreeDelivery: data['isFreeDelivery'] as bool? ?? false,
      returnPolicy: data['returnPolicy'] as String?,
      warrantyPolicy: data['warrantyPolicy'] as String?,
      isTopBrand: data['isTopBrand'] as bool? ?? false,
      isAssured: data['isAssured'] as bool? ?? false,
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] as int? ?? 0,
      recentSalesCount: data['recentSalesCount'] as int? ?? 0,
    );
  }

  /// Legacy fromMap for backward compatibility with Realtime Database
  factory Product.fromMap(Map<dynamic, dynamic> map, String id) {
    return Product(
      id: id,
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      price: (map['price'] as num).toDouble(),
      salePrice: (map['salePrice'] as num?)?.toDouble(),
      stock: map['stock'] as int,
      categoryId: map['categoryId'] ?? '',
      subCategoryId:
          map['subcategory'] ??
          map['subCategoryId'] ??
          '', // Handle both field names
      sellerId: map['sellerId'] ?? '',
      sellerName: map['sellerName'],
      images: List<String>.from(map['images'] ?? []),
      isActive: map['isActive'] as bool? ?? true,
      isFeatured: map['isFeatured'] as bool? ?? false,
      isApproved: map['isApproved'] as bool? ?? false,
      createdByRole: map['createdByRole'] ?? 'admin',
      rejectionReason: map['rejectionReason'],
      createdAt: map['timestamp'] != null
          ? DateTime.parse(map['timestamp'])
          : DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  Product copyWith({
    String? id,
    String? name,
    String? description,
    double? price,
    double? salePrice,
    int? stock,
    String? categoryId,
    String? subCategoryId,
    String? sellerId,
    String? sellerName,
    List<String>? images,
    bool? isActive,
    bool? isFeatured,
    bool? isApproved,
    String? createdByRole,
    String? rejectionReason,
    DateTime? createdAt,
    bool? isFreeDelivery,
    String? returnPolicy,
    String? warrantyPolicy,
    bool? isTopBrand,
    bool? isAssured,
    double? rating,
    int? reviewCount,
    int? recentSalesCount,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      salePrice: salePrice ?? this.salePrice,
      stock: stock ?? this.stock,
      categoryId: categoryId ?? this.categoryId,
      subCategoryId: subCategoryId ?? this.subCategoryId,
      sellerId: sellerId ?? this.sellerId,
      sellerName: sellerName ?? this.sellerName,
      images: images ?? this.images,
      isActive: isActive ?? this.isActive,
      isFeatured: isFeatured ?? this.isFeatured,
      isApproved: isApproved ?? this.isApproved,
      createdByRole: createdByRole ?? this.createdByRole,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      createdAt: createdAt ?? this.createdAt,
      isFreeDelivery: isFreeDelivery ?? this.isFreeDelivery,
      returnPolicy: returnPolicy ?? this.returnPolicy,
      warrantyPolicy: warrantyPolicy ?? this.warrantyPolicy,
      isTopBrand: isTopBrand ?? this.isTopBrand,
      isAssured: isAssured ?? this.isAssured,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      recentSalesCount: recentSalesCount ?? this.recentSalesCount,
    );
  }

  @override
  String toString() {
    return 'Product(id: $id, name: $name, price: $price, salePrice: $salePrice, isActive: $isActive)';
  }
}
