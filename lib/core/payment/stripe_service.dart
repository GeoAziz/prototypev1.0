import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'payment_service.dart';

class StripeService {
  static final String publicKey = dotenv.env['STRIPE_PUBLIC_KEY'] ?? '';
  static final String secretKey = dotenv.env['STRIPE_SECRET_KEY'] ?? '';

  static StripePaymentProvider getProvider() {
    return StripePaymentProvider(publicKey: publicKey, secretKey: secretKey);
  }
}
