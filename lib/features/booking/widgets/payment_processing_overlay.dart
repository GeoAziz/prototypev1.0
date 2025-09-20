import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

enum PaymentState { initial, processing, success, failure }

class PaymentProcessingOverlay extends StatelessWidget {
  final PaymentState state;
  final String message;
  final VoidCallback? onClose;

  const PaymentProcessingOverlay({
    super.key,
    required this.state,
    required this.message,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: Colors.black54,
      child: Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildAnimation(),
                const SizedBox(height: 24),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (state == PaymentState.success ||
                    state == PaymentState.failure) ...[
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: onClose,
                    child: Text(
                      state == PaymentState.success ? 'Continue' : 'Try Again',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimation() {
    String animationAsset;
    switch (state) {
      case PaymentState.processing:
        animationAsset = 'assets/animations/payment-processing.json';
        break;
      case PaymentState.success:
        animationAsset = 'assets/animations/payment-success.json';
        break;
      case PaymentState.failure:
        animationAsset = 'assets/animations/payment-failed.json';
        break;
      default:
        animationAsset = 'assets/animations/payment-processing.json';
    }

    return SizedBox(
      width: 120,
      height: 120,
      child: Lottie.asset(
        animationAsset,
        repeat: state == PaymentState.processing,
        errorBuilder: (context, error, stackTrace) => Icon(
          state == PaymentState.success ? Icons.check_circle : Icons.error,
          size: 80,
          color: state == PaymentState.success ? Colors.green : Colors.red,
        ),
      ),
    );
  }
}
