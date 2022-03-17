import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/db.dart';
import 'package:leaf_03/exceptions.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/pages/bounds_selection_screen.dart';
import 'package:leaf_03/pages/new_farm_screen.dart';
import 'package:leaf_03/widgets/text_field_label.dart';
import 'package:leaf_03/widgets/toolbar.dart';

class OverviewScreen extends StatefulWidget {
  final Farm farm;
  final int userId;

  const OverviewScreen({Key? key, required this.farm, required this.userId}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return OverviewScreenState();
  }
}

class OverviewScreenState extends State<OverviewScreen>
    with WidgetsBindingObserver {
  final Completer<GoogleMapController> _mapController = Completer();
  late Crop _crop;
  late CameraPosition _cameraPosition;
  bool _isButtonPressed = false;

  late List<LatLng> _latlngs;
  late Polygon _polygon;
  String area = "Loading...";
  String perimeter = "Loading...";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);
    _crop = CropLoader.getInstance().getCropFromId(widget.farm.cropId) ??
        Crop.empty;
    _cameraPosition = Helper.polibaInitialCameraPosition;
    _latlngs = [];
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();
    setState(() {
      _setMapStyle();
    });
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


  void stateset(){
    setState(() {
      
    });
  }

  @override
  Widget build(BuildContext context) {
    int ttbDelayIndex = 1;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: Toolbar(
        title: Text(
          widget.farm.farmName,
          style: UI.textStyle(
              typeface: UI.headline3.copyWith(fontWeight: FontWeight.w500),
              color: UI.textPrimaryColor(context)),
        ),
        navigationItem: ActionItem(
          icon: Icon(
            Icons.chevron_left_outlined,
            color: UI.textPrimaryColor(context),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        popupMenuItems: [
          PopupMenuItem(
              onTap: () {
                Route route = MaterialPageRoute(builder: (context) => BoundsSelectionScreen(markers: _latlngs,));
                Future.delayed(const Duration(seconds: 0), () async{
                  await Navigator.push(context, route).
                  then((value) async{
                    if(value==null){
                      return;
                    }
                    await Helper.editLand(widget.userId, widget.farm.farmId, value);
                    var res = await Helper.getLandCoordinates(widget.farm.farmId, context);
                    _latlngs.clear();
                    _latlngs.addAll(res);
                    final controller = await _mapController.future;
                    final bounds = Helper.getBounds(_latlngs);
                    controller.moveCamera(CameraUpdate.newLatLngBounds(bounds!, 16));
                    area = CoordsHelper.getPolygonArea(_latlngs).toStringAsFixed(2);
                    perimeter = CoordsHelper.getPolygonPerimeter(_latlngs).toStringAsFixed(0);
                    setState(() {
                      
                    });
                  });
                });
              },
              child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                color: UI.textPrimaryColor(context),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 12.0),
                child: Text(
                  Localization.of(context).getString("edit"),
                  style: UI.textStyle(
                      typeface: UI.headline4,
                      color: UI.textPrimaryColor(context)),
                ),
              ),
            ],
          )),
          PopupMenuItem(
              onTap: () {
                Future.delayed(Duration.zero).then((_) =>
                    Helper.showAlertDialog(
                        title: Localization.of(context).getString("delete-title"),
                        content: Localization.of(context).getString("delete-content"),
                        context: context,
                        actions: [
                          AlertDialogAction(Localization.of(context).getString("delete"), () {
                            Helper.deleteLand(widget.farm.farmId).then((value) => Navigator.pop(context));
                            Navigator.pop(context);
                            
                          }),
                          AlertDialogAction(Localization.of(context).getString("cancel"), () {
                            Navigator.pop(context);
                          })
                        ]));
                /*Helper.showAlertDialog(context: context, actions: [
                  AlertDialogAction("Delete", () async {
                    if (!_isButtonPressed) {
                      _isButtonPressed = true;
                      try {
                        await Helper.deleteLand(widget.farm.farmId);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      } on LandCreationException catch (e) {
                        _isButtonPressed = false;
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
                      } catch (e) {
                        _isButtonPressed = false;
                        Helper.showSnackBar(
                            message: Text(
                              Localization.of(context)
                                  .getString("network-error".toString()),
                              style: UI.textStyle(
                                  typeface: UI.body,
                                  color: UI.textPrimaryColorDark(context)),
                            ),
                            context: context,
                            snackBarBehavior: SnackBarBehavior.floating);
                      }
                    } else {
                      return;
                    }
                  }),
                  AlertDialogAction("Cancel", () {
                    if (!_isButtonPressed) {
                      _isButtonPressed = true;
                      Navigator.pop(context);
                    } else {
                      return;
                    }
                  })
                ]);*/
              },
              child: Row(
                children: [
                  Icon(
                    Icons.delete_outline,
                    color: UI.textPrimaryColor(context),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 12.0),
                    child: Text(
                      Localization.of(context).getString("delete"),
                      style: UI.textStyle(
                          typeface: UI.headline4,
                          color: UI.textPrimaryColor(context)),
                    ),
                  ),
                ],
              ))
        ],
      ),
      body: SafeArea(
          child: SingleChildScrollView(
            clipBehavior: Clip.antiAlias,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 24.0, bottom: 24.0, top: 24.0),
                  child: FadeAnimation(
                    delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Container(
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                            color: UI.cardBackgroundColor(context),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black.withOpacity(0.08),
                                  blurRadius: 32.0,
                                  offset: const Offset(0.0, 4.0))
                            ],
                            borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(12.0),
                                bottomLeft: Radius.circular(12.0))),
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            Image(
                                width: double.infinity,
                                height: double.infinity,
                                fit: BoxFit.contain,
                                image: AssetImage(
                                    "assets/resources/${_crop.name}.png")),
                            Container(
                              width: double.infinity,
                              margin: const EdgeInsets.all(24.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    Localization.of(context)
                                        .getString(_crop.name),
                                    style: UI.textStyle(
                                        typeface: UI.headline0,
                                        color: UI.textPrimaryColor(context)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text(
                                      Localization.of(context).getString(_crop.type),
                                      style: UI.textStyle(
                                          typeface: UI.body,
                                          color: UI.textPrimaryColor(context)),
                                    ),
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: FadeAnimation(
                    delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                    child: Text(
                      Localization.of(context).getString("overview"),
                      style: UI.textStyle(
                          typeface: UI.headline2,
                          color: UI.textPrimaryColor(context)),
                    ),
                  ),
                ),
                Padding(
                  padding:
                      const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
                  child: FadeAnimation(
                    delay: Duration(milliseconds: 300 * ttbDelayIndex++),
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
                            initialCameraPosition: _cameraPosition,
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
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 48.0),
                  child: FadeAnimation(
                    delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding:
                              const EdgeInsets.only(left: 24.0, right: 24.0, top: 24.0),
                          child: TextFormFieldLabel(label: Localization.of(context).getString("details")),
                        ),
                        _buildDetailItem(
                            Icons.table_chart_outlined, "Area", area + " ha"),
                        _buildDetailItem(Icons.rounded_corner_outlined,
                            Localization.of(context).getString("perimeter"), perimeter + " m"),
                        _buildDetailItem(
                            Icons.date_range_outlined,
                            Localization.of(context).getString("date-first-cultivation"),
                            "${widget.farm.firstCultivation.day}/${widget.farm.firstCultivation.month}/${widget.farm.firstCultivation.year}"),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    _setMapStyle();
    Helper.getLandCoordinates(widget.farm.farmId, context).then((value) {
      //non fare setState qua, tanto lo facciamo dopo quando calcoliamo
      //area e perimetro
      _latlngs.clear();
      _latlngs.addAll(value);

      final bounds = Helper.getBounds(_latlngs);
      controller.moveCamera(CameraUpdate.newLatLngBounds(bounds!, 16));
      setState(() {
        area = CoordsHelper.getPolygonArea(_latlngs).toStringAsFixed(2);
        perimeter =
            CoordsHelper.getPolygonPerimeter(_latlngs).toStringAsFixed(0);
      });
      /*Helper.zoomToFit(controller, bounds).then((value) {
        _cameraPosition =
            CameraPosition(target: Helper.getBoundsCenter(bounds), zoom: value);
        controller.moveCamera(CameraUpdate.newCameraPosition(_cameraPosition));
        
        setState(() {});
      });*/
    });
  }

  Future _setMapStyle() async {
    final controller = await _mapController.future;
    controller.setMapStyle(
        WidgetsBinding.instance?.window.platformBrightness == Brightness.light
            ? MapTheme.getInstance().lightStyle
            : MapTheme.getInstance().darkStyle);
  }

  Widget _buildDetailItem(IconData icon, String title, String subtitle) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 32.0),
            child: Icon(
              icon,
              color: UI.textPrimaryColor(context),
            ),
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: UI.textStyle(
                    typeface: UI.headline4,
                    color: UI.textPrimaryColor(context)),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  subtitle,
                  style: UI.textStyle(
                      typeface: UI.body, color: UI.textSecondaryColor(context)),
                ),
              )
            ],
          ))
        ],
      ),
    );
  }
}
