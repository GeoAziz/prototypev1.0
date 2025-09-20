import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:poafix/features/payment/screens/payment_processing_screen.dart';

class PaymentProcessingRoute extends GoRoute {
  PaymentProcessingRoute()
    : super(
        path: '/payment-processing',
        name: 'payment_processing',
        builder: (context, state) {
          final extra = state.extra as Map<String, dynamic>;
          return PaymentProcessingScreen(
            amount: extra['amount'] as double,
            serviceId: extra['serviceId'] as String,
            paymentMethod: extra['paymentMethod'] as Map<String, dynamic>,
          );
        },
      );
}
