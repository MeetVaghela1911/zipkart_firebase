// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../providers/auth_provider.dart';
// import '../../providers/cart_provider.dart';
// import '../../providers/favorite_provider.dart';
//
// class CartScreen extends ConsumerWidget {
//   const CartScreen({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final currentUser = ref.watch(currentUserProvider);
//
//     if (currentUser == null) {
//       return const Scaffold(
//         body: Center(child: Text('Please log in to view your cart')),
//       );
//     }
//
//     final cartItems = ref.watch(cartProvider(currentUser.uid));
//     final cartTotal = ref.watch(cartTotalProvider(currentUser.uid));
//
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Your Cart"),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 10.0),
//         child: cartItems.isEmpty
//             ? const Center(child: Text("Your cart is empty."))
//             : SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 2),
//                     ListView.builder(
//                       shrinkWrap: true,
//                       physics: const NeverScrollableScrollPhysics(),
//                       itemCount: cartItems.length,
//                       itemBuilder: (context, index) {
//                         final item = cartItems[index];
//                         return OrderProductCard(
//                           userId: currentUser.uid,
//                           item: item,
//                         );
//                       },
//                     ),
//                     PriceSummary(total: cartTotal),
//                     const SizedBox(height: 8),
//                     const CheckoutButton(),
//                   ],
//                 ),
//               ),
//       ),
//     );
//   }
// }
//
// class OrderProductCard extends ConsumerWidget {
//   final String userId;
//   final CartItem item;
//
//   const OrderProductCard({
//     super.key,
//     required this.userId,
//     required this.item,
//   });
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final isFav = ref.watch(isFavoriteProvider((userId: userId, productId: item.productId)));
//
//     return Container(
//       padding: const EdgeInsets.all(8.0),
//       margin: const EdgeInsets.all(4),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.grey[300]!),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 100,
//             height: 100,
//             decoration: BoxDecoration(
//               color: Colors.grey[300],
//               borderRadius: BorderRadius.circular(20),
//               image: DecorationImage(
//                 image: NetworkImage(item.image),
//                 fit: BoxFit.cover,
//               ),
//             ),
//           ),
//           const SizedBox(width: 10),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   item.name,
//                   style: const TextStyle(fontWeight: FontWeight.bold),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   '\$${item.price.toStringAsFixed(2)}',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                     color: Colors.blue,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Column(
//             children: [
//               Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.grey),
//                     onPressed: () {
//                       ref.read(cartProvider(userId).notifier).removeItem(item.id);
//                     },
//                   ),
//                   IconButton(
//                     icon: Icon(
//                       isFav ? Icons.favorite : Icons.favorite_outline,
//                       color: isFav ? Colors.red : Colors.grey,
//                     ),
//                     onPressed: () {
//                       ref.read(favoritesProvider(userId).notifier).toggleFavorite(item.productId);
//                     },
//                   ),
//                 ],
//               ),
//               Row(
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.remove, color: Colors.grey),
//                     onPressed: () {
//                       ref.read(cartProvider(userId).notifier).updateQuantity(item.id, item.quantity - 1);
//                     },
//                   ),
//                   Text("${item.quantity}"),
//                   IconButton(
//                     icon: const Icon(Icons.add, color: Colors.grey),
//                     onPressed: () {
//                       ref.read(cartProvider(userId).notifier).updateQuantity(item.id, item.quantity + 1);
//                     },
//                   ),
//                 ],
//               )
//             ],
//           )
//         ],
//       ),
//     );
//   }
// }
//
// class PriceSummary extends StatelessWidget {
//   final double total;
//
//   const PriceSummary({super.key, required this.total});
//
//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.grey[100],
//         borderRadius: BorderRadius.circular(8.0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           SummaryRow(
//             label: 'Total Price',
//             value: '\$${total.toStringAsFixed(2)}',
//             isTotal: true,
//           ),
//         ],
//       ),
//     );
//   }
// }
//
// class CheckoutButton extends StatelessWidget {
//   const CheckoutButton({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       width: double.infinity,
//       child: ElevatedButton(
//         onPressed: () {
//           Navigator.pushNamed(context, '/Payment');
//         },
//         style: ElevatedButton.styleFrom(
//           padding: const EdgeInsets.symmetric(vertical: 20.0),
//           backgroundColor: Colors.blue,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(8.0),
//           ),
//         ),
//         child: const Text(
//           'Check Out',
//           style: TextStyle(fontSize: 16, color: Colors.white),
//         ),
//       ),
//     );
//   }
// }
//
// class SummaryRow extends StatelessWidget {
//   final String label;
//   final String value;
//   final bool isTotal;
//
//   const SummaryRow({
//     super.key,
//     required this.label,
//     required this.value,
//     this.isTotal = false,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           label,
//           style: TextStyle(
//             fontSize: 16,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//         Text(
//           value,
//           style: TextStyle(
//             fontSize: 16,
//             color: isTotal ? Colors.blue : Colors.black,
//             fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
//           ),
//         ),
//       ],
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/core/globle_provider/TheameMode.dart';
import 'package:zipkart_firebase/core/theme/AppColors.dart';

const bool USE_DUMMY_DATA = true;

/// =======================================================
/// MODELS
/// =======================================================

class DummyUser {
  final String uid;
  DummyUser(this.uid);
}

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

  CartItem copyWith({int? quantity}) {
    return CartItem(
      id: id,
      productId: productId,
      name: name,
      image: image,
      price: price,
      quantity: quantity ?? this.quantity,
    );
  }
}

/// =======================================================
/// DUMMY PROVIDERS
/// =======================================================

final dummyUserProvider = Provider((_) => DummyUser('dummy_user'));

final dummyCartProvider =
    StateNotifierProvider<DummyCartNotifier, List<CartItem>>(
      (_) => DummyCartNotifier(),
    );

class DummyCartNotifier extends StateNotifier<List<CartItem>> {
  DummyCartNotifier()
    : super([
        CartItem(
          id: '1',
          productId: 'p1',
          name: 'Wireless Headphones',
          image: 'https://picsum.photos/200',
          price: 59.99,
          quantity: 1,
        ),
        CartItem(
          id: '2',
          productId: 'p2',
          name: 'Smart Watch',
          image: 'https://picsum.photos/201',
          price: 129.99,
          quantity: 2,
        ),
        CartItem(
          id: '1',
          productId: 'p1',
          name: 'Wireless Headphones',
          image: 'https://picsum.photos/200',
          price: 59.99,
          quantity: 1,
        ),
        CartItem(
          id: '2',
          productId: 'p2',
          name: 'Smart Watch',
          image: 'https://picsum.photos/201',
          price: 129.99,
          quantity: 2,
        ),
        CartItem(
          id: '1',
          productId: 'p1',
          name: 'Wireless Headphones',
          image: 'https://picsum.photos/200',
          price: 59.99,
          quantity: 1,
        ),
        CartItem(
          id: '2',
          productId: 'p2',
          name: 'Smart Watch',
          image: 'https://picsum.photos/201',
          price: 129.99,
          quantity: 2,
        ),
      ]);

  void updateQty(String id, int qty) {
    if (qty <= 0) return;
    state = state
        .map((e) => e.id == id ? e.copyWith(quantity: qty) : e)
        .toList();
  }

  void remove(String id) {
    state = state.where((e) => e.id != id).toList();
  }
}

final dummyTotalProvider = Provider<double>((ref) {
  final items = ref.watch(dummyCartProvider);
  return items.fold(0, (s, e) => s + e.price * e.quantity);
});

final dummyFavoriteProvider = StateProvider<Set<String>>((_) => {'p1'});

/// =======================================================
/// CART SCREEN (RESPONSIVE ROOT)
/// =======================================================

class CartScreen extends ConsumerWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cartItems = ref.watch(dummyCartProvider);
    final total = ref.watch(dummyTotalProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Your Cart')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 1024) {
            return _DesktopCart(items: cartItems, total: total);
          } else {
            return _MobileTabletCart(items: cartItems, total: total);
          }
        },
      ),
    );
  }
}

/// =======================================================
/// MOBILE / TABLET LAYOUT
/// =======================================================

class _MobileTabletCart extends StatelessWidget {
  final List<CartItem> items;
  final double total;

  const _MobileTabletCart({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (_, i) => OrderProductCard(item: items[i]),
          ),
        ),
        PriceSummary(total: total),
        const CheckoutButton(),
      ],
    );
  }
}

/// =======================================================
/// DESKTOP LAYOUT
/// =======================================================

class _DesktopCart extends StatelessWidget {
  final List<CartItem> items;
  final double total;

  const _DesktopCart({required this.items, required this.total});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// CART ITEMS
            Expanded(
              flex: 3,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (_, i) => OrderProductCard(item: items[i]),
              ),
            ),

            /// SUMMARY
            Expanded(
              flex: 1,
              child: Column(
                children: [
                  PriceSummary(total: total),
                  const CheckoutButton(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// CART ITEM CARD
/// =======================================================

class OrderProductCard extends ConsumerWidget {
  final CartItem item;

  const OrderProductCard({super.key, required this.item});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFav = ref.watch(dummyFavoriteProvider).contains(item.productId);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                item.image,
                width: 90,
                height: 90,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '\$${item.price}',
                    style: TextStyle(
                      color: isDarkTheme
                          ? AppColors.dark.colorPrimary
                          : AppColors.light.colorPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          ref
                              .read(dummyCartProvider.notifier)
                              .updateQty(item.id, item.quantity - 1);
                        },
                      ),
                      Text('${item.quantity}'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          ref
                              .read(dummyCartProvider.notifier)
                              .updateQty(item.id, item.quantity + 1);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Column(
              children: [
                IconButton(
                  icon: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : Colors.grey,
                  ),
                  onPressed: () {
                    // final favs =
                    // ref.read(dummyFavoriteProvider.notifier);
                    // favs.state = isFav
                    //     ? {...favs.state}..remove(item.productId)
                    //     : {...favs.state, item.productId};
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    ref.read(dummyCartProvider.notifier).remove(item.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// PRICE SUMMARY
/// =======================================================

class PriceSummary extends StatelessWidget {
  final double total;

  const PriceSummary({super.key, required this.total});

  @override
  Widget build(BuildContext context) {
    return Card(
      // padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(12),
      // decoration: BoxDecoration(
      //   color: Colors.grey.shade100,
      // borderRadius: BorderRadius.circular(12),
      // ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Total',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              '\$${total.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================================================
/// CHECKOUT BUTTON
/// =======================================================

class CheckoutButton extends StatelessWidget {
  const CheckoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 18),
          ),
          child: const Text('Checkout'),
        ),
      ),
    );
  }
}
