import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/core/theme/app_colors.dart';

class HourglassAnimation extends StatefulWidget {
  final double size;
  final Color? color;

  const HourglassAnimation({
    super.key,
    this.size = 80.0,
    this.color,
  });

  @override
  State<HourglassAnimation> createState() => _HourglassAnimationState();
}

class _HourglassAnimationState extends State<HourglassAnimation> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2), // 1s rotate + 1s pause handled by weight or delay
      vsync: this,
    )..repeat(); // Loop forever

    // Curve: Pause for a bit, then flip, then pause
    // We want 0 -> 180 (PI)
    // 0.0 - 0.5: Pause (Sand flowing)
    // 0.5 - 1.0: Rotate (Flip)
    _animation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1.0, curve: Curves.easeInOutBack),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _animation.value,
          child: Icon(
            Icons.hourglass_top_rounded, // Use rounded for better look
            size: widget.size,
            color: widget.color ?? AppColors.warning,
          ),
        );
      },
    );
  }
}
