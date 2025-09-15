import 'package:flutter/material.dart';
import 'dart:math' as math;

class PaymentAnimations {
  static Widget buildProcessingAnimation({
    required AnimationController controller,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(begin: 1.0, end: 1.2)
              .animate(
                CurvedAnimation(
                  parent: controller,
                  curve: const Interval(0.0, 0.5, curve: Curves.easeInOut),
                ),
              )
              .value,
          child: Opacity(
            opacity: Tween<double>(begin: 1.0, end: 0.5)
                .animate(
                  CurvedAnimation(
                    parent: controller,
                    curve: const Interval(0.5, 1.0, curve: Curves.easeInOut),
                  ),
                )
                .value,
            child: child,
          ),
        );
      },
      child: child,
    );
  }

  static Widget buildSuccessAnimation({
    required AnimationController controller,
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        return Transform.scale(
          scale: Tween<double>(begin: 0.0, end: 1.0)
              .animate(
                CurvedAnimation(parent: controller, curve: Curves.bounceOut),
              )
              .value,
          child: child,
        );
      },
      child: child,
    );
  }

  static Widget buildCardFlipAnimation({
    required AnimationController controller,
    required Widget frontCard,
    required Widget backCard,
  }) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final angle = controller.value * math.pi;
        return Transform(
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.001)
            ..rotateY(angle),
          alignment: Alignment.center,
          child: angle < math.pi / 2
              ? frontCard
              : Transform(
                  transform: Matrix4.identity()..rotateY(math.pi),
                  alignment: Alignment.center,
                  child: backCard,
                ),
        );
      },
    );
  }

  static Widget buildSlideAnimation({
    required AnimationController controller,
    required Widget child,
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: begin,
        end: end,
      ).animate(CurvedAnimation(parent: controller, curve: Curves.easeInOut)),
      child: child,
    );
  }

  static Widget buildFadeAnimation({
    required AnimationController controller,
    required Widget child,
  }) {
    return FadeTransition(opacity: controller, child: child);
  }
}
