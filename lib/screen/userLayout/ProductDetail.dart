import 'package:flutter/material.dart';
import 'package:zipkart_firebase/core/widgets/common_image.dart';

import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:zipkart_firebase/Models/Product.dart' as model;

/// ------------------------------------------------------------
/// PRODUCT DETAIL SCREEN
/// ------------------------------------------------------------

class ProductDetailScreen extends StatefulWidget {
  final model.Product? product;
  const ProductDetailScreen({super.key, this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _imageIndex = 0;
  late PageController _pageController;
  late model.Product product;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    product =
        widget.product ??
        model.Product(
          id: 'dummy',
          name: 'Apple iPhone 15 Pro Max (256 GB) – Natural Titanium',
          description:
              'A17 Pro chip with 6-core GPU. 48MP main camera with 5× telephoto. Titanium design with Ceramic Shield. All-day battery life.',
          price: 159999,
          salePrice: 149999,
          stock: 10,
          categoryId: '',
          subCategoryId: '',
          sellerId: '',
          images: [
            'https://www.mobiles.co.uk/blog/content/images/2025/10/Untitled-design.jpg',
          ],
          isActive: true,
          isFeatured: true,
          createdAt: DateTime.now(),
          rating: 4.6,
          reviewCount: 12456,
        );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isTablet = screenWidth >= 600 && screenWidth < 900;
    final isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        actions: [
          IconButton(icon: const Icon(Icons.share), onPressed: () {}),
          IconButton(icon: const Icon(Icons.favorite_border), onPressed: () {}),
        ],
      ),
      body: isDesktop
          ? _buildDesktopLayout(product, isMobile, isTablet, isDesktop)
          : _buildMobileLayout(product, isMobile, isTablet, isDesktop),
      bottomNavigationBar: isMobile
          ? _BottomCTA(isMobile: isMobile, product: product)
          : null,
    );
  }

  Widget _buildDesktopLayout(
    model.Product product,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    constraints: const BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 500,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: product.images.length,
                      onPageChanged: (i) => setState(() => _imageIndex = i),
                      itemBuilder: (_, i) => buildCommonImage(
                        product.images[i],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      product.images.length,
                      (i) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _imageIndex == i ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _imageIndex == i ? Colors.orange : Colors.grey,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 80,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: product.images.length,
                      itemBuilder: (_, i) => GestureDetector(
                        onTap: () {
                          setState(() => _imageIndex = i);
                          _pageController.animateToPage(
                            i,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          );
                        },
                        child: Container(
                          width: 80,
                          height: 80,
                          margin: const EdgeInsets.only(right: 8),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _imageIndex == i
                                  ? Colors.orange
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: buildCommonImage(
                            product.images[i],
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 40),

          /// RIGHT SIDE - SCROLLABLE PRODUCT INFO
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(right: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ProductInfo(product, isMobile: false),
                  const SizedBox(height: 24),
                  _BottomCTA(isMobile: false),
                  const SizedBox(height: 32),
                  _TechnicalSpecifications(product, isMobile: false),
                  const SizedBox(height: 32),
                  const Divider(),
                  if (product.description.isNotEmpty)
                    _ProductDetailBody(isMobile: false, product: product),
                  const SizedBox(height: 32),
                  if (product.reviewCount > 0) ...[
                    const Divider(),
                    _ReviewsSection(isMobile: false, product: product),
                  ],
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(
    model.Product product,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Container(
            color: Colors.grey.shade100,
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.5,
            ),
            child: PageView.builder(
              controller: _pageController,
              itemCount: product.images.length,
              onPageChanged: (i) => setState(() => _imageIndex = i),
              itemBuilder: (_, i) => buildCommonImage(
                product.images[i],
                width: double.infinity,
                height: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                product.images.length,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _imageIndex == i ? 10 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: _imageIndex == i ? Colors.orange : Colors.grey,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: isTablet ? 24 : 16,
              vertical: 12,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _ProductInfo(product, isMobile: isMobile),
                if (product.description.isNotEmpty)
                  _ProductDetailBody(isMobile: isMobile, product: product),
                const Divider(),
                _TechnicalSpecifications(product, isMobile: isMobile),
                const Divider(),
                if (product.reviewCount > 0)
                  _ReviewsSection(isMobile: isMobile, product: product),
                SizedBox(height: isMobile ? 16 : 24),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ProductDetailBody extends StatelessWidget {
  final bool isMobile;
  final model.Product product;

  const _ProductDetailBody({required this.isMobile, required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.description.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: isMobile ? 0 : 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'About this item',
            style: TextStyle(
              fontSize: isMobile ? 16 : 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: isMobile ? 8 : 12),
          MarkdownBody(data: product.description),
          SizedBox(height: isMobile ? 12 : 16),
        ],
      ),
    );
  }
}

/// PRODUCT INFO
class _ProductInfo extends StatelessWidget {
  final model.Product product;
  final bool isMobile;

  const _ProductInfo(this.product, {required this.isMobile});

  @override
  Widget build(BuildContext context) {
    final originalPrice = product.price;
    final salePrice = product.salePrice ?? product.price;
    final discount = originalPrice > 0
        ? ((1 - salePrice / originalPrice) * 100).round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          product.name,
          maxLines: isMobile ? 2 : 3,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: isMobile ? 18 : 24,
            fontWeight: FontWeight.bold,
            height: 1.3,
          ),
        ),
        SizedBox(height: isMobile ? 4 : 8),
        Text(
          product.sellerName ?? 'Zipkart',
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: isMobile ? 14 : 16,
            color: Colors.blue.shade700,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Row(
          children: [
            const Icon(Icons.star, size: 18, color: Colors.amber),
            SizedBox(width: isMobile ? 4 : 6),
            Text(
              '${product.rating} (${product.reviewCount} reviews)',
              style: TextStyle(
                fontSize: isMobile ? 13 : 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _TrustBadgesCard(product: product),
        const SizedBox(height: 12),
        _ServiceHighlightsCard(product: product),
        const SizedBox(height: 16),
        // SizedBox(height: isMobile ? 8 : 20),
        // Pricing Section
        Container(
          padding: EdgeInsets.all(isMobile ? 12 : 16),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(8)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '₹${salePrice.toInt()}',
                style: TextStyle(
                  fontSize: isMobile ? 24 : 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              if (product.salePrice != null &&
                  product.salePrice! < product.price)
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '₹${product.price.toInt()}',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '$discount% off',
                      style: TextStyle(
                        fontSize: isMobile ? 12 : 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// VARIANT SELECTOR

/// TRUST BADGES CARD
class _TrustBadgesCard extends StatelessWidget {
  final model.Product product;

  const _TrustBadgesCard({required this.product});

  @override
  Widget build(BuildContext context) {
    if (!product.isTopBrand && !product.isAssured)
      return const SizedBox.shrink();

    return Row(
      children: [
        if (product.isTopBrand)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.workspace_premium,
                  size: 16,
                  color: Colors.orange.shade800,
                ),
                const SizedBox(width: 6),
                Text(
                  'TOP BRAND',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        if (product.isTopBrand && product.isAssured) const SizedBox(width: 10),
        if (product.isAssured)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.verified, size: 16, color: Colors.blue.shade800),
                const SizedBox(width: 6),
                Text(
                  'ASSURED',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// SERVICE HIGHLIGHTS CARD
class _ServiceHighlightsCard extends StatelessWidget {
  final model.Product product;

  const _ServiceHighlightsCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final List<Widget> items = [];

    if (product.isFreeDelivery) {
      items.add(
        _HighlightItem(
          icon: Icons.local_shipping_outlined,
          label: 'Free Delivery',
          color: Colors.green.shade700,
        ),
      );
    }
    if (product.returnPolicy != null) {
      items.add(
        _HighlightItem(
          icon: Icons.assignment_return_outlined,
          label: product.returnPolicy!,
          color: Colors.blue.shade700,
        ),
      );
    }
    if (product.warrantyPolicy != null) {
      items.add(
        _HighlightItem(
          icon: Icons.security_outlined,
          label: 'Warranty',
          color: Colors.orange.shade700,
        ),
      );
    }

    if (items.isEmpty) return const SizedBox.shrink();

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: items
                .map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(right: 20),
                    child: item,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _HighlightItem({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// TECHNICAL SPECIFICATIONS
class _TechnicalSpecifications extends StatelessWidget {
  final model.Product product;
  final bool isMobile;

  const _TechnicalSpecifications(this.product, {required this.isMobile});

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: Text(
        'Technical Specifications',
        style: TextStyle(
          fontSize: isMobile ? 14 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      children: [
        ListTile(
          dense: true,
          title: const Text('Availability'),
          trailing: Text(
            product.stock > 0 ? '${product.stock} available' : 'Out of Stock',
          ),
        ),
        if (product.sellerName != null)
          ListTile(
            dense: true,
            title: const Text('Seller'),
            trailing: Text(product.sellerName!),
          ),
      ],
    );
  }
}

/// REVIEWS SECTION
class _ReviewsSection extends StatelessWidget {
  final bool isMobile;
  final model.Product product;

  const _ReviewsSection({required this.isMobile, required this.product});

  @override
  Widget build(BuildContext context) {
    if (product.reviewCount == 0) return const SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 12),
        Text(
          'Customer Ratings',
          style: TextStyle(
            fontSize: isMobile ? 16 : 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: isMobile ? 8 : 12),
        Card(
          elevation: 1,
          child: Padding(
            padding: EdgeInsets.all(isMobile ? 10 : 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 24),
                    const SizedBox(width: 8),
                    Text(
                      '${product.rating} out of 5',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Based on ${product.reviewCount} customer reviews',
                  style: TextStyle(
                    fontSize: isMobile ? 13 : 14,
                    color: Colors.grey.shade700,
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }
}

/// IMAGE GRID

/// BOTTOM CTA BAR
class _BottomCTA extends StatelessWidget {
  final bool isMobile;
  final model.Product? product;

  const _BottomCTA({required this.isMobile, this.product});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(isMobile ? 8 : 12),
      decoration: BoxDecoration(
        // color: Colors.white,
        boxShadow: [
          // BoxShadow(
          //   // color: Colors.grey.shade300,
          //   blurRadius: 4,
          //   offset: const Offset(0, -2),
          // ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: isMobile ? 22 : 26),
                // side: const BorderSide(color: Colors.orange),
              ),
              onPressed: () {},
              child: Text(
                'Add to Cart',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  // color: Colors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                // backgroundColor: Colors.orange,
                padding: EdgeInsets.symmetric(vertical: isMobile ? 22 : 26),
              ),
              onPressed: () {},
              child: Text(
                'Buy Now',
                style: TextStyle(
                  fontSize: isMobile ? 13 : 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
