import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/transactions_provider.dart';
import '../../components/empty_state.dart';
import '../../components/advanced_network_image.dart';

class ClaimedRewardsPage extends ConsumerWidget {
  const ClaimedRewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final redemptionsAsync = ref.watch(redemptionsProvider());

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: kTextColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('My Claimed Rewards', style: kSubHeadingM.copyWith(color: kTextColor)),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: redemptionsAsync.when(
          data: (paginated) {
            if (paginated.redemptions.isEmpty) {
              return const EmptyState(
                imagePath: 'assets/png/empty_rewards.png',
                title: 'No rewards claimed yet',
                subtitle: 'Claim rewards using points to see them here.',
              );
            }
            return GridView.builder(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: screenSize.responsivePadding(16),
                mainAxisSpacing: screenSize.responsivePadding(16),
                childAspectRatio: 0.85,
              ),
              itemCount: paginated.redemptions.length,
              itemBuilder: (context, index) {
                final redemption = paginated.redemptions[index];
                final offer = redemption.offerId;
                final partner = redemption.partnerId;
                
                return Container(
                  padding: EdgeInsets.all(screenSize.responsivePadding(16)),
                  decoration: BoxDecoration(
                    color: kWhite,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kStrokeColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        offer?.title ?? 'Redeemed Offer',
                        style: kSmallTitleM.copyWith(color: kTextColor, fontSize: 11),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: screenSize.responsivePadding(4)),
                      Text(
                        partner?.businessDetails?.businessName ?? 'Partner Store',
                        style: kSmallerTitleL.copyWith(
                          color: kSecondaryTextColor,
                          fontSize: 9,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const Spacer(),
                      SizedBox(
                        height: screenSize.responsivePadding(60),
                        child: AdvancedNetworkImage(
                          imageUrl: offer?.images?.isNotEmpty == true ? offer!.images!.first : '',
                        ),
                      ),
                      SizedBox(height: screenSize.responsivePadding(8)),
                      if (redemption.otp != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: kPrimaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            'OTP: ${redemption.otp}',
                            style: kSmallTitleB.copyWith(color: kPrimaryColor, fontSize: 10),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, s) => const EmptyState(
            imagePath: 'assets/png/empty_rewards.png',
            title: 'Failed to load rewards',
            subtitle: 'Please try again later.',
          ),
        ),
      ),
    );
  }
}
