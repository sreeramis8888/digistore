import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../../../firebase_options.dart';

/// Background message handler - must be top-level function
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('Handling background message: ${message.messageId}');

  // Show system notification when app is in background
  if (message.notification != null) {
    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.hashCode,
        channelKey: 'channel_setgo',
        title: message.notification?.title,
        body: message.notification?.body,
        bigPicture: message.notification?.android?.imageUrl,
        largeIcon: message.notification?.android?.imageUrl,
        notificationLayout: message.notification?.android?.imageUrl != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        payload: message.data.isNotEmpty
            ? message.data.map((key, value) => MapEntry(key, value.toString()))
            : null,
        category: NotificationCategory.Message,
        autoDismissible: true,
        showWhen: true,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
      ),
    );
  }
}

class NotificationController {
  /// Use this method to detect when a new notification or a schedule is created
  @pragma("vm:entry-point")
  static Future<void> onNotificationCreatedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('🔔 Notification created: ${receivedNotification.id}');
  }

  /// Use this method to detect every time that a new notification is displayed
  @pragma("vm:entry-point")
  static Future<void> onNotificationDisplayedMethod(
      ReceivedNotification receivedNotification) async {
    debugPrint('🔔 Notification displayed: ${receivedNotification.id}');
  }

  /// Use this method to detect if the user dismissed a notification
  @pragma("vm:entry-point")
  static Future<void> onDismissActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('🔔 Notification dismissed: ${receivedAction.id}');
  }

  /// Use this method to detect when the user taps on a notification or action button
  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
      ReceivedAction receivedAction) async {
    debugPrint('🔔 Notification action received: ${receivedAction.payload}');

    // Handle notification tap logic here
    if (receivedAction.payload != null &&
        receivedAction.payload!.containsKey('deepLink')) {
      final deepLink = receivedAction.payload!['deepLink'];
      if (deepLink != null) {
        debugPrint('Deep link to handle: $deepLink');
      }
    }
  }
}
