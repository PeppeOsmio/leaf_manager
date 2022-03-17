import 'package:flutter/material.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';

// ignore: must_be_immutable
class BottomNavyBar extends StatefulWidget {
  late int selectedItem;
  late List<BottomNavyBarItem> items;
  final Function(int index)? onItemSelected;
  final Decoration? decoration;
  final Color selectedItemColor;

  BottomNavyBar(
      {Key? key,
      this.selectedItem = 0,
      required this.items,
      this.onItemSelected,
      this.decoration,
      this.selectedItemColor = Colors.black})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _BottomNavyBarState();
  }
}

class _BottomNavyBarState extends State<BottomNavyBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _iconAnimation;
  late Animation<double> _dotAnimation;

  late int _selectedItem;
  double? _newSelectedItem, _oldSelectedItem;

  @override
  void initState() {
    super.initState();
    _selectedItem = widget.selectedItem;
    _animationController = AnimationController(
        duration: const Duration(milliseconds: 500), vsync: this)
      ..addListener(() {
        setState(() {});
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          if (_newSelectedItem != null) {
            _selectedItem = _newSelectedItem!.toInt();
          }
          _newSelectedItem = _oldSelectedItem = null;
          _animationController.reset();
        }
      });

    _iconAnimation = TweenSequence([
      TweenSequenceItem(
          tween:
              Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.ease)),
          weight: 50.0),
      TweenSequenceItem(
          tween:
              Tween(begin: 1.0, end: 1.0).chain(CurveTween(curve: Curves.ease)),
          weight: 50.0),
    ]).animate(_animationController);

    _dotAnimation = TweenSequence([
      TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.025)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 60.0),
      TweenSequenceItem(
          tween: Tween(begin: 1.025, end: 0.99)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 15.0),
      TweenSequenceItem(
          tween: Tween(begin: 0.99, end: 1.0)
              .chain(CurveTween(curve: Curves.ease)),
          weight: 25.0)
    ]).animate(_animationController);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: widget.decoration,
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 18.0),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
                children: widget.items
                    .mapIndexed((e, i) => _buildNavigationItem(e, i))
                    .toList()),
            FadeAnimation(
              direction: FadeDirection.bottomToTop,
              delay: const Duration(milliseconds: 600),
              child: SizedBox(
                height: 5.0,
                width: double.infinity,
                child: CustomPaint(
                  painter: _MovingDotPainter(
                      _dotAnimation.value,
                      _selectedItem,
                      _oldSelectedItem,
                      _newSelectedItem,
                      widget.items.length,
                      widget.selectedItemColor),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _animationController.dispose();
  }

  @override
  void didUpdateWidget(covariant BottomNavyBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    bool hasChanged = false;
    if (widget.decoration != oldWidget.decoration ||
        widget.selectedItemColor != oldWidget.selectedItemColor) {
      hasChanged = true;
    }

    if (hasChanged) setState(() {});
  }

  Widget _buildNavigationItem(BottomNavyBarItem item, int index) {
    return Expanded(
      child: FadeAnimation(
        direction: FadeDirection.bottomToTop,
        delay: Duration(milliseconds: 300 * index),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            if (!_animationController.isAnimating && _selectedItem != index) {
              _oldSelectedItem = _selectedItem.toDouble();
              _newSelectedItem = index.toDouble();
              _animationController.forward();
            }

            if (widget.onItemSelected != null) widget.onItemSelected!(index);
          },
          child: Column(children: [
            Icon(
              item.icon,
              size: 24.0,
              color: _animationController.isAnimating
                  ? _newSelectedItem == index
                      ? widget.selectedItemColor
                      : UI.textSecondaryColor(context)
                  : _selectedItem == index
                      ? widget.selectedItemColor
                      : UI.textSecondaryColor(context),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4.0, bottom: 12.0),
              child: Text(item.title,
                  style: UI.textStyle(
                      typeface:
                          UI.caption2.copyWith(fontWeight: FontWeight.w500),
                      color: _animationController.isAnimating
                          ? _newSelectedItem == index
                              ? widget.selectedItemColor
                              : UI.textSecondaryColor(context)
                          : _selectedItem == index
                              ? widget.selectedItemColor
                              : UI.textSecondaryColor(context))),
            )
          ]),
        ),
      ),
    );
  }
}

class _MovingDotPainter extends CustomPainter {
  final double value;
  final double? oldIndex, newIndex;
  final int index, length;
  final Color color;

  _MovingDotPainter(this.value, this.index, this.oldIndex, this.newIndex,
      this.length, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    double center = size.width / length;
    double x;
    if (oldIndex != null && newIndex != null) {
      x = center * (oldIndex! + 0.5) + center * (newIndex! - oldIndex!) * value;
    } else {
      x = center * (index + 0.5);
    }

    canvas.drawCircle(
        Offset(x, size.height / 2), size.height / 2, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BottomNavyBarItem {
  final IconData icon;
  final String title;

  BottomNavyBarItem({required this.icon, required this.title});
}
