import 'package:digistore/src/interfaces/components/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/rewards_provider.dart';
import '../../components/empty_state.dart';
import '../../components/rewards/reward_card.dart';

class ClaimedRewardsPage extends ConsumerWidget {
  const ClaimedRewardsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final claimedRewardsAsync = ref.watch(claimedRewardsProvider());

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: kTextColor,
            size: 20,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'My Claimed Rewards',
          style: kSubHeadingM.copyWith(color: kTextColor),
        ),
        centerTitle: false,
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: claimedRewardsAsync.when(
          data: (paginated) {
            if (paginated.rewards.isEmpty) {
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
              itemCount: paginated.rewards.length,
              itemBuilder: (context, index) {
                final claimed = paginated.rewards[index];
                return RewardCard.fromClaimedReward(claimed);
              },
            );
          },
          loading: () => const Center(child: LoadingAnimation()),
          error: (e, s) => const EmptyState(
            imagePath: 'assets/png/empty_rewards.png',
            title: 'No vouchers claimed',
            subtitle: 'Please claim vouchers to see them here.',
          ),
        ),
      ),
    );
  }
}
