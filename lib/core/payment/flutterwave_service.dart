import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'payment_service.dart';

class FlutterwaveService {
  static final String publicKey = dotenv.env['FLUTTERWAVE_PUBLIC_KEY'] ?? '';
  static final String secretKey = dotenv.env['FLUTTERWAVE_SECRET_KEY'] ?? '';

  static FlutterwavePaymentProvider getProvider() {
    return FlutterwavePaymentProvider(
      publicKey: publicKey,
      secretKey: secretKey,
    );
  }
}
