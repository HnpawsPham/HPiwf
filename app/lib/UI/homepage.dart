import 'package:flutter/material.dart';
import 'package:hpiwf/UI/setting-page.dart';
import 'package:hpiwf/UI/weather-page.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:stroke_text/stroke_text.dart';
import "../controllers/data-controller.dart";
import "../config.dart";

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Widget> pages = const [DashboardPage(), WeatherPage(), SettingPage()];
  int curPage = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBlack,
      appBar: appBar(),

      body: IndexedStack(index: curPage, children: pages),

      bottomNavigationBar: navBar(),
    );
  }

  SafeArea navBar() {
    return SafeArea(
      child: Container(
        height: 80,
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: colorDarkBlue, borderRadius: BorderRadius.circular(20)),

        child: Row(
          children: [
            createNavItem(Icons.home, "Dashboard", 0),
            createNavItem(Icons.sunny, "Weather", 1),
            createNavItem(Icons.settings, "Setting", 2),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget appBar() {
    return PreferredSize(
      preferredSize: Size.fromHeight(30),
      child: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text("HPiwf", style: TextStyle(color: colorLightBlue, fontSize: 20)),
      ),
    );
  }

  Widget createNavItem(IconData icon, String label, int id) {
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => curPage = id),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: colorWhite, size: 24),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(color: colorWhite, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text("Health Dashboard", style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),

        SizedBox(height: 20),
        Container(
          width: double.infinity,
          margin: EdgeInsets.all(20),
          decoration: BoxDecoration(color: colorLightBlue, borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: Column(
                      children: [
                        Image.asset(
                          "assets/heart-icon.png",
                          width: 100,
                          height: 100,
                          fit: BoxFit.contain,
                        ),
                        Text(
                          "BPM: " + (DataController.instance.healthInfo["bpm"] ?? "NaN").toString(),
                          style: TextStyle(color: colorWhite, fontSize: 20, fontFamily: "cubano"),
                        ),
                      ],
                    ),
                  ),

                  bpmGauge(),
                ],
              ),

              SizedBox(height: 10),

              // bottom row
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      "SPO2: ",
                      style: TextStyle(
                        color: colorWhite,
                        fontFamily: "cubano",
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    SizedBox(width: 5),
                    Expanded(
                      child: LinearProgressIndicator(
                        value: DataController.instance.healthInfo["spo2"] ?? 0.0,
                        minHeight: 10,
                        backgroundColor: colorDarkBlue,
                        color: colorWhite,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      "%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontFamily: "cubano",
                        fontSize: 20,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 10),
            ],
          ),
        ),
      ],
    );
  }

  Expanded bpmGauge() {
    return Expanded(
      child: ClipRRect(
        child: Align(
          alignment: Alignment.center,
          heightFactor: 0.5,
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                minimum: 0,
                maximum: 180,
                showLabels: false,
                canScaleToFit: true,
                startAngle: 180,
                endAngle: 0,

                ranges: <GaugeRange>[
                  GaugeRange(
                    startValue: 0,
                    endValue: 40,
                    color: const Color.fromARGB(255, 127, 147, 180),
                    startWidth: 30,
                    endWidth: 30,
                    label: "Low",
                    labelStyle: GaugeTextStyle(fontFamily: "cubano"),
                  ),
                  GaugeRange(
                    startValue: 40,
                    endValue: 80,
                    color: const Color.fromARGB(255, 175, 204, 234),
                    startWidth: 30,
                    endWidth: 30,
                    label: "Avg",
                    labelStyle: GaugeTextStyle(fontFamily: "cubano"),
                  ),
                  GaugeRange(
                    startValue: 80,
                    endValue: 130,
                    color: colorWhite,
                    startWidth: 30,
                    endWidth: 30,
                    label: "Good",
                    labelStyle: GaugeTextStyle(fontFamily: "cubano"),
                  ),
                  GaugeRange(
                    startValue: 130,
                    endValue: 160,
                    color: const Color.fromARGB(255, 175, 204, 234),
                    startWidth: 30,
                    endWidth: 30,
                    label: "High",
                    labelStyle: GaugeTextStyle(fontFamily: "cubano"),
                  ),
                  GaugeRange(
                    startValue: 160,
                    endValue: 180,
                    color: const Color.fromARGB(255, 127, 147, 180),
                    startWidth: 30,
                    endWidth: 30,
                    label: "!",
                    labelStyle: GaugeTextStyle(fontFamily: "cubano"),
                  ),
                ],
                pointers: <GaugePointer>[
                  NeedlePointer(
                    value: 90,
                    needleColor: colorWhite,
                    needleLength: 0.5,
                    knobStyle: KnobStyle(color: colorWhite, knobRadius: 0.05),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
