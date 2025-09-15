import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/services/direct_payment_service.dart';
import '../../../core/payment/payment_manager.dart';

class PaymentMethodsScreen extends StatefulWidget {
  final double amount;
  final String serviceId;
  final Map<String, dynamic> metadata;

  const PaymentMethodsScreen({
    super.key,
    required this.amount,
    required this.serviceId,
    this.metadata = const {},
  });

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  String? _selectedId;
  bool _isLoading = false;
  bool _isProcessing = false;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  Future<void> _processStripePayment() async {
    if (_isProcessing) return;

    setState(() => _isProcessing = true);
    try {
      final success = await DirectPaymentService.processStripePayment(
        context: context,
        amount: widget.amount,
        currency: 'USD', // TODO: Make configurable
        serviceId: widget.serviceId,
        metadata: {'user_id': _userId, ...widget.metadata},
      );

      if (success) {
        _onPaymentSuccess();
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _processPayPalPayment() async {
    if (_isProcessing) {
      debugPrint('[Payment] ⚠️ Payment already in progress, ignoring request');
      return;
    }

    debugPrint('\n[Payment] 🔵 Starting PayPal Payment Flow');
    debugPrint('[Payment] 📝 Parameters:');
    debugPrint('  • Amount: ${widget.amount} (${widget.amount.runtimeType})');
    debugPrint('  • Service ID: ${widget.serviceId}');
    debugPrint('  • User ID: $_userId');

    setState(() => _isProcessing = true);
    
    try {
      // Validate payment parameters
      if (widget.amount <= 0) {
        debugPrint('[Payment] ❌ Invalid amount: ${widget.amount}');
        throw Exception('Invalid payment amount: ${widget.amount}');
      }
      
      if (widget.serviceId.isEmpty) {
        debugPrint('[Payment] ❌ Missing service ID');
        throw Exception('Service ID is required');
      }
      
      debugPrint('[Payment] ✅ Parameter validation passed');
      debugPrint('[Payment] 🔄 Initializing PayPal payment...');
      
      final paymentManager = PaymentManager('paypal');
      final result = await paymentManager.pay(
        amount: widget.amount,
        currency: 'USD',
        serviceId: widget.serviceId,
        userData: {
          'userId': _userId,
          'provider': 'paypal',
          'description': 'Payment for service ${widget.serviceId}',
          'amount': widget.amount.toStringAsFixed(2),
          'context': context,
        },
      );
      
      debugPrint('\n[Payment] 📥 Payment Result:');
      debugPrint('  • Success: ${result.success}');
      debugPrint('  • Transaction ID: ${result.transactionId}');
      debugPrint('  • Error Message: ${result.errorMessage}');
      
      if (result.success) {
        debugPrint('[Payment] ✅ Payment successful, processing completion...');
        await _onPaymentSuccess();
      } else {
        debugPrint('[Payment] ❌ Payment failed');
        _showError(result.errorMessage ?? 'PayPal payment failed');
      }
    } catch (e) {
      debugPrint('[Payment] ❌ Payment error:');
      debugPrint('  • Error: $e');
      _showError('PayPal payment error: $e');
    } finally {
      debugPrint('[Payment] 🔄 Resetting processing state');
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _onPaymentSuccess() async {
    debugPrint('\n[Payment] 💾 Processing Successful Payment');
    try {
      debugPrint('[Payment] 📝 Storing payment record in Firestore');
      debugPrint('  • Amount: ${widget.amount}');
      debugPrint('  • Service ID: ${widget.serviceId}');
      debugPrint('  • User ID: $_userId');
      
      // Validate amount one more time before storing
      if (widget.amount <= 0) {
        throw Exception('Invalid amount for payment record: ${widget.amount}');
      }

      // Store the payment result in Firestore
      final paymentData = {
        'userId': _userId,
        'serviceId': widget.serviceId,
        'amount': widget.amount,
        'timestamp': FieldValue.serverTimestamp(),
        'metadata': widget.metadata,
      };
      
      debugPrint('[Payment] 📤 Writing payment data:');
      debugPrint(paymentData.toString());
      
      final docRef = await FirebaseFirestore.instance
          .collection('payments')
          .add(paymentData);
          
      debugPrint('[Payment] ✅ Payment record created');
      debugPrint('  • Document ID: ${docRef.id}');

      // Navigate to success screen
      if (mounted) {
        debugPrint('[Payment] 🔄 Navigating to success screen');
        Navigator.pushNamed(
          context,
          '/booking-success',
          arguments: {
            'amount': widget.amount.toString(),
            'serviceId': widget.serviceId,
          },
        );
      }
    } catch (e) {
      debugPrint('[Payment] ❌ Error processing payment success:');
      debugPrint('  • Error: $e');
      if (mounted) {
        _showError('Failed to save payment: $e');
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  Future<void> _setDefault(String id) async {
    setState(() => _isLoading = true);
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('payment_methods');
    final batch = FirebaseFirestore.instance.batch();
    final snapshot = await ref.get();
    for (var doc in snapshot.docs) {
      batch.update(doc.reference, {'isDefault': doc.id == id});
    }
    await batch.commit();
    setState(() {
      _selectedId = id;
      _isLoading = false;
    });
  }

  Future<void> _removeMethod(String id) async {
    setState(() => _isLoading = true);
    await FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('payment_methods')
        .doc(id)
        .delete();
    setState(() => _isLoading = false);
  }

  Future<void> _addMethod() async {
    // For demo, add a fake card
    setState(() => _isLoading = true);
    final ref = FirebaseFirestore.instance
        .collection('users')
        .doc(_userId)
        .collection('payment_methods');
    await ref.add({
      'type': 'card',
      'last4': '1234',
      'provider': 'stripe',
      'isDefault': false,
      'addedAt': FieldValue.serverTimestamp(),
    });
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment Methods')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              icon: const Icon(Icons.credit_card),
              label: const Text('Credit/Debit Card'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: _isLoading ? null : _processStripePayment,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.account_balance_wallet),
              label: const Text('PayPal'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 18),
              ),
              onPressed: _isLoading ? null : _processPayPalPayment,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .doc(_userId)
                    .collection('payment_methods')
                    .orderBy('addedAt', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final docs = snapshot.data?.docs ?? [];
                  if (docs.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.credit_card,
                            size: 64,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 16),
                          const Text('No payment methods found'),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add_card_rounded),
                            label: const Text('Add Payment Method'),
                            onPressed: _isLoading ? null : _addMethod,
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.all(8),
                    itemCount: docs.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, i) {
                      final data = docs[i].data();
                      final id = docs[i].id;
                      final isDefault = data['isDefault'] == true;
                      final isSelected = _selectedId == id || isDefault;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.blue[50] : Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? Colors.blue : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: Icon(
                            data['type'] == 'card'
                                ? Icons.credit_card
                                : Icons.account_balance_wallet,
                            color: Colors.blue,
                            size: 32,
                          ),
                          title: Text(
                            data['type'] == 'card'
                                ? 'Card **** ${data['last4']}'
                                : data['type'].toString().toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('Provider: ${data['provider']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (!isDefault)
                                IconButton(
                                  icon: const Icon(Icons.star_border),
                                  tooltip: 'Set as Default',
                                  onPressed: _isLoading
                                      ? null
                                      : () => _setDefault(id),
                                ),
                              if (isDefault)
                                const Icon(Icons.star, color: Colors.amber),
                              IconButton(
                                icon: const Icon(Icons.edit),
                                tooltip: 'Edit',
                                onPressed: _isLoading
                                    ? null
                                    : () {
                                        // For demo, just show a snackbar
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Edit not implemented',
                                            ),
                                          ),
                                        );
                                      },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete),
                                tooltip: 'Remove',
                                onPressed: _isLoading
                                    ? null
                                    : () => _removeMethod(id),
                              ),
                            ],
                          ),
                          onTap: _isLoading
                              ? null
                              : () {
                                  setState(() => _selectedId = id);
                                  Navigator.of(context).pop(data);
                                },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            if (_isLoading)
              AnimatedOpacity(
                opacity: 1,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
