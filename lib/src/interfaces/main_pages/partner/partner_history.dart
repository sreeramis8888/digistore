import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../components/partner/partner_overview_cards.dart';
import '../../components/partner/partner_redemption_list.dart';

class PartnerHistoryPage extends ConsumerWidget {
  const PartnerHistoryPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    return Scaffold(
      backgroundColor: kWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: screenSize.responsivePadding(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  'History',
                  style: kBodyTitleM.copyWith(color: const Color(0xFF373737)),
                ),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  "Today's Overview",
                  style: kSmallTitleB.copyWith(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(16)),
                PartnerOverviewCards(screenSize: screenSize),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  'Today',
                  style: kSmallTitleB.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(12)),
                PartnerRedemptionList(screenSize: screenSize, count: 3),
                SizedBox(height: screenSize.responsivePadding(24)),
                Text(
                  'Yesterday',
                  style: kSmallTitleB.copyWith(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: screenSize.responsivePadding(12)),
                PartnerRedemptionList(screenSize: screenSize, count: 3),
                SizedBox(height: screenSize.responsivePadding(40)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
