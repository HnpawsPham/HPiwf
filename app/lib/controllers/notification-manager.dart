import 'package:flutter/material.dart';
import 'package:hpiwf/config.dart';
import 'package:toastification/toastification.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_app_installations/firebase_app_installations.dart';

// DEVICE NOTIFICATION
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final title = message.notification?.title ?? message.data['title'];
  final body = message.notification?.body ?? message.data['body'];

  final level = message.data['priority'] ?? 'low';

  await LocalNoticeService.showNotification(title: title, body: body, level: level);
}

class LocalNoticeService {
  static final _noti = FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _noti.initialize(settings: initSettings);
    final androidPlugin = _noti
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) await androidPlugin.requestNotificationsPermission();

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title = message.notification?.title ?? message.data['title'];
      final body = message.notification?.body ?? message.data['body'];
      final level = message.data['priority'] ?? 'low';

      showNotification(title: title, body: body, level: level);
    });
  }

  static Future<void> showNotification({
    required String title,
    required String body,
    String level = 'high',
  }) async {
    Importance importance;
    Priority priority;
    bool isFullScreen = false;

    switch (level) {
      case 'max':
        importance = Importance.max;
        priority = Priority.max;
        isFullScreen = true;
        break;
      case 'low':
        importance = Importance.low;
        priority = Priority.low;
        break;
      case 'high':
      default:
        importance = Importance.high;
        priority = Priority.high;
        break;
    }

    final androidDetails = AndroidNotificationDetails(
      "${level}_channel",
      "$level Notifications",
      importance: importance,
      priority: priority,
      fullScreenIntent: isFullScreen,
    );

    final details = NotificationDetails(android: androidDetails);
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
