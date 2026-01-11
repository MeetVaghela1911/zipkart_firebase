import 'package:flutter/material.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final tileMaxWidth = screenWidth > 600 ? 400.0 : screenWidth * 0.9;

    return ListView(
      children: [
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tileMaxWidth),
          child: ListTile(
            leading: const Icon(Icons.person),
            title: const Text("Account"),
            onTap: () {
              // Navigate to account settings
            },
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tileMaxWidth),
          child: ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text("Notifications"),
            onTap: () {
              // Navigate to notification settings
            },
          ),
        ),
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: tileMaxWidth),
          child: ListTile(
            leading: const Icon(Icons.lock),
            title: const Text("Privacy"),
            onTap: () {
              // Navigate to privacy settings
            },
          ),
        ),
      ],
    );
  }
}
