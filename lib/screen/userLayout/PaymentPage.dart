import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaymentScreen extends ConsumerWidget {
  const PaymentScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Payment"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double widthFactor = constraints.maxWidth < 600 ? 0.9 : 0.6;
          return Center(
            child: SizedBox(
              width: constraints.maxWidth * widthFactor,
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 20),
                children: [
                  PaymentOptionCard(
                    icon: Icons.credit_card,
                    title: "Credit Card Or Debit",
                    onTap: () {
                      // Handle Credit/Debit selection
                    },
                  ),
                  PaymentOptionCard(
                    icon: Icons.account_balance_wallet,
                    title: "Paypal",
                    onTap: () {
                      // Handle PayPal selection
                    },
                  ),
                  PaymentOptionCard(
                    icon: Icons.account_balance,
                    title: "Bank Transfer",
                    onTap: () {
                      // Handle Bank Transfer selection
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PaymentOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const PaymentOptionCard({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue, size: 30),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
            ),
            IconButton(
                onPressed: onTap,
                icon: const Icon(Icons.chevron_right),
                color: Colors.grey)
          ],
        ),
      ),
    );
  }
}
