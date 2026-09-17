import 'package:flutter/material.dart';
import '../../database/authentication.dart';
import 'package:hpiwf/config.dart';
import "../login-page.dart";
import 'package:stroke_text/stroke_text.dart';

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
                                  child: Image.asset("assets/key-icon.png", width: 45, height: 45),
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

                SizedBox(height: 10),

                SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            margin: EdgeInsets.all(23),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: colorDarkBlue,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(left: 80),
                                  padding: EdgeInsets.symmetric(vertical: 10),
                                  child: Text(
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
                                      underline: null,
                                      alignment: Alignment.center,
                                      dropdownColor: colorWhite,
                                      icon: const Icon(Icons.arrow_drop_down, color: colorBlack),
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
                                                  style: TextStyle(color: colorBlack),
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
                        ],
                      ),
                    ],
                  ),
                ),

                Spacer(),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 25),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.onSurface,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: TextField(
                    controller: _GIDController,
                    onSubmitted: (value) => {},

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
                            SizedBox(width: 16),
                            Text(
                              'GID',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).scaffoldBackgroundColor,
                              ),
                            ),

                            SizedBox(width: 12),
                            VerticalDivider(
                              width: 1,
                              thickness: 1,
                              indent: 12,
                              endIndent: 12,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            SizedBox(width: 12),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: 15),

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
}
