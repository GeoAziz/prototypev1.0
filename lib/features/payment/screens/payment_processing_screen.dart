import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:poafix/features/payment/widgets/paypal_button.dart';

class PaymentProcessingScreen extends StatefulWidget {
  final double amount;
  final String serviceId;
  final Map<String, dynamic>? paymentMethod;

  const PaymentProcessingScreen({
    super.key,
    required this.amount,
    required this.serviceId,
    this.paymentMethod,
  });

  @override
  State<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState extends State<PaymentProcessingScreen> {
  bool _isSuccess = false;
  bool _isError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment'),
        automaticallyImplyLeading: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!_isSuccess && !_isError) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    Text(
                      'Total Amount: \$${widget.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 32),
                    PayPalButton(
                      amount: widget.amount,
                      onPaymentComplete: (bool success) async {
                        if (success) {
                          setState(() => _isSuccess = true);
                          
                          try {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user == null) throw Exception('User not authenticated');

                            await FirebaseFirestore.instance.collection('payments').add({
                              'userId': user.uid,
                              'serviceId': widget.serviceId,
                              'amount': widget.amount,
                              'paymentMethod': 'paypal',
                              'status': 'completed',
                              'timestamp': FieldValue.serverTimestamp(),
                            });

                            if (mounted) {
                              context.pushNamed(
                                'bookingSuccess',
                                extra: {'amount': widget.amount.toString(), 'serviceId': widget.serviceId},
                              );
                            }
                          } catch (e) {
                            setState(() {
                              _isError = true;
                              _errorMessage = e.toString();
                            });
                          }
                        } else {
                          setState(() {
                            _isError = true;
                            _errorMessage = 'Payment was not completed successfully.';
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
            ] else if (_isSuccess) ...[
              const Icon(
                Icons.check_circle_outline,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Payment Successful!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ] else ...[
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                'Payment Failed',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => setState(() {
                  _isError = false;
                  _errorMessage = null;
                }),
                child: const Text('Try Again'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
