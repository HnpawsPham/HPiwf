import 'package:flutter/material.dart';
import 'package:hpiwf/controllers/data-controller.dart';
import 'package:hpiwf/controllers/notification-manager.dart';
import 'package:hpiwf/config.dart';
import 'package:hpiwf/database/authentication.dart';
import 'package:hpiwf/database/database.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'package:flutter/services.dart';

class DevicesTab extends StatefulWidget {
  const DevicesTab({super.key});

  @override
  State<DevicesTab> createState() => _DevicesTabState();
}

class _DevicesTabState extends State<DevicesTab> {
  final TextEditingController _fireHeightController = TextEditingController();
  final TextEditingController _doorWidthMinController = TextEditingController();
  final TextEditingController _doorWidthMaxController = TextEditingController();

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

                Map<String, dynamic>? curUserData =
                    userSnapshot.data!.data() as Map<String, dynamic>?;

                return ListenableBuilder(
                  listenable: DataController.instance,
                  builder: (context, child) {
                    bool
                    USE_WRISTBAND = DataController.instance.devicesSetting["USE_WRISTBAND"]!,
                    USE_HOME_STATION = DataController.instance.devicesSetting["USE_HOME_STATION"]!,
                    USE_DOOR_DEVICE = DataController.instance.devicesSetting["USE_DOOR_DEVICE"]!,
                    USE_KITCHEN_DEVICE =
                        DataController.instance.devicesSetting["USE_KITCHEN_DEVICE"]!;

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
                                          alpha:
                                              DataController
                                                      .instance
                                                      .devicesSetting["USE_DOOR_DEVICE"] ==
                                                  true
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
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.digitsOnly,
                                                      ],
                                                      controller: _doorWidthMinController,
                                                      onSubmitted: (value) {
                                                        if (!checkPermission(curUserData)) {
                                                          notify(
                                                            context,
                                                            "You don't have permission to edit!",
                                                            5,
                                                            500,
                                                          );
                                                          return;
                                                        }

                                                        int? doorMin = int.tryParse(
                                                          _doorWidthMinController.text.trim(),
                                                        );

                                                        FirebaseDB.updateData("setting", {
                                                          "door-width-min": doorMin,
                                                        });

                                                        if (DataController
                                                                .instance
                                                                .appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                                                            true)
                                                          LocalNoticeService.showNotification(
                                                            title: "Device settings changed",
                                                            body:
                                                                "Door width min is set to $doorMin",
                                                          );
                                                      },
                                                      textAlign: TextAlign.center,
                                                      decoration: InputDecoration(
                                                        fillColor: Theme.of(
                                                          context,
                                                        ).colorScheme.surface,
                                                        filled: true,
                                                        hintText: "50",
                                                        hintStyle: TextStyle(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(alpha: 0.7),
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
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.digitsOnly,
                                                      ],
                                                      controller: _doorWidthMaxController,
                                                      onSubmitted: (_) {
                                                        if (!checkPermission(curUserData)) {
                                                          notify(
                                                            context,
                                                            "You don't have permission to edit!",
                                                            5,
                                                            500,
                                                          );
                                                          return;
                                                        }
                                                        int? doorMax = int.tryParse(
                                                          _doorWidthMaxController.text.trim(),
                                                        );

                                                        FirebaseDB.updateData("setting", {
                                                          "door-width-max": doorMax,
                                                        });

                                                        if (DataController
                                                                .instance
                                                                .appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                                                            true)
                                                          LocalNoticeService.showNotification(
                                                            title: "Device settings changed",
                                                            body:
                                                                "Door width max is set to $doorMax",
                                                          );
                                                      },

                                                      textAlign: TextAlign.center,
                                                      decoration: InputDecoration(
                                                        fillColor: Theme.of(
                                                          context,
                                                        ).colorScheme.surface,
                                                        filled: true,
                                                        contentPadding: EdgeInsets.all(0),
                                                        hintText: "80",
                                                        hintStyle: TextStyle(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(alpha: 0.7),
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
                                              onTap: () {
                                                if (!checkPermission(curUserData)) {
                                                  notify(
                                                    context,
                                                    "You don't have permission to edit!",
                                                    5,
                                                    500,
                                                  );
                                                  return;
                                                }

                                                DataController.instance.updateDevicesSetting(
                                                  "USE_DOOR_DEVICE",
                                                  !DataController
                                                      .instance
                                                      .devicesSetting["USE_DOOR_DEVICE"]!,
                                                );
                                                if (DataController
                                                        .instance
                                                        .appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                                                    true)
                                                  LocalNoticeService.showNotification(
                                                    title: "Device settings changed",
                                                    body:
                                                        "Door device usage is set to ${DataController.instance.devicesSetting["USE_DOOR_DEVICE"]! ? "ON" : "OFF"}",
                                                  );
                                              },
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
                                                            .devicesSetting["USE_DOOR_DEVICE"] ==
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
                                              DataController
                                                      .instance
                                                      .devicesSetting["USE_KITCHEN_DEVICE"] ==
                                                  true
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
                                                      keyboardType: TextInputType.number,
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter.digitsOnly,
                                                      ],
                                                      controller: _fireHeightController,
                                                      onSubmitted: (_) {
                                                        if (!checkPermission(curUserData)) {
                                                          notify(
                                                            context,
                                                            "You don't have permission to edit!",
                                                            5,
                                                            500,
                                                          );
                                                          return;
                                                        }
                                                        int? fireHeight = int.tryParse(
                                                          _fireHeightController.text.trim(),
                                                        );
                                                        FirebaseDB.updateData("setting", {
                                                          "fire-height": fireHeight,
                                                        });

                                                        if (DataController
                                                                .instance
                                                                .appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                                                            true)
                                                          LocalNoticeService.showNotification(
                                                            title: "Device settings changed",
                                                            body:
                                                                "Fire alert height is set to $fireHeight",
                                                          );
                                                      },

                                                      textAlign: TextAlign.center,
                                                      decoration: InputDecoration(
                                                        fillColor: Theme.of(
                                                          context,
                                                        ).colorScheme.surface,
                                                        filled: true,
                                                        contentPadding: EdgeInsets.all(0),
                                                        hintText: "200",
                                                        hintStyle: TextStyle(
                                                          color: Theme.of(context)
                                                              .colorScheme
                                                              .onSurface
                                                              .withValues(alpha: 0.7),
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
                                              onTap: () {
                                                if (!checkPermission(curUserData)) {
                                                  notify(
                                                    context,
                                                    "You don't have permission to edit!",
                                                    5,
                                                    500,
                                                  );
                                                  return;
                                                }
                                                DataController.instance.updateDevicesSetting(
                                                  "USE_KITCHEN_DEVICE",
                                                  !DataController
                                                      .instance
                                                      .devicesSetting["USE_KITCHEN_DEVICE"]!,
                                                );
                                                if (DataController
                                                        .instance
                                                        .appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                                                    true)
                                                  LocalNoticeService.showNotification(
                                                    title: "Device settings changed",
                                                    body:
                                                        "Kitchen device usage is set to ${DataController.instance.devicesSetting["USE_KITCHEN_DEVICE"]! ? "ON" : "OFF"}",
                                                  );
                                              },
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
                                                            .devicesSetting["USE_KITCHEN_DEVICE"] ==
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
                              child: Divider(
                                thickness: 1.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            SizedBox(width: 18),
                            Text(
                              "Additional",
                              style: TextStyle(fontFamily: "cubano", fontSize: 34),
                            ),
                            SizedBox(width: 18),
                            Expanded(
                              child: Divider(
                                thickness: 1.5,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
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
                              "Use wristband",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                            subtitle: Text(
                              "Turn on to enable wristband",
                              style: TextStyle(fontSize: 14),
                            ),
                            secondary: Icon(Icons.watch, size: 30),
                            value: USE_WRISTBAND,
                            onChanged: (USE_WRISTBAND) {
                              if (!checkPermission(curUserData)) {
                                notify(context, "You don't have permission to edit!", 5, 500);
                                return;
                              }
                              setState() => USE_WRISTBAND = !USE_WRISTBAND;
                              DataController.instance.updateDevicesSetting(
                                "USE_WRISTBAND",
                                USE_WRISTBAND,
                              );
                              if (DataController
                                      .instance
                                      .appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                                  true)
                                LocalNoticeService.showNotification(
                                  title: "Device settings changed",
                                  body: "Wristband usage is set to ${USE_WRISTBAND ? "ON" : "OFF"}",
                                );
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
                            subtitle: Text(
                              "Turn on to get Home Station's data",
                              style: TextStyle(fontSize: 14),
                            ),
                            secondary: Icon(Icons.hearing, size: 30),
                            value: USE_HOME_STATION,
                            onChanged: (USE_HOME_STATION) {
                              if (!checkPermission(curUserData)) {
                                notify(context, "You don't have permission to edit!", 5, 500);
                                return;
                              }
                              setState() => USE_HOME_STATION = !USE_HOME_STATION;
                              DataController.instance.updateDevicesSetting(
                                "USE_HOME_STATION",
                                USE_HOME_STATION,
                              );
                              if (DataController
                                      .instance
                                      .appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                                  true)
                                LocalNoticeService.showNotification(
                                  title: "Device settings changed",
                                  body:
                                      "Home station usage is set to ${USE_HOME_STATION ? "ON" : "OFF"}",
                                );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
