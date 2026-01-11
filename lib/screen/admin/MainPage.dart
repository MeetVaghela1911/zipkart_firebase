import 'package:flutter/material.dart';
import 'package:zipkart_firebase/admin/admin_home_screen.dart';
import 'package:zipkart_firebase/screen/admin/SellerListPage.dart';

/// AdminApp Widget
///
/// Main entry point for the admin panel.
/// Returns AdminMainScreen directly without wrapping in MaterialApp
/// to avoid conflicts with the main app's MaterialApp.router.
class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Return the admin screen directly without MaterialApp wrapper
    return const AdminMainScreen();
  }
}

class AdminMainScreen extends StatefulWidget {
  const AdminMainScreen({super.key});

  @override
  _AdminMainScreenState createState() => _AdminMainScreenState();
}

class _AdminMainScreenState extends State<AdminMainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const AdminHomeScreen(),
    const SellersListScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Sellers'),
        ],
      ),
    );
  }
}
