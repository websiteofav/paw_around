import 'package:flutter/material.dart';

class AnimatedContent extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;

  const AnimatedContent({
    super.key,
    required this.animation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Transform.scale(
          scale: animation.value,
          child: Opacity(
            opacity: animation.value,
            child: this.child,
          ),
        );
      },
    );
  }
}

class AnimatedScaledContent extends StatelessWidget {
  final Animation<double> animation;
  final Widget child;
  final double minScale;
  final double maxScale;

  const AnimatedScaledContent({
    super.key,
    required this.animation,
    required this.child,
    this.minScale = 0.8,
    this.maxScale = 1.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final scale = minScale + (maxScale - minScale) * animation.value;
        return Transform.scale(
          scale: scale,
          child: Opacity(
            opacity: animation.value,
            child: this.child,
          ),
        );
      },
    );
  }
}
