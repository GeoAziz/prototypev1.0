import 'package:flutter/material.dart';
import 'package:poafix/core/models/booking.dart';
import 'package:poafix/core/theme/app_colors.dart';
import 'package:poafix/core/theme/app_text_styles.dart';
import 'package:poafix/features/payment/widgets/paypal_payment_button.dart';
import 'package:go_router/go_router.dart';

class BookingPaymentScreen extends StatelessWidget {
  final String serviceId;
  final String serviceTitle;
  final double amount;

  const BookingPaymentScreen({
    super.key,
    required this.serviceId,
    required this.serviceTitle,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complete Booking'),
        backgroundColor: AppColors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Service Details', style: AppTextStyles.headline2),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(serviceTitle, style: AppTextStyles.headline3),
                      const SizedBox(height: 8),
                      Text(
                        'Amount: \$${amount.toStringAsFixed(2)}',
                        style: AppTextStyles.body1.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Text('Payment Method', style: AppTextStyles.headline2),
              const SizedBox(height: 16),
              PayPalPaymentButton(
                amount: amount,
                serviceId: serviceId,
                showLoadingAnimation: true,
                onPaymentComplete: (bool success) {
                  if (success) {
                    // Pop all routes until bookings screen
                    while (Navigator.of(context).canPop()) {
                      Navigator.of(context).pop();
                    }
                    GoRouter.of(context).go('/bookings');
                  }
                },
              ),
              const SizedBox(height: 24),
              Center(
                child: TextButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Choose Different Payment Method'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
