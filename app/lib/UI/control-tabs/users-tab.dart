import 'package:flutter/material.dart';
import 'package:hpiwf/controllers/notification-manager.dart';
import '../../database/authentication.dart';
import 'package:hpiwf/database/database.dart';
import 'package:hpiwf/config.dart';
import "../login-page.dart";
import 'package:stroke_text/stroke_text.dart';
import "package:cloud_firestore/cloud_firestore.dart";
import 'dart:convert';
import 'package:hpiwf/controllers/mqtt-manager.dart';
import "../../controllers/data-controller.dart";

const roleMap = ["View", "Editor", "Admin"];

class UsersTab extends StatefulWidget {
  const UsersTab({super.key});

  @override
  State<UsersTab> createState() => _UsersTabState();
}

class _UsersTabState extends State<UsersTab> {
  final TextEditingController _GIDController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: StreamBuilder(
        stream: FBAuth.authStateChange,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting)
            return const Center(child: CircularProgressIndicator());

          if (!snapshot.hasData || snapshot.data == null) return const LoginPage();

          String curUID = snapshot.data!.uid;

          return StreamBuilder<DocumentSnapshot?>(
            stream: FirebaseDB.getUserDataStream(curUID),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting)
                return const Center(child: CircularProgressIndicator());

              Map<String, dynamic>? curUserData =
                  userSnapshot.data?.data() as Map<String, dynamic>?;

              return Column(
                children: [
                  const SizedBox(height: 10),

                  // Header UI
                  Stack(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 145,
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
                          child: Container(
                            width: 150,
                            height: 150,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Theme.of(context).colorScheme.tertiaryContainer,
                                width: 5,
                              ),
                              image: DecorationImage(
                                image: curUserData?["avt"] != null
                                    ? MemoryImage(base64Decode(curUserData!["avt"]))
                                    : AssetImage("assets/best-avt.jpg"),
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
                            text: curUserData?["username"] ?? "Unknown",
                            textStyle: const TextStyle(
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

                      ((curUserData?["role"] ?? 0) == 2)
                          ? Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              child: Center(
                                child: Stack(
                                  children: [
                                    Transform.translate(
                                      offset: const Offset(0, 3),
                                      child: Opacity(
                                        opacity: 0.5,
                                        child: ColorFiltered(
                                          colorFilter: const ColorFilter.mode(
                                            Colors.black,
                                            BlendMode.srcIn,
                                          ),
                                          child: Image.asset(
                                            "assets/key-icon.png",
                                            width: 45,
                                            height: 45,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Image.asset("assets/key-icon.png", width: 40, height: 40),
                                  ],
                                ),
                              ),
                            )
                          : Center(
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  "You",
                                  style: TextStyle(
                                    fontFamily: "cubano",
                                    fontSize: 20,
                                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                                  ),
                                ),
                              ),
                            ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: FirebaseDB.chosenGID,
                      builder: (context, curGID, child) {
                        if (curGID.isEmpty)
                          return const Center(child: Text("You haven't joined a group!"));

                        return StreamBuilder<List<DocumentSnapshot>>(
                          stream: FirebaseDB.getUsersInGroupStream(curGID),
                          builder: (context, usersSnapshot) {
                            if (usersSnapshot.connectionState == ConnectionState.waiting) {
                              return const Center(child: CircularProgressIndicator());
                            }

                            final users =
                                usersSnapshot.data?.where((doc) => doc.id != curUID).toList() ?? [];

                            if (usersSnapshot.hasError || users.isEmpty) {
                              return const Center(
                                child: Text("You are alone.", style: TextStyle(fontSize: 20)),
                              );
                            }

                            return ListView.builder(
                              shrinkWrap: true,
                              itemCount: users.length,
                              itemBuilder: (context, id) {
                                final userData = users[id].data() as Map<String, dynamic>;

                                return Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                        horizontal: 23,
                                        vertical: 10,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: colorDarkBlue,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 80),
                                            padding: const EdgeInsets.symmetric(vertical: 8),
                                            child: Text(
                                              userData["username"] ?? "Unknown",
                                              style: TextStyle(
                                                fontFamily: "cubano",
                                                color: colorWhite,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 90,
                                            height: 32,
                                            margin: const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: colorWhite,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: roleMap[userData["role"] ?? 0],
                                                isExpanded: true,
                                                alignment: Alignment.center,
                                                dropdownColor: colorWhite,
                                                icon: const Icon(
                                                  Icons.arrow_drop_down,
                                                  color: colorBlack,
                                                ),
                                                elevation: 16,
                                                borderRadius: BorderRadius.circular(15),
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18,
                                                ),
                                                items: <String>["View", "Editor", "Admin"]
                                                    .map(
                                                      (val) => DropdownMenuItem(
                                                        value: val,
                                                        child: Align(
                                                          alignment: Alignment.center,
                                                          child: Text(
                                                            val,
                                                            overflow: TextOverflow.ellipsis,
                                                            style: const TextStyle(
                                                              color: colorBlack,
                                                            ),
                                                            textAlign: TextAlign.center,
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                                onChanged: (checkPermission(curUserData))
                                                    ? (newRole) {
                                                        if (newRole == null) return;
                                                        FirebaseDB.updateUser(users[id].id, {
                                                          "role": roleMap.indexOf(newRole),
                                                        });

                                                        if (DataController
                                                                .instance
                                                                .appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                                                            true)
                                                          LocalNoticeService.showNotification(
                                                            title: "User role changed",
                                                            body:
                                                                "User ${userData["username"] ?? "Unknown"}'s role is set to ${newRole}",
                                                          );
                                                      }
                                                    : null,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      left: 20,
                                      bottom: 0,
                                      child: Center(
                                        child: Container(
                                          width: 58,
                                          height: 58,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.tertiaryContainer,
                                              width: 5,
                                            ),
                                            image: DecorationImage(
                                              image: userData["avt"] != null
                                                  ? MemoryImage(base64Decode(userData["avt"]))
                                                  : AssetImage("assets/best-avt.jpg"),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _GIDController,
                      onSubmitted: (_) {
                        String pastedGID = _GIDController.text.trim();

                        if (pastedGID.isEmpty || pastedGID.length != 16) {
                          notify(context, "GID is invalid", 3, 500);
                          return;
                        }

                        notify(context, "Valid GID", 3, 200);
                        FirebaseDB.updateUser(curUID, {"GID": pastedGID});
                        FirebaseDB.addToList(pastedGID, curUID);

                        MQTTManager().sub("$pastedGID/data/#");
                        if (DataController.instance.appSetting["ACCEPT_UPDATE_NOTIFICATIONS"] ==
                            true)
                          LocalNoticeService.showNotification(
                            title: "User role changed",
                            body: "A new user joined the group",
                          );
                      },

                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).scaffoldBackgroundColor,
                      ),
                      decoration: InputDecoration(
                        hintText: "Paste your GID here",
                        hintStyle: TextStyle(
                          color: Theme.of(context).scaffoldBackgroundColor.withValues(alpha: 0.7),
                          fontSize: 18,
                        ),
                        contentPadding: const EdgeInsets.all(10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        prefixIcon: IntrinsicHeight(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const SizedBox(width: 16),
                              Text(
                                'GID',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Theme.of(context).scaffoldBackgroundColor,
                                ),
                              ),
                              const SizedBox(width: 12),
                              VerticalDivider(
                                width: 1,
                                thickness: 1,
                                indent: 12,
                                endIndent: 12,
                                color: Theme.of(context).scaffoldBackgroundColor,
                              ),
                              const SizedBox(width: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 50),
                      backgroundColor: colorRed,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    onPressed: () => FBAuth.logout(),
                    child: const Text(
                      "Logout",
                      style: TextStyle(fontFamily: "cubano", color: Colors.white, fontSize: 25),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
