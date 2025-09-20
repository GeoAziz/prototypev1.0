import 'package:flutter/material.dart';

class StepNavigationButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isFirstStep;
  final bool isLastStep;
  final bool isLoading;

  const StepNavigationButtons({
    super.key,
    required this.onNext,
    required this.onBack,
    required this.isFirstStep,
    required this.isLastStep,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isFirstStep)
          TextButton(onPressed: onBack, child: const Text('Back')),
        Expanded(
          child: ElevatedButton(
            onPressed: isLoading ? null : onNext,
            child: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(isLastStep ? 'Register' : 'Next'),
          ),
        ),
      ],
    );
  }
}
