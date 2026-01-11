import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/Models/banner_model.dart';
import 'package:zipkart_firebase/admin/screens/add_banner_screen.dart';
import 'package:zipkart_firebase/admin/widgets/admin_section_header.dart';
import 'package:zipkart_firebase/admin/widgets/responsive_grid.dart';
import 'package:zipkart_firebase/admin/widgets/bulk_import_dialog.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class BannerSection extends ConsumerStatefulWidget {
  const BannerSection({super.key});

  @override
  ConsumerState<BannerSection> createState() => _BannerSectionState();
}

class _BannerSectionState extends ConsumerState<BannerSection> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    // Use ALL banners provider
    final bannersAsync = ref.watch(allBannersStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: 'Banners',
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
              MaterialPageRoute(builder: (context) => const AddBannerScreen()),
            );
          },
          onBulkImportPressed: () {
            showDialog(
              context: context,
              builder: (context) =>
                  const BulkImportDialog(type: ImportType.banner),
            );
          },
        ),
        bannersAsync.when(
          data: (banners) {
            // Filter
            final displayedBanners = _showInactive
                ? banners
                : banners.where((b) => b.isActive).toList();

            if (displayedBanners.isEmpty) {
              return const Center(child: Text('No banners found'));
            }
            return ResponsiveGrid<BannerModel>(
              items: displayedBanners,
              childAspectRatio: 1.8,
              itemBuilder: (context, banner) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddBannerScreen(banner: banner),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: banner.isActive
                          ? BorderSide.none
                          : const BorderSide(color: Colors.red, width: 2),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          _buildImage(banner.imageUrl),
                          if (!banner.isActive)
                            Container(
                              color: Colors.black54,
                              alignment: Alignment.center,
                              child: const Text(
                                'INACTIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          // Optional: Add title overlay for better identification if image fails
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              color: Colors.black38,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              child: Text(
                                banner.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
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
