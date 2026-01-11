import 'package:cloud_firestore/cloud_firestore.dart';

/// AppUser Model
///
/// Represents a user in the application.
/// This model is used to store user profile data in Firestore.
///
/// SECURITY: Never store passwords here - Firebase Auth handles authentication.
///
/// The document ID in Firestore MUST be the Firebase Auth UID.
class AppUser {
  final String uid;
  final String email;
  final String username;
  final String phone;
  final String role; // "buyer" | "seller" | "admin"
  final String? photoUrl;
  final bool isApproved; // For sellers
  final Map<String, dynamic>? sellerProfile; // Only for sellers
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  AppUser({
    required this.uid,
    required this.email,
    required this.username,
    required this.phone,
    required this.role,
    this.photoUrl,
    this.isApproved = false,
    this.sellerProfile,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert AppUser to Firestore document
  ///
  /// Uses serverTimestamp() for createdAt and updatedAt to ensure
  /// consistent timestamps across all clients.
  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'email': email,
      'username': username,
      'phone': phone,
      'role': role,
      'photoUrl': photoUrl,
      'isApproved': isApproved,
      'sellerProfile': sellerProfile,
      'isActive': isActive,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  /// Create AppUser from Firestore document
  ///
  /// Handles null safety and type conversion safely.
  factory AppUser.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return AppUser(
      uid:
          data['uid'] as String? ?? doc.id, // Fallback to doc.id if uid missing
      email: data['email'] as String? ?? '',
      username: data['username'] as String? ?? '',
      phone: data['phone'] as String? ?? '',
      role: data['role'] as String? ?? 'buyer',
      photoUrl: data['photoUrl'] as String?,
      isApproved: data['isApproved'] as bool? ?? false,
      sellerProfile: data['sellerProfile'] as Map<String, dynamic>?,
      isActive: data['isActive'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create AppUser from Map (for testing or other use cases)
  factory AppUser.fromMap(Map<String, dynamic> map, String uid) {
    return AppUser(
      uid: uid,
      email: map['email'] as String? ?? '',
      username: map['username'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: map['role'] as String? ?? 'buyer',
      photoUrl: map['photoUrl'] as String?,
      isApproved: map['isApproved'] as bool? ?? false,
      sellerProfile: map['sellerProfile'] as Map<String, dynamic>?,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (map['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Create a copy of AppUser with updated fields
  AppUser copyWith({
    String? uid,
    String? email,
    String? username,
    String? phone,
    String? role,
    String? photoUrl,
    bool? isApproved,
    Map<String, dynamic>? sellerProfile,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      username: username ?? this.username,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      photoUrl: photoUrl ?? this.photoUrl,
      isApproved: isApproved ?? this.isApproved,
      sellerProfile: sellerProfile ?? this.sellerProfile,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, username: $username, role: $role, isActive: $isActive)';
  }
}
