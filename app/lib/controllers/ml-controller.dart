import 'package:flutter_onnxruntime/flutter_onnxruntime.dart';
import 'package:flutter/services.dart';
import "data-controller.dart";
import 'dart:convert';

class MLController {
  static final MLController _instance = MLController._internal();
  factory MLController() => _instance;
  MLController._internal();

  static final ort = OnnxRuntime();
  static late final OrtSession _weatherTypeSession;
  static late final OrtSession _airQualitySession;
  static late final Map<String, dynamic> _weatherTypeLe;
  static late final Map<String, dynamic> _airQualityLe;

  static Future<void> init() async {
    _weatherTypeSession = await ort.createSessionFromAsset(
      'assets/ML-models/weather-type-model.onnx',
    );
    _airQualitySession = await ort.createSessionFromAsset(
      'assets/ML-models/air-quality-model.onnx',
    );

    _weatherTypeLe = jsonDecode(
      await rootBundle.loadString('assets/ML-models/weather-type-le.json'),
    );
    _airQualityLe = jsonDecode(
      await rootBundle.loadString('assets/ML-models/air-quality-label.json'),
    );
  }

  // WEATHER TYPE PREDICT HANDLE
  static Future<String> predictWeatherType() async {
    print("weather ML filed loaded");

    // check if all inputs valid
    if (DataController.instance.weatherInfo["precipitation"] == null ||
        DataController.instance.weatherInfo["temp"] == null ||
        DataController.instance.weatherInfo["humid"] == null ||
        DataController.instance.weatherInfo["air-pressure"] == null) {
      print("default result: sunny");
      return "Sunny"; // as default
    }

    // convert months to input shape
    final month = DateTime.now().month;
    double spring = 0.0, summer = 0.0, autumn = 0.0, winter = 0.0;

    if (month >= 3 && month <= 5)
      spring = 0.1;
    else if (month >= 6 && month <= 8)
      summer = 0.1;
    else if (month >= 9 && month <= 11)
      autumn = 0.1;
    else
      winter = 0.1;

    final inputs = await OrtValue.fromList(
      [
        (DataController.instance.weatherInfo["precipitation"] as num).toDouble(),
        (DataController.instance.weatherInfo["temp"] as num).toDouble(),
        (DataController.instance.weatherInfo["humid"] as num).toDouble(),
        (DataController.instance.weatherInfo["air-pressure"] as num).toDouble(),
        autumn,
        spring,
        summer,
        winter,
      ],
      [1, 8],
    );

    final inp = _weatherTypeSession.inputNames[0];
    final out = _weatherTypeSession.outputNames[0];
    final outputs = await _weatherTypeSession.run(<String, OrtValue>{inp: inputs});

    final res = await outputs[out]!.asList();
    print("weather ok");
    inputs.dispose();
    for (final tensor in outputs.values) tensor.dispose();

    print(_weatherTypeLe[res.first] ?? "Sunny");
    return _weatherTypeLe[res.first] ?? "Sunny";
  }

  static Stream<String> getWeatherTypeStream() async* {
    while (true) {
      String result = await predictWeatherType();
      yield result;
      await Future.delayed(const Duration(seconds: 60));
    }
  }

  // AIR QUALITY PREDICT HANDLE
  static Future<String> predictAirQuality() async {
    print("air ML files loaded");

    // check if all inputs valid
    if (DataController.instance.weatherInfo["temp"] == null ||
        DataController.instance.weatherInfo["air-ppm"] == null ||
        DataController.instance.weatherInfo["humid"] == null)
      return "Unknown"; // as default

    final inputs = await OrtValue.fromList(
      [
        (DataController.instance.weatherInfo["temp"] as num).toDouble(),
        (DataController.instance.weatherInfo["humid"] as num).toDouble(),
        (DataController.instance.weatherInfo["air-ppm"] as num).toDouble(),
      ],
      [1, 3],
    );

    final inp = _airQualitySession.inputNames[0];
    final out = _airQualitySession.outputNames[0];
    final outputs = await _airQualitySession.run({inp: inputs});
    print("air ok");
    final res = await outputs[out]!.asList();

    inputs.dispose();
    for (final tensor in outputs.values) tensor.dispose();

    return _airQualityLe[res.first] ?? "Unknown";
  }

  static Stream<String> getAirQualityStream() async* {
    while (true) {
      String result = await predictAirQuality();
      yield result;
      await Future.delayed(const Duration(seconds: 60));
    }
  }
}
