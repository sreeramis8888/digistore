import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

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
      body: ListView(
        padding: EdgeInsets.all(screenSize.responsivePadding(16)),
        children: [
          _buildNotificationItem(
            screenSize: screenSize,
            title: 'Bill Approved 🎉',
            time: '2 mins ago',
            description:
                "Your bill of ₹2,350 is approved. You've earned 235 base points!",
            isUnread: true,
          ),
          _buildDivider(),
          _buildNotificationItem(
            screenSize: screenSize,
            title: "You're Now a Gold Member!",
            time: '2 days ago',
            description: "Congratulations! You've unlocked Gold benefits.",
          ),
          _buildDivider(),
          _buildNotificationItem(
            screenSize: screenSize,
            title: "Tier Progress Reminder",
            time: '2 days ago',
            description: "Earn 450 more points to reach Platinum status.",
          ),
          _buildDivider(),
          _buildNotificationItem(
            screenSize: screenSize,
            title: "You're a Lucky Winner!",
            time: '2 days ago',
            description:
                "Congratulations! You've won an iPhone 15 in the March Mega Lucky Draw. Tap to claim your prize.",
          ),
          _buildDivider(),
          _buildNotificationItem(
            screenSize: screenSize,
            title: "You're Now a Gold Member!",
            time: '2 days ago',
            description: "Congratulations! You've unlocked Gold benefits.",
          ),
        ],
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
}
