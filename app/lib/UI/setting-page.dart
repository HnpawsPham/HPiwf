import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hpiwf/controllers/data-controller.dart';
import 'package:hpiwf/controllers/notification-manager.dart';
import "../config.dart";
import '../../database/authentication.dart';
import 'package:spoiler_widget/spoiler_widget.dart';
import 'package:url_launcher/link.dart';
import 'package:url_launcher/url_launcher.dart';
import "./login-page.dart";
import 'package:stroke_text/stroke_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import "../database/database.dart";
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  bool _hidePass = true;

  File? _chosenAvt;
  ImagePicker _imgPicker = ImagePicker();

  Future<void> _openURL(String urlStr) async {
    final Uri url = Uri.parse(urlStr);

    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<String?> pickAnImage() async {
    final pickedImg = await _imgPicker.pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedImg == null) return null;

    final bytes = await File(pickedImg.path).readAsBytes();
    return base64Encode(bytes);
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

              if (!snapshot.hasData) {
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: const Text(
                      "No user data found.",
                      style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic),
                    ),
                  ),
                );
              }

              String curUID = snapshot.data!.uid;

              return StreamBuilder<DocumentSnapshot?>(
                stream: FirebaseDB.getUserDataStream(curUID),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting)
                    return const Center(child: CircularProgressIndicator());

                  if (!userSnapshot.hasData || !userSnapshot.data!.exists)
                    return const Center(child: Text("No user data found."));

                  Map<String, dynamic>? curUserData =
                      userSnapshot.data!.data() as Map<String, dynamic>?;

                  return Column(
                    children: [
                      const SizedBox(height: 10),
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            height: 240,
                            margin: const EdgeInsets.only(left: 25, right: 25, top: 80, bottom: 0),
                            padding: const EdgeInsets.symmetric(vertical: 40),
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
                              child: Stack(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8.0),
                                    width: 150,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Theme.of(context).colorScheme.tertiaryContainer,
                                        width: 5,
                                      ),
                                      image: DecorationImage(
                                        image:
                                            (curUserData?["avt"] != null &&
                                                curUserData!["avt"].isNotEmpty)
                                            ? MemoryImage(base64Decode(curUserData["avt"]))
                                            : const AssetImage("assets/best-avt.jpg")
                                                  as ImageProvider,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),

                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: IconButton.filled(
                                      onPressed: () async {
                                        String? base64 = await pickAnImage();

                                        if (base64 != null)
                                          FirebaseDB.updateUser(curUID, {"avt": base64});
                                      },
                                      icon: const Icon(Icons.camera_alt),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 80,
                            left: 0,
                            right: 0,
                            child: Container(
                              margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
                              child: TextField(
                                style: const TextStyle(
                                  color: colorBlack,
                                  fontFamily: "cubano",
                                  fontSize: 20,
                                ),
                                textAlign: TextAlign.center,

                                controller: _nameController,
                                onSubmitted: (value) async {
                                  String newName = _nameController.text.trim();

                                  if (newName.isEmpty) {
                                    notify(context, "New name is empty", 3, 500);
                                    return;
                                  } else if (newName == curUserData?["username"]) {
                                    notify(context, "Name unchanged", 3, 0);
                                    return;
                                  }

                                  FirebaseDB.updateUser(curUID, {"username": newName});
                                  notify(context, "New name is set!", 3, 200);
                                },

                                decoration: InputDecoration(
                                  label: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorLightBlue,
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(color: colorBlack),
                                    ),
                                    child: const Text(
                                      "Username:",
                                      style: TextStyle(
                                        color: colorBlack,
                                        fontFamily: "cubano",
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                  hintText: curUserData?["username"] ?? "Not set",
                                  hintStyle: TextStyle(color: colorBlack.withValues(alpha: 0.5)),
                                  filled: true,
                                  fillColor: colorWhite,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(20),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          ((curUserData?["login-method"] ?? "google") == "email")
                              ? Positioned(
                                  bottom: 10,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 50,
                                      vertical: 10,
                                    ),
                                    child: StatefulBuilder(
                                      builder: (context, setLocalState) {
                                        return TextField(
                                          style: const TextStyle(
                                            color: colorBlack,
                                            fontFamily: "cubano",
                                            fontSize: 20,
                                          ),
                                          textAlign: TextAlign.center,
                                          controller: _passController,
                                          obscureText: _hidePass,

                                          onSubmitted: (_) async {
                                            String newPass = _passController.text.trim();

                                            if (newPass.isEmpty) {
                                              notify(context, "New password is empty.", 3, 500);
                                              return;
                                            } else if (newPass == curUserData?["pass"]) {
                                              notify(context, "Password unchanged", 3, 0);
                                              return;
                                            }

                                            FirebaseDB.updateUser(curUID, {"pass": newPass});
                                            notify(context, "New password is set", 3, 200);
                                          },

                                          decoration: InputDecoration(
                                            label: Container(
                                              padding: const EdgeInsets.symmetric(
                                                horizontal: 8,
                                                vertical: 4,
                                              ),
                                              decoration: BoxDecoration(
                                                color: colorLightBlue,
                                                borderRadius: BorderRadius.circular(15),
                                                border: Border.all(color: colorBlack),
                                              ),
                                              child: const Text(
                                                "Password:",
                                                style: TextStyle(
                                                  color: colorBlack,
                                                  fontFamily: "cubano",
                                                  fontSize: 18,
                                                ),
                                              ),
                                            ),
                                            hintText: curUserData?["pass"],
                                            hintStyle: TextStyle(
                                              color: colorBlack.withValues(alpha: 0.5),
                                            ),
                                            filled: true,
                                            fillColor: colorWhite,
                                            contentPadding: const EdgeInsets.symmetric(
                                              horizontal: 10,
                                              vertical: 5,
                                            ),
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(20),
                                              borderSide: BorderSide.none,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                _hidePass ? Icons.visibility_off : Icons.visibility,
                                                color: colorBlack,
                                              ),
                                              onPressed: () =>
                                                  setLocalState(() => _hidePass = !_hidePass),
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : Positioned(
                                  bottom: 30,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Text(
                                      "This account is linked with Google.",
                                      style: TextStyle(fontSize: 20),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ],
                  );
                },
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
