import 'package:flutter/material.dart';
import "../../config.dart";
import "../../database/authentication.dart";
import "../../database/database.dart";
import "../../controllers/notification-manager.dart";
import 'package:stroke_text/stroke_text.dart';
import 'package:intl/intl.dart';
import "package:cloud_firestore/cloud_firestore.dart";

class ReminderTab extends StatefulWidget {
  const ReminderTab({super.key});

  @override
  State<ReminderTab> createState() => _ReminderTabState();
}

Map<String, dynamic>? curUserData;

class _ReminderTabState extends State<ReminderTab> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: FirebaseDB.chosenGID,
      builder: (context, curGID, child) {
        if (curGID.isEmpty) return Center(child: Text("You haven't joined a group!"));
        return StreamBuilder(
          stream: FBAuth.authStateChange,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting)
              return const Center(child: CircularProgressIndicator());

            String curUID = snapshot.data!.uid;

            return StreamBuilder<DocumentSnapshot?>(
              stream: FirebaseDB.getUserDataStream(curUID),
              builder: (context, userSnapshot) {
                if (userSnapshot.connectionState == ConnectionState.waiting)
                  return const Center(child: CircularProgressIndicator());

                curUserData = userSnapshot.data!.data() as Map<String, dynamic>?;
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
                              onPressed: () {
                                if (curUserData?["role"] == 0) {
                                  notify(context, "You don't have permission to edit!", 5, 500);
                                  return;
                                }
                                _showInputPopup(context);
                              },
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
              },
            );
          },
        );
      },
    );
  }
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: colorWhite),
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
      if (FirebaseDB.chosenGID == "") return Center(child: Text("You haven't joined a group!"));

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
                      if (curUserData?["role"] == 0) {
                        notify(context, "You don't have permission to edit!", 5, 500);
                        return;
                      }

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
                      if (curUserData?["role"] == 0) {
                        notify(context, "You don't have permission to edit!", 5, 500);
                        return;
                      }
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
                    style: TextStyle(color: colorBlack, fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                    controller: _bedtimeContentController,
                    onSubmitted: (val) {
                      if (curUserData?["role"] == 0) {
                        notify(context, "You don't have permission to edit!", 5, 500);
                        return;
                      }

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
    final formattedTime = DateFormat('hh:mm').format(dt);
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
