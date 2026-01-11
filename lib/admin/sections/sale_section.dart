import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:zipkart_firebase/Models/sale_model.dart';
import 'package:zipkart_firebase/admin/screens/add_sale_screen.dart';
import 'package:zipkart_firebase/admin/widgets/admin_section_header.dart';
import 'package:zipkart_firebase/admin/widgets/responsive_grid.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class SaleSection extends ConsumerStatefulWidget {
  const SaleSection({super.key});

  @override
  ConsumerState<SaleSection> createState() => _SaleSectionState();
}

class _SaleSectionState extends ConsumerState<SaleSection> {
  bool _showInactive = false;

  @override
  Widget build(BuildContext context) {
    final salesAsync = ref.watch(allSalesStreamProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AdminSectionHeader(
          title: 'Sale Campaigns',
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
              MaterialPageRoute(builder: (context) => const AddSaleScreen()),
            );
          },
        ),
        salesAsync.when(
          data: (sales) {
            final displayedSales = _showInactive
                ? sales
                : sales.where((s) => s.isActive).toList();

            if (displayedSales.isEmpty) {
              return const Center(
                child: Text('No active sale campaigns found. Create one!'),
              );
            }

            return ResponsiveGrid<SaleModel>(
              items: displayedSales,
              childAspectRatio: 1, // Adjusted for more height
              itemBuilder: (context, sale) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddSaleScreen(sale: sale),
                      ),
                    );
                  },
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: sale.isActive && sale.isCurrentlyActive
                          ? BorderSide.none
                          : BorderSide(
                              color: !sale.isActive
                                  ? Colors.red
                                  : Colors.orange,
                              width: 2,
                            ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Baner
                        Expanded(
                          flex: 3,
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12),
                            ),
                            child:
                                (sale.bannerUrl != null &&
                                    sale.bannerUrl!.isNotEmpty)
                                ? Image.memory(
                                    base64Decode(sale.bannerUrl!),
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Container(
                                      color: Colors.grey[300],
                                      child: const Icon(Icons.calculate),
                                    ),
                                  )
                                : Container(
                                    color: Colors.blueGrey[100],
                                    child: Center(
                                      child: Text(
                                        '${sale.discountPercent.toInt()}% OFF',
                                        style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                        // Info
                        Expanded(
                          flex: 2,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text(
                                  sale.name,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                Text(
                                  '${DateFormat('MMM d').format(sale.startDate)} - ${DateFormat('MMM d').format(sale.endDate)}',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 6,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Theme.of(
                                          context,
                                        ).primaryColor.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: Theme.of(
                                            context,
                                          ).primaryColor.withOpacity(0.5),
                                        ),
                                      ),
                                      child: Text(
                                        sale.saleType.toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).primaryColor,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      '${sale.productIds.length} Products',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (!sale.isActive)
                          Container(
                            color: Colors.red,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'INACTIVE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        else if (!sale.isCurrentlyActive)
                          Container(
                            color: Colors.orange,
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'EXPIRED / UPCOMING',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
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
