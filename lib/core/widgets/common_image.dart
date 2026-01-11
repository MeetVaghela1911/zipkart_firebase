import 'dart:convert';
import 'package:flutter/material.dart';

/// Helper function to build images from base64 strings or network URLs
/// Admin side stores images as base64, so we need to decode them
Widget buildCommonImage(
  String? imageString, {
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
  Widget? errorWidget,
}) {
  if (imageString == null || imageString.isEmpty) {
    return errorWidget ?? const Icon(Icons.image_not_supported);
  }

  // Check if it's a base64 string (starts with data:image or is a long base64 string)
  // Base64 strings are typically long and don't contain http/https
  final isBase64 =
      imageString.startsWith('data:image') ||
      (!imageString.startsWith('http://') &&
          !imageString.startsWith('https://') &&
          imageString.length > 20); // Small threshold for base64

  try {
    if (isBase64) {
      // Remove data URL prefix if present (e.g., "data:image/png;base64,")
      String base64Data = imageString;
      if (base64Data.contains(',')) {
        base64Data = base64Data.split(',').last;
      }

      // Clean up whitespace if any
      base64Data = base64Data.replaceAll(RegExp(r'\s+'), '');

      return Image.memory(
        base64Decode(base64Data),
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) {
          return errorWidget ?? const Icon(Icons.broken_image);
        },
      );
    } else {
      // Network URL
      return Image.network(
        imageString,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? const Icon(Icons.image_not_supported),
      );
    }
  } catch (e) {
    // If decoding fails, try as network URL if it looks like one
    if (imageString.startsWith('http')) {
      return Image.network(
        imageString,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? const Icon(Icons.broken_image),
      );
    }
    return errorWidget ?? const Icon(Icons.broken_image);
  }
}
