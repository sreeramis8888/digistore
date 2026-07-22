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
    if let original = UNUserNotificationCenter.current().delegate, original !== self {
      original.userNotificationCenter?(center, willPresent: notification, withCompletionHandler: completionHandler)
    } else {
      completionHandler([])
    }
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
    let isPush = notification.request.trigger is UNPushNotificationTrigger

    if let original = originalDelegate {
      original.userNotificationCenter?(center, willPresent: notification) { _ in
        if isPush {
          // Push notification in foreground: 0 banners, 0 sounds, 0 popups
          completionHandler([])
        } else {
          // Silent local tray notification (after in-app overlay timeout): place silently in Notification Center (list) without banner pop-up
          if #available(iOS 14.0, *) {
            completionHandler([.list])
          } else {
            completionHandler([.badge])
          }
        }
      }
    } else {
      if isPush {
        completionHandler([])
      } else {
        if #available(iOS 14.0, *) {
          completionHandler([.list])
        } else {
          completionHandler([.badge])
        }
      }
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
