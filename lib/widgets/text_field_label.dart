import 'package:flutter/material.dart';
import 'package:leaf_03/miscellaneous/ui.dart';

class TextFormFieldLabel extends StatelessWidget {
  final String label;

  const TextFormFieldLabel({
    Key? key,
    required this.label,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 8.0,
      ),
      child: Text(label,
          style: UI.textStyle(
              typeface: UI.body.copyWith(fontWeight: FontWeight.w500),
              color: UI.textPrimaryColor(context))),
    );
  }
}
