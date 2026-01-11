import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:zipkart_firebase/Models/banner_model.dart';
import 'package:zipkart_firebase/Models/category_model.dart';
import 'package:zipkart_firebase/Models/subcategory_model.dart';
import 'package:zipkart_firebase/Models/Product.dart';

class BulkImportService {
  Future<List<List<dynamic>>?> pickAndParseCsv() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
      withData: true,
    );

    if (result == null || result.files.isEmpty) return null;

    final file = result.files.first;
    String csvString;

    try {
      if (kIsWeb) {
        final bytes = file.bytes;
        if (bytes == null) return null;
        csvString = utf8.decode(bytes);
      } else {
        if (file.path == null) return null;
        // Simple and safe for standard CSV files
        csvString = await File(file.path!).readAsString();
      }
      // Let it detect eol automatically
      return const CsvToListConverter().convert(csvString);
    } catch (e) {
      debugPrint('Error reading CSV: $e');
      return null;
    }
  }

  // --- Parsers ---

  List<Map<String, dynamic>> parseBanners(List<List<dynamic>> rows) {
    if (rows.isEmpty) return [];
    final headers = rows.first
        .map((e) => e.toString().toLowerCase().trim())
        .toList();
    final data = <Map<String, dynamic>>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;

      try {
        final map = <String, dynamic>{};

        void add(String key, List<String> aliases) {
          for (var alias in aliases) {
            final idx = headers.indexOf(alias.toLowerCase());
            if (idx != -1 && idx < row.length) {
              map[key] = row[idx];
              return;
            }
          }
        }

        add('imageUrl', ['imageurl', 'image', 'url']);
        add('title', ['title', 'name']);
        add('linkType', ['linktype', 'type']);
        add('linkId', ['linkid', 'id']);
        add('priority', ['priority', 'order']);

        if (map.containsKey('imageUrl')) {
          data.add(map);
        }
      } catch (e) {
        debugPrint('Error parsing banner row $i: $e');
      }
    }
    return data;
  }

  List<Map<String, dynamic>> parseCategories(List<List<dynamic>> rows) {
    if (rows.isEmpty) return [];
    final headers = rows.first
        .map((e) => e.toString().toLowerCase().trim())
        .toList();
    final data = <Map<String, dynamic>>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      try {
        final map = <String, dynamic>{};

        void add(String key, List<String> aliases) {
          for (var alias in aliases) {
            final idx = headers.indexOf(alias.toLowerCase());
            if (idx != -1 && idx < row.length) {
              map[key] = row[idx];
              return;
            }
          }
        }

        add('name', ['name', 'title']);
        add('iconUrl', ['iconurl', 'image', 'icon']);
        add('order', ['order', 'priority']);

        if (map.containsKey('name')) {
          data.add(map);
        }
      } catch (e) {
        debugPrint('Error parsing category row $i: $e');
      }
    }
    return data;
  }

  List<Map<String, dynamic>> parseSubCategories(List<List<dynamic>> rows) {
    if (rows.isEmpty) return [];
    final headers = rows.first
        .map((e) => e.toString().toLowerCase().trim())
        .toList();
    final data = <Map<String, dynamic>>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      try {
        final map = <String, dynamic>{};

        void add(String key, List<String> aliases) {
          for (var alias in aliases) {
            final idx = headers.indexOf(alias.toLowerCase());
            if (idx != -1 && idx < row.length) {
              map[key] = row[idx];
              return;
            }
          }
        }

        add('name', ['name', 'title']);
        add('categoryId', ['categoryid', 'parentid']);

        if (map.containsKey('name') && map.containsKey('categoryId')) {
          data.add(map);
        }
      } catch (e) {
        debugPrint('Error parsing subcategory row $i: $e');
      }
    }
    return data;
  }

  List<Map<String, dynamic>> parseProducts(List<List<dynamic>> rows) {
    if (rows.isEmpty) return [];
    final headers = rows.first
        .map((e) => e.toString().toLowerCase().trim())
        .toList();
    final data = <Map<String, dynamic>>[];

    for (var i = 1; i < rows.length; i++) {
      final row = rows[i];
      if (row.isEmpty) continue;
      try {
        final map = <String, dynamic>{};

        void add(String key, List<String> aliases) {
          for (var alias in aliases) {
            final idx = headers.indexOf(alias.toLowerCase());
            if (idx != -1 && idx < row.length) {
              map[key] = row[idx];
              return;
            }
          }
        }

        add('name', ['name', 'title']);
        add('description', ['description', 'desc']);
        add('price', ['price']);
        add('salePrice', ['saleprice', 'discountprice']);
        add('stock', ['stock', 'qty', 'quantity']);
        add('categoryId', ['categoryid', 'category']);
        add('subCategoryId', ['subcategoryid', 'subcategory']);
        add('sellerId', ['sellerid', 'seller']);
        add('returnPolicy', ['returnpolicy']);
        add('warrantyPolicy', ['warrantypolicy']);

        // Images: Assume single column 'image' for simplicity or split by comma?
        final imgIdx = headers.indexWhere(
          (h) => h == 'image' || h == 'images' || h == 'imageurl',
        );
        if (imgIdx != -1 && imgIdx < row.length) {
          final imgRaw = row[imgIdx].toString();
          if (imgRaw.isNotEmpty) {
            // Support comma separated images
            map['images'] = imgRaw
                .split(',')
                .map((e) => e.trim())
                .where((e) => e.isNotEmpty)
                .toList();
          } else {
            map['images'] = [];
          }
        } else {
          map['images'] = [];
        }

        // Booleans
        final featIdx = headers.indexOf('isfeatured');
        if (featIdx != -1 && featIdx < row.length) {
          map['isFeatured'] = row[featIdx].toString().toLowerCase() == 'true';
        } else {
          map['isFeatured'] = false;
        }

        if (map.containsKey('name') &&
            map.containsKey('price') &&
            map.containsKey('categoryId')) {
          data.add(map);
        }
      } catch (e) {
        debugPrint('Error parsing product row $i: $e');
      }
    }
    return data;
  }
}
