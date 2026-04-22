import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../main_pages/home_pages/profile_page.dart';
import '../../main_pages/partner/partner_profile_page.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../animations/index.dart';
import '../../../data/providers/notifications_provider.dart';

class HomeAppBar extends ConsumerWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final user = ref.watch(userProvider);
    final name = (user?.name != null && user!.name!.isNotEmpty)
        ? user.name!
        : 'Guest User';
    final initial = name.isNotEmpty ? name[0].toUpperCase() : 'G';
    final locationName = (user?.location?.localBody != null &&
            user!.location!.localBody!.isNotEmpty)
        ? user.location!.localBody!.split(' ').first
        : (user?.location?.district != null &&
                user!.location!.district!.isNotEmpty)
            ? user.location!.district!.split(' ').first
            : 'Unspecified Location';
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: InteractiveFeedbackButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GlobalVariables.isPartner
                        ? const PartnerProfilePage()
                        : const ProfilePage(),
                  ),
                );
              },
              scaleFactor: 0.98,
              child: Row(
                children: [
                  Container(
                    width: screenSize.responsivePadding(50),
                    height: screenSize.responsivePadding(50),
                    decoration: BoxDecoration(
                      color: kSecondaryColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      initial,
                      style: kLargeTitleM.copyWith(color: kWhite),
                    ),
                  ).fadeIn(),
                  SizedBox(width: screenSize.responsivePadding(12)),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name, style: kSubHeadingM),
                        SizedBox(height: screenSize.responsivePadding(4)),
                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              color: kSecondaryTextColor,
                              size: 16,
                            ),
                            SizedBox(width: screenSize.responsivePadding(4)),
                            Text(
                              locationName,
                              style: kBodyTitleL.copyWith(
                                color: kSecondaryTextColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ).fadeSlideInFromLeft(delayMilliseconds: 100),
                  ),
                ],
              ),
            ),
          ),
          InteractiveFeedbackButton(
            onPressed: () {
              Navigator.pushNamed(context, 'notifications');
            },
            scaleFactor: 1.1,
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.all(screenSize.responsivePadding(10)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: kBorder),
                  ),
                  child: SvgPicture.asset('assets/svg/bell.svg'),
                ),
                if (ref.watch(notificationsProvider).unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(5),
                      decoration: const BoxDecoration(
                        color: kRed,
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        ref.watch(notificationsProvider).unreadCount.toString(),
                        style: const TextStyle(
                          color: kWhite,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ).fadeIn(delayMilliseconds: 200),
        ],
      ),
    );
  }
}
