import 'package:flutter/material.dart';
import 'package:zipkart_firebase/core/widgets/common_image.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zipkart_firebase/core/routes/routes.dart';
import 'package:zipkart_firebase/Models/Product.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

/// ------------------------------------------------------------
/// PRODUCT LIST SCREEN
/// ------------------------------------------------------------
class ProductListScreen extends ConsumerWidget {
  final String? categoryId;
  final String? subCategoryId;
  final String? categoryName;

  const ProductListScreen({
    super.key,
    this.categoryId,
    this.subCategoryId,
    this.categoryName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final width = MediaQuery.of(context).size.width;

    // REAL responsiveness
    int columns = 2;
    if (width >= 600) columns = 3;
    if (width >= 1024) columns = 4;
    double childAspectRatio = 0.65;
    if (width >= 1024) childAspectRatio = 0.75;

    AsyncValue<List<Product>> productsAsync;

    if (subCategoryId != null) {
      productsAsync = ref.watch(
        productsBySubcategoryStreamProvider(subCategoryId!),
      );
    } else if (categoryId != null) {
      productsAsync = ref.watch(productsByCategoryStreamProvider(categoryId!));
    } else {
      productsAsync = ref.watch(activeProductsStreamProvider);
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(categoryName ?? 'Products'),
        centerTitle: false,
      ),
      body: productsAsync.when(
        data: (products) {
          if (products.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products found in this category',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.builder(
              itemCount: products.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: childAspectRatio,
              ),
              itemBuilder: (context, index) {
                return ProductItemCard(product: products[index]);
              },
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(child: Text('Error: $error')),
      ),
    );
  }
}

/// ------------------------------------------------------------
/// PRODUCT ITEM CARD
/// ------------------------------------------------------------
class ProductItemCard extends StatelessWidget {
  final Product product;

  const ProductItemCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    final displayPrice = product.salePrice ?? product.price;
    final hasDiscount =
        product.salePrice != null && product.salePrice! < product.price;

    return GestureDetector(
      onTap: () {
        context.push(AppRoutes.ProductDetailScreen, extra: product);
      },
      child: Card(
        elevation: 2,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // IMAGE
            AspectRatio(
              aspectRatio: 1,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: product.images.isNotEmpty
                        ? buildCommonImage(
                            product.images.first,
                            fit: BoxFit.cover,
                            errorWidget: Container(
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.image_not_supported),
                            ),
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image),
                          ),
                  ),
                  if (hasDiscount)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '${((product.price - product.salePrice!) / product.price * 100).toStringAsFixed(0)}% OFF',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // DETAILS
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(
                              Icons.star,
                              size: 14,
                              color: Colors.amber,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              product.rating.toStringAsFixed(1),
                              style: const TextStyle(fontSize: 12),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '(${product.reviewCount})',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '₹${displayPrice.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            if (hasDiscount)
                              Text(
                                '₹${product.price.toStringAsFixed(0)}',
                                style: TextStyle(
                                  fontSize: 12,
                                  decoration: TextDecoration.lineThrough,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_shopping_cart,
                            size: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
