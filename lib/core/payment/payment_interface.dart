import 'package:flutter/material.dart';

abstract class PaymentResult {
  final bool success;
  final String? transactionId;
  final String? errorMessage;

  PaymentResult({required this.success, this.transactionId, this.errorMessage});
}

class StripePaymentResult extends PaymentResult {
  final String? paymentIntentId;

  StripePaymentResult({
    required bool success,
    this.paymentIntentId,
    String? errorMessage,
  }) : super(
         success: success,
         transactionId: paymentIntentId,
         errorMessage: errorMessage,
       );
}

class PayPalPaymentResult extends PaymentResult {
  final String? orderId;

  PayPalPaymentResult({
    required bool success,
    this.orderId,
    String? errorMessage,
  }) : super(
         success: success,
         transactionId: orderId,
         errorMessage: errorMessage,
       );
}

abstract class PaymentService {
  Future<PaymentResult> processPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required String serviceId,
    required Map<String, dynamic> metadata,
  });
}
