import 'dart:convert';
import 'dart:typed_data';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipkart_firebase/Models/Product.dart';
import 'package:zipkart_firebase/Models/Order.dart';

class FirebaseService {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref();
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload image to Firebase Storage
  Future<String> uploadImageToStorage(XFile image) async {
    Uint8List bytes = await image.readAsBytes();
    final base64Image = base64Encode(bytes);

    // final storageRef =
    //     _storage.ref().child('product_images/${image.path.split('/').last}');
    // await storageRef.putFile(image);
    // return await storageRef.getDownloadURL();
    return base64Image;
  }

  Future<List<String>> fetchBannerImages() async {
    final DatabaseReference database =
        FirebaseDatabase.instance.ref('Admin/Banners/Bannerimgs');

    final DataSnapshot snapshot = await database.get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      // Convert the map to a list of URLs
      return data.values
          .map<String>((value) => value['url'] as String)
          .toList();
    } else {
      return [];
    }
  }

  // Add product to Firebase Realtime Database under the seller's ID
  Future<void> addProduct(Product product) async {
    final productId = _databaseRef.child('sellers/products').push().key;
    if (productId != null) {
      await _databaseRef
          .child('sellers/${product.sellerId}/products/$productId')
          .set(product.toJson());
    }
  }

  // Update an existing product
  Future<void> updateProduct(Product product) async {
    await _databaseRef
        .child('sellers/${product.sellerId}/products/${product.id}')
        .update(product.toJson());
  }

  // Delete a product
  Future<void> deleteProduct(String sellerId, String productId) async {
    await _databaseRef.child('sellers/$sellerId/products/$productId').remove();
  }

// Fetch all products by category and subcategory
// Fetch all products for a specific seller
  Stream<List<Product>> getProductsBySeller(String sellerId) {
    return _databaseRef
        .child('sellers/$sellerId/products')
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      debugPrint("Raw data from Firebase: $data");

      if (data == null) {
        debugPrint("No products found.");
        return [];
      }

      final products = data.entries
          .map((entry) {
            final productData = entry.value as Map<dynamic, dynamic>;
            debugPrint("Processing product entry: $productData");
            // if (productData['sellerId'] == sellerId) {
            try {
              return Product.fromMap(productData, entry.key as String);
            } catch (e) {
              debugPrint("Error parsing product: $e");
              return null;
            }
            // }
            // return null;
          })
          .whereType<Product>()
          .toList();

      debugPrint("Products after mapping: $products");
      return products;
    });
  }

  // Update order status in Realtime Database
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _databaseRef.child('orders/$orderId').update({'status': status});
  }

  // Fetch all orders for a specific seller
  Stream<List<Orders>> getOrders(String sellerId) {
    return _databaseRef
        .child('orders')
        .orderByChild('sellerId')
        .equalTo(sellerId)
        .onValue
        .map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return [];
      return data.entries.map((entry) {
        final orderData = entry.value as Map<String, dynamic>;
        return Orders.fromMap(orderData, entry.key as String);
      }).toList();
    });
  }

  // Fetch all categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    final snapshot = await _databaseRef.child('categories').get();
    if (snapshot.exists) {
      final data = snapshot.value as Map<dynamic, dynamic>;
      return data.entries.map((entry) {
        final categoryData = entry.value as Map<dynamic, dynamic>;
        return {
          'categoryId': entry.key,
          'name': categoryData['name'],
          'subcategories':
              List<String>.from(categoryData['subcategories'] ?? []),
        };
      }).toList();
    }
    return [];
  }

  // Fetch subcategories for a given category
  Future<List<String>> getSubcategories(String? categoryId) async {
    if (categoryId == null) return [];
    final snapshot =
        await _databaseRef.child('categories/$categoryId/subcategories').get();
    if (snapshot.exists) {
      final subcategories = snapshot.value as List<dynamic>;
      return List<String>.from(subcategories);
    }
    return [];
  }
}
