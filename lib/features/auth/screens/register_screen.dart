import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../core/enums/service_category.dart';
import '../../../core/enums/user_role.dart';
import '../../../core/models/client.dart';
import '../../../core/models/provider.dart';
import '../../../core/models/service.dart';
import '../../../core/models/user.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/step_progress_indicator.dart';
import '../../../core/widgets/step_navigation_buttons.dart';
import '../../../core/widgets/animated_step_wrapper.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for all text fields
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _businessAddressController = TextEditingController();
  final _businessDescriptionController = TextEditingController();
  final _serviceAreaController = TextEditingController();

  // State variables
  int _currentStep = 0;
  bool _hidePassword = true;
  bool _isLoading = false;
  UserRole? _selectedRole;
  File? _businessLogo;
  List<File> _serviceImages = [];
  Set<ServiceCategory> _selectedCategories = {};

  // Helper method to create default services based on category
  Service _createDefaultService(
    ServiceCategory category,
    String providerId, {
    required String businessName,
    required List<String> serviceImages,
  }) {
    String name;
    String description;
    double price;
    List<String> features;
    String defaultImage = 'https://via.placeholder.com/500';

    switch (category) {
      case ServiceCategory.cleaning:
        name = 'Standard Home Cleaning';
        description =
            'Professional cleaning service by $businessName. We use eco-friendly products and advanced cleaning techniques to make your home spotless and fresh.';
        price = 120.0;
        features = [
          'Deep cleaning of all rooms',
          'Dusting and wiping all surfaces',
          'Vacuuming and mopping floors',
          'Bathroom and kitchen cleaning',
          'Waste removal',
          'Eco-friendly cleaning products',
        ];
        break;

      case ServiceCategory.plumbing:
        name = 'General Plumbing Service';
        description =
            'Expert plumbing services by $businessName. We handle everything from repairs to installations with professional expertise and reliable solutions.';
        price = 100.0;
        features = [
          'Leak detection and repair',
          'Pipe installation and replacement',
          'Drain cleaning',
          'Fixture installation',
          'Water pressure issues',
          'Emergency plumbing services',
        ];
        break;

      case ServiceCategory.electrical:
        name = 'Electrical Service';
        description =
            'Professional electrical services by $businessName. Licensed electricians for all your electrical needs, ensuring safety and quality work.';
        price = 150.0;
        features = [
          'Electrical repairs',
          'New installations',
          'Circuit testing',
          'Lighting installation',
          'Safety inspections',
          'Emergency electrical services',
        ];
        break;

      case ServiceCategory.painting:
        name = 'Professional Painting Service';
        description =
            'Transform your space with $businessName\'s professional painting services. We use premium paints and techniques for a perfect finish.';
        price = 200.0;
        features = [
          'Interior and exterior painting',
          'Surface preparation',
          'Premium quality paints',
          'Color consultation',
          'Wall repair services',
          'Clean and precise work',
        ];
        break;

      case ServiceCategory.carpentry:
        name = 'Carpentry Service';
        description =
            '$businessName offers expert carpentry services for all your woodworking needs. From repairs to custom installations, we deliver quality craftsmanship.';
        price = 180.0;
        features = [
          'Furniture repair and assembly',
          'Custom woodwork',
          'Cabinet installation',
          'Door and window work',
          'Shelving and storage solutions',
          'Wood floor repair',
        ];
        break;

      case ServiceCategory.gardening:
        name = 'Garden Maintenance Service';
        description =
            'Professional garden maintenance by $businessName. We keep your outdoor space beautiful and healthy with our expert gardening services.';
        price = 90.0;
        features = [
          'Lawn mowing and edging',
          'Plant care and maintenance',
          'Pruning and trimming',
          'Weed control',
          'Garden cleanup',
          'Seasonal maintenance',
        ];
        break;

      case ServiceCategory.moving:
        name = 'Professional Moving Service';
        description =
            '$businessName provides reliable and efficient moving services. We ensure safe and timely relocation of your belongings.';
        price = 250.0;
        features = [
          'Careful handling of items',
          'Professional packing service',
          'Loading and unloading',
          'Transportation',
          'Furniture assembly',
          'Insurance coverage',
        ];
        break;

      case ServiceCategory.appliances:
        name = 'Appliance Repair Service';
        description =
            'Expert appliance repair services by $businessName. We fix all major household appliances with professional expertise.';
        price = 120.0;
        features = [
          'Major appliance repair',
          'Parts replacement',
          'Maintenance service',
          'Same-day diagnosis',
          'Warranty on repairs',
          'Emergency repairs',
        ];
        break;

      case ServiceCategory.other:
        name = 'General Handyman Service';
        description =
            '$businessName offers professional handyman services for various home maintenance and repair needs.';
        price = 100.0;
        features = [
          'General repairs',
          'Home maintenance',
          'Installation services',
          'Minor improvements',
          'Quick fixes',
          'Custom solutions',
        ];
        break;
    }

    return Service(
      id: '', // Will be set by Firestore
      name: name,
      description: description,
      price: price,
      categoryId: category.name,
      categoryName: category.displayName,
      image: serviceImages.isNotEmpty ? serviceImages.first : defaultImage,
      rating: 0,
      reviewCount: 0,
      bookingCount: 0,
      images: serviceImages.isNotEmpty ? serviceImages : [defaultImage],
      features: features,
      providerId: providerId,
    );
  }

  // Step navigation handlers
  void _handleNext() async {
    debugPrint(
      '_handleNext called. Current step: $_currentStep, Role: $_selectedRole',
    );

    // Step 0: Role Selection
    if (_currentStep == 0) {
      if (_selectedRole == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select a role to continue')),
        );
        return;
      }
      debugPrint('Moving from step 0 to 1');
      setState(() {
        _currentStep = 1;
      });
      return;
    }

    // Step 1: Basic Info
    if (_currentStep == 1) {
      debugPrint('Validating basic info form');
      debugPrint('Form key: $_formKey');
      debugPrint('Form state: ${_formKey.currentState}');

      if (_formKey.currentState == null) {
        debugPrint('Error: Form state is null');
        return;
      }

      final isValid = _formKey.currentState!.validate();
      debugPrint('Form validation result: $isValid');

      if (!isValid) {
        debugPrint('Basic info validation failed');
        return;
      }

      debugPrint('Basic info validation passed');
      debugPrint('Current role: $_selectedRole');

      if (_selectedRole == UserRole.client) {
        debugPrint('Client role - proceeding to registration');
        _handleRegistration();
      } else {
        debugPrint('Provider role - moving to business details');
        setState(() {
          _currentStep = 2;
        });
      }
      return;
    }

    // Step 2: Business Details (Provider only)
    if (_currentStep == 2) {
      if (_businessNameController.text.isEmpty ||
          _businessAddressController.text.isEmpty ||
          _businessDescriptionController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill in all business details')),
        );
        return;
      }
      debugPrint('Moving from step 2 to 3');
      setState(() {
        _currentStep = 3;
      });
      return;
    }

    // Step 3: Service Details (Provider only)
    if (_currentStep == 3) {
      if (_selectedCategories.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select at least one service category'),
          ),
        );
        return;
      }

      if (_serviceAreaController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your service area')),
        );
        return;
      }

      // This is the final step for providers
      _handleRegistration();
      return;
    }
  }

  void _handleBack() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  // Image picker handlers
  Future<void> _pickBusinessLogo() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

      if (image != null) {
        setState(() {
          _businessLogo = File(image.path);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
    }
  }

  Future<void> _pickServiceImages() async {
    try {
      final ImagePicker _picker = ImagePicker();
      final List<XFile>? images = await _picker.pickMultiImage();

      if (images != null) {
        setState(() {
          _serviceImages.addAll(images.map((image) => File(image.path)));
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to pick images: $e')));
    }
  }

  // Registration handler
  Future<void> _handleRegistration() async {
    debugPrint('Starting registration process');
    if (!_formKey.currentState!.validate()) {
      debugPrint('Form validation failed');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      debugPrint('Creating user with email: [32m${_emailController.text}[0m');
      final auth = firebase_auth.FirebaseAuth.instance;
      final firebase_auth.UserCredential userCredential = await auth
          .createUserWithEmailAndPassword(
            email: _emailController.text,
            password: _passwordController.text,
          );

      if (userCredential.user == null) {
        debugPrint('UserCredential.user is null');
        throw Exception('Failed to create user');
      }

      final user = userCredential.user!;
      debugPrint('User created: UID=${user.uid}');
      String? profileImageUrl;
      List<String> serviceImageUrls = [];

      // Upload business logo if provider
      if (_selectedRole == UserRole.provider && _businessLogo != null) {
        debugPrint('Uploading business logo for provider UID=${user.uid}');
        final storageRef = FirebaseStorage.instance.ref();
        final logoRef = storageRef.child('business_logos/${user.uid}');
        await logoRef.putFile(_businessLogo!);
        profileImageUrl = await logoRef.getDownloadURL();
        debugPrint('Business logo uploaded: $profileImageUrl');
      }

      // Upload service images if provider
      if (_selectedRole == UserRole.provider && _serviceImages.isNotEmpty) {
        debugPrint('Uploading service images for provider UID=${user.uid}');
        final storageRef = FirebaseStorage.instance.ref();
        for (var image in _serviceImages) {
          final imageRef = storageRef.child(
            'service_images/${user.uid}/${DateTime.now().millisecondsSinceEpoch}',
          );
          await imageRef.putFile(image);
          final url = await imageRef.getDownloadURL();
          serviceImageUrls.add(url);
          debugPrint('Service image uploaded: $url');
        }
      }

      // Create base user document in Firestore
      final userDoc = FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid);
      debugPrint('Creating user document for UID=${user.uid}');

      final baseUser = User(
        id: user.uid,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
        role: _selectedRole!,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      // Store base user info in 'users' collection
      await userDoc.set(baseUser.toJson());
      debugPrint('Base user document created in users collection');

      if (_selectedRole == UserRole.provider) {
        final provider = Provider(
          id: user.uid,
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text,
          role: _selectedRole!,
          businessName: _businessNameController.text,
          businessAddress: _businessAddressController.text,
          businessDescription: _businessDescriptionController.text,
          profileImageUrl: profileImageUrl,
          serviceCategories: _selectedCategories.toList(),
          serviceArea: int.parse(_serviceAreaController.text),
          serviceImages: serviceImageUrls,
          rating: 0,
          totalRatings: 0,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );

        // Store provider data in 'providers' collection only
        final providerDoc = FirebaseFirestore.instance
            .collection('providers')
            .doc(user.uid);
        await providerDoc.set(provider.toJson());
        debugPrint('Provider document created in providers collection');

        // Create default services for selected categories
        for (var category in _selectedCategories) {
          final defaultService = _createDefaultService(
            category,
            user.uid,
            businessName: _businessNameController.text,
            serviceImages: serviceImageUrls,
          );

          // Add service to 'services' collection
          await FirebaseFirestore.instance
              .collection('services')
              .add(defaultService.toJson());
          debugPrint(
            'Created default service for category: ${category.displayName}',
          );
        }
      } else {
        // For clients, we only create the base user document
        debugPrint('Client registration complete');
      }

      // Navigate to appropriate home screen
      debugPrint('Registration successful, navigating to home');
      if (mounted) {
        if (_selectedRole == UserRole.provider) {
          context.go('/providerHome');
        } else {
          context.go('/');
        }
      }
    } catch (e, stack) {
      setState(() {
        _isLoading = false;
      });

      debugPrint('Registration failed: $e');
      debugPrint('Stack trace: $stack');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Registration failed: $e')));
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _businessNameController.dispose();
    _businessAddressController.dispose();
    _businessDescriptionController.dispose();
    _serviceAreaController.dispose();
    super.dispose();
  }

  // Build step-specific widgets
  Widget _buildRoleSelection() {
    return Column(
      children: [
        Text(
          'Choose your role',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded(
              child: _buildRoleCard(
                'Client',
                'Looking for services',
                Icons.person_outline,
                UserRole.client,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildRoleCard(
                'Provider',
                'Offering services',
                Icons.business_center_outlined,
                UserRole.provider,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRoleCard(
    String title,
    String subtitle,
    IconData icon,
    UserRole role,
  ) {
    final isSelected = _selectedRole == role;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = role),
      child: Card(
        elevation: isSelected ? 8 : 2,
        color: isSelected ? Theme.of(context).primaryColor : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 48,
                color: isSelected ? Colors.white : Colors.grey,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? Colors.white : null,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: isSelected ? Colors.white70 : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        TextFormField(
          controller: _nameController,
          decoration: const InputDecoration(
            labelText: 'Full Name',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your name';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(
            labelText: 'Email',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your email';
            }
            if (!value.contains('@')) {
              return 'Please enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter your phone number';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passwordController,
          obscureText: _hidePassword,
          decoration: InputDecoration(
            labelText: 'Password',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(
              icon: Icon(
                _hidePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () => setState(() => _hidePassword = !_hidePassword),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a password';
            }
            if (value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBusinessDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Business Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        GestureDetector(
          onTap: _pickBusinessLogo,
          child: Container(
            height: 120,
            width: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              shape: BoxShape.circle,
            ),
            child: _businessLogo != null
                ? ClipOval(child: Image.file(_businessLogo!, fit: BoxFit.cover))
                : Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _businessNameController,
          decoration: const InputDecoration(
            labelText: 'Business Name',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _businessAddressController,
          decoration: const InputDecoration(
            labelText: 'Business Address',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _businessDescriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'Business Description',
            border: OutlineInputBorder(),
          ),
        ),
      ],
    );
  }

  Widget _buildServiceDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Service Details',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: ServiceCategory.values.map((category) {
            final isSelected = _selectedCategories.contains(category);
            return FilterChip(
              label: Text(category.toString().split('.').last),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedCategories.add(category);
                  } else {
                    _selectedCategories.remove(category);
                  }
                });
              },
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _serviceAreaController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Service Area (in km)',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton.icon(
          onPressed: _pickServiceImages,
          icon: const Icon(Icons.add_photo_alternate),
          label: const Text('Add Service Images'),
        ),
        const SizedBox(height: 8),
        if (_serviceImages.isNotEmpty)
          Container(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _serviceImages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Stack(
                    children: [
                      Image.file(
                        _serviceImages[index],
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 4,
                        right: 4,
                        child: IconButton(
                          icon: const Icon(Icons.close),
                          color: Colors.white,
                          onPressed: () {
                            setState(() {
                              _serviceImages.removeAt(index);
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  bool get _isLastStep {
    if (_selectedRole == UserRole.provider) {
      return _currentStep == 3;
    }
    return _currentStep == 1;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(title: const Text('Create Account'), elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              StepProgressIndicator(
                currentStep: _currentStep,
                totalSteps: _selectedRole == UserRole.provider ? 4 : 2,
                activeColor: AppColors.primary,
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Builder(
                    builder: (context) {
                      if (_currentStep == 0) {
                        return _buildRoleSelectionStep();
                      } else if (_currentStep == 1) {
                        return _buildBasicInfoStep();
                      } else if (_selectedRole == UserRole.provider &&
                          _currentStep == 2) {
                        return _buildBusinessInfoStep();
                      } else if (_selectedRole == UserRole.provider &&
                          _currentStep == 3) {
                        return _buildServiceDetailsStep();
                      } else {
                        return const SizedBox.shrink();
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              StepNavigationButtons(
                onNext: _handleNext,
                onBack: _handleBack,
                isFirstStep: _currentStep == 0,
                isLastStep: _selectedRole == UserRole.provider
                    ? _currentStep == 3
                    : _currentStep == 1,
                isLoading: _isLoading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleSelectionStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How would you like to use the app?',
            style: AppTextStyles.headline1,
          ),
          const SizedBox(height: 24),
          ...UserRole.values.map((role) {
            final isSelected = _selectedRole == role;
            return GestureDetector(
              onTap: () => setState(() => _selectedRole = role),
              child: Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: 2,
                  ),
                  color: isSelected ? AppColors.primary.withOpacity(0.1) : null,
                ),
                child: Row(
                  children: [
                    Icon(
                      role == UserRole.client
                          ? Icons.person_outline
                          : Icons.business_center_outlined,
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary,
                      size: 32,
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            role.displayName,
                            style: AppTextStyles.headline3.copyWith(
                              color: isSelected
                                  ? AppColors.primary
                                  : AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            role.description,
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Icon(Icons.check_circle, color: AppColors.primary),
                  ],
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Basic Information', style: AppTextStyles.headline1),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _nameController,
            label: 'Full Name',
            hint: 'Enter your full name',
            prefixIcon: const Icon(Icons.person_outline),
            validator: (value) {
              debugPrint('Validating name: $value');
              if (value == null || value.isEmpty) {
                debugPrint('Name validation failed: empty');
                return 'Please enter your name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _emailController,
            label: 'Email',
            hint: 'Enter your email',
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined),
            validator: (value) {
              debugPrint('Validating email: $value');
              if (value == null || value.isEmpty) {
                debugPrint('Email validation failed: empty');
                return 'Please enter your email';
              }
              if (!value.contains('@') || !value.contains('.')) {
                debugPrint('Email validation failed: invalid format');
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _phoneController,
            label: 'Phone Number',
            hint: 'Enter your phone number',
            keyboardType: TextInputType.phone,
            prefixIcon: const Icon(Icons.phone_outlined),
            validator: (value) {
              debugPrint('Validating phone: $value');
              if (value == null || value.isEmpty) {
                debugPrint('Phone validation failed: empty');
                return 'Please enter your phone number';
              }
              if (value.length < 10) {
                debugPrint('Phone validation failed: too short');
                return 'Please enter a valid phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _passwordController,
            label: 'Password',
            hint: 'Create a password',
            obscureText: _hidePassword,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                _hidePassword ? Icons.visibility_off : Icons.visibility,
              ),
              onPressed: () {
                setState(() {
                  _hidePassword = !_hidePassword;
                });
              },
            ),
            validator: (value) {
              debugPrint(
                'Validating password: "${value ?? ''}" (length: ${value?.length ?? 0})',
              );
              if (value == null || value.isEmpty) {
                debugPrint('Password validation failed: empty');
                return 'Please enter a password';
              }
              if (value.length < 6) {
                debugPrint(
                  'Password validation failed: length is ${value.length}, needs 6+',
                );
                return 'Password must be at least 6 characters';
              }
              debugPrint('Password validation passed');
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBusinessInfoStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Business Information', style: AppTextStyles.headline1),
          const SizedBox(height: 32),
          CustomTextField(
            controller: _businessNameController,
            label: 'Business Name',
            hint: 'Enter your business name',
            prefixIcon: const Icon(Icons.business_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your business name';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _businessAddressController,
            label: 'Business Address',
            hint: 'Enter your business address',
            prefixIcon: const Icon(Icons.location_on_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your business address';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          CustomTextField(
            controller: _businessDescriptionController,
            label: 'Business Description',
            hint: 'Tell us about your business',
            maxLines: 4,
            prefixIcon: const Icon(Icons.description_outlined),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your business description';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text('Business Logo', style: AppTextStyles.headline2),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickBusinessLogo,
            child: Container(
              height: 120,
              width: 120,
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: _businessLogo != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_businessLogo!, fit: BoxFit.cover),
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate_outlined,
                          size: 32,
                          color: AppColors.textSecondary,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Add Logo',
                          style: AppTextStyles.body2.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildServiceDetailsStep() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Service Details', style: AppTextStyles.headline3),
          const SizedBox(height: 32),
          Text('Service Categories', style: AppTextStyles.headline3),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: ServiceCategory.values.map((category) {
              final isSelected = _selectedCategories.contains(category);
              return GestureDetector(
                onTap: () {
                  setState(() {
                    if (isSelected) {
                      _selectedCategories.remove(category);
                    } else {
                      _selectedCategories.add(category);
                    }
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : AppColors.background,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    category.displayName,
                    style: AppTextStyles.body2.copyWith(
                      color: isSelected
                          ? AppColors.white
                          : AppColors.textPrimary,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 24),
          Text('Service Area', style: AppTextStyles.headline3),
          const SizedBox(height: 12),
          CustomTextField(
            controller: _serviceAreaController,
            label: 'Service Area',
            hint: 'Enter your service area (e.g., 5km radius)',
            prefixIcon: const Icon(Icons.map_outlined),
            keyboardType: TextInputType.number,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your service area';
              }
              if (int.tryParse(value) == null) {
                return 'Please enter a valid number';
              }
              return null;
            },
          ),
          const SizedBox(height: 20),
          Text('Service Images', style: AppTextStyles.headline3),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _serviceImages.length + 1,
              itemBuilder: (context, index) {
                if (index == _serviceImages.length) {
                  return GestureDetector(
                    onTap: _pickServiceImages,
                    child: Container(
                      width: 120,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: AppColors.background,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 32,
                            color: AppColors.textSecondary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Add Image',
                            style: AppTextStyles.body2.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                return Container(
                  width: 120,
                  margin: const EdgeInsets.only(right: 12),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _serviceImages[index],
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _serviceImages.removeAt(index);
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: AppColors.error,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              size: 16,
                              color: AppColors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
