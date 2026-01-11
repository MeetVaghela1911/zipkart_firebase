import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:zipkart_firebase/Models/Order.dart';
import '../../firebase_cloud/FirebaseService.dart';

class OrdersPage extends StatelessWidget {
  final FirebaseService _firebaseService = FirebaseService();
  final String sellerId = FirebaseAuth.instance.currentUser!.uid;

  OrdersPage({super.key});

  void _updateOrderStatus(
      BuildContext context, Orders order, String newStatus) {
    _firebaseService.updateOrderStatus(order.id, newStatus);
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Order status updated to $newStatus")));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Orders>>(
      stream: _firebaseService.getOrders(sellerId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Center(child: Text('Error fetching orders'));
        }
        if (snapshot.hasData) {
          return const Center(child: Text('No Orders Found'));
        }
        final orders = snapshot.data ?? [];
        return ListView(
          children: orders.map((order) {
            return Card(
              child: ListTile(
                title: Text("Order ID: ${order.id}"),
                subtitle:
                    Text("Amount: ${order.price} - Status: ${order.stock}"),
                trailing: DropdownButton<String>(
                  value: order.stock.toString(),
                  items: ["Pending", "Shipped", "Delivered"].map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (newStatus) =>
                      _updateOrderStatus(context, order, newStatus!),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
