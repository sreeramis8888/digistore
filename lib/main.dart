import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'src/data/router/router.dart';
import 'src/data/providers/screen_size_provider.dart';
import 'dart:io';
import 'dart:ui';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'firebase_options.dart';
import 'src/data/services/notification_service/notification_controller.dart';
import 'src/data/services/navigation_service.dart';
import 'src/utils/http_overrides.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  // Configure global HTTP proxy overrides if PROXY_HOST is set (e.g. for JMeter interception)
  final proxyHost = dotenv.env['PROXY_HOST'];
  final proxyPort = dotenv.env['PROXY_PORT'] ?? '8888';
  if (proxyHost != null && proxyHost.isNotEmpty) {
    print('--- PROXY INTERCEPTION ENABLED ---');
    print('Routing all app HTTP/HTTPS traffic through proxy: $proxyHost:$proxyPort');
    print('----------------------------------');
    HttpOverrides.global = DevHttpOverrides(
      proxyHost: proxyHost,
      proxyPort: proxyPort,
    );
  } else {
    print('--- PROXY INTERCEPTION DISABLED ---');
  }
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };
  
  // Disable OS device notifications when app is in foreground
  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: false,
    badge: false,
    sound: false,
  );
  
  await AwesomeNotifications().initialize(
    null, 
    [
      NotificationChannel(
        channelKey: 'channel_setgo',
        channelName: 'Setgo Notifications',
        channelDescription: 'Notification channel for Setgo app',
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
      NotificationChannel(
        channelKey: 'channel_setgo_silent_v2',
        channelName: 'Setgo Silent Tray',
        channelDescription: 'Silent notifications for the tray',
        defaultColor: const Color(0xFF1e3a81),
        ledColor: Colors.white,
        importance: NotificationImportance.Default,
        channelShowBadge: true,
        playSound: false,
        enableVibration: false,
        enableLights: false,
        criticalAlerts: false,
      ),
    ],
    debug: true,
  );
  
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  AwesomeNotifications().setListeners(
    onActionReceivedMethod: NotificationController.onActionReceivedMethod,
    onNotificationCreatedMethod:
        NotificationController.onNotificationCreatedMethod,
    onNotificationDisplayedMethod:
        NotificationController.onNotificationDisplayedMethod,
    onDismissActionReceivedMethod:
        NotificationController.onDismissActionReceivedMethod,
  );
  runApp(const ProviderScope(child: ScreenSizeScope(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: NavigationService.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Setgo',
      theme: ThemeData(
        fontFamily: 'Inter',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.white,
          surface: Colors.white,
          onSurface: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.white,
        useMaterial3: true,
      ),
      initialRoute: 'splash',
      onGenerateRoute: generateRoute,
    );
  }
}
