import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

//for homepage bottomnavigation
class OffersScreeen extends ConsumerWidget {
  const OffersScreeen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Padding(
      padding: EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 16),
          OfferCard(
            title: 'Super Flash Sale 50% Off',
            description: '08 : 34 : 52',
            imageUrl:
                'https://images.pexels.com/photos/60597/dahlia-red-blossom-bloom-60597.jpeg', // Replace with an actual image URL
          ),
          SizedBox(height: 16),
          OfferCard(
            title: '90% Off Super Mega Sale',
            description: 'Special birthday Lafyuu',
            imageUrl:
                'https://images.pexels.com/photos/60597/dahlia-red-blossom-bloom-60597.jpeg', // Replace with an actual image URL
          ),
        ],
      ),
    );
  }
}

class OfferCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const OfferCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150, // Adjust as needed
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Background Image
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.network(
              imageUrl,
              fit: BoxFit.cover,
              width: double.infinity,
              height: double.infinity,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[300]),
            ),
          ),
          // Overlay with opacity
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.black.withOpacity(0.5),
            ),
          ),
          // Text content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  description,
                  style: const TextStyle(fontSize: 16, color: Colors.white70),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
