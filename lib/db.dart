import 'package:flutter/material.dart';
import 'package:leaf_03/miscellaneous/helper.dart';

class Credentials {
  final String email;
  final String password;

  Credentials(this.email, this.password);
}

class User {
  final int userId;
  final String firstName;
  final String lastName;

  User(this.userId, this.firstName, this.lastName);
}

class Farm {
  final int farmId;
  final String farmName;
  final String cropId;
  final DateTime firstCultivation;

  Farm(this.farmId, this.farmName, this.cropId, this.firstCultivation);
}

class Crop {
  final String name;
  final String type;

  Crop({required this.name, required this.type});

  static Crop empty = Crop(name: "crop-empty", type: "crop-type-empty");
}

// Just something I learned from Java...
class CropLoader {
  late Map<String, Crop>? _crops;

  static CropLoader? _instance;

  // Private constructor
  CropLoader._() {
    _instance = this;
  }

  void loadCropList(BuildContext context) {
    Helper.loadCropsFromJSON(context).then((value) => _crops = value);
  }

  List<Crop>? getCropsList() {
    if (_crops == null) return null;
    return _crops!.entries.map((e) => e.value).toList();
  }

  Crop? getCropFromId(String id) {
    if (_crops == null) return null;
    return _crops![id];
  }

  static CropLoader getInstance() {
    if (_instance == null) {
      return CropLoader._();
    }
    return _instance!;
  }
}
