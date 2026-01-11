import 'package:flutter/material.dart';

class AdminSectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAddPressed;
  final VoidCallback? onBulkImportPressed;
  final Widget? action;

  const AdminSectionHeader({
    super.key,
    required this.title,
    required this.onAddPressed,
    this.onBulkImportPressed,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              if (action != null) ...[const SizedBox(width: 16), action!],
            ],
          ),
          Row(
            children: [
              if (onBulkImportPressed != null) ...[
                OutlinedButton.icon(
                  onPressed: onBulkImportPressed,
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Bulk Import'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              ElevatedButton.icon(
                onPressed: onAddPressed,
                icon: const Icon(Icons.add),
                label: const Text('Add New'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
