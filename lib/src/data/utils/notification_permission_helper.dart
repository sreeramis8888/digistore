import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/material.dart';

class NotificationPermissionHelper {
  /// Request all necessary notification permissions
  static Future<bool> requestAllPermissions(BuildContext context) async {
    final permissions = await requestUserPermissions(
      context,
      channelKey: 'channel_setgo',
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
        builder: (context) => _ModernPermissionDialog(
          title: 'Setgo needs your permission',
          message: 'To proceed, please enable the following permissions so you don\'t miss out on important updates.',
          permissionList: lockedPermissions
              .join(', ')
              .replaceAll('NotificationPermission.', ''),
          onAllow: () async {
            await AwesomeNotifications().requestPermissionToSendNotifications(
              channelKey: channelKey,
              permissions: lockedPermissions,
            );
            permissionsAllowed = await AwesomeNotifications().checkPermissionList(
              channelKey: channelKey,
              permissions: lockedPermissions,
            );
            if (context.mounted) Navigator.pop(context);
          },
          onDeny: () => Navigator.pop(context),
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
        builder: (context) => _ModernPermissionDialog(
          title: 'Allow Notifications',
          message: 'Setgo would like to send you notifications for exclusive offers, deals, and updates.',
          onAllow: () async {
            isAllowed = await AwesomeNotifications()
                .requestPermissionToSendNotifications();
            if (context.mounted) Navigator.pop(context);
          },
          onDeny: () => Navigator.pop(context),
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

class _ModernPermissionDialog extends StatelessWidget {
  final String title;
  final String message;
  final String? permissionList;
  final VoidCallback onAllow;
  final VoidCallback onDeny;

  const _ModernPermissionDialog({
    required this.title,
    required this.message,
    this.permissionList,
    required this.onAllow,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 10,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1e3a81).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.notifications_active_rounded,
                color: Color(0xFF1e3a81),
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF111827),
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF6B7280),
                height: 1.4,
              ),
            ),
            if (permissionList != null && permissionList!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  permissionList!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF4B5563),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: onDeny,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      foregroundColor: const Color(0xFF6B7280),
                    ),
                    child: const Text(
                      'Not Now',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: onAllow,
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: const Color(0xFF1e3a81),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Allow',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
