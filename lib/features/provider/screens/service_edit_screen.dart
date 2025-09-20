import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart' hide GeoPoint;
import 'package:cloud_firestore/cloud_firestore.dart' show GeoPoint;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import '../../../core/models/service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/services/firebase_service.dart';
import '../../../core/utils/image_utils.dart';

class ServiceEditScreen extends StatefulWidget {
  final String? serviceId; // null for new service

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
  final _features = <String>[];
  final _featureController = TextEditingController();
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  final _firebaseService = FirebaseService();

  String _selectedCategory = '';
  String _selectedSubService = '';
  String _selectedPricingType = 'fixed';
  final List<String> _pricingTypes = const ['fixed', 'hourly', 'per_unit'];
  List<String> _imageUrls = [];
  List<File> _newImages = [];
  bool _isLoading = false;
  Service? _existingService;
  bool _isActive = true;

  // Location fields
  final _locationController = TextEditingController();
  double? _latitude;
  double? _longitude;

  List<String> _categories = [];
  Map<String, List<String>> _subServices = {};

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.serviceId != null) {
      _loadExistingService();
    }
  }

  Future<void> _loadCategories() async {
    try {
      final snapshot = await _firestore.collection('categories').get();
      final categories = snapshot.docs
          .map((doc) => doc.data()['name'] as String)
          .toList();
      setState(() {
        _categories = categories;
      });

      // Load sub-services for each category
      for (final category in categories) {
        final subSnapshot = await _firestore
            .collection('categories')
            .doc(category.toLowerCase())
            .collection('sub_services')
            .get();
        _subServices[category] = subSnapshot.docs
            .map((doc) => doc.data()['name'] as String)
            .toList();
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading categories: $e')));
    }
  }

  Future<void> _loadExistingService() async {
    setState(() => _isLoading = true);
    try {
      final doc = await _firestore
          .collection('services')
          .doc(widget.serviceId)
          .get();
      if (!doc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Service not found')));
          Navigator.pop(context);
        }
        return;
      }

      _existingService = Service.fromJson(doc.data()!);
      _nameController.text = _existingService!.name;
      _descriptionController.text = _existingService!.description;
      _priceController.text = _existingService!.price.toString();
      if (_existingService!.priceMax != null) {
        _priceMaxController.text = _existingService!.priceMax.toString();
      }

      _selectedCategory = _existingService!.categoryName;
      _selectedSubService = _existingService!.subService;
      _selectedPricingType = Service.normalizePricingType(
        _existingService!.pricingType,
      );
      _features.addAll(_existingService!.features);
      _imageUrls = List.from(_existingService!.images ?? []);
      _isActive = doc.data()?['active'] ?? true;

      // Initialize location
      final location = _existingService!.location;
      if (location != null) {
        setState(() {
          _latitude = location.latitude;
          _longitude = location.longitude;
        });

        // Get address from coordinates
        try {
          final placemarks = await placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          if (placemarks.isNotEmpty) {
            final place = placemarks[0];
            final address = [
              place.street,
              place.subLocality,
              place.locality,
              place.administrativeArea,
            ].where((e) => e != null && e.isNotEmpty).join(', ');
            _locationController.text = address;
          }
        } catch (e) {
          // If geocoding fails, just use coordinates as text
          _locationController.text =
              '${location.latitude}, ${location.longitude}';
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading service: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _pickImages() async {
    try {
      final images = await ImagePicker().pickMultiImage();
      if (images.isEmpty) return;

      setState(() {
        _newImages.addAll(images.map((image) => File(image.path)));
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking images: $e')));
      }
    }
  }

  Future<List<String>> _uploadImages() async {
    final uploadedUrls = <String>[];
    try {
      for (final image in _newImages) {
        final fileName =
            '${DateTime.now().millisecondsSinceEpoch}_${path.basename(image.path)}';
        final ref = _storage.ref().child(
          'services/${_firebaseService.currentUserId}/$fileName',
        );

        // Compress image before upload
        final compressedImage = await ImageUtils.compressImage(image);
        final uploadTask = ref.putFile(compressedImage);
        final snapshot = await uploadTask.whenComplete(() {});
        final url = await snapshot.ref.getDownloadURL();
        uploadedUrls.add(url);
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading images: $e')));
      rethrow;
    }
    return uploadedUrls;
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      // Upload new images
      final uploadedUrls = await _uploadImages();
      final allImageUrls = [..._imageUrls, ...uploadedUrls];

      final serviceData = {
        'name': _nameController.text,
        'description': _descriptionController.text,
        'price': double.parse(_priceController.text),
        'priceMax': _priceMaxController.text.isNotEmpty
            ? double.parse(_priceMaxController.text)
            : null,
        'pricingType': _selectedPricingType,
        'categoryName': _selectedCategory,
        'subService': _selectedSubService,
        'features': _features,
        'images': allImageUrls,
        'providerId': _firebaseService.currentUserId,
        'rating': _existingService?.rating ?? 0.0,
        'reviewCount': _existingService?.reviewCount ?? 0,
        'location': _latitude != null && _longitude != null
            ? GeoPoint(_latitude!, _longitude!)
            : null,
        'address': _locationController.text,
        'active': _isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (widget.serviceId != null) {
        await _firestore
            .collection('services')
            .doc(widget.serviceId)
            .update(serviceData);
      } else {
        serviceData['createdAt'] = FieldValue.serverTimestamp();
        await _firestore.collection('services').add(serviceData);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service saved successfully')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving service: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _addFeature() {
    if (_featureController.text.isEmpty) return;
    setState(() {
      _features.add(_featureController.text);
      _featureController.clear();
    });
  }

  void _removeFeature(int index) {
    setState(() {
      _features.removeAt(index);
    });
  }

  void _removeImage(int index, bool isNewImage) {
    setState(() {
      if (isNewImage) {
        _newImages.removeAt(index);
      } else {
        _imageUrls.removeAt(index);
      }
    });
  }

  Future<void> _getCurrentLocation() async {
    try {
      setState(() => _isLoading = true);

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permission denied');
        }
      }

      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Get address from coordinates
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks[0];
        final address = [
          place.street,
          place.subLocality,
          place.locality,
          place.administrativeArea,
        ].where((e) => e != null && e.isNotEmpty).join(', ');

        setState(() {
          _locationController.text = address;
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error getting location: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _pickLocation() async {
    // Here you would typically show a map picker
    // For now, we'll just use current location
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.serviceId != null ? 'Edit Service' : 'Add Service'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _saveService,
            child: const Text('Save'),
          ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Basic Info Section
              Text('Basic Information', style: AppTextStyles.headline3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _nameController,
                      decoration: const InputDecoration(
                        labelText: 'Service Name',
                        hintText: 'Enter service name',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a service name';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: DropdownButtonFormField<bool>(
                      value: _isActive,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: true, child: Text('Active')),
                        DropdownMenuItem(value: false, child: Text('Inactive')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setState(() {
                            _isActive = val;
                          });
                        }
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedCategory.isNotEmpty ? _selectedCategory : null,
                decoration: const InputDecoration(labelText: 'Category'),
                items: _categories
                    .map(
                      (category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value ?? '';
                    _selectedSubService = '';
                  });
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please select a category';
                  }
                  return null;
                },
              ),
              if (_selectedCategory.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: _selectedSubService.isNotEmpty
                      ? _selectedSubService
                      : null,
                  decoration: const InputDecoration(labelText: 'Sub Service'),
                  items: (_subServices[_selectedCategory] ?? [])
                      .map(
                        (sub) => DropdownMenuItem(value: sub, child: Text(sub)),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubService = value ?? '';
                    });
                  },
                ),
              ],

              // Pricing Section
              const SizedBox(height: 32),
              Text('Pricing', style: AppTextStyles.headline3),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _selectedPricingType,
                decoration: const InputDecoration(labelText: 'Pricing Type'),
                items: _pricingTypes
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type[0].toUpperCase() + type.substring(1)),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedPricingType = value ?? 'fixed';
                  });
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _priceController,
                      decoration: const InputDecoration(
                        labelText: 'Price (KES)',
                        prefixText: 'KES ',
                      ),
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
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _priceMaxController,
                      decoration: InputDecoration(
                        labelText: 'Max Price (Optional)',
                        prefixText: 'KES ',
                        helperText: _selectedPricingType == 'fixed'
                            ? 'Leave empty for fixed price'
                            : null,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          if (double.tryParse(value) == null) {
                            return 'Please enter a valid number';
                          }
                          final min = double.parse(_priceController.text);
                          final max = double.parse(value);
                          if (max <= min) {
                            return 'Max must be greater than min';
                          }
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),

              // Location Section
              const SizedBox(height: 32),
              Text('Service Location', style: AppTextStyles.headline3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _locationController,
                      decoration: const InputDecoration(
                        labelText: 'Location',
                        hintText: 'Enter service location',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                      readOnly: true,
                      onTap: _pickLocation,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a location';
                        }
                        return null;
                      },
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.my_location),
                    onPressed: _getCurrentLocation,
                    tooltip: 'Use current location',
                  ),
                ],
              ),

              // Description Section
              const SizedBox(height: 32),
              Text('Description', style: AppTextStyles.headline3),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Describe your service in detail',
                ),
                maxLines: 5,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  if (value.length < 50) {
                    return 'Description should be at least 50 characters';
                  }
                  return null;
                },
              ),

              // Features Section
              const SizedBox(height: 32),
              Text('Features', style: AppTextStyles.headline3),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _featureController,
                      decoration: const InputDecoration(
                        labelText: 'Add Feature',
                        hintText: 'Enter a feature',
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addFeature,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ..._features.asMap().entries.map(
                (entry) => ListTile(
                  leading: const Icon(Icons.check_circle),
                  title: Text(entry.value),
                  trailing: IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () => _removeFeature(entry.key),
                  ),
                ),
              ),
              if (_features.isEmpty)
                const Text(
                  'Add features to highlight what\'s included',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),

              // Images Section
              const SizedBox(height: 32),
              Text('Images', style: AppTextStyles.headline3),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._imageUrls.asMap().entries.map(
                    (entry) => Stack(
                      children: [
                        Image.network(
                          entry.value,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            color: Colors.red,
                            onPressed: () => _removeImage(entry.key, false),
                          ),
                        ),
                      ],
                    ),
                  ),
                  ..._newImages.asMap().entries.map(
                    (entry) => Stack(
                      children: [
                        Image.file(
                          entry.value,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.remove_circle),
                            color: Colors.red,
                            onPressed: () => _removeImage(entry.key, true),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: _pickImages,
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Icon(Icons.add_photo_alternate),
                    ),
                  ),
                ],
              ),
              if (_imageUrls.isEmpty && _newImages.isEmpty)
                const Text(
                  'Add at least one image of your service',
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _priceMaxController.dispose();
    _featureController.dispose();
    super.dispose();
  }
}
