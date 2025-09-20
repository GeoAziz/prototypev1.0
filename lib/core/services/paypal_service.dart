import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class PayPalService {
  static String get clientId => dotenv.env['PAYPAL_CLIENT_ID'] ?? '';
  static String get secretKey => dotenv.env['PAYPAL_CLIENT_SECRET'] ?? '';
  static bool get sandbox =>
      (dotenv.env['PAYPAL_MODE'] ?? 'sandbox') == 'sandbox';
  static String get returnUrl =>
      dotenv.env['PAYPAL_CALLBACK_URL'] ?? 'https://samplesite.com/return';
  static String get cancelUrl => 'https://samplesite.com/cancel';

  static Future<bool> makePayment({
    required BuildContext context,
    required String amount,
    required String itemName,
    required Function(bool) onResult,
  }) async {
    try {
      debugPrint(
        '[PayPalService] Starting payment. clientId: $clientId, sandbox: $sandbox, returnUrl: $returnUrl',
      );
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
            sandboxMode: sandbox,
            clientId: clientId,
            secretKey: secretKey,
            returnURL: returnUrl,
            cancelURL: cancelUrl,
            transactions: [
              {
                "amount": {"total": amount, "currency": "USD"},
                "description": "Payment for $itemName",
                "items": [
                  {
                    "name": itemName,
                    "quantity": 1,
                    "price": amount,
                    "currency": "USD",
                  },
                ],
              },
            ],
            note: "Contact us for any questions on your order.",
            onSuccess: (Map params) {
              debugPrint(
                '[PayPalService] Payment success: ' + params.toString(),
              );
              onResult(true);
              Navigator.pop(context);
            },
            onError: (error) {
              debugPrint('[PayPalService] Payment error: ' + error.toString());
              onResult(false);
              Navigator.pop(context);
            },
            onCancel: () {
              debugPrint('[PayPalService] Payment cancelled');
              onResult(false);
              Navigator.pop(context);
            },
          ),
        ),
      );
      return true;
    } catch (e) {
      debugPrint('[PayPalService] PayPal payment error: $e');
      return false;
    }
  }
}
