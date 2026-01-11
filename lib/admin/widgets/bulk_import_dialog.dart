import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';
import 'package:zipkart_firebase/services/bulk_import_service.dart';

enum ImportType { banner, category, subcategory, product }

class BulkImportDialog extends ConsumerStatefulWidget {
  final ImportType type;

  const BulkImportDialog({super.key, required this.type});

  @override
  ConsumerState<BulkImportDialog> createState() => _BulkImportDialogState();
}

class _BulkImportDialogState extends ConsumerState<BulkImportDialog> {
  bool _isProcessing = false;
  String? _status;
  final _service = BulkImportService();

  Future<void> _startImport() async {
    setState(() {
      _isProcessing = true;
      _status = 'Picking file...';
    });

    try {
      final rows = await _service.pickAndParseCsv();
      if (rows == null || rows.isEmpty) {
        setState(() {
          _isProcessing = false;
          _status = 'No file selected or empty CSV';
        });
        return;
      }

      final firestore = ref.read(firestoreServiceProvider);
      int count = 0;

      switch (widget.type) {
        case ImportType.banner:
          setState(() => _status = 'Parsing banners...');
          final data = _service.parseBanners(rows);
          if (data.isNotEmpty) {
            setState(() => _status = 'Uploading ${data.length} banners...');
            await firestore.addBulkBanners(data);
            count = data.length;
          }
          break;
        case ImportType.category:
          setState(() => _status = 'Parsing categories...');
          final data = _service.parseCategories(rows);
          if (data.isNotEmpty) {
            setState(() => _status = 'Uploading ${data.length} categories...');
            await firestore.addBulkCategories(data);
            count = data.length;
          }
          break;
        case ImportType.subcategory:
          setState(() => _status = 'Parsing subcategories...');
          final data = _service.parseSubCategories(rows);
          if (data.isNotEmpty) {
            setState(
              () => _status = 'Uploading ${data.length} subcategories...',
            );
            await firestore.addBulkSubcategories(data);
            count = data.length;
          }
          break;
        case ImportType.product:
          setState(() => _status = 'Parsing products...');
          final data = _service.parseProducts(rows);
          if (data.isNotEmpty) {
            setState(() => _status = 'Uploading ${data.length} products...');
            await firestore.addBulkProducts(data);
            count = data.length;
          }
          break;
      }

      setState(() {
        _isProcessing = false;
        _status = 'Successfully imported $count items!';
      });

      // Delay and close
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _status = 'Error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String title = 'Bulk Import ${widget.type.name}s';

    return AlertDialog(
      title: Text(title),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Upload a CSV file to import multiple items at once. Ensure headers match the expected format.',
            style: TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          if (_isProcessing)
            const CircularProgressIndicator()
          else if (_status != null)
            Text(
              _status!,
              style: TextStyle(
                color: _status!.startsWith('Error') ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          const SizedBox(height: 16),
          _buildFormatInfo(),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isProcessing ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isProcessing ? null : _startImport,
          child: const Text('Select CSV & Import'),
        ),
      ],
    );
  }

  Widget _buildFormatInfo() {
    String headers = '';
    switch (widget.type) {
      case ImportType.banner:
        headers = 'imageUrl, [title, linkType, linkId, priority]';
        break;
      case ImportType.category:
        headers = 'name, image, [order]';
        break;
      case ImportType.subcategory:
        headers = 'name, categoryId, image';
        break;
      case ImportType.product:
        headers =
            'name, description, price, categoryId, sellerId, [salePrice, stock, subCategoryId, image (Base64/URL), isFeatured]';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Expected Headers (Case-insensitive):',
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            headers,
            style: const TextStyle(fontSize: 11, fontFamily: 'monospace'),
          ),
          const Text(
            '* [] items are optional.',
            style: TextStyle(fontSize: 10, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }
}
