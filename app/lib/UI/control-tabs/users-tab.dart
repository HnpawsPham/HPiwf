import 'package:flutter/material.dart';
import 'package:hpiwf/controllers/notification-manager.dart';
import '../../database/authentication.dart';
import 'package:hpiwf/database/database.dart';
import 'package:hpiwf/config.dart';
import "../login-page.dart";
import 'package:stroke_text/stroke_text.dart';
import "package:cloud_firestore/cloud_firestore.dart";

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

              if (!userSnapshot.hasData || userSnapshot.data == null || !userSnapshot.data!.exists)
                return const Center(child: Text("User data not found!"));

              Map<String, dynamic>? curUserData =
                  userSnapshot.data!.data() as Map<String, dynamic>?;

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
                                image: AssetImage(curUserData?["avt"] ?? "assets/best-avt.jpg"),
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
                      Positioned(
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
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  // Phần hiển thị danh sách dùng ValueListenableBuilder
                  Expanded(
                    child: ValueListenableBuilder<String>(
                      valueListenable: FirebaseDB.chosenGID,
                      builder: (context, curGID, child) {
                        if (curGID.isNotEmpty) {
                          return SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Stack(
                                  children: [
                                    Container(
                                      width: double.infinity,
                                      margin: const EdgeInsets.all(23),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(15),
                                        color: colorDarkBlue,
                                      ),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(left: 80),
                                            padding: const EdgeInsets.symmetric(vertical: 10),
                                            child: const Text(
                                              "Name here",
                                              style: TextStyle(
                                                fontFamily: "cubano",
                                                color: colorWhite,
                                                fontSize: 20,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 90,
                                            height: 35,
                                            margin: const EdgeInsets.only(right: 8),
                                            decoration: BoxDecoration(
                                              color: colorWhite,
                                              borderRadius: BorderRadius.circular(15),
                                            ),
                                            child: DropdownButtonHideUnderline(
                                              child: DropdownButton<String>(
                                                value: "View",
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
                                                onChanged: (_) {},
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
                                          width: 70,
                                          height: 70,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.tertiaryContainer,
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
                                  ],
                                ),
                              ],
                            ),
                          );
                        }

                        return const Center(child: Text("You haven't joined a group!"));
                      },
                    ),
                  ),

                  const Spacer(),

                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 25),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.onSurface,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: TextField(
                      controller: _GIDController,
                      onSubmitted: (value) {
                        String pastedGID = _GIDController.text.trim();

                        if (pastedGID.isEmpty || pastedGID.length != 17) {
                          notify(context, "GID is invalid", 3, 500);
                          return;
                        }

                        notify(context, "Valid GID", 3, 200);
                        FirebaseDB.updateUser(curUID, {"GID": pastedGID});
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
