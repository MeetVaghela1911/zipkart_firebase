import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:zipkart_firebase/Models/category_model.dart';
import 'package:zipkart_firebase/core/routes/routes.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';
import '../../providers/product_provider.dart';

class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        title: Row(
          children: [
            Expanded(
              child: TextField(
                onChanged: (value) {
                  ref.read(searchProvider.notifier).search(value);
                },
                decoration: InputDecoration(
                  hintText: 'Search Product',
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  filled: true,
                  fillColor: Colors.grey[100],
                  contentPadding: const EdgeInsets.symmetric(vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                context.push(AppRoutes.Favorite);
              },
            ),
          ],
        ),
      ),
      body: searchState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : searchState.query.isNotEmpty
          ? _buildSearchResults(context, searchState.results)
          : _buildCategoryView(context, ref),
    );
  }

  Widget _buildSearchResults(BuildContext context, List<Product> results) {
    if (results.isEmpty) {
      return const Center(child: Text('No products found'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final product = results[index];
        return GestureDetector(
          onTap: () {
            // Since search uses its own Product model, we might need to fetch the full model
            // or ensure the detail screen can handle this basic model.
            context.push(AppRoutes.ProductDetailScreen);
          },
          child: Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: product.image.isNotEmpty
                        ? Image.network(
                            product.image,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          )
                        : Container(
                            color: Colors.grey.shade200,
                            child: const Icon(Icons.image),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '₹${product.price.toStringAsFixed(0)}',
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryView(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return categoriesAsync.when(
      data: (categories) {
        if (categories.isEmpty) {
          return const Center(child: Text('No categories found'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 24.0),
              child: CategorySection(category: category),
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

class CategorySection extends ConsumerWidget {
  final CategoryModel category;

  const CategorySection({super.key, required this.category});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subcategoriesAsync = ref.watch(
      subcategoriesStreamProvider(category.id),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              category.name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            TextButton(
              onPressed: () {
                context.push(
                  AppRoutes.ProductListScreen,
                  extra: {
                    'categoryId': category.id,
                    'categoryName': category.name,
                  },
                );
              },
              child: const Text('See All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        subcategoriesAsync.when(
          data: (subcategories) {
            if (subcategories.isEmpty) {
              return const Text(
                'No subcategories',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              );
            }
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 0.8,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: subcategories.length,
              itemBuilder: (context, index) {
                final sub = subcategories[index];
                return GestureDetector(
                  onTap: () {
                    context.push(
                      AppRoutes.ProductListScreen,
                      extra: {
                        'subCategoryId': sub.id,
                        'categoryName': sub.name,
                      },
                    );
                  },
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue.withOpacity(0.05),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.1),
                          ),
                        ),
                        child: const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.blue,
                          size: 28,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        sub.name,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const SizedBox(
            height: 40,
            child: Center(child: LinearProgressIndicator()),
          ),
          error: (_, __) => const Text('Error loading subcategories'),
        ),
      ],
    );
  }
}
