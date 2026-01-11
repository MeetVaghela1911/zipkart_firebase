import 'package:cloud_firestore/cloud_firestore.dart';

/// SaleModel
///
/// Represents a sale campaign for a product.
/// Supports different sale types: flash, mega, and seasonal sales.
///
/// Firestore collection: 'sales'
class SaleModel {
  final String id;
  final String name; // Sale Campaign Name
  final String? description;
  final String? bannerUrl;
  final List<String> productIds; // List of products in this sale
  final double discountPercent; // Discount percentage (0-100)
  final DateTime startDate;
  final DateTime endDate;
  final String saleType; // 'flash' | 'mega' | 'seasonal' | 'other'
  final bool isActive;

  SaleModel({
    required this.id,
    required this.name,
    this.description,
    this.bannerUrl,
    required this.productIds,
    required this.discountPercent,
    required this.startDate,
    required this.endDate,
    required this.saleType,
    required this.isActive,
  });

  /// Check if sale is currently active based on dates
  bool get isCurrentlyActive {
    final now = DateTime.now();
    return isActive && now.isAfter(startDate) && now.isBefore(endDate);
  }

  /// Convert SaleModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'bannerUrl': bannerUrl,
      'productIds': productIds,
      'discountPercent': discountPercent,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'saleType': saleType,
      'isActive': isActive,
    };
  }

  /// Create SaleModel from Firestore document
  factory SaleModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SaleModel(
      id: doc.id,
      name: data['name'] as String? ?? 'Untitled Sale',
      description: data['description'] as String?,
      bannerUrl: data['bannerUrl'] as String?,
      productIds: List<String>.from(data['productIds'] ?? []),
      discountPercent: (data['discountPercent'] as num?)?.toDouble() ?? 0.0,
      startDate: (data['startDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endDate:
          (data['endDate'] as Timestamp?)?.toDate() ??
          DateTime.now().add(const Duration(days: 1)),
      saleType: data['saleType'] as String? ?? 'other',
      isActive: data['isActive'] as bool? ?? true,
    );
  }

  /// Create a copy with updated fields
  SaleModel copyWith({
    String? id,
    String? name,
    String? description,
    String? bannerUrl,
    List<String>? productIds,
    double? discountPercent,
    DateTime? startDate,
    DateTime? endDate,
    String? saleType,
    bool? isActive,
  }) {
    return SaleModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      bannerUrl: bannerUrl ?? this.bannerUrl,
      productIds: productIds ?? this.productIds,
      discountPercent: discountPercent ?? this.discountPercent,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      saleType: saleType ?? this.saleType,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  String toString() {
    return 'SaleModel(id: $id, name: $name, type: $saleType, discount: $discountPercent%, products: ${productIds.length})';
  }
}
