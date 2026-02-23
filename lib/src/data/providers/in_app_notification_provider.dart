import 'dart:ui';
import 'package:flutter_riverpod/legacy.dart';

/// Provider to track if the app is in foreground
/// This helps determine whether to show in-app notifications or system notifications
final appLifecycleProvider = StateProvider<AppLifecycleState>((ref) {
  return AppLifecycleState.resumed;
});

/// Model for in-app notification data
class InAppNotificationData {
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime timestamp;
  final Map<String, dynamic>? payload;

  InAppNotificationData({
    required this.title,
    required this.message,
    this.imageUrl,
    DateTime? timestamp,
    this.payload,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// Provider to manage in-app notification queue
class InAppNotificationNotifier extends StateNotifier<List<InAppNotificationData>> {
  InAppNotificationNotifier() : super([]);

  void addNotification(InAppNotificationData notification) {
    state = [...state, notification];
  }

  void removeNotification(InAppNotificationData notification) {
    state = state.where((n) => n != notification).toList();
  }

  void clearAll() {
    state = [];
  }
}

final inAppNotificationProvider =
    StateNotifierProvider<InAppNotificationNotifier, List<InAppNotificationData>>(
  (ref) => InAppNotificationNotifier(),
);
