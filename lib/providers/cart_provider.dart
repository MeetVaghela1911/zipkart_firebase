import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Cart item model
class CartItem {
  final String id;
  final String productId;
  final String name;
  final String image;
  final double price;
  final int quantity;

  CartItem({
    required this.id,
    required this.productId,
    required this.name,
    required this.image,
    required this.price,
    required this.quantity,
  });

  CartItem copyWith({
    String? id,
    String? productId,
    String? name,
    String? image,
    double? price,
    int? quantity,
  }) {
    return CartItem(
      id: id ?? this.id,
      productId: productId ?? this.productId,
      name: name ?? this.name,
      image: image ?? this.image,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'image': image,
      'price': price,
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map, String docId) {
    return CartItem(
      id: docId,
      productId: map['productId'] ?? '',
      name: map['name'] ?? '',
      image: map['image'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      quantity: map['quantity'] ?? 1,
    );
  }
}

// StateNotifier for managing cart items
class CartNotifier extends StateNotifier<List<CartItem>> {
  final String userId;
  final FirebaseFirestore firestore;

  CartNotifier({required this.userId, required this.firestore}) : super([]) {
    _loadCart();
  }

  // Load cart from Firestore
  Future<void> _loadCart() async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .get();

    state = snapshot.docs
        .map((doc) => CartItem.fromMap(doc.data(), doc.id))
        .toList();
  }

  // Add item to cart
  Future<void> addItem(CartItem item) async {
    final existingIndex = state.indexWhere((i) => i.productId == item.productId);

    if (existingIndex >= 0) {
      // Update quantity if item exists
      final updatedItem = state[existingIndex].copyWith(
        quantity: state[existingIndex].quantity + 1,
      );
      
      await firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .doc(updatedItem.id)
          .update({'quantity': updatedItem.quantity});

      state = [
        ...state.sublist(0, existingIndex),
        updatedItem,
        ...state.sublist(existingIndex + 1),
      ];
    } else {
      // Add new item
      final docRef = await firestore
          .collection('users')
          .doc(userId)
          .collection('cart')
          .add(item.toMap());

      final newItem = item.copyWith(id: docRef.id);
      state = [...state, newItem];
    }
  }

  // Update item quantity
  Future<void> updateQuantity(String itemId, int quantity) async {
    if (quantity <= 0) {
      await removeItem(itemId);
      return;
    }

    await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(itemId)
        .update({'quantity': quantity});

    state = [
      for (final item in state)
        if (item.id == itemId) item.copyWith(quantity: quantity) else item,
    ];
  }

  // Remove item from cart
  Future<void> removeItem(String itemId) async {
    await firestore
        .collection('users')
        .doc(userId)
        .collection('cart')
        .doc(itemId)
        .delete();

    state = state.where((item) => item.id != itemId).toList();
  }

  // Clear cart
  Future<void> clearCart() async {
    final batch = firestore.batch();
    for (final item in state) {
      batch.delete(
        firestore.collection('users').doc(userId).collection('cart').doc(item.id),
      );
    }
    await batch.commit();
    state = [];
  }
}

// Provider for cart items
final cartProvider = StateNotifierProvider.family<CartNotifier, List<CartItem>, String>(
  (ref, userId) {
    return CartNotifier(
      userId: userId,
      firestore: FirebaseFirestore.instance,
    );
  },
);

// Provider for cart total
final cartTotalProvider = Provider.family<double, String>((ref, userId) {
  final cartItems = ref.watch(cartProvider(userId));
  return cartItems.fold(0.0, (sum, item) => sum + (item.price * item.quantity));
});

// Provider for cart count
final cartCountProvider = Provider.family<int, String>((ref, userId) {
  final cartItems = ref.watch(cartProvider(userId));
  return cartItems.fold(0, (sum, item) => sum + item.quantity);
});
