import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'payment_service.dart';
import 'paypal_payment_service.dart';

class PaymentManager {
  late final PaymentProvider provider;

  PaymentManager(String providerType) {
    switch (providerType) {
      case 'stripe':
        provider = StripePaymentProvider(
          publicKey: dotenv.env['STRIPE_PUBLIC_KEY'] ?? '',
          secretKey: dotenv.env['STRIPE_SECRET_KEY'] ?? '',
        );
        break;
      case 'paypal':
        provider = PayPalPaymentService();
        break;
      case 'flutterwave':
        provider = FlutterwavePaymentProvider(
          publicKey: dotenv.env['FLUTTERWAVE_PUBLIC_KEY'] ?? '',
          secretKey: dotenv.env['FLUTTERWAVE_SECRET_KEY'] ?? '',
        );
        break;
      default:
        throw Exception('Unsupported payment provider');
    }
  }

  Future<PaymentResult> pay({
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> userData,
  }) async {
    return await provider.pay(
      amount: amount,
      currency: currency,
      serviceId: serviceId,
      userData: userData,
    );
  }
}
