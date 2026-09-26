import 'package:flutter/material.dart';
import 'package:hpiwf/config.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// DEVICE NOTIFICATION
class LocalNoticeService {
  static final _noti = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _noti.initialize(settings: initSettings);
    final androidPlugin = _noti
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) await androidPlugin.requestNotificationsPermission();
  }

  static Future<void> showNotification({required String title, required String body}) async {
    const androidDetails = AndroidNotificationDetails(
      "default channel",
      "general notification",
      importance: Importance.max,
      priority: Priority.high,
    );

    const details = NotificationDetails(android: androidDetails);
    await _noti.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
    );
  }
}

// IN APP NOTIFICATION
Map<int, ToastificationType> notificationType = {
  200: ToastificationType.success,
  500: ToastificationType.error,
  404: ToastificationType.warning,
  0: ToastificationType.info,
};

void notify(BuildContext context, String content, int sec, int code) {
  toastification.show(
    context: context,
    type: notificationType[code],
    style: ToastificationStyle.flatColored,
    title: Text(
      content,
      style: TextStyle(fontFamily: "cubano", fontSize: 18),
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
    ),
    alignment: Alignment.topRight,
    autoCloseDuration: Duration(seconds: sec),
  );
}
