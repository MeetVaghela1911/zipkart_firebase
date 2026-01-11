import 'package:cloud_firestore/cloud_firestore.dart';

/// SubcategoryModel
///
/// Represents a product subcategory linked to a parent category.
/// Subcategories provide finer product classification within categories.
///
/// Firestore collection: 'subcategories'
class SubcategoryModel {
  final String id;
  final String name;
  final String categoryId; // Reference to parent category
  final bool isActive;
  final DateTime createdAt;

  SubcategoryModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.isActive,
    required this.createdAt,
  });

  /// Convert SubcategoryModel to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'categoryId': categoryId,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create SubcategoryModel from Firestore document
  factory SubcategoryModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SubcategoryModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      categoryId: data['categoryId'] as String? ?? '',
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  SubcategoryModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return SubcategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      categoryId: categoryId ?? this.categoryId,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SubcategoryModel(id: $id, name: $name, categoryId: $categoryId, isActive: $isActive)';
  }
}
