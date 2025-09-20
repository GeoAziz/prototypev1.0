import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import '../../services/payment_service.dart';
import '../stripe_service.dart';

class CardPaymentWidget extends StatefulWidget {
  final String bookingId;
  final double amount;
  final Function(bool success) onPaymentComplete;

  const CardPaymentWidget({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.onPaymentComplete,
  });

  @override
  State<CardPaymentWidget> createState() => _CardPaymentWidgetState();
}

class _CardPaymentWidgetState extends State<CardPaymentWidget> {
  final PaymentService _paymentService = PaymentService();
  final StripeService _stripeService = StripeService();
  bool _isLoading = false;
  String? _error;

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Payment Failed',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _processPayment,
              child: const Text('Retry Payment'),
            ),
          ],
        ),
      );
    }

    return CardField(
      onCardChanged: (card) {
        setState(() {
          _error = null;
        });
      },
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Create payment intent
      final paymentIntent = await _stripeService.createPaymentIntent(
        amount: widget.amount,
        currency: 'kes', // Kenyan Shillings
        metadata: {'booking_id': widget.bookingId},
      );

      // Initialize the payment sheet
      await _stripeService.initPaymentSheet(
        paymentIntentClientSecret: paymentIntent['client_secret'],
      );

      // Present the payment sheet to the user
      await _stripeService.presentPaymentSheet();

      // Update the payment status in our system
      await _paymentService.processPayment(
        widget.bookingId,
        widget.amount,
        'card',
      );

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Payment successful')));
        widget.onPaymentComplete(true);
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      widget.onPaymentComplete(false);
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
