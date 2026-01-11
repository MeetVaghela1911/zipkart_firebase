import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/cart_repository_impl.dart';
import '../domain/repositories/cart_repository.dart';
import '../presentation/notifier/cart_notifier.dart';

final cartRepositoryProvider = Provider<CartRepository>((ref) {
  return CartRepositoryImpl();
});

final cartNotifierProvider =
    StateNotifierProvider<CartNotifier, AsyncValue<List<String>>>((ref) {
  final repo = ref.watch(cartRepositoryProvider);
  return CartNotifier(repo);
});

