import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/models/payment.dart';
import '../../../core/services/payment_service.dart';
import '../../../core/widgets/loading_overlay.dart';
import '../../../core/widgets/error_view.dart';

class PaymentScreen extends StatefulWidget {
  final String bookingId;
  final double amount;

  const PaymentScreen({
    super.key,
    required this.bookingId,
    required this.amount,
  });

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final PaymentService _paymentService = PaymentService();
  bool _isProcessing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Payment')),
      body: LoadingOverlay(
        isLoading: _isProcessing,
        child: StreamBuilder<Payment?>(
          stream: _paymentService.getPaymentStream(widget.bookingId),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return ErrorView(
                error: 'Error loading payment: ${snapshot.error}',
                onRetry: () => setState(() {}),
              );
            }

            final payment = snapshot.data;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildPaymentSummary(),
                  const SizedBox(height: 24),
                  if (payment == null) ...[
                    _buildPaymentMethods(),
                  ] else ...[
                    _buildPaymentStatus(payment),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _buildSummaryRow('Booking ID', '#${widget.bookingId}'),
            _buildSummaryRow(
              'Amount',
              'KES ${widget.amount.toStringAsFixed(2)}',
            ),
            _buildSummaryRow(
              'Service Fee',
              'KES ${(widget.amount * 0.05).toStringAsFixed(2)}',
            ),
            const Divider(),
            _buildSummaryRow(
              'Total',
              'KES ${(widget.amount * 1.05).toStringAsFixed(2)}',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
          Text(
            value,
            style: isTotal
                ? const TextStyle(fontWeight: FontWeight.bold)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Payment Methods', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 16),
        _buildPaymentMethodCard(
          'M-Pesa',
          'Pay using M-Pesa',
          Icons.phone_android,
          () => _processPayment('mpesa'),
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodCard(
          'Card Payment',
          'Pay with credit/debit card',
          Icons.credit_card,
          () => _processPayment('card'),
        ),
        const SizedBox(height: 8),
        _buildPaymentMethodCard(
          'Bank Transfer',
          'Pay via bank transfer',
          Icons.account_balance,
          () => _processPayment('bank'),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard(
    String title,
    String subtitle,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  Widget _buildPaymentStatus(Payment payment) {
    final statusColor = payment.status == 'completed'
        ? Colors.green
        : payment.status == 'failed'
        ? Colors.red
        : Colors.orange;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(
              payment.status == 'completed'
                  ? Icons.check_circle
                  : payment.status == 'failed'
                  ? Icons.error
                  : Icons.pending,
              size: 48,
              color: statusColor,
            ),
            const SizedBox(height: 16),
            Text(
              payment.status.toUpperCase(),
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: statusColor),
            ),
            const SizedBox(height: 8),
            Text(payment.message ?? ''),
            if (payment.status == 'failed') ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _retryPayment(payment),
                child: const Text('Retry Payment'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _processPayment(String method) async {
    setState(() => _isProcessing = true);
    try {
      await _paymentService.processPayment(
        widget.bookingId,
        widget.amount,
        method,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment processed successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment failed: $e')));
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _retryPayment(Payment payment) async {
    setState(() => _isProcessing = true);
    try {
      await _paymentService.retryPayment(payment.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment retry initiated')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Payment retry failed: $e')));
      }
    } finally {
      setState(() => _isProcessing = false);
    }
  }
}
