import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/notifications_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(notificationsProvider.notifier).fetchNotifications(refresh: true));
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent - 200) {
        ref.read(notificationsProvider.notifier).fetchNotifications();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final notificationsState = ref.watch(notificationsProvider);

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: notificationsState.isLoading && notificationsState.notifications.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : notificationsState.notifications.isEmpty
              ? Center(
                  child: Text(
                    'No notifications yet',
                    style: kSmallTitleL.copyWith(color: kSecondaryTextColor),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: () => ref
                      .read(notificationsProvider.notifier)
                      .fetchNotifications(refresh: true),
                  child: ListView.separated(
                    controller: _scrollController,
                    padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                    itemCount: notificationsState.notifications.length +
                        (notificationsState.hasMore ? 1 : 0),
                    separatorBuilder: (context, index) => _buildDivider(),
                    itemBuilder: (context, index) {
                      if (index == notificationsState.notifications.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      final notification = notificationsState.notifications[index];
                      return GestureDetector(
                        onTap: () {
                          if (!notification.read) {
                            ref
                                .read(notificationsProvider.notifier)
                                .markAsRead(notification.id);
                          }
                        },
                        child: _buildNotificationItem(
                          screenSize: screenSize,
                          title: notification.title,
                          time: _formatTime(notification.createdAt),
                          description: notification.message,
                          isUnread: !notification.read,
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildDivider() {
    return const Divider(color: Color(0xFFF0F0F0), height: 1, thickness: 1);
  }

  Widget _buildNotificationItem({
    required ScreenSizeData screenSize,
    required String title,
    required String time,
    required String description,
    bool isUnread = false,
  }) {
    return Container(
      color: isUnread ? kPrimaryLightColor : kWhite,
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(title, style: kBodyTitleB.copyWith(fontSize: 15)),
              ),
              SizedBox(width: screenSize.responsivePadding(8)),
              Text(
                time,
                style: kSmallTitleR.copyWith(color: const Color(0xFF9E9E9E)),
              ),
            ],
          ),
          SizedBox(height: screenSize.responsivePadding(8)),
          Text(
            description,
            style: kSmallTitleL.copyWith(color: kSecondaryTextColor),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);
    if (difference.inDays > 0) return '${difference.inDays} days ago';
    if (difference.inHours > 0) return '${difference.inHours} hrs ago';
    if (difference.inMinutes > 0) return '${difference.inMinutes} mins ago';
    return 'Just now';
  }
}
