import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../main_pages/partner/partner_profile_page.dart';
import '../../../data/providers/partner_provider.dart';
import '../advanced_network_image.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../../animations/index.dart';
import '../../../data/providers/notifications_provider.dart';

class PartnerHomeHeader extends ConsumerWidget {
  final ScreenSizeData screenSize;

  const PartnerHomeHeader({super.key, required this.screenSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final partner = ref.watch(partnerProvider);
    final businessName = partner?.businessDetails?.businessName ?? 'Partners Shop';
    final location = partner?.businessDetails?.address ?? 'Location';
    final logo = partner?.businessInfo?.businessLogo;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        InteractiveFeedbackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PartnerProfilePage(),
              ),
            );
          },
          scaleFactor: 0.98,
          child: Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: kWhite,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AdvancedNetworkImage(
                    imageUrl: logo ?? '',
                    fit: BoxFit.cover,
                  ),
                ),
              ).fadeIn(),
              SizedBox(width: screenSize.responsivePadding(12)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(businessName, style: kSubHeadingSB),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Color(0xFF6B7280),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        location,
                        style: kSmallTitleL.copyWith(
                          color: const Color(0xFF616161),
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        size: 16,
                        color: Color(0xFF6B7280),
                      ),
                    ],
                  ),
                ],
              ).fadeSlideInFromLeft(delayMilliseconds: 100),
            ],
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
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                child: const Icon(Icons.notifications_none, size: 24, color: kBlack),
              ),
              if (ref.watch(notificationsProvider).unreadCount > 0)
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
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
    );
  }
}
