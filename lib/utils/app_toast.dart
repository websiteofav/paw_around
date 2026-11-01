import 'package:flutter/material.dart';
import 'package:paw_around/constants/app_colors.dart';
import 'package:paw_around/constants/app_decorations.dart';
import 'package:paw_around/constants/text_styles.dart';

/// Top-of-screen toast, used in place of a bottom SnackBar for messages
/// that need to stay visible above the keyboard/bottom nav/CTA buttons.
class AppToast {
  AppToast._();

  static void show(
    BuildContext context, {
    required String message,
    required Color color,
    required IconData icon,
    Duration duration = const Duration(seconds: 3),
  }) {
    final overlay = Overlay.of(context);
    final topPadding = MediaQuery.of(context).padding.top;
    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => _ToastWidget(
        topPadding: topPadding,
        message: message,
        color: color,
        icon: icon,
        duration: duration,
        onDismissed: () => entry.remove(),
      ),
    );
    overlay.insert(entry);
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        context,
        message: message,
        color: AppColors.error,
        icon: Icons.error_outline,
        duration: duration,
      );

  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        context,
        message: message,
        color: AppColors.success,
        icon: Icons.check_circle_outline,
        duration: duration,
      );

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) =>
      show(
        context,
        message: message,
        color: AppColors.primary,
        icon: Icons.info_outline,
        duration: duration,
      );
}

class _ToastWidget extends StatefulWidget {
  final double topPadding;
  final String message;
  final Color color;
  final IconData icon;
  final Duration duration;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.topPadding,
    required this.message,
    required this.color,
    required this.icon,
    required this.duration,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
    reverseDuration: const Duration(milliseconds: 180),
  );
  late final Animation<Offset> _slide = Tween(
    begin: const Offset(0, -1),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

  @override
  void initState() {
    super.initState();
    _controller.forward();
    Future.delayed(widget.duration, _dismiss);
  }

  Future<void> _dismiss() async {
    if (!mounted) return;
    await _controller.reverse();
    widget.onDismissed();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: widget.topPadding + 12,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _controller,
          child: Material(
            color: Colors.transparent,
            child: GestureDetector(
              onTap: _dismiss,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 14),
                decoration: smoothDecoration(
                  cornerRadius: 16,
                  color: AppColors.grey1000,
                  side: BorderSide(
                      color: widget.color.withValues(alpha: 0.4)),
                  shadows: [
                    BoxShadow(
                      color: AppColors.shadowOverlay.withValues(alpha: 0.15),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Icon(widget.icon, color: widget.color, size: 20),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTextStyles.mediumStyle500(
                            fontSize: 14, fontColor: AppColors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
