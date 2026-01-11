import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Product model
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String image;
  final String category;
  final double? rating;
  final int? reviewCount;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.image,
    required this.category,
    this.rating,
    this.reviewCount,
  });

  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      category: data['category'] ?? '',
      rating: data['rating']?.toDouble(),
      reviewCount: data['reviewCount'],
    );
  }
}

// Provider for all products
final productsProvider = StreamProvider<List<Product>>((ref) {
  return FirebaseFirestore.instance
      .collection('products')
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
      );
});

// Provider for products by category
final productsByCategoryProvider = StreamProvider.family<List<Product>, String>(
  (ref, category) {
    return FirebaseFirestore.instance
        .collection('products')
        .where('category', isEqualTo: category)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => Product.fromFirestore(doc)).toList(),
        );
  },
);

// Provider for single product details
final productDetailProvider = StreamProvider.family<Product?, String>((
  ref,
  productId,
) {
  return FirebaseFirestore.instance
      .collection('products')
      .doc(productId)
      .snapshots()
      .map((snapshot) {
        if (snapshot.exists) {
          return Product.fromFirestore(snapshot);
        }
        return null;
      });
});

// Search results state
class SearchState {
  final String query;
  final List<Product> results;
  final bool isLoading;

  SearchState({
    required this.query,
    required this.results,
    required this.isLoading,
  });

  SearchState copyWith({
    String? query,
    List<Product>? results,
    bool? isLoading,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

// StateNotifier for search
class SearchNotifier extends StateNotifier<SearchState> {
  SearchNotifier()
    : super(SearchState(query: '', results: [], isLoading: false));

  Future<void> search(String query) async {
    if (query.isEmpty) {
      state = SearchState(query: '', results: [], isLoading: false);
      return;
    }

    state = state.copyWith(query: query, isLoading: true);

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .where('name', isGreaterThanOrEqualTo: query)
          .where('name', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      final results = snapshot.docs
          .map((doc) => Product.fromFirestore(doc))
          .toList();
      state = state.copyWith(results: results, isLoading: false);
    } catch (e) {
      state = state.copyWith(results: [], isLoading: false);
    }
  }

  void clear() {
    state = SearchState(query: '', results: [], isLoading: false);
  }
}

// Provider for search
final searchProvider = StateNotifierProvider<SearchNotifier, SearchState>((
  ref,
) {
  return SearchNotifier();
});
