import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/db_helper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/core/models/service.dart';
import 'package:poafix/core/services/booking_service.dart';
import 'package:poafix/core/services/paypal_service.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/core/widgets/app_button.dart';
import 'package:poafix/core/widgets/app_text_field.dart';
import 'package:intl/intl.dart';
import 'package:poafix/core/utils/image_helper.dart';
import 'package:poafix/features/booking/widgets/payment_option_card.dart';

class BookingScreen extends StatefulWidget {
  final String serviceId;
  final String? providerId;

  const BookingScreen({super.key, required this.serviceId, this.providerId});

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  DateTime _selectedDate = DateTime.now().add(const Duration(days: 1));
  String _selectedTime = '10:00 AM';
  int _quantity = 1;
  // Removed unused fields _paymentState and _paymentMessage
  bool _isBooking = false;
  String? _errorMessage;
  bool _showSuccess = false;

  String _selectedPaymentMethod = 'card'; // Default to 'card' or set as needed

  final BookingService _bookingService = BookingService();

  final List<String> _availableTimes = [
    '09:00 AM',
    '10:00 AM',
    '11:00 AM',
    '12:00 PM',
    '01:00 PM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '05:00 PM',
  ];

  @override
  void dispose() {
    _addressController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _completeBooking() async {
    if (_addressController.text.trim().isEmpty) {
      debugPrint('[BookingScreen] Address is empty');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your address'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isBooking = true);
    debugPrint('[BookingScreen] Starting booking process...');

    try {
      final service = demoServices.firstWhere((s) => s.id == widget.serviceId);
      double totalAmountValue = service.price * _quantity;
      if (service.pricingType == 'hourly' ||
          service.pricingType == 'per_unit') {
        // For hourly/per_unit, multiply by quantity
        totalAmountValue = service.price * _quantity;
      } else if (service.pricingType == 'callout_fee') {
        totalAmountValue = service.price;
      }
      final totalAmount = totalAmountValue.toStringAsFixed(2);

      final bookingData = {
        'serviceTitle': service.name,
        'provider': service.providerId,
        'status': 'booked',
        'bookedAt': DateTime.now().toIso8601String(),
        'userId': FirebaseAuth.instance.currentUser?.uid ?? '',
        'address': _addressController.text.trim(),
        'notes': _notesController.text.trim(),
        'date': _selectedDate.toIso8601String(),
        'time': _selectedTime,
        'quantity': _quantity,
        'paymentMethod': _selectedPaymentMethod,
        'serviceId': widget.serviceId,
        'price': service.price,
        'priceMax': service.priceMax,
        'currency': service.currency,
        'pricingType': service.pricingType,
        'totalAmount': totalAmount,
      };
      debugPrint('[BookingScreen] Booking data: ' + bookingData.toString());

      final bookingRef = await _bookingService.addBooking(bookingData);
      debugPrint('[BookingScreen] Booking added successfully');

      // Create notification in local storage
      final notificationData = {
        'title': 'Booking Confirmed',
        'body': 'Your booking for ${service.name} has been confirmed',
        'type': 'booking',
        'data': {
          'bookingId': bookingRef.id,
          'serviceId': widget.serviceId,
          'amount': totalAmount,
        },
        'route': '/booking-details/${bookingRef.id}',
        'userId': FirebaseAuth.instance.currentUser?.uid,
        'createdAt': DateTime.now().toIso8601String(),
        'isRead': false,
      };

      // Using local storage for notifications
      await DBHelper.instance.insertNotification(notificationData);

      setState(() {
        _isBooking = false;
        _showSuccess = true;
      });

      await Future.delayed(const Duration(milliseconds: 800));

      if (!mounted) return;
      debugPrint('[BookingScreen] Navigating to booking success');
      context.go(
        '/booking-success',
        extra: {'amount': totalAmount, 'serviceId': widget.serviceId},
      );
    } catch (e) {
      debugPrint('[BookingScreen] Booking failed: $e');
      setState(() {
        _isBooking = false;
        _errorMessage = 'Booking failed: ${e.toString()}';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // In a real app, you'd fetch this from an API
    final service = demoServices.firstWhere((s) => s.id == widget.serviceId);

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(title: const Text('Book Service')),
          body: Column(
            children: [
              // Main content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Service Summary
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.shadow,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ImageHelper.loadNetworkImage(
                                imageUrl: service.image,
                                width: 80,
                                height: 80,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    service.name,
                                    style: AppTextStyles.headline3,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    service.priceMax != null
                                        ? 'KES ${service.price.toStringAsFixed(0)} - ${service.priceMax!.toStringAsFixed(0)}${service.pricingType == 'hourly'
                                              ? "/hr"
                                              : service.pricingType == 'per_unit'
                                              ? "/unit"
                                              : ''}'
                                        : 'KES ${service.price.toStringAsFixed(0)}${service.pricingType == 'hourly'
                                              ? "/hr"
                                              : service.pricingType == 'per_unit'
                                              ? "/unit"
                                              : ''}',
                                    style: AppTextStyles.price,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Date Selection
                      const Text('Select Date', style: AppTextStyles.headline3),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 100,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: 14, // Show next 14 days
                          itemBuilder: (context, index) {
                            final date = DateTime.now().add(
                              Duration(days: index),
                            );
                            final isSelected =
                                _selectedDate.year == date.year &&
                                _selectedDate.month == date.month &&
                                _selectedDate.day == date.day;

                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedDate = date;
                                });
                              },
                              child: Container(
                                width: 70,
                                margin: const EdgeInsets.only(right: 12),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isSelected
                                        ? AppColors.primary
                                        : AppColors.border,
                                  ),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      DateFormat('EEE').format(date),
                                      style: AppTextStyles.body2.copyWith(
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat('dd').format(date),
                                      style: AppTextStyles.headline3.copyWith(
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      DateFormat('MMM').format(date),
                                      style: AppTextStyles.caption.copyWith(
                                        color: isSelected
                                            ? AppColors.white
                                            : AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Time Selection
                      const Text('Select Time', style: AppTextStyles.headline3),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: _availableTimes.map((time) {
                          final isSelected = _selectedTime == time;

                          return GestureDetector(
                            onTap: () {
                              setState(() {
                                _selectedTime = time;
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.white,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? AppColors.primary
                                      : AppColors.border,
                                ),
                              ),
                              child: Text(
                                time,
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

                      // Quantity
                      const Text('Quantity', style: AppTextStyles.headline3),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (_quantity > 1) {
                                setState(() {
                                  _quantity--;
                                });
                              }
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Icon(Icons.remove, size: 16),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text('$_quantity', style: AppTextStyles.headline3),
                          const SizedBox(width: 8),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _quantity++;
                              });
                            },
                            icon: Container(
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.primary,
                              ),
                              child: const Icon(
                                Icons.add,
                                size: 16,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Address
                      const Text('Address', style: AppTextStyles.headline3),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _addressController,
                        hint: 'Enter your address',
                        maxLines: 2,
                      ),

                      const SizedBox(height: 24),

                      // Notes
                      const Text(
                        'Additional Notes',
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: 12),
                      AppTextField(
                        controller: _notesController,
                        hint: 'Add any special instructions (optional)',
                        maxLines: 3,
                      ),

                      const SizedBox(height: 24),

                      // Payment Method
                      const Text(
                        'Payment Method',
                        style: AppTextStyles.headline3,
                      ),
                      const SizedBox(height: 12),
                      Column(
                        children: [
                          PaymentOptionCard(
                            icon: 'assets/icons/paypal.png',
                            title: 'Pay with PayPal',
                            subtitle: 'International secure payment',
                            onTap: () async {
                              final service = demoServices.firstWhere(
                                (s) => s.id == widget.serviceId,
                              );
                              final totalAmount = (service.price * _quantity)
                                  .toStringAsFixed(2);
                              debugPrint(
                                '[BookingScreen] PayPal selected. Amount: $totalAmount, Service: ${service.name}',
                              );
                              await PayPalService.makePayment(
                                context: context,
                                amount: totalAmount,
                                itemName: service.name,
                                onResult: (bool success) {
                                  debugPrint(
                                    '[BookingScreen] PayPal payment result: $success',
                                  );
                                  if (success) {
                                    setState(
                                      () => _selectedPaymentMethod = 'paypal',
                                    );
                                    debugPrint(
                                      '[BookingScreen] Payment successful, method set to PayPal',
                                    );
                                    _completeBooking();
                                  } else {
                                    debugPrint(
                                      '[BookingScreen] PayPal payment failed',
                                    );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('PayPal payment failed'),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                  }
                                },
                              );
                            },
                          ),
                          const SizedBox(height: 12),
                          PaymentOptionCard(
                            icon: 'assets/icons/mpesa.png',
                            title: 'Pay with M-PESA',
                            subtitle: 'Coming soon - Mobile money payment',
                            onTap: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('M-PESA payments coming soon!'),
                                  backgroundColor: Colors.orange,
                                ),
                              );
                            },
                            isEnabled: false, // Disabled for now
                          ),
                          const SizedBox(height: 12),
                          PaymentOptionCard(
                            icon: 'assets/icons/cash.png',
                            title: 'Cash on Delivery',
                            subtitle: 'Pay when service is complete',
                            onTap: () {
                              debugPrint(
                                '[BookingScreen] Cash on Delivery selected',
                              );
                              setState(() => _selectedPaymentMethod = 'cash');
                              _completeBooking();
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      if (_errorMessage != null)
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // Bottom bar with pricing and book button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.shadow,
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Total Price', style: AppTextStyles.body2),
                        Text(
                          () {
                            double totalAmountValue = service.price * _quantity;
                            if (service.pricingType == 'hourly' ||
                                service.pricingType == 'per_unit') {
                              totalAmountValue = service.price * _quantity;
                            } else if (service.pricingType == 'callout_fee') {
                              totalAmountValue = service.price;
                            }
                            return 'KES ${totalAmountValue.toStringAsFixed(2)}';
                          }(),
                          style: AppTextStyles.headline2.copyWith(
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: AppButton(
                        text: _isBooking
                            ? 'Processing...'
                            : 'Continue to Payment',
                        onPressed: _isBooking
                            ? () {} // no-op when booking
                            : () {
                                if (_addressController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                        'Please enter your address',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }

                                // Scroll to payment methods
                                Scrollable.ensureVisible(
                                  context,
                                  alignment: 0.8,
                                  duration: const Duration(milliseconds: 500),
                                );
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_isBooking)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 400),
            child: Container(
              key: const ValueKey('loading'),
              color: Colors.black.withOpacity(0.3),
              child: const Center(child: CircularProgressIndicator()),
            ),
          ),
        if (_showSuccess)
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            child: Container(
              key: const ValueKey('success'),
              color: Colors.black.withOpacity(0.3),
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      'Booking Confirmed!',
                      style: AppTextStyles.headline2.copyWith(
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
