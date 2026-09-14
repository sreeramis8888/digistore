import 'package:setgo/src/interfaces/components/loading_indicator.dart';
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
    Future.microtask(() async {
      await ref
          .read(notificationsProvider.notifier)
          .fetchNotifications(refresh: true);
    });
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
    final isEmpty = notificationsState.notifications.isEmpty;
    final isInitialLoading =
        notificationsState.isLoading && isEmpty;

    return Scaffold(
      backgroundColor: isEmpty || isInitialLoading ? kWhite : kBackgroundColor,
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
        title: Text(
          'Notifications',
          style: kSubHeadingM.copyWith(color: kTextColor),
        ),
        centerTitle: false,
        titleSpacing: 0,
        actions: isEmpty
            ? null
            : [
                TextButton(
                  onPressed: () =>
                      ref.read(notificationsProvider.notifier).markAllAsRead(),
                  child: Text(
                    'Mark all as read',
                    style: kSmallTitleB.copyWith(color: kPrimaryColor),
                  ),
                ),
                SizedBox(width: screenSize.responsivePadding(8)),
              ],
      ),
      body: isInitialLoading
          ? const Center(child: LoadingAnimation())
          : isEmpty
          ? _buildEmptyState(context, screenSize)
          : RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: () => ref
                  .read(notificationsProvider.notifier)
                  .fetchNotifications(refresh: true),
              child: ListView.separated(
                controller: _scrollController,
                padding: EdgeInsets.symmetric(
                  vertical: screenSize.responsivePadding(8),
                ),
                itemCount:
                    notificationsState.notifications.length +
                    (notificationsState.hasMore ? 1 : 0),
                separatorBuilder: (context, index) =>
                    SizedBox(height: screenSize.responsivePadding(8)),
                itemBuilder: (context, index) {
                  if (index == notificationsState.notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: LoadingAnimation()),
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
                      description: notification.message,
                      isUnread: !notification.read,
                    ),
                  );
                },
              ),
            ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ScreenSizeData screenSize) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/png/no_notification.png',
            width: screenSize.responsivePadding(200),
            height: screenSize.responsivePadding(200),
          ),
          SizedBox(height: screenSize.responsivePadding(16)),
          Text(
            'No Notifications',
            style: kBodyTitleM,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: screenSize.responsivePadding(8)),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(40),
            ),
            child: Text(
              "You're all caught up! New updates will appear here.",
              style: kSmallTitleR.copyWith(color: kSecondaryTextColor),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: screenSize.responsivePadding(24)),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Back to home',
              style: kBodyTitleM.copyWith(color: kPrimaryColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationItem({
    required ScreenSizeData screenSize,
    required String title,
    required String description,
    bool isUnread = false,
  }) {
    return Container(
      width: double.infinity,
      color: isUnread ? kPrimaryLightColor : kWhite,
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: kBodyTitleB.copyWith(fontSize: 15)),
          SizedBox(height: screenSize.responsivePadding(8)),
          Text(
            description,
            style: kSmallTitleL.copyWith(color: kSecondaryTextColor),
          ),
        ],
      ),
    );
  }
}
