import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)

    DispatchQueue.main.async {
      ForegroundNotificationSuppressor.shared.originalDelegate = UNUserNotificationCenter.current().delegate
      UNUserNotificationCenter.current().delegate = ForegroundNotificationSuppressor.shared
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    completionHandler([])
  }
}

class ForegroundNotificationSuppressor: NSObject, UNUserNotificationCenterDelegate {
  static let shared = ForegroundNotificationSuppressor()
  weak var originalDelegate: UNUserNotificationCenterDelegate?

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    willPresent notification: UNNotification,
    withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
  ) {
    if let original = originalDelegate {
      // Forward to originalDelegate so FirebaseMessaging processes APNs payload and fires FirebaseMessaging.onMessage in Flutter
      original.userNotificationCenter?(center, willPresent: notification) { _ in
        // Always force completionHandler([]) so iOS native OS device banner pop-up is suppressed
        completionHandler([])
      }
    } else {
      completionHandler([])
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    didReceive response: UNNotificationResponse,
    withCompletionHandler completionHandler: @escaping () -> Void
  ) {
    if let original = originalDelegate {
      original.userNotificationCenter?(center, didReceive: response, withCompletionHandler: completionHandler)
    } else {
      completionHandler()
    }
  }

  func userNotificationCenter(
    _ center: UNUserNotificationCenter,
    openSettingsFor notification: UNNotification?
  ) {
    if #available(iOS 12.0, *) {
      originalDelegate?.userNotificationCenter?(center, openSettingsFor: notification)
    }
  }
}
