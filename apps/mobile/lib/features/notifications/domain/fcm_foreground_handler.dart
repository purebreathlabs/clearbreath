import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMForegroundHandler {
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;

    FirebaseMessaging.onMessage.listen((message) {
      if (message.notification != null) {
        final plugin = FlutterLocalNotificationsPlugin();
        plugin.show(
          id: message.hashCode,
          title: message.notification!.title,
          body: message.notification!.body,
          notificationDetails: const NotificationDetails(
            android: AndroidNotificationDetails(
              'life.clearbreath.clearbreath.channel.reminders',
              'Reminders',
              importance: Importance.defaultImportance,
              priority: Priority.defaultPriority,
              icon: 'ic_notification',
            ),
            iOS: DarwinNotificationDetails(
              presentAlert: true,
              presentSound: true,
            ),
          ),
        );
      }
    });

    debugPrint('FCMForegroundHandler: initialized');
  }
}
