import 'package:flutter/material.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/widgets/app_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddressManagementScreen extends StatefulWidget {
  const AddressManagementScreen({super.key});

  @override
  State<AddressManagementScreen> createState() =>
      _AddressManagementScreenState();
}

class _AddressManagementScreenState extends State<AddressManagementScreen> {
  int _selectedAddressIndex = 0;
  bool _isLoading = false;
  List<Map<String, dynamic>> _addresses = [];

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  Future<void> _fetchAddresses() async {
    setState(() => _isLoading = true);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('addresses')
        .get();
    _addresses = snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'title': data['title'] ?? '',
        'address': data['address'] ?? '',
        'city': data['city'] ?? '',
        'state': data['state'] ?? '',
        'zipCode': data['zipCode'] ?? '',
        'isDefault': data['isDefault'] ?? false,
      };
    }).toList();
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Addresses'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Expanded(
                  child: _addresses.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          padding: const EdgeInsets.all(16),
                          itemCount: _addresses.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 16),
                          itemBuilder: (context, index) {
                            return _buildAddressCard(index);
                          },
                        ),
                ),
              ],
            ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: AppButton(
            text: 'Add New Address',
            onPressed: () {
              _showAddEditAddressBottomSheet();
            },
            prefixIcon: Icons.add,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.location_off_outlined,
            size: 80,
            color: AppColors.grey,
          ),
          const SizedBox(height: 16),
          Text(
            'No addresses yet',
            style: AppTextStyles.headline3.copyWith(color: AppColors.grey),
          ),
          const SizedBox(height: 8),
          Text(
            'Add your address to book services',
            style: AppTextStyles.body2.copyWith(color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildAddressCard(int index) {
    final address = _addresses[index];
    final isSelected = index == _selectedAddressIndex;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedAddressIndex = index;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.lightGrey,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(address['title'], style: AppTextStyles.headline3),
                      const SizedBox(width: 8),
                      if (address['isDefault'])
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Default',
                            style: AppTextStyles.caption.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  PopupMenuButton(
                    itemBuilder: (context) => [
                      const PopupMenuItem(value: 'edit', child: Text('Edit')),
                      if (!address['isDefault'])
                        const PopupMenuItem(
                          value: 'default',
                          child: Text('Set as Default'),
                        ),
                      if (!address['isDefault'])
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                    ],
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showAddEditAddressBottomSheet(addressIndex: index);
                      } else if (value == 'default') {
                        _setAsDefault(index);
                      } else if (value == 'delete') {
                        _showDeleteConfirmation(index);
                      }
                    },
                    icon: const Icon(Icons.more_vert),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(address['address'], style: AppTextStyles.body1),
              const SizedBox(height: 4),
              Text(
                '${address['city']}, ${address['state']} ${address['zipCode']}',
                style: AppTextStyles.body2,
              ),
              if (isSelected)
                Container(
                  margin: const EdgeInsets.only(top: 12),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.check_circle,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Selected for delivery',
                        style: AppTextStyles.body2.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _setAsDefault(int index) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    // Removed unused variable 'addressId'
    for (int i = 0; i < _addresses.length; i++) {
      final addr = _addresses[i];
      FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('addresses')
          .doc(addr['id'])
          .update({'isDefault': i == index});
    }
    _fetchAddresses();
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Default address updated')));
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Address'),
          content: const Text('Are you sure you want to delete this address?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final user = FirebaseAuth.instance.currentUser;
                if (user != null) {
                  await FirebaseFirestore.instance
                      .collection('users')
                      .doc(user.uid)
                      .collection('addresses')
                      .doc(_addresses[index]['id'])
                      .delete();
                  await _fetchAddresses();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Address deleted')),
                  );
                }
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: AppColors.error)),
            ),
          ],
        );
      },
    );
  }

  void _showAddEditAddressBottomSheet({int? addressIndex}) {
    final isEditing = addressIndex != null;
    final addressData = isEditing
        ? Map<String, dynamic>.from(_addresses[addressIndex])
        : <String, dynamic>{
            'title': '',
            'address': '',
            'city': '',
            'state': '',
            'zipCode': '',
            'isDefault': _addresses.isEmpty,
          };

    final titleController = TextEditingController(
      text: addressData['title'] as String?,
    );
    final addressController = TextEditingController(
      text: addressData['address'] as String?,
    );
    final cityController = TextEditingController(
      text: addressData['city'] as String?,
    );
    final stateController = TextEditingController(
      text: addressData['state'] as String?,
    );
    final zipCodeController = TextEditingController(
      text: addressData['zipCode'] as String?,
    );

    bool isDefault = addressData['isDefault'] as bool;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
                left: 16,
                right: 16,
                top: 16,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          isEditing ? 'Edit Address' : 'Add New Address',
                          style: AppTextStyles.headline3,
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Title field
                    const Text('Address Title', style: AppTextStyles.body2),
                    const SizedBox(height: 8),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'E.g., Home, Office, etc.',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Address field
                    const Text('Street Address', style: AppTextStyles.body2),
                    const SizedBox(height: 8),
                    TextField(
                      controller: addressController,
                      decoration: const InputDecoration(
                        hintText: 'Street address, building, apartment, etc.',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // City, State, Zip Code fields in a row
                    const Text(
                      'City, State, Zip Code',
                      style: AppTextStyles.body2,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: cityController,
                            decoration: const InputDecoration(
                              hintText: 'City',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: stateController,
                            decoration: const InputDecoration(
                              hintText: 'State',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            controller: zipCodeController,
                            decoration: const InputDecoration(
                              hintText: 'Zip',
                              border: OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 16,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Set as default checkbox
                    if (!isDefault || isEditing)
                      Row(
                        children: [
                          Checkbox(
                            value: isDefault,
                            activeColor: AppColors.primary,
                            onChanged: (value) {
                              setState(() {
                                isDefault = value ?? false;
                              });
                            },
                          ),
                          const Text(
                            'Set as default address',
                            style: AppTextStyles.body2,
                          ),
                        ],
                      ),

                    const SizedBox(height: 24),

                    SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        text: isEditing ? 'Update Address' : 'Add Address',
                        onPressed: () async {
                          // Validation
                          if (titleController.text.trim().isEmpty ||
                              addressController.text.trim().isEmpty ||
                              cityController.text.trim().isEmpty ||
                              zipCodeController.text.trim().isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Please fill all required fields',
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          final user = FirebaseAuth.instance.currentUser;
                          if (user == null) return;
                          final newAddress = {
                            'title': titleController.text,
                            'address': addressController.text,
                            'city': cityController.text,
                            'state': stateController.text,
                            'zipCode': zipCodeController.text,
                            'isDefault': isDefault,
                          };
                          if (isDefault) {
                            // Unset default for all others
                            final batch = FirebaseFirestore.instance.batch();
                            for (final addr in _addresses) {
                              batch.update(
                                FirebaseFirestore.instance
                                    .collection('users')
                                    .doc(user.uid)
                                    .collection('addresses')
                                    .doc(addr['id']),
                                {'isDefault': false},
                              );
                            }
                            await batch.commit();
                          }
                          if (isEditing) {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('addresses')
                                .doc(_addresses[addressIndex]['id'])
                                .update(newAddress);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Address updated')),
                            );
                          } else {
                            await FirebaseFirestore.instance
                                .collection('users')
                                .doc(user.uid)
                                .collection('addresses')
                                .add(newAddress);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Address added')),
                            );
                          }
                          await _fetchAddresses();
                          Navigator.pop(context);
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // Removed unused methods
}
