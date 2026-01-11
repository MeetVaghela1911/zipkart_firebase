import 'package:flutter/material.dart';
import 'package:zipkart_firebase/admin/sections/banner_section.dart';
import 'package:zipkart_firebase/admin/sections/category_section.dart';
import 'package:zipkart_firebase/admin/sections/product_section.dart';
import 'package:zipkart_firebase/admin/sections/subcategory_section.dart';
import 'package:zipkart_firebase/admin/sections/sale_section.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Dashboard'), elevation: 0),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: const [
              BannerSection(),
              Divider(height: 32),
              SaleSection(),
              Divider(height: 32),
              CategorySection(),
              Divider(height: 32),
              SubcategorySection(),
              Divider(height: 32),
              ProductSection(),
              SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }
}
