import 'package:flutter/material.dart';

class ProfileFadeInSlide extends StatelessWidget {
  final Widget child;
  final double offsetY;
  final int delayMs;

  const ProfileFadeInSlide({
    super.key,
    required this.child,
    this.offsetY = 12,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0, end: 1),
      builder: (context, value, child) {
        double t = value;
        if (delayMs > 0) {
          final totalMs = 420 + delayMs;
          final current = (value * totalMs).clamp(0, totalMs).toDouble();
          t = (current - delayMs) / (totalMs - delayMs);
          t = t.clamp(0.0, 1.0);
        }

        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, (1 - t) * offsetY),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class ProfileScaleIn extends StatelessWidget {
  final Widget child;
  final int delayMs;

  const ProfileScaleIn({
    super.key,
    required this.child,
    this.delayMs = 0,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      tween: Tween(begin: 0.85, end: 1),
      builder: (context, value, child) {
        double t = value;
        if (delayMs > 0) {
          final totalMs = 420 + delayMs;
          final current = (value * totalMs).clamp(0, totalMs).toDouble();
          t = 0.85 +
              ((current - delayMs) / (totalMs - delayMs))
                  .clamp(0.0, 1.0) *
                  (1 - 0.85);
        }
        return Transform.scale(
          scale: t,
          child: child,
        );
      },
      child: child,
    );
  }
}
