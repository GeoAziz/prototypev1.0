import 'package:flutter/material.dart';

class AnimationDurations {
  static const Duration fast = Duration(milliseconds: 200);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 400);
}

class AnimationCurves {
  static const Curve defaultCurve = Curves.easeInOut;
  static const Curve emphasis = Curves.easeOutBack;
  static const Curve smooth = Curves.fastOutSlowIn;
  static const Curve bounce = Curves.elasticOut;
}

class AnimatedSlideTransition extends StatelessWidget {
  final Widget child;
  final bool isVisible;
  final Offset beginOffset;
  final Duration duration;
  final Curve curve;

  const AnimatedSlideTransition({
    required this.child,
    required this.isVisible,
    this.beginOffset = const Offset(0, 0.2),
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      opacity: isVisible ? 1.0 : 0.0,
      child: AnimatedSlide(
        duration: duration,
        curve: curve,
        offset: isVisible ? Offset.zero : beginOffset,
        child: child,
      ),
    );
  }
}

class AnimatedScale extends StatelessWidget {
  final Widget child;
  final bool isVisible;
  final double beginScale;
  final Duration duration;
  final Curve curve;

  const AnimatedScale({
    required this.child,
    required this.isVisible,
    this.beginScale = 0.8,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeOut,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: duration,
      opacity: isVisible ? 1.0 : 0.0,
      child: TweenAnimationBuilder<double>(
        duration: duration,
        curve: curve,
        tween: Tween<double>(
          begin: beginScale,
          end: isVisible ? 1.0 : beginScale,
        ),
        builder: (context, value, child) {
          return Transform.scale(scale: value, child: child);
        },
        child: child,
      ),
    );
  }
}

class AnimatedProgressBar extends StatelessWidget {
  final double progress;
  final Color? backgroundColor;
  final Color? progressColor;
  final double height;
  final Duration duration;
  final Curve curve;

  const AnimatedProgressBar({
    required this.progress,
    this.backgroundColor,
    this.progressColor,
    this.height = 4.0,
    this.duration = const Duration(milliseconds: 300),
    this.curve = Curves.easeInOut,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(height),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              AnimatedPositioned(
                duration: duration,
                curve: curve,
                left: 0,
                right: constraints.maxWidth * (1 - progress),
                top: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: progressColor ?? Theme.of(context).primaryColor,
                    borderRadius: BorderRadius.circular(height),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

Route<T> buildSlideTransitionRoute<T>({
  required Widget page,
  RouteSettings? settings,
  Duration duration = const Duration(milliseconds: 300),
  Offset beginOffset = const Offset(1.0, 0.0),
}) {
  return PageRouteBuilder<T>(
    settings: settings,
    transitionDuration: duration,
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut)),
        child: child,
      );
    },
  );
}
