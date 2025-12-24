import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bengkel_online_flutter/feature/admin/widgets/smartasset.dart';

/// Quick feature button with icon, label, and interactive animations
class HomeQuickFeature extends StatefulWidget {
  final String assetPath;
  final String label;
  final double iconSize;
  final VoidCallback? onTap;

  const HomeQuickFeature({
    super.key,
    required this.assetPath,
    required this.label,
    this.iconSize = 26,
    this.onTap,
  });

  @override
  State<HomeQuickFeature> createState() => _HomeQuickFeatureState();
}

class _HomeQuickFeatureState extends State<HomeQuickFeature>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<double> _scaleAnimation;
  bool _hovering = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.94).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    // Responsive sizing
    final double adaptiveIconSize =
        screenWidth < 360 ? widget.iconSize - 4 : widget.iconSize;
    final double adaptiveFontSize =
        screenWidth < 360 ? 10 : (screenWidth > 600 ? 13 : 11);

    final Color bgColor = Colors.red.shade100;

    final iconWidget = SmartAsset(
      path: widget.assetPath,
      width: adaptiveIconSize,
      height: adaptiveIconSize,
      fit: BoxFit.contain,
    );

    final featureCard = Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: iconWidget,
          ),
          const SizedBox(height: 8),
          Text(
            widget.label,
            style: TextStyle(
              fontSize: adaptiveFontSize,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
              height: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );

    Widget interactive = GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapCancel: () => _animationController.reverse(),
      onTapUp: (_) {
        _animationController.reverse();
        widget.onTap?.call();
      },
      child: ScaleTransition(scale: _scaleAnimation, child: featureCard),
    );

    // Hover animation for web/desktop
    if (kIsWeb ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.linux) {
      interactive = MouseRegion(
        onEnter: (_) => setState(() => _hovering = true),
        onExit: (_) => setState(() => _hovering = false),
        cursor: SystemMouseCursors.click,
        child: AnimatedScale(
          scale: _hovering ? 1.03 : 1.0,
          duration: const Duration(milliseconds: 120),
          child: interactive,
        ),
      );
    }

    return interactive;
  }
}
