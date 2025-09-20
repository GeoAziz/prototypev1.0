import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/services/service_service.dart';
import 'package:poafix/core/models/category.dart';
import 'package:poafix/core/services/category_service.dart';
import 'poa_text_field.dart';

Future<void> showAddServiceModal(
  BuildContext context, {
  String? providerId,
  Service? service,
}) async {
  final titleController = TextEditingController(text: service?.name ?? '');
  final priceController = TextEditingController(
    text: service?.price.toString() ?? '',
  );
  final descriptionController = TextEditingController(
    text: service?.description ?? '',
  );
  final imageController = TextEditingController(text: service?.image ?? '');
  String? selectedCategoryId;
  String selectedStatus = service?.isPopular == true ? 'Active' : 'Inactive';
  String? uploadedImageUrl = service?.image;
  bool isLoading = false;
  String? fieldError;
  List<Category> categories = await CategoryService().getCategories();

  // Set the selected category after loading categories to ensure it exists in the list
  if (service?.categoryId != null) {
    // Only set the selected category if it exists in the loaded categories
    final categoryId = service?.categoryId;
    if (categoryId != null && categories.any((cat) => cat.id == categoryId)) {
      selectedCategoryId = categoryId;
    }
  }

  Future<void> pickAndUploadImage() async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: ImageSource.gallery);
      debugPrint('[ImageUpload] providerId: $providerId');
      if (pickedFile != null) {
        final file = File(pickedFile.path);
        debugPrint('[ImageUpload] Picked file path: ${file.path}');
        final storagePath =
            'service_images/${DateTime.now().millisecondsSinceEpoch}_$providerId.jpg';
        debugPrint('[ImageUpload] Storage path: $storagePath');
        final storageRef = FirebaseStorage.instance.ref().child(storagePath);
        debugPrint('[ImageUpload] Starting upload for file: ${file.path}');
        final uploadTask = storageRef.putFile(file);
        uploadTask.snapshotEvents.listen((event) {
          debugPrint(
            '[ImageUpload] State: ${event.state}, Bytes transferred: ${event.bytesTransferred}/${event.totalBytes}',
          );
        });
        await uploadTask;
        final downloadUrl = await storageRef.getDownloadURL();
        debugPrint('[ImageUpload] Upload complete. Download URL: $downloadUrl');
        uploadedImageUrl = downloadUrl;
        imageController.text = downloadUrl;
      } else {
        debugPrint('[ImageUpload] No image selected.');
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('No image selected.')));
      }
    } catch (e, stack) {
      debugPrint('[ImageUpload] Error: $e\n$stack');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Image upload failed: $e')));
    }
  }

  if (!context.mounted) return;

  if (!context.mounted) return;

  await showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    builder: (ctx) {
      return Builder(
        builder: (builderContext) {
          return StatefulBuilder(
            builder: (stateContext, setState) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(stateContext).viewInsets.bottom,
                  left: 16,
                  right: 16,
                  top: 24,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Semantics(
                        label: 'Service Title Input',
                        child: PoaTextField(
                          controller: titleController,
                          label: 'Service Title',
                          maxLength: 40,
                          errorText: fieldError == 'title'
                              ? 'Title is required'
                              : null,
                          hint: 'e.g. Deep Cleaning for 2BR Apartment',
                          textInputAction: TextInputAction.next,
                          autofocus: true,
                          onChanged: (_) => setState(() {}),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: PoaTextField(
                              controller: priceController,
                              label: 'Price (KES)',
                              errorText: fieldError == 'price'
                                  ? 'Valid price required'
                                  : null,
                              hint: 'e.g. 1500',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: PoaTextField(
                              controller: TextEditingController(),
                              label: 'Max Price (optional)',
                              hint: 'e.g. 2000',
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      PoaTextField(
                        controller: descriptionController,
                        label: 'Description',
                        errorText: fieldError == 'description'
                            ? 'Description required'
                            : null,
                        hint: 'Describe the service',
                        maxLines: 3,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Category',
                          border: const OutlineInputBorder(),
                          errorText: fieldError == 'category'
                              ? 'Select a category'
                              : null,
                        ),
                        value:
                            categories.any(
                              (cat) => cat.id == selectedCategoryId,
                            )
                            ? selectedCategoryId
                            : null,
                        items: categories
                            .map(
                              (cat) => DropdownMenuItem<String>(
                                value: cat.id,
                                child: Text(cat.name),
                              ),
                            )
                            .toList(),
                        onChanged: (String? value) {
                          setState(() {
                            selectedCategoryId = value;
                            fieldError =
                                null; // Clear any error when user selects a value
                          });
                        },
                        isExpanded: true,
                        hint: Text('Select a category'),
                        validator: (value) =>
                            value == null ? 'Please select a category' : null,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: PoaTextField(
                              controller: imageController,
                              label: 'Image URL',
                              errorText: fieldError == 'image'
                                  ? 'Image URL required'
                                  : null,
                              hint: 'Paste image URL or use upload',
                              textInputAction: TextInputAction.done,
                            ),
                          ),
                          const SizedBox(width: 8),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.image),
                            label: const Text('Upload'),
                            onPressed: () async {
                              await pickAndUploadImage();
                              setState(() {});
                            },
                          ),
                          if (uploadedImageUrl != null)
                            Padding(
                              padding: const EdgeInsets.only(left: 8.0),
                              child: SizedBox(
                                width: 48,
                                height: 48,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.network(uploadedImageUrl!),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        decoration: InputDecoration(
                          labelText: 'Status',
                          border: const OutlineInputBorder(),
                          errorText: fieldError == 'status'
                              ? 'Select status'
                              : null,
                        ),
                        value: selectedStatus,
                        items: ['Active', 'Inactive']
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value != null)
                            setState(() => selectedStatus = value);
                        },
                      ),
                      const SizedBox(height: 24),
                      if (isLoading)
                        const Center(child: CircularProgressIndicator()),
                      if (fieldError?.isNotEmpty ?? false)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            'Please correct the highlighted errors.',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      Row(
                        children: [
                          Expanded(
                            child: Semantics(
                              label: 'Save Service',
                              button: true,
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                label: const Text('Save'),
                                onPressed: isLoading
                                    ? null
                                    : () async {
                                        FocusScope.of(context).unfocus();
                                        setState(() => fieldError = null);

                                        // Validation
                                        if (titleController.text
                                            .trim()
                                            .isEmpty) {
                                          setState(() => fieldError = 'title');
                                          return;
                                        }
                                        if (priceController.text
                                                .trim()
                                                .isEmpty ||
                                            double.tryParse(
                                                  priceController.text,
                                                ) ==
                                                null) {
                                          setState(() => fieldError = 'price');
                                          return;
                                        }
                                        if (descriptionController.text
                                            .trim()
                                            .isEmpty) {
                                          setState(
                                            () => fieldError = 'description',
                                          );
                                          return;
                                        }
                                        if (selectedCategoryId == null) {
                                          setState(
                                            () => fieldError = 'category',
                                          );
                                          return;
                                        }
                                        final imageUrl = imageController.text
                                            .trim();
                                        if (imageUrl.isEmpty) {
                                          setState(() => fieldError = 'image');
                                          return;
                                        }
                                        // Validate image URL format (basic)
                                        final validUrl =
                                            Uri.tryParse(
                                              imageUrl,
                                            )?.hasAbsolutePath ??
                                            false;
                                        if (!validUrl) {
                                          setState(() => fieldError = 'image');
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Please provide a valid image URL.',
                                              ),
                                            ),
                                          );
                                          debugPrint(
                                            '[ServiceAdd] Invalid image URL: $imageUrl',
                                          );
                                          return;
                                        }
                                        if (selectedStatus.isEmpty) {
                                          setState(() => fieldError = 'status');
                                          return;
                                        }

                                        setState(() => isLoading = true);
                                        try {
                                          debugPrint(
                                            '[ServiceAdd] Creating service with title: ${titleController.text.trim()}',
                                          );
                                          final newService = Service(
                                            id: service?.id ?? '',
                                            name: titleController.text.trim(),
                                            description: descriptionController
                                                .text
                                                .trim(),
                                            price: double.parse(
                                              priceController.text.trim(),
                                            ),
                                            categoryId: selectedCategoryId!,
                                            image:
                                                uploadedImageUrl ??
                                                imageController.text.trim(),
                                            rating: service?.rating ?? 0,
                                            reviewCount:
                                                service?.reviewCount ?? 0,
                                            bookingCount:
                                                service?.bookingCount ?? 0,
                                            images: [
                                              uploadedImageUrl ??
                                                  imageController.text.trim(),
                                            ],
                                            features: service?.features ?? [],
                                            providerId: providerId ?? '',
                                            isPopular:
                                                selectedStatus == 'Active',
                                          );
                                          if (service != null &&
                                              service.id.isNotEmpty) {
                                            await ServiceService()
                                                .updateService(
                                                  service.id,
                                                  newService.toJson(),
                                                );
                                            debugPrint(
                                              '[ServiceEdit] Service updated successfully.',
                                            );
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Service updated successfully',
                                                ),
                                              ),
                                            );
                                          } else {
                                            await ServiceService().addService(
                                              newService,
                                            );
                                            debugPrint(
                                              '[ServiceAdd] Service added successfully.',
                                            );
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Service added successfully',
                                                ),
                                              ),
                                            );
                                          }
                                        } catch (e, stack) {
                                          debugPrint(
                                            '[ServiceAdd] Error: $e\n$stack',
                                          );
                                          String errorMsg = e.toString();
                                          if (errorMsg.contains(
                                            'permission-denied',
                                          )) {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'You do not have permission to add a service. Please contact support.',
                                                ),
                                                backgroundColor: Colors.red,
                                              ),
                                            );
                                          } else {
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: Text(
                                                  'Error adding service: $e',
                                                ),
                                              ),
                                            );
                                          }
                                        } finally {
                                          setState(() => isLoading = false);
                                        }
                                      },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    },
  );
}
