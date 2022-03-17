import 'package:flutter/material.dart';
import 'package:simple_animations/simple_animations.dart';

enum _FadeTransformations { opacity, translateY, translateX }

enum FadeDirection { topToBottom, bottomToTop, leftToRight, rightToLeft, none }

class FadeAnimation extends StatelessWidget {
  final Duration delay, duration;
  final Widget child;
  final FadeDirection direction;
  final VoidCallback? onComplete;

  const FadeAnimation(
      {Key? key,
      this.delay = Duration.zero,
      this.duration = const Duration(milliseconds: 500),
      required this.child,
      this.direction = FadeDirection.topToBottom,
      this.onComplete})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final MultiTween<_FadeTransformations> tween =
        MultiTween<_FadeTransformations>()
          ..add(_FadeTransformations.opacity, Tween(begin: 0.0, end: 1.0),
              const Duration(milliseconds: 500))
          ..add(
              direction == FadeDirection.bottomToTop ||
                      direction == FadeDirection.topToBottom
                  ? _FadeTransformations.translateY
                  : _FadeTransformations.translateX,
              direction == FadeDirection.topToBottom ||
                      direction == FadeDirection.leftToRight
                  ? Tween(begin: -32.0, end: 0.0)
                  : Tween(begin: 32.0, end: 0.0),
              const Duration(milliseconds: 500),
              Curves.easeOut);

    return CustomAnimation<MultiTweenValues<_FadeTransformations>>(
      delay: Duration(
          milliseconds: duration.inMilliseconds + delay.inMilliseconds),
      builder: (context, widget, animation) => Opacity(
        opacity: animation.get(_FadeTransformations.opacity),
        child: Transform.translate(
            offset: direction != FadeDirection.none
                ? direction == FadeDirection.bottomToTop ||
                        direction == FadeDirection.topToBottom
                    ? Offset(0, animation.get(_FadeTransformations.translateY))
                    : Offset(animation.get(_FadeTransformations.translateX), 0)
                : Offset.zero,
            child: child),
      ),
      tween: tween,
      onComplete: onComplete,
    );
  }
}
