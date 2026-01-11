import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipkart_firebase/Models/banner_model.dart';
import 'package:zipkart_firebase/Models/category_model.dart';
import 'package:zipkart_firebase/Models/subcategory_model.dart';
import 'package:zipkart_firebase/Models/Product.dart';
import 'package:zipkart_firebase/Models/sale_model.dart';
import 'package:zipkart_firebase/Models/app_user.dart';

/// FirestoreService
///
/// Comprehensive service for all Firestore operations in the admin panel.
/// Replaces the old FirebaseService that used Realtime Database.
///
/// RESPONSIBILITIES:
/// - CRUD operations for banners, categories, subcategories, products, and sales
/// - Firebase Storage image uploads
/// - Real-time streams for UI updates
/// - Batch operations for efficiency
///
/// FOLLOWS: Clean architecture pattern from auth_repository.dart
class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  // ============================================
  // BANNER OPERATIONS
  // ============================================

  /// Add a new banner with optional image upload
  ///
  /// FLOW:
  /// 1. Upload image to Firebase Storage (if provided)
  /// 2. Create banner document in Firestore
  ///
  /// Returns: Banner document ID
  Future<String> addBanner({
    required String title,
    required String linkType,
    String? linkId,
    required int priority,
    XFile? image,
    isActive = true,
  }) async {
    debugPrint('🔵 [FirestoreService] addBanner started: $title');

    try {
      String? imageUrl;

      // Convert image to Base64 if provided
      if (image != null) {
        debugPrint(
          '🔵 [FirestoreService] Converting banner image to Base64...',
        );
        imageUrl = await _convertToBase64(image);
        debugPrint('✅ [FirestoreService] Banner image converted');
      }

      // Create banner document
      final banner = BannerModel(
        id: '', // Will be set by Firestore
        imageUrl: imageUrl ?? '',
        title: title,
        linkType: linkType,
        linkId: linkId,
        priority: priority,
        isActive: true,
        createdAt: DateTime.now(),
      );

      debugPrint('🔵 [FirestoreService] Creating banner document...');
      final docRef = await _firestore
          .collection('banners')
          .add(banner.toFirestore());
      debugPrint('✅ [FirestoreService] Banner created with ID: ${docRef.id}');

      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('❌ [FirestoreService] Error adding banner: $e');
      debugPrint('❌ [FirestoreService] Stack trace: $stackTrace');
      throw Exception('Failed to add banner: $e');
    }
  }

  /// Get all banners as a stream
  ///
  /// Optionally filter by active status and order by priority
  Stream<List<BannerModel>> getBanners({bool activeOnly = false}) {
    debugPrint(
      '🔵 [FirestoreService] getBanners stream started (activeOnly: $activeOnly)',
    );

    Query<Map<String, dynamic>> query = _firestore.collection('banners');
    // .orderBy('priority');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => BannerModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get all sellers (users with role 'seller')
  Stream<List<AppUser>> getSellers() {
    debugPrint('🔵 [FirestoreService] getSellers stream started');

    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'seller')
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => AppUser.fromFirestore(doc))
              .toList();
        });
  }

  /// Update banner fields
  Future<void> updateBanner(
    String bannerId,
    Map<String, dynamic> updates,
  ) async {
    debugPrint('🔵 [FirestoreService] updateBanner: $bannerId');

    try {
      await _firestore.collection('banners').doc(bannerId).update(updates);
      debugPrint('✅ [FirestoreService] Banner updated successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error updating banner: $e');
      throw Exception('Failed to update banner: $e');
    }
  }

  /// Delete a banner
  Future<void> deleteBanner(String bannerId) async {
    debugPrint('🔵 [FirestoreService] deleteBanner: $bannerId');

    try {
      // Delete banner document
      await _firestore.collection('banners').doc(bannerId).delete();
      debugPrint('✅ [FirestoreService] Banner deleted successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error deleting banner: $e');
      throw Exception('Failed to delete banner: $e');
    }
  }

  // ============================================
  // SELLER MANAGEMENT OPERATIONS
  // ============================================

  /// Approve a seller
  Future<void> approveSeller(String uid) async {
    debugPrint('🔵 [FirestoreService] approveSeller: $uid');
    try {
      await _firestore.collection('users').doc(uid).update({
        'isApproved': true,
        'isActive': true,
      });
      debugPrint('✅ [FirestoreService] Seller approved');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error approving seller: $e');
      throw Exception('Failed to approve seller: $e');
    }
  }

  /// Reject a seller (or revoke approval)
  Future<void> rejectSeller(String uid) async {
    debugPrint('🔵 [FirestoreService] rejectSeller: $uid');
    try {
      await _firestore.collection('users').doc(uid).update({
        'isApproved': false,
      });
      debugPrint('✅ [FirestoreService] Seller rejected/revoked');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error rejecting seller: $e');
      throw Exception('Failed to reject seller: $e');
    }
  }

  /// Disable a seller (soft block)
  Future<void> disableSeller(String uid) async {
    debugPrint('🔵 [FirestoreService] disableSeller: $uid');
    try {
      await _firestore.collection('users').doc(uid).update({'isActive': false});
      debugPrint('✅ [FirestoreService] Seller disabled');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error disabling seller: $e');
      throw Exception('Failed to disable seller: $e');
    }
  }

  /// Convert user role to seller
  Future<void> makeUserSeller(String uid) async {
    debugPrint('🔵 [FirestoreService] makeUserSeller: $uid');
    try {
      await _firestore.collection('users').doc(uid).update({
        'role': 'seller',
        'isApproved': false, // Requires approval
      });
      debugPrint('✅ [FirestoreService] User converted to seller');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error converting user to seller: $e');
      throw Exception('Failed to convert user to seller: $e');
    }
  }

  /// Get all users (for finding potential sellers)
  Stream<List<AppUser>> getAllUsers() {
    return _firestore.collection('users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => AppUser.fromFirestore(doc)).toList();
    });
  }

  // ============================================
  // CATEGORY OPERATIONS
  // ============================================

  /// Add a new category with optional icon upload
  Future<String> addCategory({
    required String name,
    required int order,
    XFile? icon,
  }) async {
    debugPrint('🔵 [FirestoreService] addCategory started: $name');

    try {
      String? iconUrl;

      // Convert icon to Base64 if provided
      if (icon != null) {
        debugPrint(
          '🔵 [FirestoreService] Converting category icon to Base64...',
        );
        iconUrl = await _convertToBase64(icon);
        debugPrint('✅ [FirestoreService] Category icon converted');
      }

      // Create category document
      final category = CategoryModel(
        id: '',
        name: name,
        iconUrl: iconUrl,
        order: order,
        isActive: true,
        createdAt: DateTime.now(),
      );

      debugPrint('🔵 [FirestoreService] Creating category document...');
      final docRef = await _firestore
          .collection('categories')
          .add(category.toFirestore());
      debugPrint('✅ [FirestoreService] Category created with ID: ${docRef.id}');

      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('❌ [FirestoreService] Error adding category: $e');
      debugPrint('❌ [FirestoreService] Stack trace: $stackTrace');
      throw Exception('Failed to add category: $e');
    }
  }

  /// Get all categories as a stream
  Stream<List<CategoryModel>> getCategories({bool activeOnly = false}) {
    debugPrint(
      '🔵 [FirestoreService] getCategories stream started (activeOnly: $activeOnly)',
    );

    Query<Map<String, dynamic>> query = _firestore.collection('categories');
    // .orderBy('order');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => CategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update category fields
  Future<void> updateCategory(
    String categoryId,
    Map<String, dynamic> updates,
  ) async {
    debugPrint('🔵 [FirestoreService] updateCategory: $categoryId');

    try {
      await _firestore.collection('categories').doc(categoryId).update(updates);
      debugPrint('✅ [FirestoreService] Category updated successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error updating category: $e');
      throw Exception('Failed to update category: $e');
    }
  }

  /// Soft delete a category
  Future<void> deleteCategory(String categoryId) async {
    debugPrint('🔵 [FirestoreService] deleteCategory (soft): $categoryId');

    try {
      // Soft delete category by setting isActive to false
      await _firestore.collection('categories').doc(categoryId).update({
        'isActive': false,
      });
      debugPrint('✅ [FirestoreService] Category soft deleted successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error deleting category: $e');
      throw Exception('Failed to delete category: $e');
    }
  }

  // ============================================
  // SUBCATEGORY OPERATIONS
  // ============================================

  /// Add a new subcategory
  Future<String> addSubcategory({
    required String name,
    required String categoryId,
  }) async {
    debugPrint(
      '🔵 [FirestoreService] addSubcategory started: $name (category: $categoryId)',
    );

    try {
      final subcategory = SubcategoryModel(
        id: '',
        name: name,
        categoryId: categoryId,
        isActive: true,
        createdAt: DateTime.now(),
      );

      debugPrint('🔵 [FirestoreService] Creating subcategory document...');
      final docRef = await _firestore
          .collection('subcategories')
          .add(subcategory.toFirestore());
      debugPrint(
        '✅ [FirestoreService] Subcategory created with ID: ${docRef.id}',
      );

      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('❌ [FirestoreService] Error adding subcategory: $e');
      debugPrint('❌ [FirestoreService] Stack trace: $stackTrace');
      throw Exception('Failed to add subcategory: $e');
    }
  }

  /// Get subcategories for a specific category
  Stream<List<SubcategoryModel>> getSubcategories(
    String categoryId, {
    bool activeOnly = false,
  }) {
    debugPrint(
      '🔵 [FirestoreService] getSubcategories stream started for category: $categoryId',
    );

    Query<Map<String, dynamic>> query = _firestore
        .collection('subcategories')
        .where('categoryId', isEqualTo: categoryId);
    // .orderBy('name');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SubcategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Get all subcategories
  Stream<List<SubcategoryModel>> getAllSubcategories({
    bool activeOnly = false,
  }) {
    debugPrint('🔵 [FirestoreService] getAllSubcategories stream started');

    Query<Map<String, dynamic>> query = _firestore
        .collection('subcategories')
        .orderBy('name');

    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => SubcategoryModel.fromFirestore(doc))
          .toList();
    });
  }

  /// Update subcategory fields
  Future<void> updateSubcategory(
    String subcategoryId,
    Map<String, dynamic> updates,
  ) async {
    debugPrint('🔵 [FirestoreService] updateSubcategory: $subcategoryId');

    try {
      await _firestore
          .collection('subcategories')
          .doc(subcategoryId)
          .update(updates);
      debugPrint('✅ [FirestoreService] Subcategory updated successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error updating subcategory: $e');
      throw Exception('Failed to update subcategory: $e');
    }
  }

  /// Soft delete a subcategory
  Future<void> deleteSubcategory(String subcategoryId) async {
    debugPrint(
      '🔵 [FirestoreService] deleteSubcategory (soft): $subcategoryId',
    );

    try {
      await _firestore.collection('subcategories').doc(subcategoryId).update({
        'isActive': false,
      });
      debugPrint('✅ [FirestoreService] Subcategory soft deleted successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error deleting subcategory: $e');
      throw Exception('Failed to delete subcategory: $e');
    }
  }

  // ============================================
  // PRODUCT OPERATIONS
  // ============================================

  /// Add a new product with multiple image uploads
  Future<String> addProduct({
    required String name,
    required String description,
    required double price,
    double? salePrice,
    required int stock,
    required String categoryId,
    required String subCategoryId,
    required String sellerId,
    String? sellerName,
    required bool isFeatured,
    List<XFile>? images,
    bool isApproved = false,
    String createdByRole = 'seller',
    // New Features
    bool isFreeDelivery = false,
    String? returnPolicy,
    String? warrantyPolicy,
    bool isTopBrand = false,
    bool isAssured = false,
    double rating = 0.0,
    int reviewCount = 0,
    int recentSalesCount = 0,
  }) async {
    debugPrint('🔵 [FirestoreService] addProduct started: $name');

    try {
      List<String> imageUrls = [];

      // Convert images to Base64 if provided
      if (images != null && images.isNotEmpty) {
        debugPrint(
          '🔵 [FirestoreService] Converting ${images.length} product images to Base64...',
        );
        for (int i = 0; i < images.length; i++) {
          final imageUrl = await _convertToBase64(images[i]);
          imageUrls.add(imageUrl);
        }
        debugPrint('✅ [FirestoreService] All product images converted');
      }

      // Create product document
      final product = Product(
        id: '',
        name: name,
        description: description,
        price: price,
        salePrice: salePrice,
        stock: stock,
        categoryId: categoryId,
        subCategoryId: subCategoryId,
        sellerId: sellerId,
        sellerName: sellerName,
        images: imageUrls,
        isActive: isApproved, // Only active if approved immediately
        isFeatured: isFeatured,
        isApproved: isApproved, // Set based on role (admin=true, seller=false)
        createdByRole: createdByRole,
        createdAt: DateTime.now(),
        // New Fields
        isFreeDelivery: isFreeDelivery,
        returnPolicy: returnPolicy,
        warrantyPolicy: warrantyPolicy,
        isTopBrand: isTopBrand,
        isAssured: isAssured,
        rating: rating,
        reviewCount: reviewCount,
        recentSalesCount: recentSalesCount,
      );

      debugPrint('🔵 [FirestoreService] Creating product document...');
      final docRef = await _firestore
          .collection('products')
          .add(product.toFirestore());
      debugPrint('✅ [FirestoreService] Product created with ID: ${docRef.id}');

      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('❌ [FirestoreService] Error adding product: $e');
      debugPrint('❌ [FirestoreService] Stack trace: $stackTrace');
      throw Exception('Failed to add product: $e');
    }
  }

  /// Get products with optional filtering
  Stream<List<Product>> getProducts({
    String? categoryId,
    String? subCategoryId,
    String? sellerId,
    bool activeOnly = false,
    bool featuredOnly = false,
  }) {
    debugPrint('🔵 [FirestoreService] getProducts stream started');

    Query<Map<String, dynamic>> query = _firestore.collection('products');

    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (subCategoryId != null) {
      query = query.where('subCategoryId', isEqualTo: subCategoryId);
    }
    if (sellerId != null) {
      query = query.where('sellerId', isEqualTo: sellerId);
    }
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    if (featuredOnly) {
      query = query.where('isFeatured', isEqualTo: true);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList();
    });
  }

  /// Get a single product by ID
  Future<Product?> getProduct(String productId) async {
    debugPrint('🔵 [FirestoreService] getProduct: $productId');

    try {
      final doc = await _firestore.collection('products').doc(productId).get();
      if (doc.exists) {
        return Product.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error getting product: $e');
      throw Exception('Failed to get product: $e');
    }
  }

  /// Update product with image handling
  Future<void> updateProduct(
    String productId,
    Map<String, dynamic> updates,
  ) async {
    debugPrint('🔵 [FirestoreService] updateProduct: $productId');

    try {
      await _firestore.collection('products').doc(productId).update(updates);
      debugPrint('✅ [FirestoreService] Product updated successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error updating product: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  /// Update a product with full details and optional new images
  Future<void> updateProductFull({
    required String productId,
    required String name,
    required String description,
    required double price,
    double? salePrice,
    required int stock,
    required String categoryId,
    required String subCategoryId,
    required String sellerId,
    required bool isFeatured,
    required List<String> existingImages, // Images to keep
    List<XFile>? newImages, // New images to add
    // New Fields
    bool isFreeDelivery = false,
    String? returnPolicy,
    String? warrantyPolicy,
    bool isTopBrand = false,
    bool isAssured = false,
    double rating = 0.0,
    int reviewCount = 0,
    int recentSalesCount = 0,
  }) async {
    debugPrint('🔵 [FirestoreService] updateProductFull started: $name');

    try {
      List<String> finalImageUrls = List.from(existingImages);

      // Convert new images to Base64
      if (newImages != null && newImages.isNotEmpty) {
        debugPrint(
          '🔵 [FirestoreService] Converting ${newImages.length} new images to Base64...',
        );
        for (int i = 0; i < newImages.length; i++) {
          final imageUrl = await _convertToBase64(newImages[i]);
          finalImageUrls.add(imageUrl);
        }
      }

      final updates = {
        'name': name,
        'description': description,
        'price': price,
        'salePrice': salePrice,
        'stock': stock,
        'categoryId': categoryId,
        'subCategoryId': subCategoryId,
        'sellerId': sellerId,
        'isFeatured': isFeatured,
        'images': finalImageUrls,
        // New Fields
        'isFreeDelivery': isFreeDelivery,
        'returnPolicy': returnPolicy,
        'warrantyPolicy': warrantyPolicy,
        'isTopBrand': isTopBrand,
        'isAssured': isAssured,
        'rating': rating,
        'reviewCount': reviewCount,
        'recentSalesCount': recentSalesCount,
      };

      await updateProduct(productId, updates);
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error updating product full: $e');
      throw Exception('Failed to update product: $e');
    }
  }

  /// Delete a product
  Future<void> deleteProduct(String productId) async {
    debugPrint('🔵 [FirestoreService] deleteProduct: $productId');

    try {
      // Delete product document
      await _firestore.collection('products').doc(productId).delete();
      debugPrint('✅ [FirestoreService] Product deleted successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error deleting product: $e');
      throw Exception('Failed to delete product: $e');
    }
  }

  /// Approve a product
  Future<void> approveProduct(String productId) async {
    debugPrint('🔵 [FirestoreService] approveProduct: $productId');
    try {
      await _firestore.collection('products').doc(productId).update({
        'isApproved': true,
        'isActive': true, // Typically approved products become visible
        'rejectionReason': FieldValue.delete(),
      });
      debugPrint('✅ [FirestoreService] Product approved');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error approving product: $e');
      throw Exception('Failed to approve product: $e');
    }
  }

  /// Reject a product with reason
  Future<void> rejectProduct(String productId, String reason) async {
    debugPrint('🔵 [FirestoreService] rejectProduct: $productId');
    try {
      await _firestore.collection('products').doc(productId).update({
        'isApproved': false,
        'isActive': false,
        'rejectionReason': reason,
      });
      debugPrint('✅ [FirestoreService] Product rejected');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error rejecting product: $e');
      throw Exception('Failed to reject product: $e');
    }
  }

  // ============================================
  // SALE OPERATIONS
  // ============================================

  /// Add a new sale
  /// Add a new sale campaign
  Future<String> addSale({
    required String name,
    String? description,
    required List<String> productIds,
    required double discountPercent,
    required DateTime startDate,
    required DateTime endDate,
    required String saleType,
    XFile? bannerImage,
  }) async {
    debugPrint('🔵 [FirestoreService] addSale started: $name');

    try {
      String? bannerUrl;
      if (bannerImage != null) {
        bannerUrl = await _convertToBase64(bannerImage);
      }

      final sale = SaleModel(
        id: '',
        name: name,
        description: description,
        bannerUrl: bannerUrl,
        productIds: productIds,
        discountPercent: discountPercent,
        startDate: startDate,
        endDate: endDate,
        saleType: saleType,
        isActive: true,
      );

      debugPrint('🔵 [FirestoreService] Creating sale document...');
      final docRef = await _firestore
          .collection('sales')
          .add(sale.toFirestore());
      debugPrint('✅ [FirestoreService] Sale created with ID: ${docRef.id}');

      return docRef.id;
    } catch (e, stackTrace) {
      debugPrint('❌ [FirestoreService] Error adding sale: $e');
      debugPrint('❌ [FirestoreService] Stack trace: $stackTrace');
      throw Exception('Failed to add sale: $e');
    }
  }

  /// Get sales with optional filtering
  Stream<List<SaleModel>> getSales({
    String? saleType,
    bool activeOnly = false,
    bool currentOnly = false,
  }) {
    debugPrint('🔵 [FirestoreService] getSales stream started');

    Query<Map<String, dynamic>> query = _firestore.collection('sales');

    if (saleType != null) {
      query = query.where('saleType', isEqualTo: saleType);
    }
    if (activeOnly) {
      query = query.where('isActive', isEqualTo: true);
    }
    if (currentOnly) {
      query = query.where('endDate', isGreaterThan: Timestamp.now());
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => SaleModel.fromFirestore(doc)).toList();
    });
  }

  /// Get products on sale by sale type
  Future<List<Product>> getProductsOnSale(String saleType) async {
    debugPrint('🔵 [FirestoreService] getProductsOnSale: $saleType');

    try {
      // Get active sales of the specified type
      final salesSnapshot = await _firestore
          .collection('sales')
          .where('saleType', isEqualTo: saleType)
          .where('isActive', isEqualTo: true)
          .where('endDate', isGreaterThan: Timestamp.now())
          .get();

      // Get unique product IDs from all active sales
      final Set<String> productIds = {};
      for (var doc in salesSnapshot.docs) {
        final sale = SaleModel.fromFirestore(doc);
        productIds.addAll(sale.productIds);
      }

      if (productIds.isEmpty) {
        return [];
      }

      final uniqueIds = productIds.toList();

      // Fetch products (Firestore 'in' query supports up to 10 items)
      // For more than 10, we need to batch the queries
      List<Product> products = [];
      for (int i = 0; i < uniqueIds.length; i += 10) {
        final batch = uniqueIds.skip(i).take(10).toList();
        final productsSnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        products.addAll(
          productsSnapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList(),
        );
      }

      return products;
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error getting products on sale: $e');
      throw Exception('Failed to get products on sale: $e');
    }
  }

  /// Get products by their IDs
  Future<List<Product>> getProductsByIds(List<String> productIds) async {
    debugPrint(
      '🔵 [FirestoreService] getProductsByIds: ${productIds.length} ids',
    );

    if (productIds.isEmpty) {
      return [];
    }

    try {
      List<Product> products = [];
      // Firestore 'in' query supports up to 10-30 items depending on Firestore version,
      // but to be safe we use 10 as used in getProductsOnSale.
      for (int i = 0; i < productIds.length; i += 10) {
        final batch = productIds.skip(i).take(10).toList();
        final productsSnapshot = await _firestore
            .collection('products')
            .where(FieldPath.documentId, whereIn: batch)
            .get();

        products.addAll(
          productsSnapshot.docs
              .map((doc) => Product.fromFirestore(doc))
              .toList(),
        );
      }

      return products;
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error getting products by IDs: $e');
      throw Exception('Failed to get products by IDs: $e');
    }
  }

  /// Update sale fields
  Future<void> updateSale(String saleId, Map<String, dynamic> updates) async {
    debugPrint('🔵 [FirestoreService] updateSale: $saleId');

    try {
      await _firestore.collection('sales').doc(saleId).update(updates);
      debugPrint('✅ [FirestoreService] Sale updated successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error updating sale: $e');
      throw Exception('Failed to update sale: $e');
    }
  }

  /// Delete a sale
  Future<void> deleteSale(String saleId) async {
    debugPrint('🔵 [FirestoreService] deleteSale: $saleId');

    try {
      await _firestore.collection('sales').doc(saleId).delete();
      debugPrint('✅ [FirestoreService] Sale deleted successfully');
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error deleting sale: $e');
      throw Exception('Failed to delete sale: $e');
    }
  }

  // ============================================
  // BULK OPERATIONS
  // ============================================

  /// Bulk add banners
  Future<void> addBulkBanners(List<Map<String, dynamic>> banners) async {
    debugPrint('🔵 [FirestoreService] addBulkBanners: ${banners.length}');
    final batch = _firestore.batch();
    for (final data in banners) {
      final docRef = _firestore.collection('banners').doc();
      batch.set(docRef, {
        ...data,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'priority': data['priority'] ?? 0,
        'linkType': data['linkType'] ?? 'none',
      });
    }
    await batch.commit();
    debugPrint('✅ [FirestoreService] Bulk banners added');
  }

  /// Bulk add categories
  Future<void> addBulkCategories(List<Map<String, dynamic>> categories) async {
    debugPrint('🔵 [FirestoreService] addBulkCategories: ${categories.length}');
    final batch = _firestore.batch();
    for (final data in categories) {
      final docRef = _firestore.collection('categories').doc();
      batch.set(docRef, {
        ...data,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
        'order': data['order'] ?? 0,
      });
    }
    await batch.commit();
    debugPrint('✅ [FirestoreService] Bulk categories added');
  }

  /// Bulk add subcategories
  Future<void> addBulkSubcategories(
    List<Map<String, dynamic>> subcategories,
  ) async {
    debugPrint(
      '🔵 [FirestoreService] addBulkSubcategories: ${subcategories.length}',
    );
    final batch = _firestore.batch();
    for (final data in subcategories) {
      final docRef = _firestore.collection('subcategories').doc();
      batch.set(docRef, {
        ...data,
        'isActive': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    await batch.commit();
    debugPrint('✅ [FirestoreService] Bulk subcategories added');
  }

  /// Bulk add products
  Future<void> addBulkProducts(List<Map<String, dynamic>> products) async {
    debugPrint('🔵 [FirestoreService] addBulkProducts: ${products.length}');

    final chunks = _chunkList(products, 490); // Batch limit is 500

    for (final chunk in chunks) {
      final batch = _firestore.batch();
      for (final data in chunk) {
        final docRef = _firestore.collection('products').doc();
        batch.set(docRef, {
          ...data,
          'isActive': data['isActive'] ?? true,
          'isApproved': data['isApproved'] ?? true,
          'createdByRole': 'admin',
          'createdAt': FieldValue.serverTimestamp(),
          'price': _toDouble(data['price']),
          'salePrice': _toDouble(data['salePrice']),
          'stock': _toInt(data['stock']),
          'rating': _toDouble(data['rating']),
          'reviewCount': _toInt(data['reviewCount']),
          'recentSalesCount': _toInt(data['recentSalesCount']),
        });
      }
      await batch.commit();
    }
    debugPrint('✅ [FirestoreService] Bulk products added');
  }

  List<List<T>> _chunkList<T>(List<T> list, int chunkSize) {
    List<List<T>> chunks = [];
    for (var i = 0; i < list.length; i += chunkSize) {
      chunks.add(
        list.sublist(
          i,
          i + chunkSize > list.length ? list.length : i + chunkSize,
        ),
      );
    }
    return chunks;
  }

  double? _toDouble(dynamic v) {
    if (v == null) return null;
    if (v is double) return v;
    if (v is int) return v.toDouble();
    if (v is String) return double.tryParse(v);
    return null;
  }

  int _toInt(dynamic v) {
    if (v == null) return 0;
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  // ============================================
  // PRIVATE HELPER METHODS
  // ============================================

  /// Convert image to Base64 string
  Future<String> _convertToBase64(XFile image) async {
    try {
      final Uint8List bytes = await image.readAsBytes();
      return base64Encode(bytes);
    } catch (e) {
      debugPrint('❌ [FirestoreService] Error converting image to Base64: $e');
      throw Exception('Failed to process image: $e');
    }
  }
}
