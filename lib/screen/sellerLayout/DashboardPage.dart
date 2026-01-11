import 'package:flutter/material.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final maxCardWidth = screenWidth > 600
        ? 400.0
        : screenWidth * 0.9; // Limit width on large screens

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Dashboard Overview",
            style: TextStyle(
              fontSize: screenWidth < 600
                  ? screenWidth * 0.05
                  : 24, // Limit font size for larger screens
            ),
          ),
          const SizedBox(height: 20),
          DashboardStatCard(
              title: "Total Sales", value: "\$5000", maxWidth: maxCardWidth),
          DashboardStatCard(
              title: "Total Orders", value: "150", maxWidth: maxCardWidth),
          DashboardStatCard(
              title: "Inventory", value: "80 items", maxWidth: maxCardWidth),
        ],
      ),
    );
  }
}

class DashboardStatCard extends StatelessWidget {
  final String title;
  final String value;
  final double maxWidth;

  const DashboardStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth),
      child: Card(
        margin: const EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 10),
              Text(
                value,
                style:
                    const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
