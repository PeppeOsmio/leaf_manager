import 'package:flutter/material.dart';
import 'package:leaf_03/miscellaneous/ui.dart';

class RoundCheckBoxTile extends StatelessWidget {
  final Color? color;
  final bool enabled;
  final String title;

  const RoundCheckBoxTile(
      {Key? key, this.color, this.enabled = false, required this.title})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8.0),
            decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: enabled
                    ? color ?? UI.applicationBrandColor
                    : UI.checkboxTileDefaultColor(context)),
            padding: const EdgeInsets.all(2.0),
            child: Icon(
              Icons.check_outlined,
              size: 12.0,
              color: UI.textPrimaryColorDark(context),
            ),
          ),
          Text(
            title,
            style: UI.textStyle(
                typeface: UI.body.copyWith(fontWeight: FontWeight.w500),
                color: enabled
                    ? color ?? UI.applicationBrandColor
                    : UI.checkboxTileDefaultColor(context)),
          )
        ],
      ),
    );
  }
}
