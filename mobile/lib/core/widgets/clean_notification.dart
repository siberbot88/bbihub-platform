

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum NotificationType { success, error, warning, info }

class CleanNotification extends StatelessWidget {
  final String title;
  final String message;
  final NotificationType type;
  final VoidCallback? onAction;
  final String? actionText;
  final VoidCallback? onDismiss;
  final String? secondaryActionText;
  final VoidCallback? onSecondaryAction;

  const CleanNotification({
    Key? key,
    required this.title,
    required this.message,
    this.type = NotificationType.info,
    this.onAction,
    this.actionText,
    this.onDismiss,
    this.secondaryActionText,
    this.onSecondaryAction,
  }) : super(key: key);

  /// Helper method to show the notification (Top Overlay)
  static void show(
    BuildContext context, {
    required String title,
    required String message,
    NotificationType type = NotificationType.info,
    VoidCallback? onAction,
    String? actionText,
    VoidCallback? onSecondaryAction,
    String? secondaryActionText,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    late OverlayEntry overlayEntry;

    overlayEntry = OverlayEntry(
      builder: (context) => _CleanNotificationOverlay(
        title: title,
        message: message,
        type: type,
        duration: duration,
        onAction: onAction,
        actionText: actionText,
        onSecondaryAction: onSecondaryAction,
        secondaryActionText: secondaryActionText,
        onRemove: () {
          overlayEntry.remove();
        },
      ),
    );

    overlay.insert(overlayEntry);
  }

  // ... (color and icon getters remain same)
  Color get _leftBarColor {
    switch (type) {
      case NotificationType.error:
        return const Color(0xFFEF4444); 
      case NotificationType.success:
        return const Color(0xFF22C55E);
      case NotificationType.warning:
        return const Color(0xFFF59E0B);
      case NotificationType.info:
      default:
        return const Color(0xFF3B82F6);
    }
  }

  IconData get _icon {
    switch (type) {
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.info:
      default:
        return Icons.wifi_off;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(width: 4, color: _leftBarColor),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(_icon, color: Colors.black54, size: 20),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  title,
                                  style: GoogleFonts.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF111827),
                                  ),
                                ),
                              ),
                              Row(
                                children: [
                                  Text("Baru saja", style: GoogleFonts.inter(fontSize: 10, color: const Color(0xFF9CA3AF))),
                                  const SizedBox(width: 8),
                                  if (onDismiss != null)
                                    GestureDetector(
                                      onTap: onDismiss,
                                      child: const Icon(Icons.close, size: 16, color: Color(0xFF9CA3AF)),
                                    ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            message,
                            style: GoogleFonts.inter(fontSize: 13, color: const Color(0xFF4B5563), height: 1.5),
                          ),
                          if (onAction != null || onSecondaryAction != null) ...[
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                if (onAction != null)
                                  GestureDetector(
                                    onTap: onAction,
                                    child: Text(
                                      actionText ?? "Coba Lagi",
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w600, color: const Color(0xFF111827)),
                                    ),
                                  ),
                                if (onAction != null && onSecondaryAction != null) const SizedBox(width: 16),
                                if (onSecondaryAction != null)
                                  GestureDetector(
                                    onTap: onSecondaryAction,
                                    child: Text(
                                      secondaryActionText ?? "Abaikan",
                                      style: GoogleFonts.inter(fontSize: 13, fontWeight: FontWeight.w500, color: const Color(0xFF6B7280)),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CleanNotificationOverlay extends StatefulWidget {
  final String title;
  final String message;
  final NotificationType type;
  final Duration duration;
  final VoidCallback? onAction;
  final String? actionText;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionText;
  final VoidCallback onRemove;

  const _CleanNotificationOverlay({
    Key? key,
    required this.title,
    required this.message,
    required this.type,
    required this.duration,
    required this.onRemove,
    this.onAction,
    this.actionText,
    this.onSecondaryAction,
    this.secondaryActionText,
  }) : super(key: key);

  @override
  State<_CleanNotificationOverlay> createState() => _CleanNotificationOverlayState();
}

class _CleanNotificationOverlayState extends State<_CleanNotificationOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;
  late Animation<double> _fadeAnimation;
  bool _isClosing = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeIn,
    ));

    _controller.forward();

    if (widget.duration != Duration.zero) {
      Future.delayed(widget.duration, () {
        if (mounted && !_isClosing) _close();
      });
    }
  }

  void _close() {
    if (_isClosing) return;
    _isClosing = true;
    _controller.reverse().then((_) {
      if (mounted) widget.onRemove();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 16,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.transparent,
        child: SlideTransition(
          position: _offsetAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: CleanNotification(
              title: widget.title,
              message: widget.message,
              type: widget.type,
              onAction: () {
                widget.onAction?.call();
                _close();
              },
              actionText: widget.actionText,
              onSecondaryAction: () {
                 widget.onSecondaryAction?.call();
                 _close();
              },
              secondaryActionText: widget.secondaryActionText,
              onDismiss: _close,
            ),
          ),
        ),
      ),
    );
  }
}
