// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';

// TODO: Create a custom ShapeBorder for the PopupMenu.
class Toolbar extends StatefulWidget implements PreferredSizeWidget {
  /// The Title of the action bar, a widget which the user can decide
  /// its nature, such as a Text or a SearchBar.
  Widget? title;

  /// A list of widgets to show in a Row after the Title.
  /// If there are too many widgets, then the user might
  /// want to add a PopupMenuActionItem for less common actions.
  List<Widget>? actionItems;

  /// A list of PopupMenuItems to show inside a box
  /// when the "more" menu is pressed.
  List<PopupMenuItem>? popupMenuItems;

  /// The action item to show before the Title.
  /// It usually shows a "back button" to navigate
  /// between pages, but the user can customize its functionality.
  Widget? navigationItem;

  /// A decoration that the user can add to the ActionBar,
  /// such as background color, shadow, borders etc.
  Decoration? decoration;

  //Per evitare che su web il latlng venga messo al di sotto del menu
  VoidCallback? onMenuPressed;

  Toolbar(
      {Key? key,
      this.decoration,
      this.navigationItem,
      this.actionItems,
      this.popupMenuItems,
      this.onMenuPressed,
      this.title})
      : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _ToolbarState();
  }

  @override
  Size get preferredSize => const Size(double.infinity, 68.0);
}

class _ToolbarState extends State<Toolbar> {
  Widget? _title;

  @override
  void initState() {
    super.initState();
    _title = widget.title;
  }

  @override
  Widget build(BuildContext context) {
    return FadeAnimation(
      child: Container(
          decoration: widget.decoration,
          child: SafeArea(
            bottom: false,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (widget.navigationItem != null)
                        Container(
                          margin: const EdgeInsets.only(right: 16.0),
                          child: widget.navigationItem!,
                        ),
                      const Spacer(),
                      if (widget.actionItems != null)
                        for (int i = 0; i < widget.actionItems!.length; ++i)
                          Container(
                              margin:
                                  EdgeInsets.only(left: i == 0 ? 16.0 : 8.0),
                              child: widget.actionItems![i]),
                      if (widget.popupMenuItems != null)
                        Container(
                            margin: EdgeInsets.only(
                                left: widget.actionItems == null ||
                                        widget.actionItems!.isEmpty
                                    ? 16.0
                                    : 8.0),
                            child: ActionItem(
                              icon: Icon(Icons.more_horiz_outlined,
                                  color: UI.textPrimaryColor(context)),
                              onPressed: () {
                                if(widget.onMenuPressed!=null){
                                  widget.onMenuPressed!.call();
                                }
                                // TODO: Re-engineer this function?
                                showMenu(
                                    context: context,
                                    elevation: 2.0,
                                    color: UI.cardBackgroundColor(context),
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0)),
                                    position: const RelativeRect.fromLTRB(
                                        double.infinity, 0.0, 0.0, 0.0),
                                    items: widget.popupMenuItems!);
                              },
                            )),
                    ],
                  ),
                  if (_title != null)
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: EdgeInsets.symmetric(
                          horizontal: widget.popupMenuItems != null
                              ? (36.0 + 8.0) * widget.popupMenuItems!.length
                              : 36.0 + 16.0),
                      child: _title!,
                    )
                ],
              ),
            ),
          )),
    );
  }

  @override
  void didUpdateWidget(covariant Toolbar oldWidget) {
    if (widget.title != oldWidget.title) {
      _title = widget.title;
    }
    super.didUpdateWidget(oldWidget);
  }
}

class ActionItem extends StatelessWidget {
  final Icon? icon;
  final VoidCallback? onPressed;

  const ActionItem({Key? key, this.icon, this.onPressed}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        boxShadow: const [
          BoxShadow(
              color: Color.fromRGBO(0, 0, 0, 0.08),
              offset: Offset(0.0, 2.0),
              blurRadius: 12.0)
        ],
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Material(
        clipBehavior: Clip.antiAlias,
        borderRadius: BorderRadius.circular(12.0),
        color: UI.toolbarActionButtonColor(context),
        child: InkWell(
          onTap: onPressed,
          child: Center(
            child: SizedBox(width: 24, height: 24, child: icon),
          ),
        ),
      ),
    );
  }
}
