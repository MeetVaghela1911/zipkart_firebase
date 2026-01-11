import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/Models/Product.dart';
import 'package:zipkart_firebase/admin/screens/add_product_screen.dart';
import 'package:zipkart_firebase/admin/widgets/admin_section_header.dart';
import 'package:zipkart_firebase/admin/widgets/responsive_grid.dart';
import 'package:zipkart_firebase/admin/widgets/bulk_import_dialog.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class ProductSection extends ConsumerWidget {
  const ProductSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsAsync = ref.watch(allProductsStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: 'Products',
          onAddPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AddProductScreen()),
            );
          },
          onBulkImportPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  const BulkImportDialog(type: ImportType.product),
            );
          },
        ),
        productsAsync.when(
          data: (products) {
            if (products.isEmpty) {
              return const Center(child: Text('No products found'));
            }
            return ResponsiveGrid<Product>(
              items: products,
              itemBuilder: (context, product) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddProductScreen(product: product),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Stack(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                  top: Radius.circular(12),
                                ),
                                child: product.images.isNotEmpty
                                    ? _buildImage(product.images.first)
                                    : Container(
                                        color: Colors.grey[200],
                                        child: const Icon(
                                          Icons.inventory_2,
                                          size: 48,
                                          color: Colors.grey,
                                        ),
                                      ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          product.name,
                                          style: const TextStyle(
                                            fontWeight: FontWeight.bold,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      _buildStatusDot(product),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '\$${product.price.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Theme.of(context).primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Stock: ${product.stock}',
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(color: Colors.grey),
                                  ),
                                  if (product.sellerName != null &&
                                      product.sellerName!.isNotEmpty)
                                    Text(
                                      'Seller: ${product.sellerName}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            fontStyle: FontStyle.italic,
                                            fontSize: 10,
                                          ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      if (!product.isApproved)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.check_circle,
                                            color: Colors.green,
                                            size: 20,
                                          ),
                                          onPressed: () => _approveProduct(
                                            context,
                                            ref,
                                            product.id,
                                          ),
                                          tooltip: 'Approve',
                                        ),
                                      if (product.isApproved)
                                        IconButton(
                                          icon: const Icon(
                                            Icons.block,
                                            color: Colors.red,
                                            size: 20,
                                          ),
                                          onPressed: () => _rejectProduct(
                                            context,
                                            ref,
                                            product.id,
                                          ),
                                          tooltip: 'Reject',
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        if (product.rejectionReason != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              color: Colors.red.withOpacity(0.9),
                              child: Text(
                                'Rejected: ${product.rejectionReason}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Text('Error: $error'),
        ),
      ],
    );
  }

  Widget _buildImage(String base64String) {
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } catch (e) {
      return const Icon(Icons.broken_image);
    }
  }

  Widget _buildStatusDot(Product product) {
    Color color;
    if (product.isApproved) {
      color = Colors.green;
    } else if (product.rejectionReason != null) {
      color = Colors.red;
    } else {
      color = Colors.amber;
    }
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Future<void> _approveProduct(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) async {
    try {
      await ref.read(firestoreServiceProvider).approveProduct(productId);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Product Approved')));
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _rejectProduct(
    BuildContext context,
    WidgetRef ref,
    String productId,
  ) async {
    final reasonController = TextEditingController();
    final reason = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reject Product'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(labelText: 'Reason'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, reasonController.text),
            child: const Text('Reject'),
          ),
        ],
      ),
    );

    if (reason != null && reason.isNotEmpty) {
      try {
        await ref
            .read(firestoreServiceProvider)
            .rejectProduct(productId, reason);
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Product Rejected')));
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        }
      }
    }
  }
}
