import 'package:flutter/material.dart';
import 'package:zipkart_firebase/screen/sellerLayout/DashboardPage.dart';
import 'package:zipkart_firebase/screen/sellerLayout/OrdersPage.dart';
import 'package:zipkart_firebase/screen/sellerLayout/ProductsPage.dart';
import 'package:zipkart_firebase/screen/sellerLayout/SettingsPage.dart';

class SellerApp extends StatelessWidget {
  const SellerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Seller App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SellerHomeScreen(),
    );
  }
}

class SellerHomeScreen extends StatefulWidget {
  const SellerHomeScreen({super.key});

  @override
  _SellerHomeScreenState createState() => _SellerHomeScreenState();
}

class _SellerHomeScreenState extends State<SellerHomeScreen> {
  int _selectedIndex = 0;

  static final List<Widget> _pages = <Widget>[
    const DashboardPage(),
    const ProductsPage(),
    // const ProductsPage(),
    // FilterSearchScreen(),
    OrdersPage(),
    const SettingsPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Seller Dashboard'),
      ),
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
              icon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_bag), label: 'Products'),
          BottomNavigationBarItem(
              icon: Icon(Icons.shopping_cart), label: 'Orders'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.blue,
        useLegacyColorScheme: true,
      ),
    );
  }
}
