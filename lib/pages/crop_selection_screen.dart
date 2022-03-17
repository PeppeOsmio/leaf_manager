import 'package:flutter/material.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/db.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/widgets/toolbar.dart';

class CropSelectionScreen extends StatefulWidget {
  const CropSelectionScreen({Key? key}) : super(key: key);

  @override
  State<CropSelectionScreen> createState() => _CropSelectionScreenState();
}

class _CropSelectionScreenState extends State<CropSelectionScreen> {
  late List<Crop>? _fullList;
  late List<Crop> _actualList;

  late bool _initialized;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _initialized = false;
    _fullList = CropLoader.getInstance().getCropsList();
    _actualList = [];
    if (_fullList != null) {
      _actualList.addAll(_fullList!);
    }
  }

  @override
  Widget build(BuildContext context) {
    int ttbDelayIndex = 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        children: [
          FadeAnimation(
            delay: Duration(milliseconds: 300 * ttbDelayIndex++),
            child: Toolbar(
              title: Text(
                Localization.of(context).getString("crop-selection-title"),
                style: UI.textStyle(
                    typeface:
                        UI.headline3.copyWith(fontWeight: FontWeight.w500),
                    color: UI.textPrimaryColor(context)),
              ),
              navigationItem: ActionItem(
                icon: Icon(
                  Icons.chevron_left_outlined,
                  color: UI.textPrimaryColor(context),
                ),
                onPressed: (){
                  if(!_isPressed){
                    _isPressed = true;
                    Navigator.pop(context);
                  }
                },
              ),
            ),
          ),
          FadeAnimation(
            delay: Duration(milliseconds: 300 * ttbDelayIndex++),
            child: Padding(
              padding:
                  const EdgeInsets.only(top: 24.0, left: 24.0, right: 24.0),
              child: TextFormField(
                maxLines: 1,
                autocorrect: false,
                onChanged: (value) {
                  if (_fullList != null) {
                    setState(() {
                      if (value.isEmpty || value == "") {
                        _actualList.clear();
                        _actualList.addAll(_fullList!);
                      } else {
                        _actualList.clear();

                        for (Crop crop in _fullList!) {
                          if (Localization.of(context)
                              .getString(crop.name)
                              .toLowerCase()
                              .contains(value.toLowerCase())) {
                            _actualList.add(crop);
                          }
                        }
                      }
                    });
                  }
                },
                decoration: InputDecoration(
                    filled: true,
                    fillColor: UI.textfieldBackgroundColor(context),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 16.0),
                    hintText: Localization.of(context).getString("search-crop"),
                    hintStyle: UI.textStyle(
                        typeface:
                            UI.headline4.copyWith(fontWeight: FontWeight.w400),
                        color: UI.textSecondaryColor(context)),
                    border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(12.0))),
                style: UI.textStyle(
                    typeface:
                        UI.headline4.copyWith(fontWeight: FontWeight.w400),
                    color: UI.textPrimaryColor(context)),
              ),
            ),
          ),
          if (_actualList.isNotEmpty)
            Expanded(
              child: _initialized
                  ? _createCropsListView()
                  : FadeAnimation(
                      delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                      onComplete: () => _initialized = true,
                      child: _createCropsListView(),
                    ),
            )
        ],
      ),
    );
  }

  Widget _createCropsListView() {
    return ListView.separated(
        padding: const EdgeInsets.only(top: 24.0, bottom: 24.0),
        itemBuilder: (BuildContext context, int index) {
          return _buildListItem(_actualList[index], context);
        },
        itemCount: _actualList.length,
        separatorBuilder: (BuildContext context, int index) {
          return Divider(
            height: 1.0,
            thickness: 1.0,
            indent: 24.0,
            color: UI.dividerColor(context),
          );
        });
  }

  Widget _buildListItem(Crop crop, BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: (){
          if(!_isPressed){
            _isPressed = true;
            Navigator.pop(context, crop);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
          child: Row(
            children: [
              Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: UI.cropCircleBackgroundColor(context)),
                  child: Image(
                      image: AssetImage(
                    "assets/resources/${crop.name}.png",
                  ))),
              Expanded(
                  child: Padding(
                padding: const EdgeInsets.only(left: 24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      Localization.of(context).getString(crop.name),
                      style: UI.textStyle(
                          typeface: UI.headline3
                              .copyWith(fontWeight: FontWeight.w500),
                          color: UI.textPrimaryColor(context)),
                    ),
                    Container(
                      margin: const EdgeInsets.only(top: 12.0),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 4.0),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.0),
                          color: UI.applicationBrandColor.withOpacity(0.24)),
                      child: Text(
                        Localization.of(context).getString(crop.type),
                        style: UI.textStyle(
                            typeface:
                                UI.body.copyWith(fontWeight: FontWeight.w500),
                            color: UI.textPrimaryColor(context)),
                      ),
                    )
                  ],
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
