import 'dart:math';
import 'package:hpiwf/UI/login-page.dart';
import 'package:hpiwf/controllers/data-controller.dart';
import 'package:hpiwf/controllers/notification-manager.dart';
import 'package:hpiwf/database/database.dart';
import 'package:intl/intl.dart';
import '../database/authentication.dart';
import 'package:flutter/material.dart';
import 'package:hpiwf/config.dart';
import 'package:stroke_text/stroke_text.dart';
import '../database/authentication.dart';

class ControlPage extends StatefulWidget {
  const ControlPage({super.key});

  @override
  State<ControlPage> createState() => _ControlPageState();
}

class _ControlPageState extends State<ControlPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          Text(
            "Control",
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurface,
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
            child: TabBarView(children: [reminderTab(), geofencingTab(), devicesTab(), usersTab()]),
          ),
        ],
      ),
    );
  }

  ListenableBuilder devicesTab() => ListenableBuilder(
    listenable: DataController.instance,
    builder: (context, child) {
      bool TAKE_OFF_ALERT = DataController.instance.systemSetting["TAKE_OFF_ALERT"]!,
          USE_DOOR_DEVICE = DataController.instance.systemSetting["USE_DOOR_DEVICE"]!,
          USE_KITCHEN_DEVICE = DataController.instance.systemSetting["USE_KITCHEN_DEVICE"]!;

      return Column(
        children: [
          Center(
            child: Column(
              children: [
                SizedBox(height: 20),
                Row(
                  children: [
                    SizedBox(width: 20),
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha: DataController.instance.systemSetting["USE_DOOR_DEVICE"] == true
                                ? 1
                                : 0.7,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(height: 10),
                                Image.asset(
                                  "assets/door-icon.png",
                                  width: 40,
                                  color: Theme.of(context).colorScheme.surface,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Door width",
                                  style: TextStyle(
                                    fontFamily: "cubano",
                                    fontSize: 18,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          fillColor: Theme.of(context).colorScheme.surface,
                                          filled: true,
                                          hintText: "50",
                                          hintStyle: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                          contentPadding: EdgeInsets.all(0),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Text(
                                      " - ",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                    ),
                                    Expanded(
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          fillColor: Theme.of(context).colorScheme.surface,
                                          filled: true,
                                          contentPadding: EdgeInsets.all(0),
                                          hintText: "80",
                                          hintStyle: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 5),
                                    Text(
                                      "cm",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "cubano",
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),

                            Positioned(
                              top: 5,
                              left: 5,
                              child: GestureDetector(
                                onTap: () => DataController.instance.updateSetting(
                                  "USE_DOOR_DEVICE",
                                  !DataController.instance.systemSetting["USE_DOOR_DEVICE"]!,
                                ),
                                child: Icon(
                                  Icons.power_settings_new_sharp,
                                  weight: 700,
                                  size: 30,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),

                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 28,
                                height: 15,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    width: 1.5,
                                  ),
                                  color:
                                      (DataController.instance.systemSetting["USE_DOOR_DEVICE"] ==
                                          true
                                      ? const Color.fromARGB(255, 10, 154, 2)
                                      : colorRed),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(width: 20),

                    Expanded(
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: Theme.of(context).colorScheme.onSurface.withValues(
                            alpha:
                                DataController.instance.systemSetting["USE_KITCHEN_DEVICE"] == true
                                ? 1
                                : 0.7,
                          ),
                        ),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                SizedBox(height: 10),
                                Image.asset(
                                  "assets/fire-icon.png",
                                  width: 45,
                                  color: Theme.of(context).colorScheme.surface,
                                  colorBlendMode: BlendMode.srcIn,
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "Alert height",
                                  style: TextStyle(
                                    fontFamily: "cubano",
                                    fontSize: 18,
                                    color: Theme.of(context).colorScheme.surface,
                                  ),
                                ),
                                SizedBox(height: 10),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: TextField(
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          fillColor: Theme.of(context).colorScheme.surface,
                                          filled: true,
                                          contentPadding: EdgeInsets.all(0),
                                          hintText: "200",
                                          hintStyle: TextStyle(
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onSurface.withValues(alpha: 0.7),
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(20),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Text(
                                      "cm",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontFamily: "cubano",
                                        color: Theme.of(context).colorScheme.surface,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                  ],
                                ),
                                SizedBox(height: 10),
                              ],
                            ),
                            Positioned(
                              top: 5,
                              left: 5,
                              child: GestureDetector(
                                onTap: () => DataController.instance.updateSetting(
                                  "USE_KITCHEN_DEVICE",
                                  !DataController.instance.systemSetting["USE_KITCHEN_DEVICE"]!,
                                ),
                                child: Icon(
                                  Icons.power_settings_new_sharp,
                                  weight: 700,
                                  size: 30,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),

                            Positioned(
                              top: 10,
                              right: 10,
                              child: Container(
                                width: 28,
                                height: 15,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Theme.of(context).scaffoldBackgroundColor,
                                    width: 1.5,
                                  ),
                                  color:
                                      (DataController
                                              .instance
                                              .systemSetting["USE_KITCHEN_DEVICE"] ==
                                          true
                                      ? const Color.fromARGB(255, 10, 154, 2)
                                      : colorRed),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                  ],
                ),
              ],
            ),
          ),

          SizedBox(height: 40),

          Row(
            children: [
              SizedBox(width: 22),
              Expanded(
                child: Divider(thickness: 1.5, color: Theme.of(context).colorScheme.onSurface),
              ),
              SizedBox(width: 18),
              Text("Additional", style: TextStyle(fontFamily: "cubano", fontSize: 34)),
              SizedBox(width: 18),
              Expanded(
                child: Divider(thickness: 1.5, color: Theme.of(context).colorScheme.onSurface),
              ),
              SizedBox(width: 22),
            ],
          ),

          SizedBox(height: 30),

          Theme(
            data: Theme.of(context).copyWith(
              switchTheme: SwitchThemeData(
                trackOutlineWidth: WidgetStateProperty.all(1.0),
                trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.surface;
                  }
                  return Theme.of(context).colorScheme.primary;
                }),
              ),
            ),
            child: SwitchListTile(
              activeTrackColor: Theme.of(context).colorScheme.surface,
              activeThumbColor: Theme.of(context).colorScheme.onSurface,

              trackOutlineColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected))
                  return Theme.of(context).colorScheme.onSurface;
                return Theme.of(context).colorScheme.onSurface;
              }),

              title: Text(
                "Use Wristband",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Turn on to use wristband", style: TextStyle(fontSize: 14)),
              secondary: Icon(Icons.watch, size: 30),
              value: TAKE_OFF_ALERT,
              onChanged: (TAKE_OFF_ALERT) {
                setState() => TAKE_OFF_ALERT = !TAKE_OFF_ALERT;
                DataController.instance.updateSetting("TAKE_OFF_ALERT", TAKE_OFF_ALERT);
              },
            ),
          ),

          SizedBox(height: 10),

          Theme(
            data: Theme.of(context).copyWith(
              switchTheme: SwitchThemeData(
                trackOutlineWidth: WidgetStateProperty.all(1.0),
                trackOutlineColor: WidgetStateProperty.resolveWith((states) {
                  if (states.contains(WidgetState.selected)) {
                    return Theme.of(context).colorScheme.surface;
                  }
                  return Theme.of(context).colorScheme.primary;
                }),
              ),
            ),
            child: SwitchListTile(
              activeTrackColor: Theme.of(context).colorScheme.surface,
              activeThumbColor: Theme.of(context).colorScheme.onSurface,

              trackOutlineColor: WidgetStateColor.resolveWith((states) {
                if (states.contains(WidgetState.selected))
                  return Theme.of(context).colorScheme.onSurface;
                return Theme.of(context).colorScheme.onSurface;
              }),

              title: Text(
                "Listen to Home Station",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              subtitle: Text("Turn on to get Home Station's data", style: TextStyle(fontSize: 14)),
              secondary: Icon(Icons.hearing, size: 30),
              value: TAKE_OFF_ALERT,
              onChanged: (TAKE_OFF_ALERT) {
                setState() => TAKE_OFF_ALERT = !TAKE_OFF_ALERT;
                DataController.instance.updateSetting("TAKE_OFF_ALERT", TAKE_OFF_ALERT);
              },
            ),
          ),

          Spacer(),

          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: colorRed,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            ),
            child: Text(
              "Reset to default",
              style: TextStyle(color: Colors.white, fontFamily: "cubano", fontSize: 24),
            ),
          ),
          SizedBox(height: 20),
        ],
      );
    },
  );

  Center usersTab() {
    return Center(
      child: StreamBuilder(
        stream: FBAuth.authStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (snapshot.hasData)
            return Column(
              children: [
                SizedBox(height: 10),
                Stack(
                  children: [
                    Container(
                      width: double.infinity,
                      height: 145,
                      margin: EdgeInsets.only(left: 25, right: 25, top: 80, bottom: 0),
                      padding: EdgeInsets.symmetric(vertical: 40),
                      decoration: BoxDecoration(
                        color: colorDarkBlue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),

                    Positioned(
                      top: 15,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 150,
                          height: 150,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: colorWhite, width: 5),
                            image: const DecorationImage(
                              image: AssetImage("assets/best-avt.jpg"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      bottom: 10,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: StrokeText(
                          text: "Name here",
                          textStyle: TextStyle(
                            fontFamily: "cubano",
                            fontSize: 30,
                            color: colorWhite,
                            fontWeight: FontWeight.bold,
                          ),
                          strokeWidth: 4,
                          strokeColor: colorBlack,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),

                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Image.asset("assets/key-icon.png", width: 40, height: 40),
                      ),
                    ),
                  ],
                ),

                SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                 
                    ],
                  ),
                ),

                Spacer(),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                    backgroundColor: colorRed,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: () => FBAuth.logout(),
                  child: Text(
                    "Logout",
                    style: TextStyle(fontFamily: "cubano", color: Colors.white, fontSize: 25),
                  ),
                ),
                SizedBox(height: 20),
              ],
            );

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
    TextEditingController _textController = TextEditingController();
    TextEditingController _timePickerController = TextEditingController();

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
                controller: _textController,
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
                controller: _timePickerController,
                readOnly: true,
                onTap: () => _selectTime(context, _timePickerController),
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
                String medName = _textController.text.trim();
                String medTime = _timePickerController.text.trim();
                print(medName);

                bool ok = true;
                if (medName.isEmpty) {
                  notify(context, "Medicine name is empty!", 3, 404);
                  ok = false;
                }
                if (medTime.isEmpty) {
                  notify(context, "Please pick a time!", 3, 404);
                  ok = false;
                }

                if (ok) {
                  FirebaseDB.addData("medicine", {"name": medName, "time": medTime});
                  notify(context, "New medicine reminder added", 4, 200);
                  Navigator.pop(context);
                }
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

  Widget medicineSection() {
    return StreamBuilder(
      stream: FirebaseDB.getDBStream("medicine"),
      builder: (context, asyncSnapshot) {
        bool _hasMedicine = true;

        if (asyncSnapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());

        if (!asyncSnapshot.hasData || asyncSnapshot.data!.docs.isEmpty) _hasMedicine = false;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 20),
          padding: const EdgeInsets.only(top: 30, bottom: 20, left: 20, right: 20),
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: colorDarkBlue),
          child: _hasMedicine
              ? ListView.builder(
                  shrinkWrap: true,
                  itemCount: asyncSnapshot.data!.docs.length,
                  itemBuilder: (context, id) {
                    Map<String, dynamic> data =
                        asyncSnapshot.data!.docs[id].data() as Map<String, dynamic>;

                    return Container(
                      margin: EdgeInsets.only(top: 10),

                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: colorBlack,
                      ),
                      child: Flexible(
                        fit: FlexFit.loose,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              margin: EdgeInsets.only(left: 25, top: 8, bottom: 8),
                              child: Text(
                                data["name"],
                                style: TextStyle(
                                  color: colorWhite,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            Container(
                              margin: EdgeInsets.only(right: 25),
                              child: Text(
                                data["time"],
                                style: TextStyle(
                                  color: colorWhite,
                                  fontSize: 20,
                                  fontFamily: "cubano",
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                )
              : Center(
                  child: Text(
                    "No medicine added.",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
        );
      },
    );
  }

  // CHANGE BEDTIME AND WAKE UP TIME
  final TextEditingController _bedtimeController = TextEditingController();
  final TextEditingController _wakeTimeController = TextEditingController();
  final TextEditingController _bedtimeContentController = TextEditingController();

  Widget bedtimeSection() {
    return StreamBuilder(
      stream: FirebaseDB.getDBStream("bedtime"),
      builder: (context, asyncSnapshot) {
        if (asyncSnapshot.hasData && asyncSnapshot.data!.docs.isNotEmpty) {
          Map<String, dynamic> data = asyncSnapshot.data!.docs.first.data() as Map<String, dynamic>;

          if (_bedtimeController.text.isEmpty && data["sleep"] != null)
            _bedtimeController.text = data["sleep"];
          if (_wakeTimeController.text.isEmpty && data["wake"] != null)
            _wakeTimeController.text = data["wake"];
          if (_bedtimeContentController.text.isEmpty && data["content"] != null)
            _bedtimeContentController.text = data["content"];
        }

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
                      onTap: () async {
                        await _selectTime(context, _bedtimeController);

                        String wakeTime = _bedtimeController.text.trim();
                        if (wakeTime.isEmpty) {
                          notify(context, "Please set a time.", 3, 404);
                          return;
                        }

                        FirebaseDB.updateData("bedtime", {"sleep": wakeTime});
                        notify(context, "Bedtime updated", 3, 200);
                      },
                      decoration: InputDecoration(
                        hintText: "9:00 PM",
                        hintStyle: TextStyle(color: colorWhite.withValues(alpha: 0.5)),
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
                      onTap: () async {
                        await _selectTime(context, _wakeTimeController);

                        String wakeTime = _wakeTimeController.text.trim();
                        if (wakeTime.isEmpty) {
                          notify(context, "Please set a time.", 3, 404);
                          return;
                        }

                        FirebaseDB.updateData("bedtime", {"wake": wakeTime});
                        notify(context, "Wake time updated", 3, 200);
                      },
                      decoration: InputDecoration(
                        hintText: "7:00 AM",
                        hintStyle: TextStyle(color: colorWhite.withValues(alpha: 0.5)),
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

              SizedBox(height: 15),

              Row(
                children: [
                  Text(
                    "Content: ",
                    style: TextStyle(color: colorWhite, fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      style: TextStyle(
                        color: colorBlack,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      controller: _bedtimeContentController,
                      onSubmitted: (val) {
                        String content = _bedtimeContentController.text.trim();
                        if (content.isNotEmpty) {
                          FirebaseDB.updateData("bedtime", {"content": content});
                          notify(context, "Bedtime content changed", 3, 200);
                        }
                      },
                      decoration: InputDecoration(
                        hintText: "It's time to go to sleep zzz",
                        hintStyle: TextStyle(color: colorBlack.withValues(alpha: 0.5)),
                        filled: true,
                        isDense: true,
                        fillColor: colorWhite,
                        contentPadding: EdgeInsets.symmetric(vertical: 5),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
