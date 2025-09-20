import 'package:flutter/material.dart';

class StepProgressIndicator extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final double height;
  final Color activeColor;
  final Color inactiveColor;
  final Duration animationDuration;

  const StepProgressIndicator({
    required this.currentStep,
    required this.totalSteps,
    this.height = 4.0,
    this.activeColor = Colors.blue,
    this.inactiveColor = Colors.grey,
    this.animationDuration = const Duration(milliseconds: 300),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            return Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 2),
                child: TweenAnimationBuilder<double>(
                  duration: animationDuration,
                  tween: Tween<double>(begin: 0, end: isActive ? 1 : 0),
                  builder: (context, value, _) {
                    return LinearProgressIndicator(
                      value: value,
                      backgroundColor: inactiveColor,
                      color: activeColor,
                      minHeight: height,
                    );
                  },
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(totalSteps, (index) {
            final isActive = index <= currentStep;
            return Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isActive ? activeColor : inactiveColor,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                if (index < totalSteps - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: isActive ? activeColor : inactiveColor,
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }
}

class StepNavigationButtons extends StatelessWidget {
  final VoidCallback onNext;
  final VoidCallback onBack;
  final bool isLastStep;
  final bool isFirstStep;
  final bool isLoading;

  const StepNavigationButtons({
    required this.onNext,
    required this.onBack,
    this.isLastStep = false,
    this.isFirstStep = false,
    this.isLoading = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (!isFirstStep)
          TextButton.icon(
            onPressed: isLoading ? null : onBack,
            icon: const Icon(Icons.arrow_back),
            label: const Text('Back'),
          )
        else
          const SizedBox.shrink(),
        ElevatedButton(
          onPressed: isLoading ? null : onNext,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isLoading)
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ),
              Text(isLastStep ? 'Complete' : 'Next'),
              if (!isLastStep && !isLoading)
                const Icon(Icons.arrow_forward, size: 16),
            ],
          ),
        ),
      ],
    );
  }
}

class AnimatedStepWrapper extends StatelessWidget {
  final Widget child;
  final int step;
  final int currentStep;
  final Duration duration;

  const AnimatedStepWrapper({
    required this.child,
    required this.step,
    required this.currentStep,
    this.duration = const Duration(milliseconds: 300),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      opacity: step == currentStep ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: duration,
        offset: Offset(
          step == currentStep
              ? 0
              : step > currentStep
              ? 1
              : -1,
          0,
        ),
        child: IgnorePointer(ignoring: step != currentStep, child: child),
      ),
    );
  }
}
