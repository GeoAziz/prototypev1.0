import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/payment.dart';
import 'firebase_service.dart';

class PaymentService {
  final FirebaseService _firebaseService = FirebaseService();
  static const String paymentsCollection = 'payments';

  Stream<Payment?> getPaymentStream(String bookingId) {
    return _firebaseService
        .collection(paymentsCollection)
        .doc(bookingId)
        .snapshots()
        .map((doc) => doc.exists ? Payment.fromJson(doc.data()!) : null);
  }

  Future<void> processPayment(
    String bookingId,
    double amount,
    String method,
  ) async {
    // Create a new payment document
    await _firebaseService.collection(paymentsCollection).doc(bookingId).set({
      'id': bookingId,
      'amount': amount,
      'method': method,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    });

    // Get the userId for M-Pesa payments
    final userId = _firebaseService.currentUserId;
    if (userId == null) {
      throw Exception('User not authenticated');
    }

    // Depending on the payment method, initiate the appropriate payment flow
    switch (method) {
      case 'mpesa':
        await _processMpesaPayment(bookingId, amount, userId);
        break;
      case 'card':
        await _processCardPayment(bookingId, amount);
        break;
      case 'bank':
        await _processBankTransfer(bookingId, amount);
        break;
      default:
        throw Exception('Unsupported payment method');
    }
  }

  Future<void> _processMpesaPayment(
    String bookingId,
    double amount,
    String userId,
  ) async {
    try {
      // TODO: Integrate with M-Pesa API
      // 1. Create payment request using Daraja API
      // Example integration with Daraja API:
      /*
      final darajaClient = DarajaClient(
        consumerKey: 'your_consumer_key',
        consumerSecret: 'your_consumer_secret',
        environment: DarajaEnvironment.sandbox, // or .production
      );

      final stkPushResponse = await darajaClient.stkPush(
        businessShortCode: 'your_shortcode',
        amount: amount,
        phoneNumber: phoneNumber, // Get from user profile
        callbackUrl: 'your_callback_url',
        accountReference: bookingId,
        transactionDesc: 'Service Payment',
      );

      if (stkPushResponse.responseCode == '0') {
        // STK push successful, update payment status to 'processing'
        await _updatePaymentStatus(
          bookingId,
          'processing',
          'M-Pesa payment initiated. Please enter your PIN.',
        );
      } else {
        throw Exception(stkPushResponse.responseDescription);
      }
      */

      // For now, simulate a successful payment after a delay
      await Future.delayed(const Duration(seconds: 2));
      await _updatePaymentStatus(
        bookingId,
        'completed',
        'Payment processed via M-Pesa',
      );
    } catch (e) {
      await _updatePaymentStatus(
        bookingId,
        'failed',
        'M-Pesa payment failed: $e',
      );
      rethrow;
    }
  }

  Future<void> _processCardPayment(String bookingId, double amount) async {
    try {
      // TODO: Integrate with a card payment gateway (e.g., Stripe)
      // Example integration with Stripe:
      /*
      final stripe = Stripe('your_publishable_key');
      
      // Create payment intent on your server
      final paymentIntent = await _createPaymentIntent(amount, 'KES');
      
      // Confirm payment with card details
      final paymentResult = await stripe.confirmPayment(
        paymentIntent['client_secret'],
        paymentMethodData: CardPaymentMethodData(
          // Card details collected from UI
        ),
      );

      if (paymentResult.status == 'succeeded') {
        await _updatePaymentStatus(
          bookingId,
          'completed',
          'Card payment successful',
        );
      } else {
        throw Exception('Payment failed: ${paymentResult.error?.message}');
      }
      */

      // For now, simulate a successful payment after a delay
      await Future.delayed(const Duration(seconds: 2));
      await _updatePaymentStatus(
        bookingId,
        'completed',
        'Payment processed via card',
      );
    } catch (e) {
      await _updatePaymentStatus(
        bookingId,
        'failed',
        'Card payment failed: $e',
      );
      rethrow;
    }
  }

  Future<void> _processBankTransfer(String bookingId, double amount) async {
    try {
      // Generate unique bank transfer reference
      final transferRef = 'TRF${DateTime.now().millisecondsSinceEpoch}';

      // Store bank transfer details
      await _firebaseService.collection('bankTransfers').doc(bookingId).set({
        'reference': transferRef,
        'amount': amount,
        'accountNumber': 'XXXX-XXXX-XXXX', // Replace with actual account
        'bankName': 'Example Bank',
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });

      // Update payment with bank transfer instructions
      await _updatePaymentStatus(
        bookingId,
        'pending',
        'Please transfer KES $amount to account XXXX-XXXX-XXXX using reference: $transferRef',
      );

      // Note: In a real implementation, you would:
      // 1. Set up webhooks to receive bank transfer notifications
      // 2. Implement a background job to check transfer status
      // 3. Update payment status when transfer is confirmed
    } catch (e) {
      await _updatePaymentStatus(
        bookingId,
        'failed',
        'Bank transfer setup failed: $e',
      );
      rethrow;
    }
  }

  Future<void> _updatePaymentStatus(
    String bookingId,
    String status,
    String message,
  ) async {
    await _firebaseService
        .collection(paymentsCollection)
        .doc(bookingId)
        .update({
          'status': status,
          'message': message,
          'updatedAt': DateTime.now().toIso8601String(),
        });
  }

  Future<void> retryPayment(String paymentId) async {
    final paymentDoc = await _firebaseService
        .collection(paymentsCollection)
        .doc(paymentId)
        .get();

    if (!paymentDoc.exists) {
      throw Exception('Payment not found');
    }

    final payment = Payment.fromJson(paymentDoc.data()!);
    await processPayment(payment.id, payment.amount, payment.method);
  }

  // Helper method to validate payment status
  Future<bool> validatePayment(String bookingId) async {
    final paymentDoc = await _firebaseService
        .collection(paymentsCollection)
        .doc(bookingId)
        .get();

    if (!paymentDoc.exists) {
      return false;
    }

    final payment = Payment.fromJson(paymentDoc.data()!);
    return payment.status == 'completed';
  }
}
