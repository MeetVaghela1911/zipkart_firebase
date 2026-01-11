import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/firebase_cloud/firestore_service.dart';
import 'package:zipkart_firebase/Models/banner_model.dart';
import 'package:zipkart_firebase/Models/category_model.dart';
import 'package:zipkart_firebase/Models/subcategory_model.dart';
import 'package:zipkart_firebase/Models/Product.dart';
import 'package:zipkart_firebase/Models/sale_model.dart';
import 'package:zipkart_firebase/Models/app_user.dart';

// ============================================
// FIRESTORE SERVICE PROVIDER
// ============================================

/// Global Firestore service provider
///
/// This is the single source of truth for Firestore operations
final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

// ============================================
// BANNER PROVIDERS
// ============================================

/// Stream provider for all banners (active only)
final bannersStreamProvider = StreamProvider<List<BannerModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getBanners(activeOnly: true);
});

/// Stream provider for all banners (including inactive)
final allBannersStreamProvider = StreamProvider<List<BannerModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getBanners(activeOnly: false);
});

// ============================================
// CATEGORY PROVIDERS
// ============================================

/// Stream provider for all categories (active only)
final categoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getCategories(activeOnly: true);
});

/// Stream provider for all categories (including inactive)
final allCategoriesStreamProvider = StreamProvider<List<CategoryModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getCategories(activeOnly: false);
});

// ============================================
// SUBCATEGORY PROVIDERS
// ============================================

/// Stream provider for subcategories by category ID
final subcategoriesStreamProvider =
    StreamProvider.family<List<SubcategoryModel>, String>((ref, categoryId) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getSubcategories(categoryId, activeOnly: true);
    });

/// Stream provider for all subcategories
final allSubcategoriesStreamProvider = StreamProvider<List<SubcategoryModel>>((
  ref,
) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getAllSubcategories(activeOnly: false);
});

// ============================================
// PRODUCT PROVIDERS
// ============================================

/// Stream provider for all products
final allProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getProducts();
});

/// Stream provider for active products only
final activeProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getProducts(activeOnly: true);
});

/// Stream provider for featured products
final featuredProductsStreamProvider = StreamProvider<List<Product>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getProducts(activeOnly: true, featuredOnly: true);
});

/// Stream provider for products by category
final productsByCategoryStreamProvider =
    StreamProvider.family<List<Product>, String>((ref, categoryId) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getProducts(categoryId: categoryId, activeOnly: true);
    });

/// Stream provider for products by subcategory
final productsBySubcategoryStreamProvider =
    StreamProvider.family<List<Product>, String>((ref, subCategoryId) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getProducts(
        subCategoryId: subCategoryId,
        activeOnly: true,
      );
    });

/// Stream provider for products by seller
final productsBySellerStreamProvider =
    StreamProvider.family<List<Product>, String>((ref, sellerId) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getProducts(sellerId: sellerId);
    });

// ============================================
// SELLER PROVIDERS
// ============================================

/// Stream provider for all sellers
final sellersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getSellers();
});

/// Stream provider for all users
final allUsersStreamProvider = StreamProvider<List<AppUser>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getAllUsers();
});

// ============================================
// SALE PROVIDERS
// ============================================

/// Stream provider for all sales
final allSalesStreamProvider = StreamProvider<List<SaleModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getSales();
});

/// Stream provider for active sales only
final activeSalesStreamProvider = StreamProvider<List<SaleModel>>((ref) {
  final service = ref.watch(firestoreServiceProvider);
  return service.getSales(activeOnly: true, currentOnly: true);
});

/// Stream provider for sales by type
final salesByTypeStreamProvider =
    StreamProvider.family<List<SaleModel>, String>((ref, saleType) {
      final service = ref.watch(firestoreServiceProvider);
      return service.getSales(
        saleType: saleType,
        activeOnly: true,
        currentOnly: true,
      );
    });

/// Stream provider for flash sale products
final flashSaleProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getProductsOnSale('flash');
});

/// Stream provider for mega sale products
final megaSaleProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getProductsOnSale('mega');
});

/// Stream provider for seasonal sale products
final seasonalSaleProductsProvider = FutureProvider<List<Product>>((ref) async {
  final service = ref.watch(firestoreServiceProvider);
  return service.getProductsOnSale('seasonal');
});

/// Future provider for products by IDs
final productsByIdsProvider =
    FutureProvider.family<List<Product>, List<String>>((ref, ids) async {
      final service = ref.watch(firestoreServiceProvider);
      return service.getProductsByIds(ids);
    });
