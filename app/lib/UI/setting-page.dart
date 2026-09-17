import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hpiwf/controllers/data-controller.dart';
import "../config.dart";
import '../../database/authentication.dart';
import 'package:spoiler_widget/spoiler_widget.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: DataController.instance,
      builder: (context, value) {
        return Center(
          child: SafeArea(
            child: Column(
              children: [
                Text(
                  "Setting",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.2,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: 20),

                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // APP INFO (GID AND INVITATIONS)
                        _createHeader(context, "App info"),
                        SizedBox(height: 10),
                        // ACCOUNT SETTING
                        _createHeader(context, "My account"),
                        SizedBox(height: 10),

                        // NOTIFICATIONS SETTING
                        _createHeader(context, "Notifications"),
                        SizedBox(height: 10),

                        _createSwitch(
                          context,
                          "Receive updates",
                          "Ex: weather, users' changes",
                          "ACCEPT_UPDATE_NOTIFICATIONS",
                        ),

                        _createSwitch(
                          context,
                          "Receive completions",
                          "Ex: drink water reminder sent",
                          "ACCEPT_COMPLETION_NOTIFICATIONS",
                        ),

                        _createSwitch(
                          context,
                          "Receive alerts",
                          "Ex: fall detection, gas detection",
                          "ACCEPT_ALERTS",
                        ),
                        SizedBox(height: 20),

                        // RECONNECT DEVICES
                        _createHeader(context, "Connection"),
                        SizedBox(height: 20),

                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(20),
                          margin: EdgeInsets.symmetric(horizontal: 20),
                          decoration: BoxDecoration(
                            color: colorLightBlue,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            children: [
                              _createConnectionBar("Home Station: ", "home-station"),
                              SizedBox(height: 10),

                              _createConnectionBar("Door device: ", "door-device"),
                              SizedBox(height: 10),

                              _createConnectionBar("Kitchen device: ", "kitchen-device"),
                              SizedBox(height: 10),

                              _createConnectionBar("Wristband: ", "wristband"),
                              SizedBox(height: 10),
                            ],
                          ),
                        ),
                        SizedBox(height: 40),

                        // RESET ALL SETTINGS TO DEFAULT
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                            backgroundColor: colorRed,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          ),
                          onPressed: () => DataController.instance.resetSystemSetting(),
                          child: Text(
                            "Reset to default",
                            style: TextStyle(
                              fontFamily: "cubano",
                              color: Colors.white,
                              fontSize: 23,
                            ),
                          ),
                        ),
                        SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Theme _createSwitch(BuildContext context, String name, String desc, String key) {
    return Theme(
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
      child: ListenableBuilder(
        listenable: DataController.instance,
        builder: (context, _) {
          final val = DataController.instance.appSetting[key] ?? false;
          return SwitchListTile(
            activeTrackColor: Theme.of(context).colorScheme.surface,
            activeThumbColor: Theme.of(context).colorScheme.onSurface,
            trackOutlineColor: WidgetStateColor.resolveWith(
              (states) => Theme.of(context).colorScheme.onSurface,
            ),
            title: Text(name, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            subtitle: Text(desc, style: TextStyle(fontSize: 17)),
            secondary: Icon(Icons.watch, size: 30),
            value: val,
            onChanged: (newVal) {
              DataController.instance.updateAppSetting(key, newVal);
            },
          );
        },
      ),
    );
  }

  Container _createConnectionBar(String name, String deviceName) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(color: colorDarkBlue, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name,
            style: TextStyle(fontWeight: FontWeight.bold, color: colorWhite, fontSize: 20),
          ),

          switch (DataController.instance.connectionInfo[deviceName] == true) {
            true => Text(
              "Connected",
              style: TextStyle(
                color: CupertinoColors.activeGreen,
                fontFamily: "cubano",
                fontSize: 20,
              ),
            ),
            _ => Text(
              "Lost",
              style: TextStyle(color: colorRed, fontFamily: "cubano", fontSize: 20),
            ),
          },
        ],
      ),
    );
  }

  Row _createHeader(BuildContext context, String header) {
    return Row(
      children: [
        SizedBox(width: 22),
        Expanded(child: Divider(thickness: 1, color: Theme.of(context).colorScheme.onSurface)),
        SizedBox(width: 18),
        Text(header, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        SizedBox(width: 18),
        Expanded(child: Divider(thickness: 1, color: Theme.of(context).colorScheme.onSurface)),
        SizedBox(width: 22),
      ],
    );
  }
}
