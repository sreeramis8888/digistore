import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../models/app_notification_model.dart';
import 'api_provider.dart';
import 'user_provider.dart';
import 'partner_provider.dart';
import 'user_type_provider.dart';

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

  bool _isFetchingUnreadCount = false;
  DateTime? _lastUnreadFetchTime;

  Future<void> fetchNotifications({bool refresh = false, bool syncUnreadCount = false}) async {
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
        if (syncUnreadCount) {
          fetchUnreadCount(force: true);
        }
      } else {
        state = state.copyWith(isLoading: false, error: response.message ?? 'Failed to load notifications');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> fetchUnreadCount({bool force = false}) async {
    if (_isFetchingUnreadCount) return;
    if (!force && _lastUnreadFetchTime != null && DateTime.now().difference(_lastUnreadFetchTime!) < const Duration(seconds: 15)) {
      return;
    }

    _isFetchingUnreadCount = true;
    try {
      final api = ref.read(apiProvider);
      final response = await api.get('/notifications/unread-count');
      if (response.success && response.data != null) {
        final count = response.data!['data']?['count'] ?? 0;
        state = state.copyWith(unreadCount: count);
        _lastUnreadFetchTime = DateTime.now();
      }
    } catch (e) {
      // Ignore
    } finally {
      _isFetchingUnreadCount = false;
    }
  }

  void addNotificationFromPush(dynamic message) {
    int newUnreadCount = state.unreadCount + 1;
    List<AppNotificationModel> updatedNotifications = state.notifications;

    try {
      if (message != null) {
        final data = (message.data is Map) ? message.data as Map<dynamic, dynamic> : {};
        final notification = message.notification;
        final title = notification?.title ?? data['title']?.toString() ?? '';
        final body = notification?.body ?? data['message']?.toString() ?? data['body']?.toString() ?? '';
        final id = data['id']?.toString() ?? data['_id']?.toString() ?? DateTime.now().millisecondsSinceEpoch.toString();

        if (title.isNotEmpty || body.isNotEmpty) {
          final newNotification = AppNotificationModel(
            id: id,
            title: title,
            message: body,
            read: false,
            createdAt: DateTime.now(),
          );
          updatedNotifications = [newNotification, ...state.notifications];
        }
      }
    } catch (e) {
      // Ignore parse error, count still incremented locally
    }

    state = state.copyWith(
      unreadCount: newUnreadCount,
      notifications: updatedNotifications,
    );
  }

  void incrementUnreadCount({int count = 1}) {
    state = state.copyWith(unreadCount: state.unreadCount + count);
  }

  Future<void> markAsRead(String id) async {
    try {
      final api = ref.read(apiProvider);
      final response = await api.patch('/notifications/$id/read', null);
      if (response.success) {
        bool wasUnread = false;
        final updatedList = state.notifications.map((n) {
          if (n.id == id) {
            if (!n.read) wasUnread = true;
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
        final newCount = wasUnread
            ? (state.unreadCount > 0 ? state.unreadCount - 1 : 0)
            : state.unreadCount;
        state = state.copyWith(notifications: updatedList, unreadCount: newCount);
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
        bool wasUnread = false;
        final updatedList = state.notifications.where((n) {
          if (n.id == id && !n.read) {
            wasUnread = true;
          }
          return n.id != id;
        }).toList();
        final newCount = wasUnread
            ? (state.unreadCount > 0 ? state.unreadCount - 1 : 0)
            : state.unreadCount;
        state = state.copyWith(notifications: updatedList, unreadCount: newCount);
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

      if (response.success) {
        final userType = ref.read(userTypeProvider);
        if (userType == UserType.customer) {
          await ref.read(userProvider.notifier).getProfile();
        } else {
          await ref.read(partnerProvider.notifier).getPartnerProfile();
        }
      }

      return response.success;
    } catch (e) {
      return false;
    }
  }
}

final notificationsProvider = StateNotifierProvider<NotificationsNotifier, NotificationsState>((ref) {
  return NotificationsNotifier(ref);
});
