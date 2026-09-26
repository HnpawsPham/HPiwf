// control data routes to display UI
import 'package:flutter/material.dart';
import "../database/database.dart";
import "notification-manager.dart";
import 'package:shared_preferences/shared_preferences.dart';

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
  //   "humid": 0.8,
  //   "air-pressure": 1024,
  //   "rain-val": 1243,
  //   "temp": 31,
  //   "air-ppm": 10000,
  //   "noise-delta": 1340,
  // };

  // HEALTH INFO
  Map<String, dynamic> healthInfo = {"bpm": 0, "spo2": 0};

  // GPS INFO
  double? lat, lng;

  // NOTIFICATION & WARNING
  bool? fallDetected, lostDetected, takenOffDetected;

  // UPDATE FUNCS
  void updateWeather(String key, dynamic value) {
    weatherInfo[key] = value;
    notifyListeners();
  }

  void updateHealth(String key, dynamic value) {
    healthInfo[key] = value;

    if (key == "bpm") {
      if (value > 0 && value < 40)
        LocalNoticeService.showNotification(
          title: "HEALTH WARNING!",
          body: "Low beats per minutue detected: $value",
        );
      else if (value > 130)
        LocalNoticeService.showNotification(
          title: "HEALTH WARNING!",
          body: "High beats per minutue detected: $value",
        );
    } else if (key == "spo2") {
      if (value == 0)
        LocalNoticeService.showNotification(
          title: "HEALTH WARNING!",
          body: "SpO2 level is 0%. Potential taking off wristband",
        );
      else if (value < 95)
        LocalNoticeService.showNotification(
          title: "HEALTH WARNING!",
          body: "SpO2 level is low: $value%",
        );
    }
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

  void setTakeOff(bool status) {
    takenOffDetected = status;
    notifyListeners();
  }

  // UPDATE SETTINGS
  void updateDevicesSetting(String key, bool val) {
    devicesSetting[key] = val;
    FirebaseDB.updateData("setting", {key: val});
    notifyListeners();
  }

  Future<void> updateAppSetting(String key, bool val) async {
    appSetting[key] = val;
    notifyListeners();

    final pref = await SharedPreferences.getInstance();
    await pref.setBool(key, val);
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
    if (noise > 1000) {
      LocalNoticeService.showNotification(
        title: "Bad condition",
        body: "It's abnormally loud outside",
      );
      return "High";
    }
    if (noise > 600) return "Moderate";
    return "Normal";
  }

  String getRainLvl() {
    int? rain = weatherInfo["rain-val"];
    if (rain == null) return "Unknown";

    rain = 4095 - rain;
    if (rain > 1000) {
      LocalNoticeService.showNotification(title: "Bad weather", body: "It's heavy rain outside");
      return "Heavy Rain";
    }
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

  // SAVE USER NOTIFICATION PREFERENCES
  Future<void> loadSettings() async {
    final pref = await SharedPreferences.getInstance();

    appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] =
        pref.getBool("ACCEPT_UPDATE_NOTIFICATIONS") ?? true;
    appSetting["ACCEPT_COMPLETION_NOTIFICATIONS"] =
        pref.getBool("ACCEPT_COMPLETION_NOTIFICATIONS") ?? true;
    appSetting["ACCEPT_ALERTS"] = pref.getBool("ACCEPT_ALERTS") ?? true;
  }
}
