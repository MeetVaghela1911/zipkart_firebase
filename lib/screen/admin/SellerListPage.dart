import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class SellersListScreen extends ConsumerStatefulWidget {
  const SellersListScreen({super.key});

  @override
  ConsumerState<SellersListScreen> createState() => _SellersListScreenState();
}

class _SellersListScreenState extends ConsumerState<SellersListScreen> {
  final Map<String, List<String>> selectedProductsBySeller = {};

  @override
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('User Management'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Sellers'),
              Tab(text: 'All Users'),
            ],
          ),
        ),
        body: TabBarView(children: [_buildSellersTab(), _buildUsersTab()]),
      ),
    );
  }

  Widget _buildSellersTab() {
    final sellersAsync = ref.watch(sellersStreamProvider);

    return sellersAsync.when(
      data: (sellers) {
        if (sellers.isEmpty) {
          return const Center(child: Text('No sellers found.'));
        }
        return ListView.builder(
          itemCount: sellers.length,
          itemBuilder: (context, index) {
            final seller = sellers[index];
            return Card(
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: ListTile(
                title: Row(
                  children: [
                    Text(
                      seller.username.isNotEmpty
                          ? seller.username
                          : 'Seller ID: ${seller.uid}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    _buildStatusChip(seller),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(seller.email),
                    if (selectedProductsBySeller[seller.uid]?.isNotEmpty ??
                        false)
                      Text(
                        '${selectedProductsBySeller[seller.uid]!.length} products selected',
                        style: const TextStyle(color: Colors.green),
                      ),
                  ],
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Action Buttons
                    if (!seller.isApproved)
                      IconButton(
                        icon: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                        tooltip: 'Approve Seller',
                        onPressed: () => _approveSeller(seller.uid),
                      ),
                    if (seller.isApproved)
                      IconButton(
                        icon: const Icon(Icons.block, color: Colors.orange),
                        tooltip: 'Revoke/Reject',
                        onPressed: () => _rejectSeller(seller.uid),
                      ),
                    if (seller.isActive)
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        tooltip: 'Disable Account',
                        onPressed: () => _disableSeller(seller.uid),
                      ),

                    const VerticalDivider(),
                    IconButton(
                      icon: const Icon(Icons.inventory),
                      tooltip: 'View Products',
                      onPressed: () => _navigateToProducts(seller.uid),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildUsersTab() {
    final usersAsync = ref.watch(allUsersStreamProvider);

    return usersAsync.when(
      data: (users) {
        final nonSellers = users
            .where((u) => u.role != 'seller' && u.role != 'admin')
            .toList();

        if (nonSellers.isEmpty) {
          return const Center(child: Text('No potential sellers found.'));
        }
        return ListView.builder(
          itemCount: nonSellers.length,
          itemBuilder: (context, index) {
            final user = nonSellers[index];
            return ListTile(
              title: Text(user.username.isNotEmpty ? user.username : user.uid),
              subtitle: Text('${user.email} (${user.role})'),
              trailing: ElevatedButton(
                child: const Text('Make Seller'),
                onPressed: () => _makeUserSeller(user.uid),
              ),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildStatusChip(dynamic seller) {
    if (seller.isApproved) {
      return const Chip(
        label: Text(
          'Approved',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: Colors.green,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    } else if (!seller.isActive) {
      return const Chip(
        label: Text(
          'Disabled',
          style: TextStyle(fontSize: 10, color: Colors.white),
        ),
        backgroundColor: Colors.red,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    } else {
      return const Chip(
        label: Text('Pending', style: TextStyle(fontSize: 10)),
        backgroundColor: Colors.amber,
        padding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      );
    }
  }

  Future<void> _approveSeller(String uid) async {
    try {
      await ref.read(firestoreServiceProvider).approveSeller(uid);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Seller approved')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _rejectSeller(String uid) async {
    try {
      await ref.read(firestoreServiceProvider).rejectSeller(uid);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Seller rejected')));
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _disableSeller(String uid) async {
    try {
      await ref.read(firestoreServiceProvider).disableSeller(uid);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Seller disabled')));
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _makeUserSeller(String uid) async {
    try {
      await ref.read(firestoreServiceProvider).makeUserSeller(uid);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('User converted to seller')),
        );
      }
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _navigateToProducts(String sellerId) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SellerProductsScreen(sellerId: sellerId),
      ),
    );

    if (result != null) {
      setState(() {
        selectedProductsBySeller[sellerId] = result as List<String>;
      });
    }
  }
}

class SellerProductsScreen extends ConsumerStatefulWidget {
  final String sellerId;

  const SellerProductsScreen({super.key, required this.sellerId});

  @override
  ConsumerState<SellerProductsScreen> createState() =>
      _SellerProductsScreenState();
}

class _SellerProductsScreenState extends ConsumerState<SellerProductsScreen> {
  final Map<String, bool> selectedProducts = {};

  @override
  Widget build(BuildContext context) {
    final productsAsync = ref.watch(
      productsBySellerStreamProvider(widget.sellerId),
    );

    return Scaffold(
      appBar: AppBar(
        title: Text('Products of ${widget.sellerId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: () async {
              List<String> selectedProductIds = selectedProducts.keys
                  .where((productId) => selectedProducts[productId]!)
                  .toList();

              // For now, mirroring the old logic of just popping back or showing success
              // The user request was about loading issues, which this refactor fixes
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Selection captured')),
                );
                Navigator.pop(context, selectedProductIds);
              }
            },
          ),
        ],
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Text('No products found for this seller.'),
            );
          }
          return ListView.builder(
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              final productId = product.id;

              // Initialize the state for checkboxes if not already set
              selectedProducts.putIfAbsent(productId, () => false);

              return CheckboxListTile(
                secondary:
                    product.images.isNotEmpty && product.images[0].isNotEmpty
                    ? Image.memory(
                        base64Decode(product.images[0]),
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      )
                    : const Icon(Icons.image),
                title: Text(product.name),
                subtitle: Text('Price: \$${product.price}'),
                value: selectedProducts[productId],
                onChanged: (bool? isChecked) {
                  setState(() {
                    selectedProducts[productId] = isChecked ?? false;
                  });
                },
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
