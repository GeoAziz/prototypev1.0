import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/payment_service.dart';

class BankTransferWidget extends StatefulWidget {
  final String bookingId;
  final double amount;
  final Function(bool success) onPaymentComplete;

  const BankTransferWidget({
    super.key,
    required this.bookingId,
    required this.amount,
    required this.onPaymentComplete,
  });

  @override
  State<BankTransferWidget> createState() => _BankTransferWidgetState();
}

class _BankTransferWidgetState extends State<BankTransferWidget> {
  final PaymentService _paymentService = PaymentService();
  bool _isLoading = false;
  String? _error;
  String? _transferReference;
  Map<String, String>? _bankDetails;

  @override
  void initState() {
    super.initState();
    _initializeBankTransfer();
  }

  Future<void> _initializeBankTransfer() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      // Process the payment to generate bank transfer details
      await _paymentService.processPayment(
        widget.bookingId,
        widget.amount,
        'bank',
      );

      // For demo purposes, using static bank details
      // In production, these would come from your backend
      _bankDetails = {
        'bankName': 'Example Bank',
        'accountName': 'Your Company Name',
        'accountNumber': 'XXXX-XXXX-XXXX',
        'branchCode': '012',
        'swiftCode': 'EXBKKEXX',
      };

      _transferReference = 'TRF${DateTime.now().millisecondsSinceEpoch}';
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

  Future<void> _copyToClipboard(String text) async {
    await Clipboard.setData(ClipboardData(text: text));
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Copied to clipboard')));
    }
  }

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
              'Error',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.red),
            ),
            const SizedBox(height: 8),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _initializeBankTransfer,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_bankDetails == null || _transferReference == null) {
      return const Center(child: Text('Unable to load bank transfer details'));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bank Transfer Details',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 24),
          _buildDetailsCard(),
          const SizedBox(height: 24),
          _buildInstructions(),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              widget.onPaymentComplete(true);
            },
            child: const Text('I have completed the transfer'),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildDetailRow(
              'Amount',
              'KES ${widget.amount.toStringAsFixed(2)}',
            ),
            _buildDetailRow('Bank Name', _bankDetails!['bankName']!),
            _buildDetailRow('Account Name', _bankDetails!['accountName']!),
            _buildDetailRow('Account Number', _bankDetails!['accountNumber']!),
            _buildDetailRow('Branch Code', _bankDetails!['branchCode']!),
            _buildDetailRow('Swift Code', _bankDetails!['swiftCode']!),
            _buildDetailRow('Reference', _transferReference!, showCopy: true),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool showCopy = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(value),
              if (showCopy) ...[
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.copy, size: 20),
                  onPressed: () => _copyToClipboard(value),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Instructions', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 16),
        const Text(
          '1. Copy the bank details above\n'
          '2. Make a transfer using your bank\'s app or website\n'
          '3. Use the reference number provided when making the transfer\n'
          '4. Keep your transfer receipt safe\n'
          '5. Click "I have completed the transfer" button below\n'
          '\nNote: Transfers typically take 1-3 business days to process',
        ),
      ],
    );
  }
}
