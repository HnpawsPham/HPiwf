// control data routes to display UI
import 'package:flutter/material.dart';

class DataController extends ChangeNotifier {
  static final DataController instance = DataController._internal();
  factory DataController() => instance;
  DataController._internal();

  // weather info
  // Map<String, dynamic> weatherInfo = {
  //   "precipitation": null,
  //   "humid": null,
  //   "air-pressure": null,
  //   "rain-val": null,
  //   "temp": null,
  //   "air-ppm": null,
  //   "noise-delta": null,
  // };

  Map<String, dynamic> weatherInfo = {
    "precipitation": 1009,
    "humid": 0.7,
    "air-pressure": 1024,
    "rain-val": 0,
    "temp": 31,
    "air-ppm": 234,
    "noise-delta": 10,
  };

  // health info
  Map<String, dynamic> healthInfo = {"bpm": 86, "spo2": 94};

  // gps info
  double? lat, lng;

  // notification and warning
  bool? fallDetected, lostDetected;

  // update UI
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
}
