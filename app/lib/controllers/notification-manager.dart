import 'package:flutter/material.dart';
import 'package:hpiwf/config.dart';
import 'package:toastification/toastification.dart';

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
    title: Text(content, style: TextStyle(fontFamily: "cubano", fontSize: 18)),
    alignment: Alignment.topRight,
    autoCloseDuration: Duration(seconds: sec),
  );
}
