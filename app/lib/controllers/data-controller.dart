// control data routes to display UI
import 'package:flutter/material.dart';
import "../database/database.dart";

class DataController extends ChangeNotifier {
  static final DataController instance = DataController._internal();
  factory DataController() => instance;
  DataController._internal();

  // SETTING VARIABLES
  Map<String, bool> devicesSetting = {
    "USE_WRISTBAND": true,
    "USE_DOOR_DEVICE": true,
    "USE_KITCHEN_DEVICE": true,
    "USE_HOME_STATION": true,
  };

  Map<String, bool> appSetting = {
    "ACCEPT_UPDATE_NOTIFICATIONS": true,
    "ACCEPT_COMPLETION_NOTIFICATIONS": true,
    "ACCEPT_ALERTS": true,
  };

  // CONNECTION INFO
  Map<String, bool> connectionInfo = {
    "home-station": false,
    "kitchen-device": false,
    "home-device": false,
    "wristband": false,
  };

  // weather info
  Map<String, dynamic> weatherInfo = {
    "precipitation": null,
    "humid": null,
    "air-pressure": null,
    "rain-val": null,
    "temp": null,
    "air-ppm": null,
    "noise-delta": null,
  };

  // Map<String, dynamic> weatherInfo = {
  //   "precipitation": 1009,
  //   "humid": 0.7,
  //   "air-pressure": 1024,
  //   "rain-val": 0,
  //   "temp": 31,
  //   "air-ppm": 234,
  //   "noise-delta": 10,
  // };

  // HEALTH INFO
  Map<String, dynamic> healthInfo = {"bpm": 0, "spo2": 0};

  // GPS INFO
  double? lat, lng;

  // NOTIFICATION & WARNING
  bool? fallDetected, lostDetected;

  // UPDATE FUNCS
  void updateWeather(String key, dynamic value) {
    weatherInfo[key] = value;
    notifyListeners();
  }

  void updateHealth(String key, dynamic value) {
    healthInfo[key] = value;
    notifyListeners();
  }

  void updateGps(double? newLat, double? newLng) {
    lat = newLat;
    lng = newLng;
    print("$newLat  $newLng");
    notifyListeners();
  }

  void setFall(bool status) {
    fallDetected = status;
    notifyListeners();
  }

  void setLost(bool status) {
    lostDetected = status;
    notifyListeners();
  }

  // UPDATE SETTINGS
  void updateDevicesSetting(String key, bool val) {
    devicesSetting[key] = val;
    FirebaseDB.updateData("setting", {key: val});
    notifyListeners();
  }

  void updateAppSetting(String key, bool val) {
    appSetting[key] = val;
    notifyListeners();
  }

  // UPDATE DEVICES CONNECTION STATES
  void updateConnectionState(String device, bool state) {
    connectionInfo[device] = state;
    notifyListeners();
  }

  // GET DATA FUNCS
  String getNoiseLvl() {
    final noise = weatherInfo["noise-delta"];
    if (noise == null) return "Unknown";
    if (noise > 1000) return "High";
    if (noise > 600) return "Moderate";
    return "Normal";
  }

  String getRainLvl() {
    final rain = weatherInfo["rain-val"];
    if (rain == null) return "Unknown";
    if (rain > 100) return "Heavy Rain";
    if (rain > 0) return "Light Rain";
    return "Dry";
  }

  // RESET ALL SETTING TO DEFAULT
  void resetSystemSetting() {
    devicesSetting = {
      "USE_WRISTBAND": true,
      "USE_DOOR_DEVICE": true,
      "USE_KITCHEN_DEVICE": true,
      "TAKE_OFF_ALERT": true,
      "USE_HOME_STATION": true,
    };

    appSetting = {
      "ACCEPT_UPDATE_NOTIFICATIONS": true,
      "ACCEPT_COMPLETION_NOTIFICATIONS": true,
      "ACCEPT_ALERTS": true,
    };
    notifyListeners();
  }
}
