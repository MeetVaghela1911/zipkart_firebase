abstract class CartRepository {
  Future<List<String>> fetchCartItemIds();
  Future<void> addItem(String id);
  Future<void> removeItem(String id);
}

