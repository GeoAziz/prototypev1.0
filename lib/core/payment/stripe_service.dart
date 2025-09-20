import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';

class StripeService {
  static final String publishableKey = dotenv.env['STRIPE_PUBLIC_KEY'] ?? '';
  static final String secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  static StripeService? _instance;

  factory StripeService() {
    _instance ??= StripeService._internal();
    return _instance!;
  }

  StripeService._internal() {
    Stripe.publishableKey = publishableKey;
  }

  Future<Map<String, dynamic>> createPaymentIntent({
    required double amount,
    required String currency,
    String? customerId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('https://api.stripe.com/v1/payment_intents'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {
          'amount': (amount * 100).round().toString(), // Convert to cents
          'currency': currency,
          if (customerId != null) 'customer': customerId,
          if (metadata != null)
            for (var entry in metadata.entries)
              'metadata[$entry.key]': entry.value.toString(),
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to create payment intent: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error creating payment intent: $e');
    }
  }

  Future<Map<String, dynamic>> confirmCardPayment({
    required String clientSecret,
    required PaymentMethodParams params,
  }) async {
    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: params,
      );
      return {'status': paymentIntent.status, 'id': paymentIntent.id};
    } catch (e) {
      throw Exception('Error confirming card payment: $e');
    }
  }

  Future<PaymentMethod> createPaymentMethod() async {
    try {
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(),
          ),
        ),
      );
      return paymentMethod;
    } catch (e) {
      throw Exception('Error creating payment method: $e');
    }
  }

  Future<void> initPaymentSheet({
    required String paymentIntentClientSecret,
    String? customerId,
    String? customerEphemeralKeySecret,
  }) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: paymentIntentClientSecret,
          merchantDisplayName: AppConstants.stripeMerchantName,
          customerId: customerId,
          customerEphemeralKeySecret: customerEphemeralKeySecret,
          style: ThemeMode.system,
        ),
      );
    } catch (e) {
      throw Exception('Error initializing payment sheet: $e');
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      throw Exception('Error presenting payment sheet: $e');
    }
  }

  Future<Map<String, dynamic>> retrievePaymentIntent(
    String paymentIntentId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('https://api.stripe.com/v1/payment_intents/$paymentIntentId'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/x-www-form-urlencoded',
        },
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to retrieve payment intent: ${response.body}');
      }

      return jsonDecode(response.body);
    } catch (e) {
      throw Exception('Error retrieving payment intent: $e');
    }
  }
}
