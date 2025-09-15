import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DirectPaymentService {
  static final String _stripePublishableKey =
      dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  static final String _stripeSecretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  // Initialize Stripe
  static void init() {
    Stripe.publishableKey = _stripePublishableKey;
  }

  // Process Stripe Payment directly
  static Future<bool> processStripePayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      // 1. Create Payment Intent directly
      final paymentIntentResult = await _createPaymentIntent(
        amount: (amount * 100).round(),
        currency: currency,
        metadata: metadata,
      );

      if (paymentIntentResult == null) {
        _showError(context, 'Failed to create payment intent');
        return false;
      }

      // 2. Initialize Payment Sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Home Service App',
          paymentIntentClientSecret: paymentIntentResult['clientSecret'],
          style: ThemeMode.system,
        ),
      );

      // 3. Present Payment Sheet
      await Stripe.instance.presentPaymentSheet();

      // 4. Store payment record in Firestore
      await _storePaymentRecord(
        amount: amount,
        currency: currency,
        serviceId: serviceId,
        metadata: metadata,
        paymentIntentId: paymentIntentResult['paymentIntentId'] ?? '',
      );

      return true;
    } catch (e) {
      if (e is StripeException) {
        _showError(
          context,
          e.error.localizedMessage ?? 'An unknown Stripe error occurred',
        );
      } else {
        _showError(context, e.toString());
      }
      return false;
    }
  }

  // Create Stripe Payment Intent directly
  static Future<Map<String, String>?> _createPaymentIntent({
    required int amount,
    required String currency,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final url = Uri.parse('https://api.stripe.com/v1/payment_intents');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $_stripeSecretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': amount.toString(),
          'currency': currency,
          'metadata': jsonEncode(metadata),
        },
      );

      final json = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return {
          'clientSecret': json['client_secret'],
          'paymentIntentId': json['id'],
        };
      }
      return null;
    } catch (e) {
      print('Error creating payment intent: $e');
      return null;
    }
  }

  // Store payment record in Firestore
  static Future<void> _storePaymentRecord({
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> metadata,
    required String paymentIntentId,
  }) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    await FirebaseFirestore.instance.collection('payments').add({
      'userId': userId,
      'serviceId': serviceId,
      'amount': amount,
      'currency': currency,
      'paymentIntentId': paymentIntentId,
      'timestamp': FieldValue.serverTimestamp(),
      'metadata': metadata,
    });
  }

  // Show error message
  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}
