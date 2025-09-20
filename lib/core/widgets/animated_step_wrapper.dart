import 'package:flutter/material.dart';

class AnimatedStepWrapper extends StatelessWidget {
  final int step;
  final int currentStep;
  final Widget child;

  const AnimatedStepWrapper({
    super.key,
    required this.step,
    required this.currentStep,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: step == currentStep ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: IgnorePointer(ignoring: step != currentStep, child: child),
    );
  }
}
