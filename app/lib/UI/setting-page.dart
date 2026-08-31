import 'dart:math';
import 'package:hpiwf/UI/login-page.dart';
import '../database/authentication.dart';
import 'package:flutter/material.dart';
import 'package:hpiwf/config.dart';
import 'package:stroke_text/stroke_text.dart';
import 'package:intl/intl.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Text(
            "Setting",
            style: TextStyle(
              color: colorWhite,
              fontSize: 40,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
            textAlign: TextAlign.center,
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 10),
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                indicator: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: colorDarkBlue,
                ),
                indicatorPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                labelColor: colorWhite,
                unselectedLabelColor: colorLightBlue,
                overlayColor: WidgetStateProperty.all(Colors.transparent),
                splashFactory: NoSplash.splashFactory,
                labelStyle: const TextStyle(fontSize: 14, fontFamily: "cubano"),
                tabs: const [
                  Tab(text: "Reminder"),
                  Tab(text: "Geofencing"),
                  Tab(text: "Devices"),
                  Tab(text: "Users"),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                reminderTab(),
                geofencingTab(),
                const Center(child: Text("Reminder")),
                usersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Center usersTab() {
    return Center(
      child: StreamBuilder(
        stream: FBAuth.authStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.hasData) return Center(child: Text("logged in"));

          // if not signed in
          return const LoginPage();
        },
      ),
    );
  }

  Container geofencingTab() {
    return Container(
      padding: const EdgeInsets.all(10),
      child: Center(
        child: Text("COMING SOON", style: TextStyle(fontFamily: "cubano", fontSize: 30)),
      ),
    );
  }

  // SHOW TIME PICKER WITH FORMATED TIME
  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final now = DateTime.now();
      final dt = DateTime(now.year, now.month, now.day, picked.hour, picked.minute);

      // from 0-23 to AM PM
      final formattedTime = DateFormat('h:mm a').format(dt);
      controller.text = formattedTime;
    }
  }

  // ADD NEW MEDICINE REMINDER
  void _showInputPopup(BuildContext context) {
    TextEditingController textController = TextEditingController();
    TextEditingController timePickerController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: colorDarkBlue,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            "New medicine reminder",
            style: TextStyle(color: colorWhite, fontFamily: "cubano"),
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,

            children: [
              TextField(
                controller: textController,
                style: const TextStyle(color: colorWhite),
                decoration: InputDecoration(
                  hintText: "Medicine name",
                  hintStyle: TextStyle(color: colorWhite, fontSize: 18),
                  filled: true,
                  fillColor: colorBlack,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 10),

              TextField(
                controller: timePickerController,
                readOnly: true,
                onTap: () => _selectTime(context, timePickerController),
                decoration: InputDecoration(
                  hintText: "9:00 PM",
                  hintStyle: TextStyle(color: colorWhite),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(color: colorLightBlue, width: 5),
                  ),
                ),
              ),
            ],
          ),

          actions: [
            // Cancel btn
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red, fontFamily: "cubano"),
              ),
            ),

            // Submit btn
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: colorWhite),
              onPressed: () {
                String inpText = textController.text;
                // !!!! save to db sth here
                Navigator.pop(context);
              },
              child: const Text(
                "OK",
                style: TextStyle(color: colorBlack, fontFamily: "cubano", fontSize: 15),
              ),
            ),
          ],
        );
      },
    );
  }

  Padding reminderTab() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              // bedtime section
              bedtimeSection(),
              Positioned(
                top: 0,
                left: 25,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorWhite,
                  ),
                  child: const Text(
                    "Bedtime",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorBlack,
                      fontFamily: "cubano",
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 50),

          // medicine section
          Stack(
            clipBehavior: Clip.none,
            children: [
              medicineSection(),

              // title
              Positioned(
                top: 0,
                left: 25,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: colorWhite,
                  ),
                  child: const Text(
                    "Medicine",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colorBlack,
                      fontFamily: "cubano",
                    ),
                  ),
                ),
              ),

              // add reminder btn
              Positioned(
                top: 0,
                right: 25,
                child: ElevatedButton(
                  onPressed: () => _showInputPopup(context),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size.zero,
                    padding: EdgeInsets.all(0),
                  ),

                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: colorLightBlue,
                    ),
                    child: const Text(
                      "+",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: colorDarkBlue,
                        fontFamily: "cubano",
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Container medicineSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colorDarkBlue),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colorBlack),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  margin: EdgeInsets.only(left: 25),
                  child: Text(
                    "Med name",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),

                SizedBox(
                  width: 120,
                  child: TextField(
                    style: TextStyle(color: colorWhite, fontFamily: "cubano", fontSize: 20),
                    textAlign: TextAlign.center,
                    decoration: InputDecoration(
                      hintText: "9:00 PM",
                      hintStyle: TextStyle(color: colorWhite),
                      filled: true,
                      fillColor: colorBlack,
                      contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CHANGE BEDTIME AND WAKE UP TIME
  final TextEditingController _bedtimeController = TextEditingController(text: "9:00 PM");
  final TextEditingController _wakeTimeController = TextEditingController(text: "7:00 AM");

  Container bedtimeSection() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 15),
      padding: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colorDarkBlue),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              SizedBox(
                width: 120,
                child: TextField(
                  style: TextStyle(color: colorWhite, fontFamily: "cubano", fontSize: 20),
                  textAlign: TextAlign.center,
                  readOnly: true,
                  controller: _bedtimeController,
                  onTap: () => _selectTime(context, _bedtimeController),
                  decoration: InputDecoration(
                    hintText: "9:00 PM",
                    hintStyle: TextStyle(color: colorWhite),
                    filled: true,
                    fillColor: colorBlack,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: 30,
                child: StrokeText(
                  text: "─",
                  textStyle: TextStyle(color: colorWhite, fontFamily: "cubano", fontSize: 30),
                  strokeColor: colorBlack,
                  strokeWidth: 2,
                  textAlign: TextAlign.center,
                ),
              ),

              SizedBox(
                width: 120,
                child: TextField(
                  style: TextStyle(color: colorWhite, fontFamily: "cubano", fontSize: 20),
                  textAlign: TextAlign.center,
                  readOnly: true,
                  controller: _wakeTimeController,
                  onTap: () => _selectTime(context, _wakeTimeController),
                  decoration: InputDecoration(
                    hintText: "7:00 AM",
                    hintStyle: TextStyle(color: colorWhite),
                    filled: true,
                    fillColor: colorBlack,
                    contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 10),

          Row(
            children: [
              Text(
                "Content: ",
                style: TextStyle(fontWeight: FontWeight.bold, color: colorWhite, fontSize: 20),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
