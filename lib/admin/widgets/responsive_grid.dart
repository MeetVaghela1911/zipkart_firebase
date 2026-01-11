import 'package:flutter/material.dart';

class ResponsiveGrid<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double spacing;
  final double runSpacing;
  final double childAspectRatio;

  const ResponsiveGrid({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.spacing = 16.0,
    this.runSpacing = 16.0,
    this.childAspectRatio = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        int crossAxisCount;

        if (width >= 1200) {
          crossAxisCount = 5;
        } else if (width >= 900) {
          crossAxisCount = 4;
        } else if (width >= 600) {
          crossAxisCount = 3;
        } else {
          crossAxisCount = 2;
        }

        // Since we want a grid, but GridView can be scrollable or shrinkWrapped.
        // User req: "Grid must: Be non-scrollable, Respect parent scroll"
        // So we should probably use a Wrap or a custom column/row layout,
        // OR a GridView with physics: NeverScrollableScrollPhysics and shrinkWrap: true.
        // GridView is usually easier for uniform grids.

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: spacing,
            mainAxisSpacing: runSpacing,
            childAspectRatio: childAspectRatio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) => itemBuilder(context, items[index]),
        );
      },
    );
  }
}
