import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:zipkart_firebase/Models/banner_model.dart';
import 'package:zipkart_firebase/providers/admin_providers.dart';

class AddBannerScreen extends ConsumerStatefulWidget {
  final BannerModel? banner; // If provided, edit mode

  const AddBannerScreen({super.key, this.banner});

  @override
  ConsumerState<AddBannerScreen> createState() => _AddBannerScreenState();
}

class _AddBannerScreenState extends ConsumerState<AddBannerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _priorityController = TextEditingController(); // Only for Add

  XFile? _selectedImage;
  bool _isActive = true;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.banner != null) {
      _titleController.text = widget.banner!.title;
      _priorityController.text = widget.banner!.priority.toString();
      _isActive = widget.banner!.isActive;
    } else {
      _titleController.text =
          'New Banner ${DateTime.now().millisecondsSinceEpoch}';
      _priorityController.text = '0';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _priorityController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = image;
      });
    }
  }

  Future<void> _saveBanner() async {
    if (!_formKey.currentState!.validate()) return;

    // For Add, image is required
    if (widget.banner == null && _selectedImage == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please select an image')));
      return;
    }

    setState(() => _isLoading = true);

    try {
      final service = ref.read(firestoreServiceProvider);

      if (widget.banner == null) {
        // Add
        await service.addBanner(
          title: _titleController.text.trim(),
          linkType: 'none', // Hardcoded as per original
          priority: int.tryParse(_priorityController.text) ?? 0,
          image: _selectedImage,
          isActive: _isActive,
        );
      } else {
        // Edit - Currently only updates isActive as per original logic,
        // but we can potentially update more if service supports it.
        // Service updateBanner supports Map<String, dynamic>.
        // We will update isActive and title for now.
        // Image update is not supported by updateBanner in Step 18 view?
        // Step 18: updateBanner(id, updates).
        // It doesn't handle image upload inside updateBanner.

        await service.updateBanner(widget.banner!.id, {
          'isActive': _isActive,
          // 'title': _titleController.text.trim(), // Optional extension
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.banner == null ? 'Banner added' : 'Banner updated',
            ),
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.banner != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Banner' : 'Add Banner')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title (Edit only title if needed, mostly internal name)
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Banner Title (Internal)',
                  border: OutlineInputBorder(),
                ),
                enabled:
                    !isEdit, // Keep it read-only on edit if we want strict regression adherence, or editable.
                // Original code auto-generated title on Add.
                validator: (v) => v?.isEmpty ?? true ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              if (!isEdit)
                TextFormField(
                  controller: _priorityController,
                  decoration: const InputDecoration(
                    labelText: 'Priority',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              if (!isEdit) const SizedBox(height: 16),

              // Image
              const Text(
                'Banner Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: isEdit
                    ? null
                    : _pickImage, // Disable image change on edit as service doesn't support it easily yet
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey),
                  ),
                  child: _selectedImage != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: kIsWeb
                              ? Image.network(
                                  _selectedImage!.path,
                                  fit: BoxFit.cover,
                                )
                              : Image.file(
                                  File(_selectedImage!.path),
                                  fit: BoxFit.cover,
                                ),
                        )
                      : (isEdit && widget.banner!.imageUrl.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: _buildNetworkImage(widget.banner!.imageUrl),
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.add_a_photo,
                              size: 40,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 4),
                            Text('Tap to select image'),
                          ],
                        ),
                ),
              ),
              if (isEdit)
                const Padding(
                  padding: EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Image update not supported in this version',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ),

              const SizedBox(height: 16),

              // Active
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Is Active'),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),

              const SizedBox(height: 24),

              ElevatedButton(
                onPressed: _isLoading ? null : _saveBanner,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : Text(isEdit ? 'Update Banner' : 'Add Banner'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetworkImage(String base64String) {
    try {
      return Image.memory(
        base64Decode(base64String),
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
      );
    } catch (e) {
      return const Icon(Icons.broken_image);
    }
  }
}
