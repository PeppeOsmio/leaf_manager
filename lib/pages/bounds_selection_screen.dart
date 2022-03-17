import 'dart:async';
import 'dart:developer';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:leaf_03/animation/fade_animation.dart';
import 'package:leaf_03/exceptions.dart';
import 'package:leaf_03/localization.dart';
import 'package:leaf_03/miscellaneous/helper.dart';
import 'package:leaf_03/miscellaneous/ui.dart';
import 'package:leaf_03/widgets/floaty_buttons.dart';
import 'package:leaf_03/widgets/toolbar.dart';

class BoundsSelectionScreen extends StatefulWidget {
  final List<LatLng>? markers;

  const BoundsSelectionScreen({Key? key, this.markers}) : super(key: key);

  @override
  State<BoundsSelectionScreen> createState() => _BoundsSelectionScreenState();
}

class _BoundsSelectionScreenState extends State<BoundsSelectionScreen>
    with WidgetsBindingObserver {
  final Completer<GoogleMapController> _mapController = Completer();
  final List<LatLng> _latlngs = [];
  final List<Marker> _markers = [];
  late Polygon _polygon;
  late CameraPosition _initialCameraPosition;

  bool _isPressed = false;
  bool _isButtonPressed = false;
  int initialMarkers = 0;

  BitmapDescriptor? _markerIcon;

  bool isSatelliteModeEnabled = false;
  bool firstBuild = true;

  //other variables for markers
  late int
      markerpositionindex; //we NEED to know where the vertex that we are moving is located in latlngs

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance?.addObserver(this);

    if (widget.markers != null) {
      initialMarkers = widget.markers!.length;
      _latlngs.addAll(widget.markers!);
    }

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

    if (!kIsWeb && firstBuild) {
      loadMarkerIcon().then((value) => setState(() {
            _markerIcon = value;
            firstBuild = false;
            _markers.clear();
            for (int i = 0; i < _latlngs.length; ++i) {
              Marker marker = _buildMarker(_latlngs[i], i);
              log("Adding marker: " + marker.markerId.toString());
              _markers.add(marker);
            }
            log("DidChangeDependencies: " + _markers.toString());
          }));
    }
  }

  @override
  void didChangePlatformBrightness() {
    super.didChangePlatformBrightness();

    if (!kIsWeb && !firstBuild) {
      loadMarkerIcon().then((value) => setState(() {
            _setMapStyle();
            _markerIcon = value;
            _markers.clear();
            for (int i = 0; i < _latlngs.length; ++i) {
              Marker marker = _buildMarker(_latlngs[i], i);
              log("Adding marker: " + marker.markerId.toString());
              _markers.add(marker);
            }
            log("DidChangePlatformBrightness: " + _markers.toString());
          }));
    } else {
      setState(() {
        _setMapStyle();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance?.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("Length: ${_markers.length}");
    for (int i = 0; i < _markers.length; i++) {
      print(_markers[i].markerId);
    }
    int ttbDelayIndex = 0;
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Stack(
        alignment: Alignment.centerRight,
        children: [
          FadeAnimation(
            direction: FadeDirection.bottomToTop,
            delay: Duration(milliseconds: 300 * ttbDelayIndex++),
            child: GoogleMap(
              padding: const EdgeInsets.all(8.0),
              initialCameraPosition: _initialCameraPosition,
              onMapCreated: _onMapCreated,
              myLocationButtonEnabled: false,
              tiltGesturesEnabled: false,
              buildingsEnabled: false,
              zoomControlsEnabled: false,
              mapType:
                  isSatelliteModeEnabled ? MapType.satellite : MapType.normal,
              markers: _markers.toSet(),
              polygons: _latlngs.isNotEmpty ? {_polygon} : {},
              onTap: (latlng) {
                if (_isButtonPressed) {
                  _isButtonPressed = false;
                } else {
                  setState(() {
                    _latlngs.add(latlng);
                    Marker marker = _buildMarker(latlng, _markers.length);
                    log("Adding marker: " + marker.markerId.toString());
                    _markers.add(marker);
                  });
                }
              },
            ),
          ),
          Column(
            children: [
              FadeAnimation(
                delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                child: Toolbar(
                  decoration: BoxDecoration(
                      gradient: LinearGradient(colors: [
                    UI.windowBackgroundColor(context).withOpacity(0.12),
                    Colors.transparent
                  ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
                  onMenuPressed: () {
                    if (kIsWeb) {
                      _isButtonPressed = true;
                    }
                  }, //per evitare che sotto al menu vengano messe le latlng
                  navigationItem:
                      //back button
                      ActionItem(
                    icon: Icon(
                      Icons.chevron_left_outlined,
                      color: UI.textPrimaryColor(context),
                    ),
                    onPressed: () {
                      if (kIsWeb) {
                        _isButtonPressed = true;
                      }
                      if (!_isPressed) {
                        _isPressed = true;
                        Navigator.pop(context);
                      }
                    },
                  ),
                  actionItems: [
                    //confirm button
                    ActionItem(
                      icon: Icon(
                        Icons.check_outlined,
                        color: UI.textPrimaryColor(context),
                      ),
                      onPressed: () {
                        if (kIsWeb) {
                          _isButtonPressed = true;
                        }
                        if (_markers.length < 3) {
                          Helper.showSnackBar(
                            message: Text(
                              Localization.of(context)
                                  .getString("new-farm-min-verteces"),
                              style: UI.textStyle(
                                  typeface: UI.body,
                                  color: UI.textPrimaryColorDark(context)),
                            ),
                            context: context,
                            snackBarBehavior: SnackBarBehavior.floating,
                          );
                          return;
                        }
                        if (!_isPressed) {
                          _isPressed = true;
                          Navigator.pop(context, _latlngs);
                        }
                      },
                    ),
                  ],
                  popupMenuItems: [
                    //clear all button
                    PopupMenuItem(
                        onTap: () {
                          if (kIsWeb) {
                            _isButtonPressed = true;
                          }
                          Future.delayed(Duration.zero).then((_) =>
                              //dialog
                              Helper.showAlertDialog(
                                  title: Localization.of(context)
                                      .getString("clear-markers-title"),
                                  content: Localization.of(context)
                                      .getString("clear-markers-content"),
                                  context: context,
                                  actions: [
                                    AlertDialogAction(
                                        Localization.of(context)
                                            .getString("clear-markers-button"),
                                        () {
                                      if (kIsWeb) {
                                        _isButtonPressed = true;
                                      }
                                      Navigator.pop(context);
                                      setState(() {
                                        _latlngs.clear();
                                        _markers.clear();
                                      });
                                    }),
                                    AlertDialogAction(
                                        Localization.of(context)
                                            .getString("cancel"), () {
                                      if (kIsWeb) {
                                        _isButtonPressed = true;
                                      }
                                      Navigator.pop(context);
                                    })
                                  ]));
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
                                Localization.of(context).getString("clear"),
                                style: UI.textStyle(
                                    typeface: UI.headline4,
                                    color: UI.textPrimaryColor(context)),
                              ),
                            ),
                          ],
                        ))
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(24.0),
                  alignment: Alignment.centerRight,
                  child: SafeArea(
                    top: false,
                    child: Column(
                      children: [
                        FadeAnimation(
                          direction: FadeDirection.bottomToTop,
                          delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                          child:
                              //my location button
                              FloatyActionButton(
                            onPressed: () async {
                              if (kIsWeb) {
                                _isButtonPressed = true;
                              }
                              try {
                                await Helper.getUserLocation(context)
                                    .then((value) async {
                                  final controller =
                                      await _mapController.future;
                                  controller.animateCamera(
                                      CameraUpdate.newCameraPosition(
                                          CameraPosition(
                                              target: LatLng(value.latitude,
                                                  value.longitude),
                                              zoom: 18.0)));
                                });
                              } on GPSException catch (e) {
                                Helper.showSnackBar(
                                    message: Text(
                                      Localization.of(context)
                                          .getString(e.message.toString()),
                                      style: UI.textStyle(
                                          typeface: UI.body,
                                          color:
                                              UI.textPrimaryColorDark(context)),
                                    ),
                                    context: context,
                                    snackBarBehavior:
                                        SnackBarBehavior.floating);
                              }
                            },
                            color: UI.buttonPrimaryColor(context),
                            icon: Icon(
                              Icons.my_location_outlined,
                              color: UI.textPrimaryColorDark(context),
                            ),
                            size: FloatyActionButtonSize.SMALL,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: FadeAnimation(
                            direction: FadeDirection.bottomToTop,
                            delay:
                                Duration(milliseconds: 300 * ttbDelayIndex++),
                            child:
                                //satellite mode
                                FloatyActionButton(
                              onPressed: () {
                                if (kIsWeb) {
                                  _isButtonPressed = true;
                                }
                                setState(() {
                                  isSatelliteModeEnabled =
                                      !isSatelliteModeEnabled;
                                });
                              },
                              color: UI.buttonPrimaryColor(context),
                              icon: Icon(
                                isSatelliteModeEnabled
                                    ? Icons.map_outlined
                                    : Icons.satellite_outlined,
                                color: UI.textPrimaryColorDark(context),
                              ),
                              size: FloatyActionButtonSize.SMALL,
                            ),
                          ),
                        ),
                        const Spacer(),
                        FadeAnimation(
                          delay: Duration(milliseconds: 300 * ttbDelayIndex++),
                          direction: FadeDirection.bottomToTop,
                          child:
                              //zoom in
                              FloatyActionButton(
                            onPressed: () async {
                              if (kIsWeb) {
                                _isButtonPressed = true;
                              }
                              final controller = await _mapController.future;
                              controller.animateCamera(CameraUpdate.zoomIn());
                            },
                            color: UI.buttonPrimaryColor(context),
                            icon: Icon(
                              Icons.zoom_in_outlined,
                              color: UI.textPrimaryColorDark(context),
                            ),
                            size: FloatyActionButtonSize.SMALL,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: FadeAnimation(
                            delay:
                                Duration(milliseconds: 300 * ttbDelayIndex++),
                            direction: FadeDirection.bottomToTop,
                            child:
                                //zoom out
                                FloatyActionButton(
                              onPressed: () async {
                                if (kIsWeb) {
                                  _isButtonPressed = true;
                                }
                                final controller = await _mapController.future;
                                controller
                                    .animateCamera(CameraUpdate.zoomOut());
                              },
                              color: UI.buttonPrimaryColor(context),
                              icon: Icon(
                                Icons.zoom_out_outlined,
                                color: UI.textPrimaryColorDark(context),
                              ),
                              size: FloatyActionButtonSize.SMALL,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  void _onMapCreated(GoogleMapController controller) {
    _mapController.complete(controller);
    _setMapStyle();
    if (_latlngs.isNotEmpty) {
      for (int i = 0; i < _latlngs.length; i++) {
        Marker marker = _buildMarker(_latlngs[i], i);
        log("Adding marker: " + marker.markerId.toString());
        _markers.add(marker);
      }
      setState(() {});
      final bounds = Helper.getBounds(_latlngs);
      controller.moveCamera(CameraUpdate.newLatLngBounds(bounds!, 100));
    }
  }

  Future _setMapStyle() async {
    final controller = await _mapController.future;
    controller.setMapStyle(
        WidgetsBinding.instance?.window.platformBrightness == Brightness.light
            ? MapTheme.getInstance().lightStyle
            : MapTheme.getInstance().darkStyle);
  }

  //
  Future<BitmapDescriptor> loadMarkerIcon() async {
    double? dpr = createLocalImageConfiguration(context).devicePixelRatio;

    var folder = "";

    if (dpr != null) {
      if (dpr >= 3.0) {
        folder = "3x/";
      } else if (dpr >= 2.0) {
        folder = "2x/";
      }
    }

    return BitmapDescriptor.fromBytes(await Helper.getBytesFromAsset(
        Helper.isDarkMode(context)
            ? 'assets/resources/${folder}marker-dark.png'
            : 'assets/resources/${folder}marker-light.png',
        56));
  }

  Marker _buildMarker(LatLng latlng, int index) {
    int newIndex = index;
    if (index >= initialMarkers) {
      newIndex = index - initialMarkers;
    }
    return Marker(
        markerId: MarkerId(newIndex.toString()),
        consumeTapEvents: true,
        draggable: true,
        onDragStart: (ltlg) {
          setState(() {
            _latlngs[newIndex] = ltlg;
            latlng = ltlg;
          });
        },
        onDrag: (ltlg) {
          setState(() {
            _latlngs[newIndex] = ltlg;
            latlng = ltlg;
          });
        },
        onDragEnd: (ltlg) {
          setState(() {
            _latlngs[newIndex] = ltlg;
            latlng = ltlg;
          });
        },
        anchor: const Offset(0.5, 0.5),
        icon: kIsWeb
            ? BitmapDescriptor.defaultMarker
            : _markerIcon ?? BitmapDescriptor.defaultMarker,
        position: latlng);
  }
}
