import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/payment_service.dart';
import '../mpesa_service.dart';
import '../../utils/input_formatters.dart';

class MpesaPaymentWidget extends StatefulWidget {
  final String bookingId;
  final double amount;
  final Function(bool success) onPaymentComplete;

  const MpesaPaymentWidget({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.onPaymentComplete,
  });

  @override
  State<MpesaPaymentWidget> createState() => _MpesaPaymentWidgetState();
}

class _MpesaPaymentWidgetState extends State<MpesaPaymentWidget> {
  final PaymentService _paymentService = PaymentService();
  final MpesaService _mpesaService = MpesaService(
    consumerKey: 'your_consumer_key', // Replace with actual key
    consumerSecret: 'your_consumer_secret', // Replace with actual secret
    shortcode: 'your_shortcode', // Replace with actual shortcode
    isSandbox: true, // Set to false for production
  );

  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  bool _isLoading = false;
  String? _error;
  String? _checkoutRequestId;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'Phone Number',
              hintText: '07XXXXXXXX',
              prefixText: '+254 ',
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
              PhoneNumberFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your phone number';
              }
              if (value.length != 9) {
                return 'Please enter a valid 9-digit phone number';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          if (_error != null) ...[
            Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
          ],
          ElevatedButton(
            onPressed: _isLoading ? null : _processPayment,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Pay with M-Pesa'),
          ),
          if (_checkoutRequestId != null) ...[
            const SizedBox(height: 16),
            const Text(
              'Please enter your M-Pesa PIN to complete the payment',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Format the phone number to include country code
      final phoneNumber = '254${_phoneController.text.replaceAll(' ', '')}';

      // Initiate STK push
      final stkResponse = await _mpesaService.initiateSTKPush(
        phoneNumber: phoneNumber,
        amount: widget.amount,
        accountReference: widget.bookingId,
        description: 'Service Payment',
      );

      // Store the CheckoutRequestID for status query
      _checkoutRequestId = stkResponse['CheckoutRequestID'];

      // Start polling for payment status
      _startPollingPaymentStatus();

      // Update payment record in our system
      await _paymentService.processPayment(
        widget.bookingId,
        widget.amount,
        'mpesa',
      );
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
      widget.onPaymentComplete(false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _startPollingPaymentStatus() async {
    if (_checkoutRequestId == null) return;

    int attempts = 0;
    const maxAttempts = 10;
    const pollInterval = Duration(seconds: 5);

    while (attempts < maxAttempts) {
      try {
        final status = await _mpesaService.queryTransactionStatus(
          _checkoutRequestId!,
        );

        if (status['ResultCode'] == '0') {
          // Payment successful
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text('Payment successful')));
            widget.onPaymentComplete(true);
          }
          return;
        } else if (status['ResultCode'] != 'pending') {
          // Payment failed
          throw Exception(status['ResultDesc']);
        }

        attempts++;
        if (mounted) {
          await Future.delayed(pollInterval);
        } else {
          return;
        }
      } catch (e) {
        if (mounted) {
          setState(() {
            _error = e.toString();
          });
          widget.onPaymentComplete(false);
        }
        return;
      }
    }

    // Max attempts reached
    if (mounted) {
      setState(() {
        _error =
            'Payment status check timed out. Please check your M-Pesa messages.';
      });
    }
  }
}
