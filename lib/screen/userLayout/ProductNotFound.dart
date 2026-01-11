import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProductNotFoundScreen extends ConsumerWidget {
  const ProductNotFoundScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100, // Fixed size for the icon container
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.blue,
                  size: 50, // Fixed icon size
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                "Product Not Found",
                style: TextStyle(
                  fontSize: 22, // Fixed font size
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                "Thank you for shopping using lafyuu",
                style: TextStyle(
                  fontSize: 16, // Fixed font size
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 80, // Fixed button width
                    vertical: 16,
                  ),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/HomePage');
                },
                child: const Text(
                  "Back to Home",
                  style: TextStyle(
                    fontSize: 18, // Fixed font size
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
