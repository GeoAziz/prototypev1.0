import 'dart:convert';
import 'package:http/http.dart' as http;

abstract class PaymentProvider {
  Future<PaymentResult> pay({
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> userData,
  });
}

class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;

  PaymentResult({required this.success, this.transactionId, this.errorMessage});
}

class StripePaymentProvider implements PaymentProvider {
  final String publicKey;
  final String secretKey;

  StripePaymentProvider({required this.publicKey, required this.secretKey});

  @override
  Future<PaymentResult> pay({
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> userData,
  }) async {
    // Example using flutter_stripe (pseudo-code, replace with real implementation)
    try {
      // 1. Create PaymentIntent on backend and get clientSecret
      // 2. Confirm payment with flutter_stripe
      // final paymentResult = await Stripe.instance.confirmPayment(...);
      // if (paymentResult.status == 'succeeded') {
      //   return PaymentResult(success: true, transactionId: paymentResult.id);
      // }
      // return PaymentResult(success: false, errorMessage: paymentResult.error);
      return PaymentResult(
        success: true,
        transactionId: 'stripe_txn_id',
      ); // Remove when real logic is added
    } catch (e) {
      return PaymentResult(success: false, errorMessage: e.toString());
    }
  }
}

class PayPalPaymentProvider implements PaymentProvider {
  final String clientId;
  final String secret;

  PayPalPaymentProvider({required this.clientId, required this.secret});

  @override
  Future<PaymentResult> pay({
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> userData,
  }) async {
    // Example using flutter_braintree or direct REST API (pseudo-code)
    try {
      // 1. Create PayPal payment on backend and get approval URL
      // 2. Redirect user to PayPal approval
      // 3. On approval, execute payment and get transactionId
      // if (paymentSuccess) {
      //   return PaymentResult(success: true, transactionId: transactionId);
      // }
      // return PaymentResult(success: false, errorMessage: error);
      return PaymentResult(
        success: true,
        transactionId: 'paypal_txn_id',
      ); // Remove when real logic is added
    } catch (e) {
      return PaymentResult(success: false, errorMessage: e.toString());
    }
  }
}

class FlutterwavePaymentProvider implements PaymentProvider {
  final String publicKey;
  final String secretKey;

  FlutterwavePaymentProvider({
    required this.publicKey,
    required this.secretKey,
  });

  @override
  Future<PaymentResult> pay({
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> userData,
  }) async {
    try {
      final Map<String, dynamic> customer = {
        'email': userData['email'],
        'phone_number': userData['phoneNumber'],
        'name': userData['name'],
      };

      final Map<String, dynamic> customizations = {
        'title': 'Service Payment',
        'description': 'Payment for service $serviceId',
        'logo': 'https://your-logo-url.com/logo.png',
      };

      final Map<String, dynamic> paymentData = {
        'tx_ref': 'poafix_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'currency': currency,
        'payment_options': 'card,mpesa,ussd',
        'redirect_url': 'https://your-redirect-url.com/callback',
        'customer': customer,
        'customizations': customizations,
        'meta': {'service_id': serviceId, 'user_id': userData['userId']},
      };

      final response = await http.post(
        Uri.parse('https://api.flutterwave.com/v3/payments'),
        headers: {
          'Authorization': 'Bearer $secretKey',
          'Content-Type': 'application/json',
        },
        body: json.encode(paymentData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          return PaymentResult(
            success: true,
            transactionId: responseData['data']['transaction_id'].toString(),
          );
        }
      }

      return PaymentResult(
        success: false,
        errorMessage: 'Payment initialization failed',
      );
    } catch (e) {
      return PaymentResult(
        success: false,
        errorMessage: 'Error processing payment: ${e.toString()}',
      );
    }
  }
}
