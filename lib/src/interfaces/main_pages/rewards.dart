import 'package:digistore/src/interfaces/animations/index.dart';
import 'package:digistore/src/interfaces/components/shimmers/card_shimmers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../../data/providers/rewards_provider.dart';
import '../components/rewards/reward_card.dart';

import '../components/empty_state.dart';

class RewardsPage extends ConsumerStatefulWidget {
  const RewardsPage({super.key});

  @override
  ConsumerState<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends ConsumerState<RewardsPage> {
  String? selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(200);
    final aspectRatio = itemWidth / itemHeight;

    final rewardsAsync = ref.watch(rewardsProvider(category: selectedCategory));

    return Scaffold(
      backgroundColor: kWhite,
      appBar: AppBar(
        title: Text(
          'Rewards',
          style: kSubHeadingM.copyWith(color: const Color(0xFF373737)),
        ),
        backgroundColor: kWhite,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: SafeArea(
        child: rewardsAsync.when(
          data: (paginated) {
            if (paginated.rewards.isEmpty) {
              return const EmptyState(
                imagePath: 'assets/png/empty_rewards.png',
                title: 'No rewards available',
                subtitle:
                    'New rewards are added regularly. Keep earning points to redeem them for exciting gift cards and vouchers!',
              );
            }
            return GridView.builder(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: screenSize.responsivePadding(16),
                crossAxisSpacing: screenSize.responsivePadding(16),
                childAspectRatio: aspectRatio,
              ),
              itemCount: paginated.rewards.length,
              itemBuilder: (context, index) {
                final reward = paginated.rewards[index];
                return RewardCard.fromReward(reward).fadeScaleUp(
                  delayMilliseconds: index * 50,
                );
              },
            );
          },
          loading: () => GridView.builder(
            padding: EdgeInsets.all(screenSize.responsivePadding(16)),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: screenSize.responsivePadding(16),
              crossAxisSpacing: screenSize.responsivePadding(16),
              childAspectRatio: aspectRatio,
            ),
            itemCount: 6,
            itemBuilder: (context, index) =>
                CardShimmers.rewardCardShimmer(screenSize),
          ),
          error: (e, s) => const EmptyState(
            imagePath: 'assets/png/empty_rewards.png',
            title: 'No rewards available',
            subtitle:
                'New rewards are added regularly. Keep earning points to redeem them for exciting gift cards and vouchers!',
          ),
        ),
      ),
    );
  }
}
