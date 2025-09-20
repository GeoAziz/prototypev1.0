import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class AddPortfolioDialog extends StatefulWidget {
  final String userId;
  final String collection;
  const AddPortfolioDialog({
    required this.userId,
    required this.collection,
    super.key,
  });

  @override
  State<AddPortfolioDialog> createState() => AddPortfolioDialogState();
}

class AddPortfolioDialogState extends State<AddPortfolioDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();
  final _tagsController = TextEditingController();
  File? _pickedImageFile;
  String? _imageUrl;
  bool _isUploading = false;
  String? _errorText;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _pickedImageFile = File(picked.path);
        _imageUrl = null;
      });
    }
  }

  Future<String?> _uploadImage(File file) async {
    final ref = FirebaseStorage.instance.ref().child(
      'portfolio_images/${DateTime.now().millisecondsSinceEpoch}_${widget.userId}.jpg',
    );
    final uploadTask = ref.putFile(file);
    final snapshot = await uploadTask;
    return await snapshot.ref.getDownloadURL();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_pickedImageFile == null && (_imageUrl == null || _imageUrl!.isEmpty)) {
      setState(() {
        _errorText = 'Please select or paste an image.';
      });
      return;
    }
    setState(() {
      _isUploading = true;
      _errorText = null;
    });
    String imageUrl = _imageUrl ?? '';
    if (_pickedImageFile != null) {
      final uploadedUrl = await _uploadImage(_pickedImageFile!);
      imageUrl = uploadedUrl ?? '';
    }
    await FirebaseFirestore.instance.collection(widget.collection).add({
      'userId': widget.userId,
      'title': _titleController.text.trim(),
      'image': imageUrl,
      'description': _descController.text.trim(),
      'tags': _tagsController.text
          .trim()
          .split(',')
          .map((t) => t.trim())
          .where((t) => t.isNotEmpty)
          .toList(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    setState(() {
      _isUploading = false;
    });
    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Portfolio item added!'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: theme.dialogTheme.backgroundColor,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [theme.primaryColor.withOpacity(0.08), theme.cardColor],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.15),
              blurRadius: 12,
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Semantics(
                  label: 'Add New Portfolio Item',
                  child: Text(
                    'Add New Portfolio Item',
                    style: theme.textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  decoration: InputDecoration(
                    labelText: 'Title',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (v) =>
                      v == null || v.trim().isEmpty ? 'Title required' : null,
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descController,
                  decoration: InputDecoration(
                    labelText: 'Description (optional)',
                    prefixIcon: const Icon(Icons.description),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                  minLines: 1,
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _tagsController,
                  decoration: InputDecoration(
                    labelText: 'Tags (comma separated)',
                    prefixIcon: const Icon(Icons.label),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                      onPressed: _isUploading ? null : _pickImage,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Or paste image URL',
                          prefixIcon: const Icon(Icons.link),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (v) => setState(() {
                          _imageUrl = v.trim();
                        }),
                        enabled: !_isUploading,
                      ),
                    ),
                  ],
                ),
                if (_pickedImageFile != null ||
                    (_imageUrl != null && _imageUrl!.isNotEmpty)) ...[
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'Image Preview',
                    child: Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.12),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _pickedImageFile != null
                            ? Image.file(_pickedImageFile!, fit: BoxFit.cover)
                            : Image.network(_imageUrl!, fit: BoxFit.cover),
                      ),
                    ),
                  ),
                ],
                if (_errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(_errorText!, style: const TextStyle(color: Colors.red)),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _isUploading
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.primaryColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                      ),
                      icon: _isUploading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.check),
                      label: Text(_isUploading ? 'Uploading...' : 'Add'),
                      onPressed: _isUploading ? null : _submit,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
