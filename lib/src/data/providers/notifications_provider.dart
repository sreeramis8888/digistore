import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/app_notification_model.dart';
import 'api_provider.dart';

class NotificationsState {
  final List<AppNotificationModel> notifications;
  final int unreadCount;
  final bool isLoading;
  final String? error;
  final int page;
  final bool hasMore;

  NotificationsState({
    this.notifications = const [],
    this.unreadCount = 0,
    this.isLoading = false,
    this.error,
    this.page = 1,
    this.hasMore = true,
  });

  NotificationsState copyWith({
    List<AppNotificationModel>? notifications,
    int? unreadCount,
    bool? isLoading,
    String? error,
    int? page,
    bool? hasMore,
  }) {
    return NotificationsState(
      notifications: notifications ?? this.notifications,
      unreadCount: unreadCount ?? this.unreadCount,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      page: page ?? this.page,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}

class NotificationsNotifier extends StateNotifier<NotificationsState> {
  final Ref ref;

  NotificationsNotifier(this.ref) : super(NotificationsState()) {
    fetchUnreadCount();
  }

  Future<void> fetchNotifications({bool refresh = false}) async {
    if (state.isLoading) return;
    if (refresh) {
      state = state.copyWith(page: 1, hasMore: true, notifications: []);
    }
    if (!state.hasMore) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      final api = ref.read(apiProvider);
      final response = await api.get('/notifications?page=${state.page}&limit=20');

      if (response.success && response.data != null) {
        final List<dynamic> items = response.data!['data'] ?? [];
        final newNotifications = items.map((e) => AppNotificationModel.fromJson(e)).toList();

        state = state.copyWith(
          notifications: [...state.notifications, ...newNotifications],
          page: state.page + 1,
          hasMore: newNotifications.length == 20,
          isLoading: false,
        );
        fetchUnreadCount();
      } else {
        state = state.copyWith(isLoading: false, error: response.message ?? 'Failed to load notifications');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchUnreadCount() async {
    try {
      final api = ref.read(apiProvider);
      final response = await api.get('/notifications/unread-count');
      if (response.success && response.data != null) {
        final count = response.data!['data']?['count'] ?? 0;
        state = state.copyWith(unreadCount: count);
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      final api = ref.read(apiProvider);
      final response = await api.patch('/notifications/$id/read', null);
      if (response.success) {
        final updatedList = state.notifications.map((n) {
          if (n.id == id) {
            return AppNotificationModel(
              id: n.id,
              title: n.title,
              message: n.message,
              read: true,
              createdAt: n.createdAt,
            );
          }
          return n;
        }).toList();
        state = state.copyWith(notifications: updatedList);
        fetchUnreadCount();
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> markAllAsRead() async {
    try {
      final api = ref.read(apiProvider);
      final response = await api.patch('/notifications/read-all', null);
      if (response.success) {
        final updatedList = state.notifications.map((n) {
          return AppNotificationModel(
            id: n.id,
            title: n.title,
            message: n.message,
            read: true,
            createdAt: n.createdAt,
          );
        }).toList();
        state = state.copyWith(notifications: updatedList, unreadCount: 0);
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<void> removeNotification(String id) async {
    try {
      final api = ref.read(apiProvider);
      final response = await api.delete('/notifications/$id');
      if (response.success) {
        final updatedList = state.notifications.where((n) => n.id != id).toList();
        state = state.copyWith(notifications: updatedList);
        fetchUnreadCount();
      }
    } catch (e) {
      // Ignore
    }
  }

  Future<bool> registerDeviceToken(String fcmToken) async {
    try {
      final api = ref.read(apiProvider);
      final response = await api.put('/notifications/device-token', {
        'fcmToken': fcmToken,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'appVersion': '1.0.0',
      });
      return response.success;
    } catch (e) {
      return false;
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref);
});
