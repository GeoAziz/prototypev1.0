import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PayPalService {
  static final PayPalService _instance = PayPalService._internal();
  factory PayPalService() => _instance;
  PayPalService._internal();

  Future<Map<String, dynamic>> processPayment({
    required double amount,
    required String serviceId,
    required Function(bool success, String? error) onComplete,
  }) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Create payment record
      final paymentRef = await FirebaseFirestore.instance.collection('payments').add({
        'userId': user.uid,
        'serviceId': serviceId,
        'amount': amount,
        'paymentMethod': 'paypal',
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Get PayPal configuration
      final clientId = dotenv.env['PAYPAL_CLIENT_ID'];
      final returnUrl = dotenv.env['PAYPAL_CALLBACK_URL'] ?? 'http://localhost:5000/api/payments/paypal/callback';
      final sandbox = dotenv.env['PAYPAL_MODE'] == 'sandbox';

      if (clientId == null) {
        throw Exception('PayPal configuration not found');
      }

      return {
        'clientId': clientId,
        'returnUrl': returnUrl,
        'sandbox': sandbox,
        'amount': amount.toStringAsFixed(2),
        'paymentId': paymentRef.id,
      };
    } catch (e) {
      debugPrint('[PayPal Service] Error: $e');
      onComplete(false, e.toString());
      rethrow;
    }
  }

  Future<void> updatePaymentStatus({
    required String paymentId,
    required bool success,
    String? transactionId,
    String? error,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('payments').doc(paymentId).update({
        'status': success ? 'completed' : 'failed',
        if (transactionId != null) 'transactionId': transactionId,
        if (error != null) 'error': error,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('[PayPal Service] Error updating payment status: $e');
      rethrow;
    }
  }
}
