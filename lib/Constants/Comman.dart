import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class Comman{

  Future<void> requestGalleryPermission(dynamic context) async {
    if (await Permission.storage.request().isGranted) {
      // Permission granted, proceed with image picker
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission is required to select an image')),
      );
    }
  }

}