import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hpiwf/controllers/data-controller.dart';
import "../config.dart";
import '../../database/authentication.dart';
import 'package:spoiler_widget/spoiler_widget.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import "./login-page.dart";
import 'package:stroke_text/stroke_text.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _hidePass = true;

  Future<void> _openURL(String urlStr) async {
    final Uri url = Uri.parse(urlStr);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

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
                        appInfo(context),
                        SizedBox(height: 10),

                        // ACCOUNT SETTING
                        myAccount(context),
                        SizedBox(height: 20),

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

  Column myAccount(BuildContext context) {
    return Column(
      children: [
        _createHeader(context, "My account"),
        Center(
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
                          height: 230,
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
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                  width: 5,
                                ),
                                image: const DecorationImage(
                                  image: AssetImage("assets/best-avt.jpg"),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 70,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            child: TextField(
                              style: TextStyle(
                                color: colorWhite,
                                fontFamily: "cubano",
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                              controller: _nameController,

                              onTap: () async {
                                String newName = _nameController.text.trim();
                              },

                              decoration: InputDecoration(
                                labelText: "Username: ",
                                labelStyle: TextStyle(color: colorBlack, fontFamily: "cubano"),
                                hintText: "Name",
                                hintStyle: TextStyle(color: colorBlack.withValues(alpha: 0.5)),
                                filled: true,
                                fillColor: colorWhite,
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 10,
                          left: 0,
                          right: 0,
                          child: Container(
                            margin: EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                            child: TextField(
                              style: TextStyle(
                                color: colorBlack,
                                fontFamily: "cubano",
                                fontSize: 20,
                              ),
                              textAlign: TextAlign.center,
                              controller: _passController,
                              obscureText: _hidePass,

                              onTap: () async {},
                              decoration: InputDecoration(
                                hintText: "123455",
                                labelText: "Password: ",
                                labelStyle: TextStyle(color: colorBlack, fontFamily: "cubano"),
                                hintStyle: TextStyle(color: colorBlack.withValues(alpha: 0.5)),
                                filled: true,
                                fillColor: colorWhite,
                                contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _hidePass ? Icons.visibility_off : Icons.visibility,
                                    color: colorBlack,
                                  ),
                                  onPressed: () => setState(() => _hidePass = !_hidePass),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              else
                return Center(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      borderRadius: BorderRadius.circular(15),
                    ),
                  ),
                );
            },
          ),
        ),
      ],
    );
  }

  Column appInfo(BuildContext context) {
    return Column(
      children: [
        _createHeader(context, "App info"),
        SizedBox(height: 10),
        Text(
          "HPiwf Application",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, fontFamily: "cubano"),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
          child: Text(
            "An IoT system for the Elderly and Alzheimer's patients",
            style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: Row(
            children: [
              Text("Author: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              Text("Hnpaws Pham - PĐVT", style: TextStyle(fontSize: 20)),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 30, vertical: 5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Source: ", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),

              Expanded(
                child: GestureDetector(
                  onTap: () => _openURL("https://github.com/HnpawsPham/HPiwf"),
                  child: Text(
                    "github.com/HnpawsPham/HPiwf",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 20,
                      color: colorLightBlue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
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
