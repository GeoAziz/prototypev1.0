import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/models/service.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/enums/service_category.dart';

class ServiceEditScreen extends StatefulWidget {
  final String? serviceId;
  const ServiceEditScreen({super.key, this.serviceId});

  @override
  State<ServiceEditScreen> createState() => _ServiceEditScreenState();
}

class _ServiceEditScreenState extends State<ServiceEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _priceMaxController = TextEditingController();
  final List<TextEditingController> _featureControllers = [];
  ServiceCategory _selectedCategory = ServiceCategory.other;
  String _pricingType = 'fixed';
  List<String> _features = [''];
  List<File> _newImages = [];
  List<String> _existingImages = [];
  bool _isLoading = false;
  Service? _service;

  @override
  void initState() {
    super.initState();
    _initializeFeatureControllers();
    if (widget.serviceId != null) {
      _loadService();
    }
  }

  void _initializeFeatureControllers() {
    _featureControllers.add(TextEditingController());
  }

  @override
  void dispose() {
    for (var controller in _featureControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadService() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('services')
          .doc(widget.serviceId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        _service = Service.fromJson(data);
        setState(() {
          _nameController.text = _service!.name;
          _descriptionController.text = _service!.description;
          _priceController.text = _service!.price.toString();
          _priceMaxController.text = _service!.priceMax?.toString() ?? '';
          _pricingType = _service!.pricingType;
          _features = List<String>.from(_service!.features);
          _existingImages = List<String>.from(_service!.images ?? []);
          _selectedCategory = ServiceCategory.values.firstWhere(
            (e) => e.toString() == _service!.categoryId,
            orElse: () => ServiceCategory.other,
          );

          // Update feature controllers
          _featureControllers.clear();
          for (var feature in _features) {
            final controller = TextEditingController(text: feature);
            _featureControllers.add(controller);
          }
          if (_featureControllers.isEmpty) {
            _featureControllers.add(TextEditingController());
          }
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading service: $e')));
    }
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      if (pickedFile != null) {
        setState(() {
          _newImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
    }
  }

  Future<List<String>> _uploadImages() async {
    final urls = <String>[];
    final storage = FirebaseStorage.instance;
    for (var image in _newImages) {
      final ref = storage.ref().child(
        'service_images/${DateTime.now().millisecondsSinceEpoch}_${urls.length}',
      );
      await ref.putFile(image);
      final url = await ref.getDownloadURL();
      urls.add(url);
    }
    return urls;
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final imageUrls = await _uploadImages();
      final allImages = [..._existingImages, ...imageUrls];

      final features = _featureControllers
          .map((controller) => controller.text)
          .where((text) => text.isNotEmpty)
          .toList();

      final data = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'priceMax': _priceMaxController.text.isEmpty
            ? null
            : double.parse(_priceMaxController.text),
        'pricingType': _pricingType,
        'categoryId': _selectedCategory.toString(),
        'categoryName': _selectedCategory.displayName,
        'features': features,
        'images': allImages,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final providerId = _service?.providerId;
      if (providerId != null) {
        // Get provider data to update location
        final providerDoc = await FirebaseFirestore.instance
            .collection('providers')
            .doc(providerId)
            .get();
        if (providerDoc.exists) {
          final providerData = providerDoc.data()!;
          final location = providerData['location'] as GeoPoint?;
          if (location != null) {
            data['location'] = {
              'latitude': location.latitude,
              'longitude': location.longitude,
            };
          }
        }
      }

      if (widget.serviceId != null) {
        await FirebaseFirestore.instance
            .collection('services')
            .doc(widget.serviceId)
            .update(data);
      } else {
        await FirebaseFirestore.instance.collection('services').add(data);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.serviceId != null
                  ? 'Service updated successfully'
                  : 'Service created successfully',
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving service: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _removeImage(int index, bool isExisting) {
    setState(() {
      if (isExisting) {
        _existingImages.removeAt(index);
      } else {
        _newImages.removeAt(index);
      }
    });
  }

  void _addFeature() {
    setState(() {
      _featureControllers.add(TextEditingController());
    });
  }

  void _removeFeature(int index) {
    setState(() {
      _featureControllers[index].dispose();
      _featureControllers.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceId != null ? 'Edit Service' : 'New Service'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CustomTextField(
                      controller: _nameController,
                      label: 'Service Name',
                      hint: 'Enter service name',
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter service description',
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<ServiceCategory>(
                      value: _selectedCategory,
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      items: ServiceCategory.values.map((category) {
                        return DropdownMenuItem(
                          value: category,
                          child: Text(category.displayName),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _selectedCategory = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _priceController,
                      label: 'Price',
                      hint: 'Enter price',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a price';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      controller: _priceMaxController,
                      label: 'Maximum Price (Optional)',
                      hint: 'Enter maximum price',
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final min = double.parse(_priceController.text);
                          final max = double.parse(value);
                          if (max <= min) {
                            return 'Maximum price must be greater than minimum';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _pricingType,
                      decoration: const InputDecoration(
                        labelText: 'Pricing Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'fixed', child: Text('Fixed')),
                        DropdownMenuItem(
                          value: 'hourly',
                          child: Text('Per Hour'),
                        ),
                        DropdownMenuItem(
                          value: 'per_unit',
                          child: Text('Per Unit'),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            _pricingType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),
                    Text('Features', style: AppTextStyles.headline3),
                    const SizedBox(height: 8),
                    ..._featureControllers.asMap().entries.map((entry) {
                      final index = entry.key;
                      final controller = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Expanded(
                              child: CustomTextField(
                                controller: controller,
                                label: 'Feature ${index + 1}',
                                hint: 'Enter feature',
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: () => _removeFeature(index),
                            ),
                          ],
                        ),
                      );
                    }),
                    TextButton.icon(
                      onPressed: _addFeature,
                      icon: const Icon(Icons.add),
                      label: const Text('Add Feature'),
                    ),
                    const SizedBox(height: 24),
                    Text('Images', style: AppTextStyles.headline3),
                    const SizedBox(height: 8),
                    if (_existingImages.isNotEmpty) ...[
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _existingImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: NetworkImage(
                                        _existingImages[index],
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeImage(index, true),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    if (_newImages.isNotEmpty) ...[
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _newImages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  height: 100,
                                  margin: const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: FileImage(_newImages[index]),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 4,
                                  right: 12,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.remove_circle,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _removeImage(index, false),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                    Center(
                      child: TextButton.icon(
                        onPressed: _pickImage,
                        icon: const Icon(Icons.add_photo_alternate),
                        label: const Text('Add Image'),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: widget.serviceId != null
                            ? 'Save Changes'
                            : 'Create Service',
                        onPressed: _saveService,
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
