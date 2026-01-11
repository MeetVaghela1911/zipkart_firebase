import 'package:cloud_firestore/cloud_firestore.dart';

/// BannerModel
///
/// Represents a promotional banner in the application.
/// Banners are displayed on the home page and can link to products, categories, or external URLs.
///
/// Firestore collection: 'banners'
class BannerModel {
  final String id;
  final String imageUrl;
  final String title;
  final String linkType; // 'product' | 'category' | 'external' | 'none'
  final String? linkId; // Product ID, Category ID, or external URL
  final int priority; // Lower number = higher priority (for ordering)
  final bool isActive;
  final DateTime createdAt;

  BannerModel({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.linkType,
    this.linkId,
    required this.priority,
    required this.isActive,
    required this.createdAt,
  });

  /// Convert BannerModel to Firestore document
  ///
  /// Uses serverTimestamp() for createdAt to ensure consistent timestamps.
  Map<String, dynamic> toFirestore() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'linkType': linkType,
      'linkId': linkId,
      'priority': priority,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create BannerModel from Firestore document
  factory BannerModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return BannerModel(
      id: doc.id,
      imageUrl: data['imageUrl'] as String? ?? '',
      title: data['title'] as String? ?? '',
      linkType: data['linkType'] as String? ?? 'none',
      linkId: data['linkId'] as String?,
      priority: data['priority'] as int? ?? 0,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy with updated fields
  BannerModel copyWith({
    String? id,
    String? imageUrl,
    String? title,
    String? linkType,
    String? linkId,
    int? priority,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return BannerModel(
      id: id ?? this.id,
      imageUrl: imageUrl ?? this.imageUrl,
      title: title ?? this.title,
      linkType: linkType ?? this.linkType,
      linkId: linkId ?? this.linkId,
      priority: priority ?? this.priority,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'BannerModel(id: $id, title: $title, priority: $priority, isActive: $isActive)';
  }
}
