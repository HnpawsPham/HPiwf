import 'dart:math';
import "dart:ui";
import 'package:collection/collection.dart';
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
import "control-tabs/reminder-tab.dart";
import "control-tabs/devices-tab.dart";
import "control-tabs/users-tab.dart";
import "control-tabs/geofencing-tab.dart";

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
            child: TabBarView(children: [ReminderTab(), GeofencingTab(), DevicesTab(), UsersTab()]),
          ),
        ],
      ),
    );
  }
}
