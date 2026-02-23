import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:digistore/src/data/services/deep_link_service.dart';
import 'package:digistore/src/data/services/navigation_service.dart';
import 'package:digistore/src/interfaces/components/in_app_notification_overlay.dart';
import 'package:digistore/src/data/services/notification_service/notification_controller.dart';
import 'package:digistore/src/data/router/nav_router.dart';
import 'package:flutter/material.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final deepLinkService = ref.watch(deepLinkServiceProvider);
  return NotificationService(ref, deepLinkService);
});

/// Notification Service
///
/// Features:
/// - In-app overlay notifications (foreground) - WhatsApp style
/// - System heads-up notifications (background) - pops up on screen
/// - Deep linking support
/// - FCM integration
///
/// Permissions are handled by get_fcm.dart
class NotificationService {
  final Ref _ref;
  final DeepLinkService _deepLinkService;

  NotificationService(this._ref, this._deepLinkService);

  static const String _channelKey = 'channel_connect24';
  static const String _channelName = 'Connect24 Notifications';
  static const String _channelDescription =
      'Notification channel for Connect24 app';

  static bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) {
      debugPrint('🔔 Notification Service already initialized');
      return;
    }
    try {
      debugPrint('🔔 Initializing Notification Service...');

      // Initialize Awesome Notifications
      await AwesomeNotifications().initialize(
        null, // Use default app icon
        [
          NotificationChannel(
            channelKey: _channelKey,
            channelName: _channelName,
            channelDescription: _channelDescription,
            defaultColor: const Color(0xFF1e3a81),
            ledColor: Colors.white,
            importance: NotificationImportance.Max,
            channelShowBadge: true,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            criticalAlerts: true,
            defaultRingtoneType: DefaultRingtoneType.Notification,
          ),
        ],
        debug: true, // Enable debug for testing
      );

      debugPrint('✅ Awesome Notifications initialized');

      // Set up notification listeners with top-level functions
      // AwesomeNotifications().setListeners(
      //   onActionReceivedMethod: NotificationController.onActionReceivedMethod,
      //   onNotificationCreatedMethod:
      //       NotificationController.onNotificationCreatedMethod,
      //   onNotificationDisplayedMethod:
      //       NotificationController.onNotificationDisplayedMethod,
      //   onDismissActionReceivedMethod:
      //       NotificationController.onDismissActionReceivedMethod,
      // );

      // Set up FCM handlers
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
        debugPrint("🔑 New FCM Token: $newToken");
      });

      FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);
      await _handleInitialMessage();

      _isInitialized = true;
      debugPrint('✅ Notification Service initialized successfully');
    } catch (e) {
      debugPrint('❌ Notification initialization error: $e');
    }
  }

  /// Check if notifications are allowed
  Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }

  void _handleForegroundMessage(RemoteMessage message) {
    log("Notification received in FOREGROUND: ${message.data}");

    try {
      if (message.notification != null) {
        String? deepLink;
        if (message.data.containsKey('screen')) {
          final screen = message.data['screen'];
          final id = message.data['id'];


          deepLink = _deepLinkService.generateDeepLink(screen, id: id);
        }

        // ALWAYS show in-app notification overlay when app is in foreground
        // DO NOT show system notification
        final context = NavigationService.navigatorKey.currentContext;
        if (context != null && context.mounted) {
          debugPrint('Showing IN-APP notification overlay');
          InAppNotificationOverlay.show(
            context,
            overlayState: NavigationService.navigatorKey.currentState?.overlay,
            title: message.notification?.title ?? 'Notification',
            message: message.notification?.body ?? '',
            imageUrl: message.notification?.android?.imageUrl,
            accentColor: const Color(0xFF1e3a81),
            onTap: () {
              if (deepLink != null) {
                _deepLinkService.handleDeepLink(Uri.parse(deepLink));
              }
            },
          );
        } else {
          debugPrint('Context not available, cannot show in-app notification');
        }
      }
    } catch (e) {
      debugPrint('Foreground message handling error: $e');
    }
  }

  void _showSystemNotification(RemoteMessage message, String? deepLink) {
    debugPrint('Creating SYSTEM notification with MAX priority');
    AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: message.hashCode,
        channelKey: _channelKey,
        title: message.notification?.title,
        body: message.notification?.body,
        bigPicture: message.notification?.android?.imageUrl,
        largeIcon: message.notification?.android?.imageUrl,
        notificationLayout: message.notification?.android?.imageUrl != null
            ? NotificationLayout.BigPicture
            : NotificationLayout.Default,
        payload: deepLink != null ? {'deepLink': deepLink} : null,
        category: NotificationCategory.Message,
        autoDismissible: true,
        showWhen: true,
        criticalAlert: true,
        wakeUpScreen: true,
        fullScreenIntent: true,
        locked: false,
      ),
      actionButtons: [
        NotificationActionButton(
          key: 'OPEN',
          label: 'Open',
          autoDismissible: true,
        ),
      ],
    );
  }

  void _handleMessageOpenedApp(RemoteMessage message) {
    try {
      String? deepLink;
      if (message.data.containsKey('screen')) {
        final screen = message.data['screen'];
        final id = message.data['id'];
        deepLink = _deepLinkService.generateDeepLink(screen, id: id);
      }

      if (deepLink != null) {
        _deepLinkService.handleDeepLink(Uri.parse(deepLink));
      }
    } catch (e) {
      debugPrint('Message opened app handling error: $e');
    }
  }

  Future<void> _handleInitialMessage() async {
    try {
      RemoteMessage? initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();
      if (initialMessage != null) {
        debugPrint('Handling initial message');
        _handleMessageOpenedApp(initialMessage);
      }
    } catch (e) {
      debugPrint('Initial message handling error: $e');
    }
  }

  Future<String?> getToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
      return null;
    }
  }

  Future<void> cancelNotification(int id) async {
    await AwesomeNotifications().cancel(id);
  }

  Future<void> cancelAllNotifications() async {
    await AwesomeNotifications().cancelAll();
  }
}
