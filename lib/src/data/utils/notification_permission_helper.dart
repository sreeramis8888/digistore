import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationPermissionHelper {
  /// Request all necessary notification permissions
  static Future<bool> requestAllPermissions(BuildContext context) async {
    final permissions = await requestUserPermissions(
      context,
      channelKey: 'channel_connect24',
      permissionList: [
        NotificationPermission.Alert,
        NotificationPermission.Sound,
        NotificationPermission.Badge,
        NotificationPermission.Vibration,
        NotificationPermission.Light,
      ],
    );

    return permissions.length >= 3; // At least Alert, Sound, and Badge
  }

  /// Request notification permissions with rationale dialog
  static Future<List<NotificationPermission>> requestUserPermissions(
    BuildContext context, {
    String? channelKey,
    required List<NotificationPermission> permissionList,
  }) async {
    // Check if the basic permission was granted by the user
    if (!await _requestBasicPermissionToSendNotifications(context)) {
      return [];
    }

    // Check which of the permissions you need are allowed at this time
    List<NotificationPermission> permissionsAllowed =
        await AwesomeNotifications().checkPermissionList(
      channelKey: channelKey,
      permissions: permissionList,
    );

    // If all permissions are allowed, there is nothing to do
    if (permissionsAllowed.length == permissionList.length) {
      return permissionsAllowed;
    }

    // Refresh the permission list with only the disallowed permissions
    List<NotificationPermission> permissionsNeeded =
        permissionList.toSet().difference(permissionsAllowed.toSet()).toList();

    // Check if some of the permissions needed request user's intervention to be enabled
    List<NotificationPermission> lockedPermissions =
        await AwesomeNotifications().shouldShowRationaleToRequest(
      channelKey: channelKey,
      permissions: permissionsNeeded,
    );

    // If there is no permissions depending on user's intervention, so request it directly
    if (lockedPermissions.isEmpty) {
      // Request the permission through native resources
      await AwesomeNotifications().requestPermissionToSendNotifications(
        channelKey: channelKey,
        permissions: permissionsNeeded,
      );

      // After the user come back, check if the permissions has successfully enabled
      permissionsAllowed = await AwesomeNotifications().checkPermissionList(
        channelKey: channelKey,
        permissions: permissionsNeeded,
      );
    } else {
      // Show a rationale to educate the user
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xfffbfbfb),
          title: const Text(
            'Connect24 needs your permission',
            textAlign: TextAlign.center,
            maxLines: 2,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_active,
                size: MediaQuery.of(context).size.height * 0.15,
                color: const Color(0xFF1e3a81),
              ),
              const SizedBox(height: 20),
              Text(
                'To proceed, you need to enable the permissions above${channelKey?.isEmpty ?? true ? '' : ' on channel $channelKey'}:',
                maxLines: 3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 5),
              Text(
                lockedPermissions
                    .join(', ')
                    .replaceAll('NotificationPermission.', ''),
                maxLines: 2,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Deny',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () async {
                // Request the permission through native resources
                await AwesomeNotifications().requestPermissionToSendNotifications(
                  channelKey: channelKey,
                  permissions: lockedPermissions,
                );

                // After the user come back, check if the permissions has successfully enabled
                permissionsAllowed = await AwesomeNotifications().checkPermissionList(
                  channelKey: channelKey,
                  permissions: lockedPermissions,
                );
                Navigator.pop(context);
              },
              child: const Text(
                'Allow',
                style: TextStyle(
                  color: Color(0xFF1e3a81),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }

    // Return the updated list of allowed permissions
    return permissionsAllowed;
  }

  static Future<bool> _requestBasicPermissionToSendNotifications(
    BuildContext context,
  ) async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: const Color(0xfffbfbfb),
          title: const Text(
            'Allow Notifications',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.notifications_outlined,
                size: MediaQuery.of(context).size.height * 0.15,
                color: const Color(0xFF1e3a81),
              ),
              const SizedBox(height: 20),
              const Text(
                'Connect24 would like to send you notifications',
                maxLines: 2,
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                'Don\'t Allow',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
            TextButton(
              onPressed: () async {
                isAllowed = await AwesomeNotifications()
                    .requestPermissionToSendNotifications();
                Navigator.pop(context);
              },
              child: const Text(
                'Allow',
                style: TextStyle(
                  color: Color(0xFF1e3a81),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      );
    }
    return isAllowed;
  }

  /// Check if notifications are allowed
  static Future<bool> isNotificationAllowed() async {
    return await AwesomeNotifications().isNotificationAllowed();
  }
}
