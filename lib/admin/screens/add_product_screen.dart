import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipkart_firebase/Models/Product.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class AddProductScreen extends ConsumerStatefulWidget {
  final Product? product; // Optional: If provided, we are in Edit mode

  const AddProductScreen({super.key, this.product});

  @override
  ConsumerState<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends ConsumerState<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();
  final _salePriceController =
      TextEditingController(); // Added for Selling Price
  final _warrantyController = TextEditingController();
  final _ratingController = TextEditingController();
  final _reviewCountController = TextEditingController();
  final _recentSalesController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedSubcategoryId;
  String? _selectedSellerId;

  List<XFile> _selectedImages = []; // New images to upload
  List<String> _existingImageUrls = []; // Existing images (for edit mode)

  bool get _isEditMode => widget.product != null;

  bool _isFeatured = false;
  bool _isFreeDelivery = false;
  bool _isTopBrand = false;
  bool _isAssured = false;
  String? _returnPolicy;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_calculateDiscount);
    _salePriceController.addListener(_calculateDiscount);

    if (_isEditMode) {
      _initializeForEdit();
    }
  }

  void _initializeForEdit() {
    final p = widget.product!;
    _nameController.text = p.name;
    _descController.text = p.description;
    _priceController.text = p.price.toString();
    if (p.salePrice != null) {
      _salePriceController.text = p.salePrice.toString();
    }
    _stockController.text = p.stock.toString();

    _selectedCategoryId = p.categoryId;
    _selectedSubcategoryId = p.subCategoryId;
    _selectedSellerId = p.sellerId;

    _existingImageUrls = List.from(p.images);

    _isFeatured = p.isFeatured;
    _isFreeDelivery = p.isFreeDelivery;
    _isTopBrand = p.isTopBrand;
    _isAssured = p.isAssured;
    _returnPolicy = p.returnPolicy;

    if (p.warrantyPolicy != null) {
      _warrantyController.text = p.warrantyPolicy!;
    }
    _ratingController.text = p.rating.toString();
    _reviewCountController.text = p.reviewCount.toString();
    _recentSalesController.text = p.recentSalesCount.toString();
  }

  void _calculateDiscount() {
    setState(() {}); // Rebuild to update discount display
  }

  String get _discountDisplay {
    final mrp = double.tryParse(_priceController.text.trim()) ?? 0;
    final sp = double.tryParse(_salePriceController.text.trim()) ?? 0;
    if (mrp > 0 && sp > 0 && mrp > sp) {
      final discount = ((mrp - sp) / mrp) * 100;
      return '${discount.toStringAsFixed(0)}% OFF';
    }
    return '';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    _salePriceController.dispose();
    _warrantyController.dispose();
    _ratingController.dispose();
    _reviewCountController.dispose();
    _recentSalesController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    if (images.isNotEmpty) {
      if (_selectedImages.length + _existingImageUrls.length + images.length >
          5) {
        // Limit check if needed
      }
      setState(() {
        _selectedImages.addAll(images);
      });
    }
  }

  void _removeNewImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  void _removeExistingImage(int index) {
    setState(() {
      _existingImageUrls.removeAt(index);
    });
  }

  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    // Validations
    if (_selectedCategoryId == null) {
      _showError('Please select a category');
      return;
    }
    if (_selectedSubcategoryId == null) {
      _showError('Please select a subcategory');
      return;
    }
    if (_selectedSellerId == null) {
      _showError('Please select a seller');
      return;
    }
    if (_selectedImages.isEmpty && _existingImageUrls.isEmpty) {
      _showError('Please select at least one product image');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(firestoreServiceProvider);

      if (_isEditMode) {
        await service.updateProductFull(
          productId: widget.product!.id,
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          salePrice: _salePriceController.text.trim().isNotEmpty
              ? double.parse(_salePriceController.text.trim())
              : null,
          stock: int.parse(_stockController.text.trim()),
          categoryId: _selectedCategoryId!,
          subCategoryId: _selectedSubcategoryId!,
          sellerId: _selectedSellerId!,
          isFeatured: _isFeatured,
          existingImages: _existingImageUrls,
          newImages: _selectedImages,
          // New Features
          isFreeDelivery: _isFreeDelivery,
          returnPolicy: _returnPolicy,
          warrantyPolicy: _warrantyController.text.trim().isEmpty
              ? null
              : _warrantyController.text.trim(),
          isTopBrand: _isTopBrand,
          isAssured: _isAssured,
          rating: double.tryParse(_ratingController.text.trim()) ?? 0.0,
          reviewCount: int.tryParse(_reviewCountController.text.trim()) ?? 0,
          recentSalesCount:
              int.tryParse(_recentSalesController.text.trim()) ?? 0,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product updated successfully')),
          );
        }
      } else {
        await service.addProduct(
          name: _nameController.text.trim(),
          description: _descController.text.trim(),
          price: double.parse(_priceController.text.trim()),
          salePrice: _salePriceController.text.trim().isNotEmpty
              ? double.parse(_salePriceController.text.trim())
              : null,
          stock: int.parse(_stockController.text.trim()),
          categoryId: _selectedCategoryId!,
          subCategoryId: _selectedSubcategoryId!,
          sellerId: _selectedSellerId!,
          isFeatured: _isFeatured,
          images: _selectedImages,
          // New Features
          isFreeDelivery: _isFreeDelivery,
          returnPolicy: _returnPolicy,
          warrantyPolicy: _warrantyController.text.trim().isEmpty
              ? null
              : _warrantyController.text.trim(),
          isTopBrand: _isTopBrand,
          isAssured: _isAssured,
          rating: double.tryParse(_ratingController.text.trim()) ?? 0.0,
          reviewCount: int.tryParse(_reviewCountController.text.trim()) ?? 0,
          recentSalesCount:
              int.tryParse(_recentSalesController.text.trim()) ?? 0,
        );
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Product added successfully')),
          );
        }
      }

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      _showError('Error: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final categoriesAsync = ref.watch(categoriesStreamProvider);
    final sellersAsync = ref.watch(sellersStreamProvider);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditMode ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Basic Info ---
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Product Name*',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v?.trim().isEmpty ?? true
                    ? 'Product name is required'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descController,
                decoration: const InputDecoration(
                  labelText: 'Description*',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (v) => v?.trim().isEmpty ?? true
                    ? 'Description is required'
                    : null,
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'MRP (Actual Price)',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator: (v) =>
                          v?.isEmpty ?? true ? 'MRP is required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _salePriceController,
                      decoration: const InputDecoration(
                        labelText: 'Selling Price',
                        border: OutlineInputBorder(),
                        prefixText: '\$ ',
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                      ],
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Selling Price is required';
                        final mrp = double.tryParse(_priceController.text) ?? 0;
                        final sp = double.tryParse(v) ?? 0;
                        if (sp > mrp) return 'Cannot be > MRP';
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (_discountDisplay.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.local_offer,
                          size: 16,
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Discount Applied: $_discountDisplay',
                          style: const TextStyle(
                            color: Colors.green,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock Quantity',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (v) =>
                    v?.isEmpty ?? true ? 'Stock quantity is required' : null,
              ),

              const SizedBox(height: 16),

              // --- Relations ---
              // Category
              categoriesAsync.when(
                data: (categories) => DropdownButtonFormField<String>(
                  value: categories.any((c) => c.id == _selectedCategoryId)
                      ? _selectedCategoryId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Category*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null ? 'Category is required' : null,
                  items: categories
                      .map(
                        (c) =>
                            DropdownMenuItem(value: c.id, child: Text(c.name)),
                      )
                      .toList(),
                  onChanged: (val) {
                    if (val != _selectedCategoryId) {
                      setState(() {
                        _selectedCategoryId = val;
                        _selectedSubcategoryId =
                            null; // Reset subcategory when category changes
                      });
                    }
                  },
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),

              const SizedBox(height: 16),

              // Subcategory (Changes based on Category)
              if (_selectedCategoryId != null)
                Consumer(
                  builder: (context, ref, child) {
                    final subcategoriesAsync = ref.watch(
                      subcategoriesStreamProvider(_selectedCategoryId!),
                    );

                    return subcategoriesAsync.when(
                      data: (subcategories) {
                        return DropdownButtonFormField<String>(
                          value:
                              subcategories.any(
                                (s) => s.id == _selectedSubcategoryId,
                              )
                              ? _selectedSubcategoryId
                              : null, // Reset logic handled in category change
                          decoration: const InputDecoration(
                            labelText: 'Subcategory*',
                            border: OutlineInputBorder(),
                          ),
                          validator: (v) =>
                              v == null ? 'Subcategory is required' : null,
                          items: subcategories
                              .map(
                                (s) => DropdownMenuItem(
                                  value: s.id,
                                  child: Text(s.name),
                                ),
                              )
                              .toList(),
                          onChanged: (val) =>
                              setState(() => _selectedSubcategoryId = val),
                        );
                      },
                      loading: () => const LinearProgressIndicator(),
                      error: (e, s) => Text('Error loading subcategories: $e'),
                    );
                  },
                )
              else
                DropdownButtonFormField<String>(
                  items: [],
                  onChanged: null,
                  decoration: InputDecoration(
                    labelText: 'Subcategory (Select Category First)',
                    border: OutlineInputBorder(),
                    enabled: false,
                  ),
                ),

              const SizedBox(height: 16),

              // Seller
              sellersAsync.when(
                data: (sellers) => DropdownButtonFormField<String>(
                  value: sellers.any((s) => s.uid == _selectedSellerId)
                      ? _selectedSellerId
                      : null,
                  decoration: const InputDecoration(
                    labelText: 'Seller*',
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) => v == null ? 'Seller is required' : null,
                  items: sellers
                      .map(
                        (s) => DropdownMenuItem(
                          value: s.uid,
                          child: Text(s.username),
                        ),
                      )
                      .toList(),
                  onChanged: (val) => setState(() => _selectedSellerId = val),
                ),
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error: $e'),
              ),

              const SizedBox(height: 16),

              // --- Images ---
              const Text(
                'Product Images',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      _existingImageUrls.length + _selectedImages.length + 1,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return GestureDetector(
                        onTap: _pickImages,
                        child: Container(
                          width: 100,
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add_a_photo,
                            color: Colors.grey,
                          ),
                        ),
                      );
                    }

                    final adjustedIndex = index - 1;

                    // Display Existing Images First
                    if (adjustedIndex < _existingImageUrls.length) {
                      final imageUrl = _existingImageUrls[adjustedIndex];
                      return Stack(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              base64Decode(imageUrl),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 100,
                                height: 100,
                                color: Colors.grey,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                          ),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: GestureDetector(
                              onTap: () => _removeExistingImage(adjustedIndex),
                              child: Container(
                                color: Colors.black54,
                                child: const Icon(
                                  Icons.close,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    // Display New Images
                    final newIndex = adjustedIndex - _existingImageUrls.length;
                    final image = _selectedImages[newIndex];
                    return Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  image.path,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(image.path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () => _removeNewImage(newIndex),
                            child: Container(
                              color: Colors.black54,
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 16),

              // --- Toggle ---
              // --- Feature Cards Grid ---
              const Text(
                'Product Features & Badges',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 12),
              LayoutBuilder(
                builder: (context, constraints) {
                  final width = constraints.maxWidth;
                  final crossAxisCount = width > 600 ? 4 : 2;
                  final aspectRatio = width > 600
                      ? 3.0
                      : 2.0; // Reduced from 2.5 to 2.0 for more height

                  return GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: crossAxisCount,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: aspectRatio,
                    children: [
                      _buildSelectionCard(
                        title: 'Featured Product',
                        icon: Icons.star,
                        isSelected: _isFeatured,
                        onTap: () => setState(() => _isFeatured = !_isFeatured),
                      ),
                      _buildSelectionCard(
                        title: 'Free Delivery',
                        icon: Icons.local_shipping,
                        isSelected: _isFreeDelivery,
                        onTap: () =>
                            setState(() => _isFreeDelivery = !_isFreeDelivery),
                      ),
                      _buildSelectionCard(
                        title: 'ZipKart Assured',
                        icon: Icons.verified,
                        isSelected: _isAssured,
                        onTap: () => setState(() => _isAssured = !_isAssured),
                      ),
                      _buildSelectionCard(
                        title: 'Top Brand',
                        icon: Icons.workspace_premium,
                        isSelected: _isTopBrand,
                        onTap: () => setState(() => _isTopBrand = !_isTopBrand),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _returnPolicy,
                decoration: const InputDecoration(
                  labelText: 'Return Policy',
                  border: OutlineInputBorder(),
                ),
                items:
                    [
                          'No Returns',
                          '7 Days Replacement',
                          '7 Days Returnable',
                          '10 Days Replacement',
                          '10 Days Returnable',
                          '15 Days Returnable',
                        ]
                        .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                        .toList(),
                onChanged: (val) => setState(() => _returnPolicy = val),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _warrantyController,
                decoration: const InputDecoration(
                  labelText:
                      'Warranty Policy (e.g. 1 Year Manufacturer Warranty)',
                  border: OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 16),
              const Divider(),
              const Text(
                'Visibility & Social Proof (Optional)',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _ratingController,
                      decoration: const InputDecoration(
                        labelText: 'Initial Rating (0-5)',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _reviewCountController,
                      decoration: const InputDecoration(
                        labelText: 'Initial Review Count',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _recentSalesController,
                decoration: const InputDecoration(
                  labelText: 'Recent Sales Count (e.g. 500+ bought)',
                  border: OutlineInputBorder(),
                  helperText: 'Shows as "X+ bought in past month"',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveProduct,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Save Product'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required bool isSelected,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    final isDark = theme.brightness == Brightness.dark;

    // Uniform background color regardless of selection state
    final backgroundColor = isDark ? Colors.grey[800] : Colors.white;

    final borderColor = isSelected
        ? primaryColor
        : (isDark ? Colors.grey[700]! : Colors.grey[300]!);

    // Icon and text colors match the border/active state for better visibility
    final contentColor = isSelected ? primaryColor : Colors.grey;
    final textColor = isDark ? Colors.grey[300] : Colors.grey[800];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: borderColor,
            width: isSelected ? 2.5 : 1, // Thicker border when selected
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Main Content
            Center(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min, // Added to hug content
                  children: [
                    Icon(icon, color: contentColor, size: 26),
                    const SizedBox(height: 4), // Reduced from 8
                    Flexible(
                      // flexible to avoid overflow
                      child: Text(
                        title,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? primaryColor : textColor,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 12,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Checkmark Indicator
            if (isSelected)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, size: 12, color: Colors.white),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
