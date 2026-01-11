import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/Models/category_model.dart';
import 'package:zipkart_firebase/admin/screens/add_category_screen.dart';
import 'package:zipkart_firebase/admin/widgets/admin_section_header.dart';
import 'package:zipkart_firebase/admin/widgets/responsive_grid.dart';
import 'package:zipkart_firebase/admin/widgets/bulk_import_dialog.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class CategorySection extends ConsumerStatefulWidget {
  const CategorySection({super.key});

  @override
  ConsumerState<CategorySection> createState() => _CategorySectionState();
}

class _CategorySectionState extends ConsumerState<CategorySection> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    // Use ALL categories provider to get everything, then filter locally
    final categoriesAsync = ref.watch(allCategoriesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: 'Categories',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _showInactive,
                onChanged: (val) {
                  setState(() {
                    _showInactive = val ?? false;
                  });
                },
              ),
              const Text('Show Inactive'),
            ],
          ),
          onAddPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddCategoryScreen(),
              ),
            );
          },
          onBulkImportPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  const BulkImportDialog(type: ImportType.category),
            );
          },
        ),
        categoriesAsync.when(
          data: (categories) {
            // Filter list based on toggle
            final displayedCategories = _showInactive
                ? categories
                : categories.where((c) => c.isActive).toList();

            if (displayedCategories.isEmpty) {
              return const Center(child: Text('No categories found'));
            }
            return ResponsiveGrid<CategoryModel>(
              items: displayedCategories,
              itemBuilder: (context, category) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddCategoryScreen(category: category),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: category.isActive
                          ? BorderSide.none
                          : const BorderSide(color: Colors.red, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (category.iconUrl != null &&
                              category.iconUrl!.isNotEmpty)
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: _buildImage(category.iconUrl!),
                              ),
                            )
                          else
                            const Expanded(
                              child: Icon(
                                Icons.category,
                                size: 48,
                                color: Colors.grey,
                              ),
                            ),
                          const SizedBox(height: 8),
                          Text(
                            category.name,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (!category.isActive)
                            const Text(
                              'INACTIVE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
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
}
