import 'dart:convert';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:zipkart_firebase/Models/Product.dart';
import 'package:zipkart_firebase/Models/sale_model.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class AddSaleScreen extends ConsumerStatefulWidget {
  final SaleModel? sale; // Optional for edit

  const AddSaleScreen({super.key, this.sale});

  @override
  ConsumerState<AddSaleScreen> createState() => _AddSaleScreenState();
}

class _AddSaleScreenState extends ConsumerState<AddSaleScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  late TextEditingController _nameController;
  late TextEditingController _descriptionController;
  late TextEditingController _discountController;

  // State
  XFile? _selectedImage;
  DateTime? _startDate;
  DateTime? _endDate;
  String _selectedSaleType = 'flash';
  List<String> _selectedProductIds = [];
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.sale?.name ?? '');
    _descriptionController = TextEditingController(
      text: widget.sale?.description ?? '',
    );
    _discountController = TextEditingController(
      text: widget.sale?.discountPercent.toString() ?? '',
    );

    _startDate = widget.sale?.startDate;
    _endDate = widget.sale?.endDate;
    _selectedSaleType = widget.sale?.saleType ?? 'flash';
    _selectedProductIds = List.from(widget.sale?.productIds ?? []);
    _isActive = widget.sale?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _discountController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() => _selectedImage = image);
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStart
          ? (_startDate ?? DateTime.now())
          : (_endDate ?? _startDate ?? DateTime.now()),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      // Optional: Add Time Picker for more precision
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(
          isStart
              ? (_startDate ?? DateTime.now())
              : (_endDate ?? DateTime.now().add(const Duration(hours: 1))),
        ),
      );

      if (time != null) {
        final DateTime fullDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
        setState(() {
          if (isStart) {
            _startDate = fullDate;
            // Auto-adjust end date if needed
            if (_endDate != null && _endDate!.isBefore(_startDate!)) {
              _endDate = _startDate!.add(const Duration(days: 1));
            }
          } else {
            _endDate = fullDate;
          }
        });
      }
    }
  }

  Future<void> _showProductSelector(List<Product> allProducts) async {
    final List<String>? result = await showDialog<List<String>>(
      context: context,
      builder: (ctx) => ProductSelectionDialog(
        allProducts: allProducts,
        initialSelection: _selectedProductIds,
      ),
    );

    if (result != null) {
      setState(() {
        _selectedProductIds = result;
      });
    }
  }

  // ... (rest of _save and build methods remain, just ensure _showProductSelector calls this new version)

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select start and end dates')),
      );
      return;
    }
    if (_endDate!.isBefore(_startDate!)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('End date must be after start date')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(firestoreServiceProvider);

      if (widget.sale == null) {
        // ADD NEW
        await service.addSale(
          name: _nameController.text.trim(),
          description: _descriptionController.text.trim(),
          productIds: _selectedProductIds,
          discountPercent: double.tryParse(_discountController.text) ?? 0.0,
          startDate: _startDate!,
          endDate: _endDate!,
          saleType: _selectedSaleType,
          bannerImage: _selectedImage,
        );
      } else {
        // UPDATE EXISTING
        await service.updateSale(widget.sale!.id, {
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'productIds': _selectedProductIds,
          'discountPercent': double.tryParse(_discountController.text) ?? 0.0,
          'startDate': Timestamp.fromDate(_startDate!),
          'endDate': Timestamp.fromDate(_endDate!),
          'saleType': _selectedSaleType,
          'isActive': _isActive,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Sale campaign ${widget.sale == null ? 'created' : 'updated'}!',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Sale'),
        content: const Text('Are you sure you want to delete this sale?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(firestoreServiceProvider).deleteSale(widget.sale!.id);
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch all products for selection
    final productsAsync = ref.watch(allProductsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.sale == null ? 'Create Sale Campaign' : 'Edit Sale'),
        actions: [
          if (widget.sale != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _delete,
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Basic Info
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Sale Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),

              const SizedBox(height: 16),

              // 2. Dates & Type
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _selectedSaleType,
                      decoration: const InputDecoration(
                        labelText: 'Sale Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'flash',
                          child: Text('Flash Sale'),
                        ),
                        DropdownMenuItem(
                          value: 'mega',
                          child: Text('Mega Sale'),
                        ),
                        DropdownMenuItem(
                          value: 'seasonal',
                          child: Text('Seasonal Sale'),
                        ),
                        DropdownMenuItem(
                          value: 'clearance',
                          child: Text('Clearance'),
                        ),
                        DropdownMenuItem(value: 'other', child: Text('Other')),
                      ],
                      onChanged: (v) => setState(() => _selectedSaleType = v!),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _discountController,
                      decoration: const InputDecoration(
                        labelText: 'Discount %',
                        border: OutlineInputBorder(),
                        suffixText: '%',
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        final n = double.tryParse(v);
                        if (n == null || n < 0 || n > 100) return 'Invalid';
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context, true),
                      icon: const Icon(Icons.date_range),
                      label: Text(
                        _startDate == null
                            ? 'Start Date'
                            : DateFormat(
                                'MMM dd, yyyy HH:mm',
                              ).format(_startDate!),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _selectDate(context, false),
                      icon: const Icon(Icons.event),
                      label: Text(
                        _endDate == null
                            ? 'End Date'
                            : DateFormat(
                                'MMM dd, yyyy HH:mm',
                              ).format(_endDate!),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              const SizedBox(height: 24),
              const Text(
                'Sale Banner',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Image Picker
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : (widget.sale?.bannerUrl != null &&
                            widget.sale!.bannerUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.memory(
                            base64Decode(widget.sale!.bannerUrl!),
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Center(child: Icon(Icons.broken_image)),
                          ),
                        )
                      : const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo),
                              Text('Add Banner Image'),
                            ],
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),
              const Text(
                'Included Products',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Product Selector
              productsAsync.when(
                data: (products) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _showProductSelector(products),
                        icon: const Icon(Icons.checklist),
                        label: Text(
                          'Select Products (${_selectedProductIds.length} selected)',
                        ),
                      ),
                      if (_selectedProductIds.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _selectedProductIds.map((id) {
                              final prod = products.firstWhere(
                                (p) => p.id == id,
                                orElse: () => Product(
                                  id: '?',
                                  name: 'Unknown',
                                  description: '',
                                  price: 0,
                                  stock: 0,
                                  categoryId: '',
                                  subCategoryId: '',
                                  sellerId: '',
                                  images: [],
                                  isActive: false,
                                  isFeatured: false,
                                  isApproved: false,
                                  createdByRole: 'seller',
                                  createdAt: DateTime.now(),
                                ),
                              );
                              return Chip(
                                label: Text(prod.name),
                                onDeleted: () {
                                  setState(() {
                                    _selectedProductIds.remove(id);
                                  });
                                },
                              );
                            }).toList(),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const LinearProgressIndicator(),
                error: (e, s) => Text('Error loading products: $e'),
              ),

              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.sale == null
                            ? 'Create Campaign'
                            : 'Update Campaign',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProductSelectionDialog extends ConsumerStatefulWidget {
  final List<Product> allProducts;
  final List<String> initialSelection;

  const ProductSelectionDialog({
    super.key,
    required this.allProducts,
    required this.initialSelection,
  });

  @override
  ConsumerState<ProductSelectionDialog> createState() =>
      _ProductSelectionDialogState();
}

class _ProductSelectionDialogState
    extends ConsumerState<ProductSelectionDialog> {
  late List<String> _tempSelectedIds;
  String _searchQuery = '';
  String? _selectedCategoryId;
  String? _selectedSubcategoryId;

  @override
  void initState() {
    super.initState();
    _tempSelectedIds = List.from(widget.initialSelection);
  }

  @override
  Widget build(BuildContext context) {
    // Watch categories and subcategories for filters
    final categoriesAsync = ref.watch(allCategoriesStreamProvider);
    final subcategoriesAsync = ref.watch(allSubcategoriesStreamProvider);

    // Filter products locally
    final filteredProducts = widget.allProducts.where((product) {
      bool matchesSearch = product.name.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesCategory =
          _selectedCategoryId == null ||
          product.categoryId == _selectedCategoryId;
      bool matchesSubcategory =
          _selectedSubcategoryId == null ||
          product.subCategoryId == _selectedSubcategoryId;
      return matchesSearch && matchesCategory && matchesSubcategory;
    }).toList();

    return AlertDialog(
      title: const Text('Select Products'),
      content: SizedBox(
        width: 800, // Fixed wider width
        height: 600, // Fixed height
        child: Column(
          children: [
            // FILTERS
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 0,
                      ),
                    ),
                    onChanged: (val) => setState(() => _searchQuery = val),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: categoriesAsync.when(
                    data: (cats) => DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: const InputDecoration(
                        labelText: 'Filter Category',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                      ),
                      items: [
                        const DropdownMenuItem(
                          value: null,
                          child: Text('All Categories'),
                        ),
                        ...cats.map(
                          (c) => DropdownMenuItem(
                            value: c.id,
                            child: Text(c.name),
                          ),
                        ),
                      ],
                      onChanged: (val) {
                        setState(() {
                          _selectedCategoryId = val;
                          _selectedSubcategoryId = null; // Reset subcat
                        });
                      },
                    ),
                    loading: () => const LinearProgressIndicator(),
                    error: (_, __) => const SizedBox(),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: subcategoriesAsync.when(
                    data: (allSubs) {
                      // Only show subcategories for selected category
                      final relevantSubs = _selectedCategoryId == null
                          ? []
                          : allSubs
                                .where(
                                  (s) => s.categoryId == _selectedCategoryId,
                                )
                                .toList();

                      return DropdownButtonFormField<String>(
                        value: _selectedSubcategoryId,
                        decoration: const InputDecoration(
                          labelText: 'Filter Subcategory',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('All Subcategories'),
                          ),
                          ...relevantSubs.map(
                            (s) => DropdownMenuItem(
                              value: s.id,
                              child: Text(s.name),
                            ),
                          ),
                        ],
                        onChanged: relevantSubs.isEmpty
                            ? null
                            : (val) =>
                                  setState(() => _selectedSubcategoryId = val),
                        disabledHint: const Text('Select Category first'),
                      );
                    },
                    loading: () => const SizedBox(),
                    error: (_, __) => const SizedBox(),
                  ),
                ),
              ],
            ),
            const Divider(),

            // PRODUCT LIST
            Expanded(
              child: filteredProducts.isEmpty
                  ? const Center(
                      child: Text('No products found matching filters'),
                    )
                  : ListView.builder(
                      itemCount: filteredProducts.length,
                      itemBuilder: (ctx, index) {
                        final product = filteredProducts[index];
                        final isSelected = _tempSelectedIds.contains(
                          product.id,
                        );
                        return CheckboxListTile(
                          title: Text(product.name),
                          subtitle: Text(
                            '\$${product.price} - Stock: ${product.stock}',
                          ),
                          secondary: product.images.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.memory(
                                    base64Decode(product.images.first),
                                    width: 40,
                                    height: 40,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) =>
                                        const Icon(Icons.error),
                                  ),
                                )
                              : const Icon(Icons.image_not_supported),
                          value: isSelected,
                          onChanged: (val) {
                            setState(() {
                              if (val == true) {
                                _tempSelectedIds.add(product.id);
                              } else {
                                _tempSelectedIds.remove(product.id);
                              }
                            });
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 16.0),
              child: Text('${_tempSelectedIds.length} selected'),
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, _tempSelectedIds),
                  child: const Text('Confirm Selection'),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}
