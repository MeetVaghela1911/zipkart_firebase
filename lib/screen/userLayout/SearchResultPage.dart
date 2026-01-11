import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/product_provider.dart';
import 'package:zipkart_firebase/Models/Product.dart' as model;
import 'ProductDetail.dart';

class SearchResultScreen extends ConsumerWidget {
  const SearchResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Define screen width
    final screenWidth = MediaQuery.of(context).size.width;

    // Adjust the number of columns based on screen width
    int crossAxisCount;
    if (screenWidth > 800) {
      crossAxisCount = 4;
    } else if (screenWidth > 600) {
      crossAxisCount = 3;
    } else {
      crossAxisCount = 2;
    }

    // Adjust the aspect ratio based on screen width
    double aspectRatio = screenWidth > 800 ? 0.7 : 0.6;

    final searchState = ref.watch(searchProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 9),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Container(
          child: TextField(
            onChanged: (value) {
              ref.read(searchProvider.notifier).search(value);
            },
            decoration: InputDecoration(
              hintText: "Search Product",
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey[200],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () {
              Navigator.pushNamed(context, '/FilterSearch');
            },
          ),
          IconButton(
            icon: const Icon(Icons.sort_by_alpha_outlined, color: Colors.grey),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: searchState.isLoading
            ? const Center(child: CircularProgressIndicator())
            : searchState.results.isEmpty
            ? const Center(child: Text("No products found"))
            : GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: aspectRatio,
                ),
                itemCount: searchState.results.length,
                itemBuilder: (context, index) {
                  return ProductCard(product: searchState.results[index]);
                },
              ),
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(
              product: model.Product(
                id: product.id,
                name: product.name,
                description: product.description,
                price: product.price,
                stock: 0,
                categoryId: product.category,
                subCategoryId: '',
                sellerId: '',
                images: [product.image],
                isActive: true,
                isFeatured: false,
                createdAt: DateTime.now(),
                rating: product.rating ?? 0.0,
                reviewCount: product.reviewCount ?? 0,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey[300]!),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(20),
                  image: DecorationImage(
                    image: NetworkImage(product.image),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < (product.rating ?? 0).round()
                            ? Icons.star
                            : Icons.star_border,
                        color: Colors.yellow,
                        size: 16,
                      );
                    }),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '\$${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Row(
                    children: [
                      Text('24% Off', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
