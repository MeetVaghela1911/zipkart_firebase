import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/repositories/cart_repository.dart';

class CartNotifier extends StateNotifier<AsyncValue<List<String>>> {
  final CartRepository _repo;

  CartNotifier(this._repo) : super(const AsyncValue.loading()) {
    _load();
  }

  Future<void> _load() async {
    try {
      final items = await _repo.fetchCartItemIds();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> add(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.addItem(id);
      final items = await _repo.fetchCartItemIds();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> remove(String id) async {
    state = const AsyncValue.loading();
    try {
      await _repo.removeItem(id);
      final items = await _repo.fetchCartItemIds();
      state = AsyncValue.data(items);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

