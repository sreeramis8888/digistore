import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/user_provider.dart';
import '../../../data/providers/home_provider.dart';
import '../../../data/models/home_data_model.dart';

class WalletHeader extends ConsumerWidget {
  const WalletHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final user = ref.watch(userProvider);
    final homeDataState = ref.watch(homeDataProvider).value;

    final name = (user?.name != null && user!.name!.isNotEmpty)
        ? user.name!
        : 'Guest User';

    int points = user?.pointsBalance ?? 0;
    String? tierName = user?.currentTier?.name;

    if (homeDataState is CustomerHomeState) {
      final loyaltyCard = homeDataState.data.loyaltyCard;
      if (loyaltyCard != null) {
        if (loyaltyCard.pointsBalance != null) {
          points = loyaltyCard.pointsBalance!;
        }
        if (loyaltyCard.tier != null && loyaltyCard.tier!.isNotEmpty) {
          tierName = loyaltyCard.tier;
        }
      }
    }

    return Padding(
      padding: EdgeInsets.fromLTRB(
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(16),
        screenSize.responsivePadding(8),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(screenSize.responsivePadding(16)),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [kHeroPurpleStart, kHeroPurpleEnd],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: kBodyTitleB.copyWith(
                      color: kWhite,
                      fontSize: 18,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: screenSize.responsivePadding(4)),
                  Text(
                    tierName != null && tierName.isNotEmpty
                        ? '$tierName · Available points'
                        : 'Available points',
                    style: kSmallerTitleL.copyWith(
                      color: kWhite.withValues(alpha: 0.85),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(12),
                vertical: screenSize.responsivePadding(10),
              ),
              decoration: BoxDecoration(
                color: kWhite.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: kWhite.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SvgPicture.asset(
                    'assets/svg/coin.svg',
                    width: 20,
                    height: 20,
                  ),
                  SizedBox(width: screenSize.responsivePadding(8)),
                  Text(
                    '$points',
                    style: kSubHeadingB.copyWith(
                      color: kWhite,
                      fontSize: 20,
                      height: 1,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
