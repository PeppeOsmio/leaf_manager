import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:leaf_03/db.dart';
import 'dart:convert';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:core';

import 'package:leaf_03/exceptions.dart';

class AlertDialogAction {
  final String title;
  final VoidCallback onPressed;

  AlertDialogAction(this.title, this.onPressed);
}

class Helper {
  static bool isDarkMode(BuildContext context) {
    final brightness = MediaQuery.of(context).platformBrightness;
    return brightness == Brightness.dark;
  }

  static void showSnackBar(
      {required Widget message,
      required BuildContext context,
      Duration duration = const Duration(milliseconds: 3000),
      SnackBarBehavior snackBarBehavior = SnackBarBehavior.fixed,
      SnackBarAction? action}) {
    SnackBar snackBar = SnackBar(
      duration: duration,
      content: message,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      behavior: snackBarBehavior,
      action: action,
    );
    try {
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      return;
    }
  }

  static void showAlertDialog(
      {required BuildContext context,
      String? title,
      String? content,
      required List<AlertDialogAction> actions}) {
    if (!kIsWeb && Platform.isIOS) {
      showCupertinoDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return CupertinoAlertDialog(
            title: title != null ? Text(title) : null,
            content: content != null ? Text(content) : null,
            actions: actions
                .map((e) => CupertinoDialogAction(
                      child: Text(e.title),
                      onPressed: e.onPressed,
                    ))
                .toList(),
          );
        },
      );
    } else {
      showDialog(
        useRootNavigator: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            title: title != null ? Text(title) : null,
            content: content != null ? Text(content) : null,
            actions: actions
                .map((e) => ElevatedButton(
                      child: Text(e.title),
                      onPressed: e.onPressed,
                    ))
                .toList(),
          );
        },
      );
    }
  }

  static Future<Credentials?> loadUserCredentials() async {

    if(kIsWeb){
      return null;
    }

    const storage = FlutterSecureStorage();

    final String? email = await storage.read(key: "email");
    final String? password = await storage.read(key: "password");

    if (email != null && isEmailValid(email) && password != null) {
      return Credentials(email, password);
    }
    return null;
  }

  static Future<void> writeUserCredentials(Credentials credentials) async {
    const storage = FlutterSecureStorage();
    storage.write(key: "email", value: credentials.email);
    storage.write(key: "password", value: credentials.password);
  }

  static Future deleteUserCredentials() async{
    const storage = FlutterSecureStorage();
    storage.delete(key: "email");
    storage.delete(key: "password");
  }

  static Future<Uint8List> getBytesFromAsset(String path, int width) async {
    ByteData data = await rootBundle.load(path);
    ui.Codec codec = await ui.instantiateImageCodec(data.buffer.asUint8List(),
        targetWidth: width);
    ui.FrameInfo fi = await codec.getNextFrame();
    return (await fi.image.toByteData(format: ui.ImageByteFormat.png))!
        .buffer
        .asUint8List();
  }

  static Future<User> register2(
      String firstName, String lastName, String email, String password) async {
    if (firstName.isEmpty) throw RegisterException("invalid-first-name");
    if (lastName.isEmpty) throw RegisterException("invalid-last-name");
    if (email.isEmpty || !Helper.isEmailValid(email)) {
      throw RegisterException("invalid-email");
    }
    if (password.isEmpty) throw RegisterException("invalid-password");

    http.Response response = await http.post(
        Uri.parse("https://www.emanuelefrascella.it/php/register.php"),
        body: {
          "userEmail": email,
          "firstName": firstName,
          "lastName": lastName,
          "password": password
        });

    late Map map;

    try {
      map = jsonDecode(response.body);
    } catch (error) {
      throw const FormatException();
    }

    if (map["message"] == "success") {
      return User(int.parse(map["id"]), firstName, lastName);
    } else if (map["message"] == "email_exists") {
      throw RegisterException("email-exists");
    } else {
      throw RegisterException("generic-error-message");
    }
  }

  static Future<User> login2(String email, String password) async {
    if (email.isEmpty || !Helper.isEmailValid(email)) {
      throw LoginException("invalid-email");
    }
    if (password.isEmpty) throw LoginException("invalid-password");

    http.Response response = await http.post(
        Uri.parse("https://www.emanuelefrascella.it/php/login.php"),
        body: {"userEmail": email, "password": password});

    Map map;
    try {
      map = jsonDecode(response.body);
    } catch (error) {
      throw LoginException("server-error");
    }

    if (map["message"] == "success") {
      return User(int.parse(map["id"]), map["firstName"], map["lastName"]);
    } else if (map["message"] == "wrong_credentials") {
      throw LoginException("wrong-credentials");
    } else {
      throw LoginException("server-error");
    }
  }

  static bool isEmailValid(String email) {
    return RegExp(
            r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,253}[a-zA-Z0-9])?)*$")
        .hasMatch(email);
  }

  static List<bool> isPasswordValid(String password) {
    return [
      password.length > 7,
      RegExp(r"^(?=.*[a-z])(?=.*[A-Z])").hasMatch(password),
      RegExp(r"(?=.*[0-9])|(?=.*[@$!%*#?&])").hasMatch(password)
    ];
  }

  static Future<Map<String, Crop>> loadCropsFromJSON(
      BuildContext context) async {
    final String response =
        await DefaultAssetBundle.of(context).loadString('assets/crops.json');
    final data = await json.decode(response);

    Map<String, Crop> map = {};

    for (var value in data["crops"]) {
      map[value["name"]] = Crop(name: value["name"], type: value["type"]);
    }

    return map;
  }

  static const CameraPosition polibaInitialCameraPosition = CameraPosition(
      target: LatLng(41.10882192968079, 16.878706819303783),
      zoom: 16.5); // PoliBa's coords

  static LatLngBounds? getBounds(List<LatLng> list) {
    if (list.isEmpty) {
      return null;
    }

    double latMin = list[0].latitude, latMax = list[0].latitude;
    double lonMin = list[0].longitude, lonMax = list[0].longitude;

    for (LatLng latlng in list) {
      if (latlng.latitude < latMin) {
        latMin = latlng.latitude;
      } else if (latlng.latitude > latMax) {
        latMax = latlng.latitude;
      }

      if (latlng.longitude < lonMin) {
        lonMin = latlng.longitude;
      } else if (latlng.longitude > lonMax) {
        lonMax = latlng.longitude;
      }
    }

    final LatLngBounds bounds = LatLngBounds(
        northeast: LatLng(latMax, lonMax), southwest: LatLng(latMin, lonMin));

    return bounds;
  }

  static LatLng getBoundsCenter(LatLngBounds? bounds) {
    if (bounds == null) return polibaInitialCameraPosition.target;
    return LatLng((bounds.northeast.latitude + bounds.southwest.latitude) / 2,
        (bounds.northeast.longitude + bounds.southwest.longitude) / 2);
  }

  static Future<double> zoomToFit(
      GoogleMapController controller, LatLngBounds? bounds) async {
    if (bounds == null) {
      await controller.moveCamera(
          CameraUpdate.newCameraPosition(polibaInitialCameraPosition));
      return polibaInitialCameraPosition.zoom;
    }

    bool fits = false;
    final LatLng center = getBoundsCenter(bounds);
    await controller.moveCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: center, zoom: 18.0)));
    while (!fits) {
      await controller.getVisibleRegion().then((value) {
        if (_fits(bounds, value)) {
          fits = true;
        } else {
          controller.moveCamera(CameraUpdate.zoomBy(-0.25));
        }
      });
    }

    return controller.getZoomLevel();
  }

  static bool _fits(LatLngBounds bounds, LatLngBounds screenBounds) {
    return screenBounds.contains(bounds.northeast) &&
        screenBounds.contains(bounds.southwest);
  }

  static Future<Position> getUserLocation(BuildContext context) async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      throw GPSException(message: "gps-disabled");
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        throw GPSException(message: "gps-permission-denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      throw GPSException(message: "gps-permission-perm-denied");
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }

  // TODO: Add throw statements.
  static Future<List<Farm>> loadFarmsFromDB(
      int userId, BuildContext context) async {
    List<Farm> lands = [];

    late http.Response response;

    response = await http.post(
        Uri.parse("https://www.emanuelefrascella.it/php/getlandsids.php"),
        body: {"userId": userId.toString()});

    List landIds = jsonDecode(response.body);

    for (int i = 0; i < landIds.length; i++) {
      response = await http.post(
          Uri.parse("https://www.emanuelefrascella.it/php/getlanddetails.php"),
          body: {"userId": userId.toString(), "landId": landIds[i]["landId"]});
      if (response.statusCode != 200) {
        return Future.error("error");
      }
      List details = jsonDecode(response.body);
      lands.add(Farm(
        int.parse(landIds[i]['landId']),
        details[0]['name'],
        details[0]['fk_cropName'],
        DateTime.parse(details[0]['dateFirstCultivation']),
      ));
    }
    return lands;
    /*try {
      response = await http.post(
          Uri.parse("https://www.emanuelefrascella.it/php/getlandsids.php"),
          body: {"userId": userId});

      List landIds = jsonDecode(response.body);

      for (int i = 0; i < landIds.length; i++) {
        response = await http.post(
            Uri.parse(
                "https://www.emanuelefrascella.it/php/getlanddetails.php"),
            body: {"userId": userId, "landId": landIds[i]["landId"]});
        if (response.statusCode != 200) {
          return Future.error("error");
        }
        List details = jsonDecode(response.body);
        lands.add(Farm(
          int.parse(landIds[i]['landId']),
          details[0]['name'],
          details[0]['crop'],
          DateTime.parse(details[0]['dateFirstCultivation']),
        ));
      }
      return lands;
    } catch (error) {
      if (error is SocketException) {
        return Future.error("network_error");
      } else if (error is TimeoutException) {
        return Future.error("connection_timeout");
      } else if (error is http.ClientException) {
        return Future.error("client_exception");
      } else {
        return Future.error("error");
      }
    }*/
  }

  static Future editLand(int userId, int landId, List<LatLng> coords) async{
    var response = await http.post(
      Uri.parse("https://www.emanuelefrascella.it/php/edit.php"), 
      body: {
        "userId": userId.toString(),
        "landId": landId.toString(),
        "coords": CoordsHelper.encodeCoords(coords)
      }
    );
    print("editLand: " + response.body);
  }

  static Future deleteLand(int landId) async {
    var response = await http.post(
        Uri.parse("https://www.emanuelefrascella.it/php/deleteland.php"),
        body: {
          "landId": landId.toString(),
        });
    if (response.statusCode == 200) {
      if (response.body == "success") {
        return;
      } else {
        throw LandCreationException(message: "generic-error-message");
      }
    }
  }

  static Future addLand(
      {List<LatLng>? coords,
      String? landName,
      String? cropName,
      String? date,
      int? userId,
      required BuildContext context}) async {
    if (landName == null || landName.isEmpty) {
      throw LandCreationException(message: "empty-land-name");
    } else if (date == null || date.isEmpty) {
      throw LandCreationException(message: "empty-date");
    } else if (cropName == null || cropName.isEmpty) {
      throw LandCreationException(message: "empty-crop-id");
    } else if (coords == null || coords.isEmpty) {
      throw LandCreationException(message: "empty-latlngs");
    }

    late http.Response response;

    String latlngString = CoordsHelper.encodeCoords(coords);
    response = await http.post(
        Uri.parse('https://www.emanuelefrascella.it/php/createland.php'),
        body: {
          'name': landName,
          'cropName': cropName,
          'dateFirstCultivation': date,
          "userId": userId.toString(),
          "coords": latlngString
        }).timeout(const Duration(seconds: 20));

    if (!(response.statusCode == 200)) {
      throw LandCreationException(message: "general-error-message");
    } else {
      if (response.body == "land_name_exists") {
        throw LandCreationException(message: "land-name-exists");
      } else if (response.body != "") {
        throw LandCreationException(message: "general-error-message");
      }
    }
  }

  static Future<List<LatLng>> getLandCoordinates(
      int landId, BuildContext context) async {
    List<LatLng> coordinates = [];

    var response = await http.post(
        Uri.parse(
            'https://www.emanuelefrascella.it/php/getlandcoordinates.php'),
        body: {"landId": landId.toString()});
    Map<String, dynamic> map = jsonDecode(response.body);
    String stringCoords = map["markers"];
    if (response.statusCode != 200) {
      throw Exception("general-error-message");
    }

    coordinates = CoordsHelper.parseCoords(stringCoords);

    return coordinates;
  }
}

class CoordsHelper {
  static const double EARTH_RADIUS = 6371009.0; // Meters

  static String encodeCoords(List<LatLng> latlngs) {
    String stringCoords = "";
    for (int i = 0; i < latlngs.length; i++) {
      String lat = latlngs[i].latitude.toStringAsFixed(8);
      String lng = latlngs[i].longitude.toStringAsFixed(8);
      stringCoords += "{$lat;$lng}";
    }
    return stringCoords;
  }

  static List<LatLng> parseCoords(String latlngString) {
    List<double> lat = [];
    List<double> lng = [];
    List<LatLng> coords = [];

    for (int i = 0; i < latlngString.length; i++) {
      if (latlngString[i] == "{") {
        int j = 0;
        String temp = "";
        for (j = i + 1; latlngString[j] != ";"; j++) {
          temp += latlngString[j];
        }
        lat.add(double.parse(temp));
        i = j;
        temp = "";
        for (j = i + 1; latlngString[j] != "}"; j++) {
          temp += latlngString[j];
        }
        lng.add(double.parse(temp));
        i = j;
      }
    }

    for (int i = 0; i < lng.length; i++) {
      coords.add(LatLng(lat[i], lng[i]));
    }

    return coords;
  }

  static List<List<double>> _getCoordinatesMatrix(List<LatLng> list) {
    List<List<double>> matrix = [];
    for (int i = 0; i < list.length; i++) {
      double latRad = list[i].latitude * pi / 180; //latitude in radians
      double lngRad = list[i].longitude * pi / 180; //longitude in radians
      //x = latRad * R
      //y = lngRad * R *cos(latRad)
      List<double> temp = [];
      temp.add(
          EARTH_RADIUS * latRad); //length of latitude in meters (y coordinate)
      temp.add(EARTH_RADIUS *
          lngRad *
          cos(latRad)); //length of longitude in meters (x coordinate)
      matrix.add(temp);
    }
    return matrix;
  }

  static double getPolygonArea(List<LatLng> list) {
    double area = 0.0;

    var matrix = _getCoordinatesMatrix(list);

    for (int i = 0; i < list.length - 1; i++) {
      double xi = matrix[i][0];
      double yi = matrix[i][1];
      double xiplus1 = matrix[i + 1][0];
      double yiplus1 = matrix[i + 1][1];

      area += 0.5 * (yiplus1 * xi - yi * xiplus1);
      //https://en.wikipedia.org/wiki/Shoelace_formula if you don't trust me
    } // area = 0.5 * sum of |x(i)   y(i)  | for 0<=i<=n-1, where n is the number of verteces
    //                       |x(i+1) y(i+1)| and instead of x(n) and y(n) we mean x(0) and y(0)
    //                                       because the verteces are n-1s

    double x0 = matrix[0][0];
    double y0 = matrix[0][1];
    double xnminus1 = matrix[list.length - 1][0];
    double ynminus1 = matrix[list.length - 1][1];

    area += 0.5 * (xnminus1 * y0 - x0 * ynminus1);
    // we have to add  0.5 * |x(n-1) y(n-1)| to the area, and we can do it only after the for
    //                       |x(0)   y(0)  |

    area = (area / 10000).abs(); //convert to hectares

    return area;
  }

  static double getPolygonPerimeter(List<LatLng> list) {
    double perimeter = 0.0;

    var matrix = _getCoordinatesMatrix(list);

    //calculate the perimeter
    for (int i = 0; i < list.length - 1; i++) {
      double xi = matrix[i][0];
      double yi = matrix[i][1];
      double xiplus1 = matrix[i + 1][0];
      double yiplus1 = matrix[i + 1][1];
      perimeter += sqrt(pow((xi - xiplus1), 2) +
          pow((yi - yiplus1),
              2)); //distance between 2 points known their coordinates
    }

    double x0 = matrix[0][0];
    double y0 = matrix[0][1];
    double xnminus1 = matrix[list.length - 1][0];
    double ynminus1 = matrix[list.length - 1][1];

    perimeter += sqrt(pow((x0 - xnminus1), 2) +
        pow((y0 - ynminus1),
            2)); // we add the distance between last vertex and first vertex

    return perimeter;
  }
}

class MapTheme {
  static MapTheme? _instance;

  late String lightStyle, darkStyle;

  // Private constructor
  MapTheme._() {
    _instance = this;
  }

  void loadMapStyles(BuildContext context) async {
    lightStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style_light.json');
    darkStyle = await DefaultAssetBundle.of(context)
        .loadString('assets/map_style_dark.json');
  }

  String getLightStyle() {
    return lightStyle;
  }

  String getDarkStyle() {
    return darkStyle;
  }

  static MapTheme getInstance() {
    if (_instance == null) {
      return MapTheme._();
    }
    return _instance!;
  }
}

extension IndexedIterable<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(E e, int i) f) {
    var i = 0;
    return map((e) => f(e, i++));
  }
}
