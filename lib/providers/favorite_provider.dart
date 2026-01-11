import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateNotifier for managing favorites
class FavoritesNotifier extends StateNotifier<List<String>> {
  final String userId;
  final FirebaseFirestore firestore;

  FavoritesNotifier({required this.userId, required this.firestore}) : super([]) {
    _loadFavorites();
  }

  // Load favorites from Firestore
  Future<void> _loadFavorites() async {
    final snapshot = await firestore
        .collection('users')
        .doc(userId)
        .collection('favorites')
        .get();

    state = snapshot.docs.map((doc) => doc.id).toList();
  }

  // Toggle favorite status
  Future<void> toggleFavorite(String productId) async {
    if (state.contains(productId)) {
      // Remove from favorites
      await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .delete();

      state = state.where((id) => id != productId).toList();
    } else {
      // Add to favorites
      await firestore
          .collection('users')
          .doc(userId)
          .collection('favorites')
          .doc(productId)
          .set({'addedAt': FieldValue.serverTimestamp()});

      state = [...state, productId];
    }
  }

  // Check if product is favorited
  bool isFavorite(String productId) {
    return state.contains(productId);
  }
}

// Provider for favorites
final favoritesProvider = StateNotifierProvider.family<FavoritesNotifier, List<String>, String>(
  (ref, userId) {
    return FavoritesNotifier(
      userId: userId,
      firestore: FirebaseFirestore.instance,
    );
  },
);

// Provider to check if a specific product is favorited
final isFavoriteProvider = Provider.family<bool, ({String userId, String productId})>((ref, params) {
  final favorites = ref.watch(favoritesProvider(params.userId));
  return favorites.contains(params.productId);
});
