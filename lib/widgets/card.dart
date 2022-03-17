import 'package:flutter/material.dart';

class ThemedCard extends StatelessWidget {
  Widget? _child;
  Decoration? _decoration;

  ThemedCard({Key? key, Widget? child, Decoration? decoration})
      : super(key: key) {
    _child = child;
    _decoration = decoration;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity, decoration: _decoration, child: _child);
  }
}
