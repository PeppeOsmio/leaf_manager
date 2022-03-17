import 'package:flutter/material.dart';
import 'package:leaf_03/miscellaneous/ui.dart';

class FloatyWidgetButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget? child;
  final BorderRadius? borderRadius;
  final Color? buttonColor;
  final List<BoxShadow>? boxShadow;
  final Border? border;

  const FloatyWidgetButton(this.child,
      {Key? key,
      this.onPressed,
      this.borderRadius,
      this.buttonColor,
      this.boxShadow,
      this.border})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          boxShadow: boxShadow, border: border, borderRadius: borderRadius),
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: buttonColor,
        child: InkWell(
            borderRadius: borderRadius,
            onTap: onPressed,
            splashFactory: InkRipple.splashFactory,
            child: child),
      ),
    );
  }

  static FloatyWidgetButton primary(
          {required Widget child,
          required BuildContext context,
          VoidCallback? onPressed}) =>
      FloatyWidgetButton(child,
          onPressed: onPressed,
          borderRadius: BorderRadius.circular(12.0),
          buttonColor: UI.buttonPrimaryColor(context));

  static FloatyWidgetButton secondary(
          {required Widget child,
          required BuildContext context,
          VoidCallback? onPressed}) =>
      FloatyWidgetButton(child,
          onPressed: onPressed,
          buttonColor: Colors.transparent,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(
            color: UI.buttonSecondaryColor(context),
          ));

  static FloatyWidgetButton tertiary(
          {required Widget child, VoidCallback? onPressed}) =>
      FloatyWidgetButton(
        child,
        onPressed: onPressed,
        buttonColor: Colors.transparent,
        borderRadius: BorderRadius.circular(12.0),
      );
}

enum FloatyActionButtonSize { SMALL, NORMAL }

class FloatyActionButton extends StatelessWidget {
  final Icon? icon;
  final VoidCallback? onPressed;
  final Color color;
  final FloatyActionButtonSize size;

  const FloatyActionButton(
      {Key? key,
      this.icon,
      this.onPressed,
      this.color = Colors.white,
      this.size = FloatyActionButtonSize.NORMAL})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FloatyWidgetButton(
      Container(
          width: size == FloatyActionButtonSize.NORMAL ? 56.0 : 48.0,
          height: size == FloatyActionButtonSize.NORMAL ? 56.0 : 48.0,
          alignment: Alignment.center,
          child: icon),
      onPressed: onPressed,
      buttonColor: color,
      borderRadius: size == FloatyActionButtonSize.NORMAL
          ? BorderRadius.circular(18.0)
          : BorderRadius.circular(14.0),
      boxShadow: [
        BoxShadow(
            offset: const Offset(0, 4),
            blurRadius: 16,
            color: const Color(0xFF000000).withOpacity(0.08))
      ],
    );
  }
}
