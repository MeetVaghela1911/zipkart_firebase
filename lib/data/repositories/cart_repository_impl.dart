import '../../domain/repositories/cart_repository.dart';

class CartRepositoryImpl implements CartRepository {
  final List<String> _items = [];

  @override
  Future<List<String>> fetchCartItemIds() async {
    await Future.delayed(const Duration(milliseconds: 150));
    return List.unmodifiable(_items);
  }

  @override
  Future<void> addItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _items.add(id);
  }

  @override
  Future<void> removeItem(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    _items.remove(id);
  }
}

