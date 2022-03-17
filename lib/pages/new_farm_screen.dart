import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/db.dart';
import 'package:leaf_03/exceptions.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/pages/bounds_selection_screen.dart';
import 'package:leaf_03/pages/crop_selection_screen.dart';
import 'package:leaf_03/widgets/text_field_label.dart';
import 'package:leaf_03/widgets/toolbar.dart';
import 'package:intl/intl.dart';

class NewFarmScreen extends StatefulWidget {
  final int userId;

  const NewFarmScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return NewFarmScreenState();
  }
}

class NewFarmScreenState extends State<NewFarmScreen>
    with WidgetsBindingObserver {
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _datePickerController = TextEditingController();
  final TextEditingController _cropController = TextEditingController();

  // This holds information about the selected crop
  // that will be cultivated on this terrain.
  Crop? _product;

  final Completer<GoogleMapController> _mapController = Completer();
  late CameraPosition _initialCameraPosition;

  // This list holds all the markers that make up
  // the boundaries of the farm.
  final List<LatLng> _latlngs = <LatLng>[];
  late Polygon _polygon;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _initialCameraPosition = Helper.polibaInitialCameraPosition;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _polygon = Polygon(
        polygonId: const PolygonId("farm"),
        fillColor: UI.polygonFillColor(context),
        strokeColor: UI.polygonStrokeColor(context),
        strokeWidth: 2,
        points: _latlngs);
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    int ttbDelayIndex = 0;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: Theme.of(context).backgroundColor,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FadeAnimation(
            delay: Duration(milliseconds: 300 * ttbDelayIndex++),
            child: Toolbar(
              navigationItem: ActionItem(
                icon: Icon(
                  Icons.chevron_left_outlined,
                  color: UI.textPrimaryColor(context),
                ),
                onPressed: () {
                  if (!_isPressed) {
                    _isPressed = true;
                    Navigator.of(context).pop();
                  } else {
                    return;
                  }
                },
              ),
              actionItems: [
                ActionItem(
                  icon: Icon(
                    Icons.check_outlined,
                    color: UI.textPrimaryColor(context),
                  ),
                  onPressed: () async {
                    if (!_isPressed) {
                      _isPressed = true;
                      try {
                        await Helper.addLand(
                            context: context,
                            landName: _farmNameController.text,
                            cropName: _product == null ? null : _product!.name,
                            date: _datePickerController.text,
                            coords: _latlngs,
                            userId: widget.userId);
                        Navigator.pop(context);
                      } catch (e) {
                        _isPressed = false;
                        if (e is LandCreationException) {
                          Helper.showSnackBar(
                              message: Text(
                                Localization.of(context)
                                    .getString(e.message.toString()),
                                style: UI.textStyle(
                                    typeface: UI.body,
                                    color: UI.textPrimaryColorDark(context)),
                              ),
                              context: context,
                              snackBarBehavior: SnackBarBehavior.floating);
                        } else {
                          Helper.showSnackBar(
                              message: Text(Localization.of(context)
                                  .getString("network-error")),
                              context: context);
                        }
                      }
                    } else {
                      return;
                    }
                  },
                ),
              ],
            ),
          ),
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeAnimation(
                  delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 24.0, right: 24.0, top: 16.0),
                      child: Text(
                          Localization.of(context).getString("new-farm-title"),
                          style: UI.textStyle(
                              typeface: UI.headline1,
                              color: UI.textPrimaryColor(context)))),
                ),
                FadeAnimation(
                  delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                  child: Padding(
                      padding: const EdgeInsets.only(
                          left: 24.0, right: 24.0, top: 8.0, bottom: 24.0),
                      child: Text(
                          Localization.of(context)
                              .getString("new-farm-subtitle"),
                          style: UI.textStyle(
                              typeface: UI.body,
                              color: UI.textSecondaryColor(context)))),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: [
                      Expanded(
                          child: FadeAnimation(
                        delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormFieldLabel(
                                label: Localization.of(context)
                                    .getString("new-farm-name")),
                            TextFormField(
                              maxLines: 1,
                              autocorrect: false,
                              controller: _farmNameController,
                              decoration: InputDecoration(
                                  filled: true,
                                  fillColor:
                                      UI.textfieldBackgroundColor(context),
                                  contentPadding: const EdgeInsets.symmetric(
                                      vertical: 16.0, horizontal: 16.0),
                                  hintStyle: UI.textStyle(
                                      typeface: UI.headline4.copyWith(
                                          fontWeight: FontWeight.w400),
                                      color: UI.textSecondaryColor(context)),
                                  border: OutlineInputBorder(
                                      borderSide: BorderSide.none,
                                      borderRadius:
                                          BorderRadius.circular(12.0))),
                              style: UI.textStyle(
                                  typeface: UI.headline4
                                      .copyWith(fontWeight: FontWeight.w400),
                                  color: UI.textPrimaryColor(context)),
                            ),
                          ],
                        ),
                      )),
                      const SizedBox(width: 16.0),
                      Expanded(
                          child: FadeAnimation(
                        delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextFormFieldLabel(
                                label: Localization.of(context)
                                    .getString("new-farm-date")),
                            TextFormField(
                              //bisogna disabilitarlo se no ci mettono date a cazzo
                              readOnly: true,
                              controller: _datePickerController,
                              onTap: () async {
                                FocusScope.of(context)
                                    .requestFocus(FocusNode());
                                // TODO: Add platform dependent DatePicker
                                DateTime? date = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime(1960, 1),
                                    lastDate: DateTime.now()
                                        .add(const Duration(days: 365)));
                                if (date != null) {
                                  _datePickerController.text =
                                      DateFormat("yyyy-MM-dd").format(date);
                                } else {
                                  return;
                                }
                              },
                              decoration: InputDecoration(
                                filled: true,
                                fillColor: UI.textfieldBackgroundColor(context),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 16.0),
                                hintStyle: UI.textStyle(
                                    typeface: UI.headline4
                                        .copyWith(fontWeight: FontWeight.w400),
                                    color: UI.textSecondaryColor(context)),
                                border: OutlineInputBorder(
                                    borderSide: BorderSide.none,
                                    borderRadius: BorderRadius.circular(12.0)),
                                suffixIconConstraints: const BoxConstraints(
                                    maxWidth: 36.0, maxHeight: 24.0),
                                suffixIcon: Padding(
                                  padding: const EdgeInsets.only(right: 12.0),
                                  child: Icon(Icons.date_range_outlined,
                                      color: UI.textPrimaryColor(context)),
                                ),
                              ),
                              style: UI.textStyle(
                                  typeface: UI.headline4
                                      .copyWith(fontWeight: FontWeight.w400),
                                  color: UI.textPrimaryColor(context)),
                            ),
                          ],
                        ),
                      ))
                    ],
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(top: 24.0, right: 24.0, left: 24.0),
                  child: FadeAnimation(
                    delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormFieldLabel(
                            label: Localization.of(context)
                                .getString("new-farm-crop")),
                        TextFormField(
                          readOnly: true,
                          controller: _cropController,
                          onTap: () {
                            if (!_isPressed) {
                              _isPressed = true;
                              Route route = MaterialPageRoute(
                                  builder: (context) =>
                                      const CropSelectionScreen());
                              Navigator.push(context, route)
                                  .then((value) => setState(() {
                                        _isPressed = false;
                                        if (value is Crop) {
                                          _product = value;
                                          _cropController.text =
                                              Localization.of(context)
                                                  .getString(_product!.name);
                                        }
                                      }));
                            } else {
                              return;
                            }
                          },
                          decoration: InputDecoration(
                              filled: true,
                              fillColor: UI.textfieldBackgroundColor(context),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 16.0, horizontal: 16.0),
                              hintStyle: UI.textStyle(
                                  typeface: UI.headline4
                                      .copyWith(fontWeight: FontWeight.w400),
                                  color: UI.textSecondaryColor(context)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide.none,
                                  borderRadius: BorderRadius.circular(12.0))),
                          style: UI.textStyle(
                              typeface: UI.headline4
                                  .copyWith(fontWeight: FontWeight.w400),
                              color: UI.textPrimaryColor(context)),
                        ),
                      ],
                    ),
                  ),
                ),
                FadeAnimation(
                  delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TextFormFieldLabel(
                            label: Localization.of(context)
                                .getString("new-farm-map")),
                        Container(
                          width: double.infinity,
                          height: 156.0,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0)),
                          foregroundDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              border: Border.all(
                                  color: UI.textfieldBackgroundColor(context),
                                  width: 1.0)),
                          clipBehavior: Clip.antiAlias,
                          child: GoogleMap(
                            onMapCreated: _onMapCreated,
                            onTap: (latlng) {
                              if (!_isPressed) {
                                _isPressed = true;
                                Route route = MaterialPageRoute(
                                    builder: (context) => BoundsSelectionScreen(
                                          markers: _latlngs,
                                        ));
                                Navigator.push(context, route)
                                    .then((value) async {
                                  _isPressed = false;
                                  if (value == null) return;
                                  if (value is List<LatLng>) {
                                    _latlngs.clear();
                                    _latlngs.addAll(value);
                                    setState(() {});
                                    final controller =
                                        await _mapController.future;
                                    final bounds = Helper.getBounds(_latlngs);
                                    Future.delayed(
                                        Duration(
                                            milliseconds: kIsWeb ? 200 : 0),
                                        () {
                                      controller.moveCamera(
                                          CameraUpdate.newLatLngBounds(
                                              bounds!, 16));
                                    });
                                  }
                                });
                              }
                            },
                            initialCameraPosition: _initialCameraPosition,
                            padding: const EdgeInsets.all(
                                8.0), // Needed for Google logo to show up properly
                            scrollGesturesEnabled: false,
                            zoomGesturesEnabled: false,
                            rotateGesturesEnabled: false,
                            myLocationButtonEnabled: false,
                            tiltGesturesEnabled: false,
                            buildingsEnabled: false,
                            zoomControlsEnabled: false,
                            polygons: _latlngs.isNotEmpty ? {_polygon} : {},
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    _setMapStyle();

    /* Questa è inutile perchè possiamo fare moveCamera direttamente al ritorno da
       bounds_selection_screen (dopo navigator.push), tanto appena creiamo new_farm_screen 
       le _latlngs sono vuote e non c'è nessun moveCamera da fare
    
    if (_latlngs.isNotEmpty) {
      final bounds = Helper.getBounds(_latlngs);
      controller.moveCamera(CameraUpdate.newLatLngBounds(bounds!, 16));
    }*/
  }

  Future _setMapStyle() async {
    final controller = await _mapController.future;
    controller.setMapStyle(
        WidgetsBinding.instance?.window.platformBrightness == Brightness.light
            ? MapTheme.getInstance().lightStyle
            : MapTheme.getInstance().darkStyle);
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      _setMapStyle();
    });
  }
}
