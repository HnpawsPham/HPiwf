import 'package:flutter/material.dart';
import 'package:hpiwf/config.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:intl/intl.dart';
import "../controllers/data-controller.dart";
import "../controllers/ml-controller.dart";

// weather icon map
// ['Rainy' 'Cloudy' 'Sunny' 'Snowy']
final Map<String, String> weatherIcon = {
  "Rainy": "assets/rainy-icon.png",
  "Cloudy": "assets/windy-icon.png",
  "Sunny": "assets/sunny-icon.png",
  "Snowy": "assets/snowy-icon.png",
};

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: ListenableBuilder(
        listenable: DataController.instance,
        builder: (context, child) {
          return Container(
            width: double.infinity,
            child: Column(
              children: [
                Text(
                  "Weather",
                  style: TextStyle(
                    color: colorWhite,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 30),

                Container(
                  width: 120,
                  child: StreamBuilder<String>(
                    stream: MLController.getWeatherTypeStream(),
                    builder: (context, res) {
                      return Image.asset(weatherIcon[res.data ?? "Sunny"]!);
                    },
                  ),
                  // sunny as default
                ),
                Text(
                  DataController.instance.healthInfo["temp"] ?? "NaN",
                  style: TextStyle(
                    fontSize: 50,
                    fontFamily: "cubano",
                    fontWeight: FontWeight.bold,
                    letterSpacing: 3,
                  ),
                ),

                Text(
                  DateFormat("d MMM yyyy").format(DateTime.now()),
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, letterSpacing: 1.2),
                ),

                SizedBox(height: 30),

                Container(
                  margin: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: colorLightBlue,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  width: double.infinity,
                  child: Column(
                    children: [
                      SizedBox(height: 10),

                      StrokeText(
                        text: "TODAY",
                        textStyle: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: colorWhite,
                          fontSize: 30,
                          fontFamily: "cubano",
                        ),
                        strokeColor: colorDarkBlue,
                        textAlign: TextAlign.center,
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),

                        // HUMIDITY BAR
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Humdity",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 10),

                            Expanded(
                              child: LinearProgressIndicator(
                                backgroundColor: colorDarkBlue,
                                color: colorWhite,
                                value: DataController.instance.healthInfo["temp"] ?? 0.0,
                                minHeight: 10,
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),

                            SizedBox(width: 5),

                            Text(
                              "%",
                              style: TextStyle(
                                fontFamily: "cubano",
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // AIR PRESSURE BAR
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              "Pressure",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 30),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorDarkBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: colorBlack, width: 2),
                                ),
                                child: Text(
                                  DataController.instance.healthInfo["air-pressure"] ?? "NaN",
                                  style: TextStyle(fontFamily: "cubano", fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),

                            SizedBox(width: 10),

                            Text("hPa", style: TextStyle(fontFamily: "cubano", fontSize: 20)),
                          ],
                        ),
                      ),

                      // AIR QUALITY BAR
                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // AIR QUALITY
                            Text(
                              "Air quality",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 30),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorDarkBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: colorBlack, width: 2),
                                ),
                                child: StreamBuilder<String>(
                                  stream: MLController.getAirQualityStream(),
                                  builder: (context, res) {
                                    return Text(
                                      res.data ?? "Unknown",
                                      //moderate as default
                                      style: TextStyle(fontFamily: "cubano", fontSize: 20),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Rain level
                            Text(
                              "Rain level",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 30),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorDarkBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: colorBlack, width: 2),
                                ),
                                child: Text(
                                  DataController.instance.getRainLvl(),
                                  style: TextStyle(fontFamily: "cubano", fontSize: 20),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // NOISE LEVEL
                            Text(
                              "Noise level",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),

                            SizedBox(width: 30),

                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: colorDarkBlue,
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(color: colorBlack, width: 2),
                                ),
                                child: StreamBuilder<String>(
                                  stream: MLController.getAirQualityStream(),
                                  builder: (context, res) {
                                    return Text(
                                      DataController.instance.getNoiseLvl(),
                                      style: TextStyle(fontFamily: "cubano", fontSize: 20),
                                      textAlign: TextAlign.center,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 15),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
