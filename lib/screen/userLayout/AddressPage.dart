import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/core/globle_provider/TheameMode.dart';
import 'package:zipkart_firebase/core/theme/AppColors.dart';

class AddressScreen extends ConsumerStatefulWidget {
  const AddressScreen({super.key});

  @override
  ConsumerState<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends ConsumerState<AddressScreen> {
  // In a real app, this would come from a provider
  List<Address> addresses = [
    Address(
        name: 'Priscekila',
        address: '3711 Spring Hill Rd, Tallahassee, Nevada 52874 United States',
        phone: '+99 1234567890'),
    Address(
        name: 'Ahmad Khadir',
        address: '3711 Spring Hill Rd, Tallahassee, Nevada 52874 United States',
        phone: '+99 1234567890'),
  ];

  void addOrEditAddress({Address? address, int? index}) {
    showDialog(
      context: context,
      builder: (context) {
        final nameController = TextEditingController(text: address?.name ?? '');
        final addressController =
            TextEditingController(text: address?.address ?? '');
        final phoneController =
            TextEditingController(text: address?.phone ?? '');

        return AlertDialog(
          title: Text(address == null ? 'Add Address' : 'Edit Address'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: addressController,
                decoration: const InputDecoration(labelText: 'Address'),
              ),
              TextField(
                controller: phoneController,
                decoration: const InputDecoration(labelText: 'Phone'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newAddress = Address(
                  name: nameController.text,
                  address: addressController.text,
                  phone: phoneController.text,
                );

                setState(() {
                  if (index != null) {
                    addresses[index] = newAddress;
                  } else {
                    addresses.add(newAddress);
                  }
                });
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteAddress(int index) {
    setState(() {
      addresses.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Ship To"),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back_ios),
        //   onPressed: () {
        //     Navigator.pop(context);
        //   },
        // ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double widthFactor = constraints.maxWidth < 600 ? 0.9 : 0.6;
          return Center(
            child: Container(
              margin: const EdgeInsets.all(10),
              width: constraints.maxWidth * widthFactor,
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: addresses.length,
                      itemBuilder: (context, index) {
                        final address = addresses[index];
                        return AddressCard(
                          address: address,
                          onEdit: () =>
                              addOrEditAddress(address: address, index: index),
                          onDelete: () => deleteAddress(index),
                        );
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, '/Payment');
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            backgroundColor: isDarkTheme ? AppColors.dark.colorPrimary : AppColors.light.colorPrimary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(
                                // color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
                            addOrEditAddress();
                          },
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            ),
                          ),
                          child: const Text(
                            "Add Address",
                            style: TextStyle(
                                // color: Colors.white,
                                fontSize: 18
                            ),
                          ),
                        ),
                      ),
                    ],
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

class AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            address.name,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(address.address),
          const SizedBox(height: 8),
          Text(address.phone),
          const SizedBox(height: 10),
          Row(
            children: [
              ElevatedButton(
                onPressed: onEdit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0, horizontal: 20),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                child: const Text(
                  'Edit',
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onDelete,
                icon: const Icon(Icons.delete, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class Address {
  String name;
  String address;
  String phone;

  Address({required this.name, required this.address, required this.phone});
}
