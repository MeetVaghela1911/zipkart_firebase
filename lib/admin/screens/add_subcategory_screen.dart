import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/Models/category_model.dart';
import 'package:zipkart_firebase/Models/subcategory_model.dart'; // Added
import 'package:zipkart_firebase/providers/admin_providers.dart';

class AddSubcategoryScreen extends ConsumerStatefulWidget {
  final SubcategoryModel? subcategory; // Optional for edit

  const AddSubcategoryScreen({super.key, this.subcategory});

  @override
  ConsumerState<AddSubcategoryScreen> createState() =>
      _AddSubcategoryScreenState();
}

class _AddSubcategoryScreenState extends ConsumerState<AddSubcategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  String? _selectedCategoryId;
  bool _isLoading = false;
  bool _isActive = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: widget.subcategory?.name ?? '',
    );
    _selectedCategoryId = widget.subcategory?.categoryId;
    _isActive = widget.subcategory?.isActive ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveSubcategory() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select a category')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(firestoreServiceProvider);

      if (widget.subcategory == null) {
        // ADD
        await service.addSubcategory(
          name: _nameController.text.trim(),
          categoryId: _selectedCategoryId!,
        );
      } else {
        // UPDATE
        await service.updateSubcategory(widget.subcategory!.id, {
          'name': _nameController.text.trim(),
          'categoryId': _selectedCategoryId,
          'isActive': _isActive,
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Subcategory ${widget.subcategory == null ? 'added' : 'updated'} successfully',
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
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _deleteSubcategory() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Subcategory'),
        content: Text(
          'Are you sure you want to delete "${widget.subcategory?.name}"? (Soft Delete)',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(firestoreServiceProvider)
            .deleteSubcategory(widget.subcategory!.id);
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Subcategory deleted')));
          Navigator.pop(context);
        }
      } catch (e) {
        if (mounted)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get active categories for the dropdown
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.subcategory == null ? 'Add Subcategory' : 'Edit Subcategory',
        ),
        actions: [
          if (widget.subcategory != null)
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _isLoading ? null : _deleteSubcategory,
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
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Subcategory Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => value == null || value.isEmpty
                    ? 'Please enter a name'
                    : null,
              ),
              const SizedBox(height: 16),
              categoriesAsync.when(
                data: (categories) {
                  return DropdownButtonFormField<String>(
                    value: _selectedCategoryId,
                    decoration: const InputDecoration(
                      labelText: 'Parent Category',
                      border: OutlineInputBorder(),
                    ),
                    items: categories.map((CategoryModel category) {
                      return DropdownMenuItem<String>(
                        value: category.id,
                        child: Text(category.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategoryId = value;
                      });
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) =>
                    Text('Error loading categories: $error'),
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Active'),
                value: _isActive,
                onChanged: (val) => setState(() => _isActive = val),
              ),

              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _isLoading ? null : _saveSubcategory,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(
                        widget.subcategory == null
                            ? 'Save Subcategory'
                            : 'Update Subcategory',
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
