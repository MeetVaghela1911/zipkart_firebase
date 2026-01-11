import 'package:cloud_firestore/cloud_firestore.dart';

/// CategoryModel
///
/// Represents a product category in the e-commerce system.
/// Categories can have subcategories and are displayed with icons.
///
/// Firestore collection: 'categories'
class CategoryModel {
  final String id;
  final String name;
  final String? iconUrl; // Firebase Storage URL for category icon
  final int order; // Display order (lower number = higher priority)
  final bool isActive;
  final DateTime createdAt;

  CategoryModel({
    required this.id,
    required this.name,
    this.iconUrl,
    required this.order,
    required this.isActive,
    required this.createdAt,
  });

  /// Convert CategoryModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'iconUrl': iconUrl,
      'order': order,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create CategoryModel from Firestore document
  factory CategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return CategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      iconUrl: data['iconUrl'] as String?,
      order: data['order'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  CategoryModel copyWith({
    String? id,
    String? name,
    String? iconUrl,
    int? order,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      iconUrl: iconUrl ?? this.iconUrl,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'CategoryModel(id: $id, name: $name, order: $order, isActive: $isActive)';
  }
}
