import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/Models/category_model.dart';
import 'package:zipkart_firebase/Models/subcategory_model.dart';
import 'package:zipkart_firebase/admin/screens/add_subcategory_screen.dart';
import 'package:zipkart_firebase/admin/widgets/admin_section_header.dart';
import 'package:zipkart_firebase/admin/widgets/responsive_grid.dart';
import 'package:zipkart_firebase/admin/widgets/bulk_import_dialog.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class SubcategorySection extends ConsumerStatefulWidget {
  const SubcategorySection({super.key});

  @override
  ConsumerState<SubcategorySection> createState() => _SubcategorySectionState();
}

class _SubcategorySectionState extends ConsumerState<SubcategorySection> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final subcategoriesAsync = ref.watch(allSubcategoriesStreamProvider);
    final categoriesAsync = ref.watch(categoriesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: 'Subcategories',
          action: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _showInactive,
                onChanged: (val) =>
                    setState(() => _showInactive = val ?? false),
              ),
              const Text('Show Inactive'),
            ],
          ),
          onAddPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AddSubcategoryScreen(),
              ),
            );
          },
          onBulkImportPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  const BulkImportDialog(type: ImportType.subcategory),
            );
          },
        ),
        subcategoriesAsync.when(
          data: (subcategories) {
            // Filter
            final displayedSubcategories = _showInactive
                ? subcategories
                : subcategories.where((s) => s.isActive).toList();

            if (displayedSubcategories.isEmpty) {
              return const Center(child: Text('No subcategories found'));
            }
            return ResponsiveGrid<SubcategoryModel>(
              items: displayedSubcategories,
              childAspectRatio: 3.0, // Wider cards for text-only content
              itemBuilder: (context, subcategory) {
                // Find parent category name safely
                final categoryName = categoriesAsync.maybeWhen(
                  data: (categories) => categories
                      .firstWhere(
                        (c) => c.id == subcategory.categoryId,
                        orElse: () => CategoryModel(
                          id: '',
                          name: 'Unknown',
                          order: 0,
                          isActive: false,
                          createdAt: DateTime.now(),
                        ),
                      )
                      .name,
                  orElse: () => '...',
                );

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AddSubcategoryScreen(subcategory: subcategory),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: subcategory.isActive
                          ? BorderSide.none
                          : const BorderSide(color: Colors.red, width: 2),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.subdirectory_arrow_right,
                            size: 24,
                            color: Colors.blueGrey,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  subcategory.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  categoryName,
                                  style: Theme.of(context).textTheme.bodySmall
                                      ?.copyWith(color: Colors.grey),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (!subcategory.isActive)
                            const Text(
                              'INACTIVE',
                              style: TextStyle(
                                color: Colors.red,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          const SizedBox(width: 8),
                          const Icon(Icons.edit, size: 16, color: Colors.grey),
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
}
