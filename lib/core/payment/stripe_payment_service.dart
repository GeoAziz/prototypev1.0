import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'payment_interface.dart';

class StripePaymentService implements PaymentService {
  static final String _stripePublishableKey =
      dotenv.env['STRIPE_PUBLIC_KEY'] ?? '';
  static final String _backendUrl =
      dotenv.env['BACKEND_URL'] ?? 'http://localhost:3000';

  StripePaymentService() {
    Stripe.publishableKey = _stripePublishableKey;
  }

  @override
  Future<PaymentResult> processPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      // 1. Create payment intent on the server
      final paymentIntentResult = await _createPaymentIntent(
        amount: (amount * 100).round(), // Convert to cents
        currency: currency,
        metadata: {'service_id': serviceId, ...metadata},
      );

      if (paymentIntentResult == null) {
        return StripePaymentResult(
          success: false,
          errorMessage: 'Failed to create payment intent',
        );
      }

      // 2. Initialize payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          merchantDisplayName: 'Home Service App',
          paymentIntentClientSecret: paymentIntentResult['clientSecret'],
          style: ThemeMode.system,
        ),
      );

      // 3. Present payment sheet and wait for result
      await Stripe.instance.presentPaymentSheet();

      // 4. Return success result
      return StripePaymentResult(
        success: true,
        paymentIntentId: paymentIntentResult['paymentIntentId'],
      );
    } catch (e) {
      if (e is StripeException) {
        return StripePaymentResult(
          success: false,
          errorMessage: e.error.localizedMessage,
        );
      }
      return StripePaymentResult(success: false, errorMessage: e.toString());
    }
  }

  Future<Map<String, String>?> _createPaymentIntent({
    required int amount,
    required String currency,
    required Map<String, dynamic> metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_backendUrl/create-payment-intent'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'amount': amount,
          'currency': currency,
          'metadata': metadata,
        }),
      );

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        return {
          'clientSecret': json['clientSecret'],
          'paymentIntentId': json['paymentIntentId'],
        };
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
