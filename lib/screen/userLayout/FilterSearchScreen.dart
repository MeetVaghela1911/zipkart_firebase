import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class FilterSearchScreen extends ConsumerStatefulWidget {
  const FilterSearchScreen({super.key});

  @override
  ConsumerState<FilterSearchScreen> createState() => _FilterSearchScreenState();
}

class _FilterSearchScreenState extends ConsumerState<FilterSearchScreen> {
  double _currentMinPrice = 0.0;
  double _currentMaxPrice = 0.0;

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();

  List<String> selectedCondition = [];
  List<String> selectedBuyingFormat = [];
  List<String> selectedItemLocation = [];
  List<String> selectedShowOnly = [];

  @override
  void dispose() {
    _minPriceController.dispose();
    _maxPriceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filter Search"),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle("Price Range"),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: _currentMinPrice == 0.0 ? "From" : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentMinPrice = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: _currentMaxPrice == 0.0 ? "To" : null,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _currentMaxPrice = double.tryParse(value) ?? 0.0;
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildSectionTitle("Condition"),
            const SizedBox(height: 10),
            _buildOptionButtons(
                ["New", "Used", "Not Specified"], selectedCondition),
            const SizedBox(height: 20),
            _buildSectionTitle("Buying Format"),
            const SizedBox(height: 10),
            _buildOptionButtons([
              "All Listings",
              "Accepts Offers",
              "Auction",
              "Buy It Now",
              "Classified Ads"
            ], selectedBuyingFormat),
            const SizedBox(height: 20),
            _buildSectionTitle("Item Location"),
            const SizedBox(height: 10),
            _buildOptionButtons(["US Only", "North America", "Europe", "Asia"],
                selectedItemLocation),
            const SizedBox(height: 20),
            _buildSectionTitle("Show Only"),
            const SizedBox(height: 10),
            _buildOptionButtons([
              "Free Returns",
              "Returns Accepted",
              "Authorized Seller",
              "Completed Items",
              "Sold Items",
              "Deals & Savings",
              "Sale Items",
              "Listed as Lots",
              "Search in Description",
              "Benefits charity",
              "Authenticity Verified"
            ], selectedShowOnly),
            const SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FilterResultsScreen(
                        minPrice: _currentMinPrice,
                        maxPrice: _currentMaxPrice,
                        condition: selectedCondition,
                        buyingFormat: selectedBuyingFormat,
                        itemLocation: selectedItemLocation,
                        showOnly: selectedShowOnly,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 150, vertical: 22),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text("Apply",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }

  Widget _buildOptionButtons(
      List<String> options, List<String> selectedOptions) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      children: options.map((option) {
        bool isSelected = selectedOptions.contains(option);
        return ChoiceChip(
          label: Text(option),
          selected: isSelected,
          onSelected: (isSelected) {
            setState(() {
              if (isSelected) {
                selectedOptions.add(option);
              } else {
                selectedOptions.remove(option);
              }
            });
          },
          backgroundColor: Colors.grey[200],
          selectedColor: Colors.blue[100],
          labelStyle: const TextStyle(color: Colors.black),
        );
      }).toList(),
    );
  }
}

class FilterResultsScreen extends ConsumerWidget {
  final double minPrice;
  final double maxPrice;
  final List<String> condition;
  final List<String> buyingFormat;
  final List<String> itemLocation;
  final List<String> showOnly;

  const FilterResultsScreen({
    super.key,
    required this.minPrice,
    required this.maxPrice,
    required this.condition,
    required this.buyingFormat,
    required this.itemLocation,
    required this.showOnly,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Filtered Results"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
                "Price Range: \$${minPrice.toStringAsFixed(2)} - \$${maxPrice.toStringAsFixed(2)}"),
            const SizedBox(height: 10),
            Text("Condition: ${condition.join(', ')}"),
            const SizedBox(height: 10),
            Text("Buying Format: ${buyingFormat.join(', ')}"),
            const SizedBox(height: 10),
            Text("Item Location: ${itemLocation.join(', ')}"),
            const SizedBox(height: 10),
            Text("Show Only: ${showOnly.join(', ')}"),
          ],
        ),
      ),
    );
  }
}
