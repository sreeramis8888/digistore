import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../rewards/reward_card.dart';
import '../../../data/models/reward_model.dart';

class RewardsCarousel extends ConsumerWidget {
  final List<RewardModel>? rewards;
  const RewardsCarousel({super.key, this.rewards});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rewards == null || rewards!.isEmpty) return const SizedBox.shrink();
    final screenSize = ref.watch(screenSizeProvider);

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: screenSize.responsivePadding(16),
        vertical: screenSize.responsivePadding(10),
      ),
      child: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE1FDFF), Color(0xFFFFFFFF)],
          ),
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: const Color(0xFFF2F6FF)),
        ),
        padding: EdgeInsets.symmetric(
          vertical: screenSize.responsivePadding(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
              ),
              child: Text(
                'Rewards',
                style: kSmallTitleM.copyWith(color: const Color(0xFF34C759)),
              ),
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
            CarouselSlider.builder(
              itemCount: rewards!.length,
              options: CarouselOptions(
                height: screenSize.responsivePadding(200),
                viewportFraction: 0.45,
                enableInfiniteScroll: false,
                padEnds: false,
              ),
              itemBuilder: (context, index, realIndex) {
                final reward = rewards![index];
                return RewardCard(
                  title: reward.title ?? '',
                  subtitle: reward.description ?? '',
                  points: reward.pointsCost?.toString() ?? '0',
                  imageUrl: reward.image,
                  logoText: reward.category,
                  logoColor: kBlue.withOpacity(0.1),
                  width: screenSize.responsivePadding(145),
                  margin: EdgeInsets.only(
                    left: index == 0
                        ? screenSize.responsivePadding(16)
                        : screenSize.responsivePadding(12),
                    right: index == rewards!.length - 1 ? screenSize.responsivePadding(16) : 0,
                  ),
                );
              },
            ),
            SizedBox(height: screenSize.responsivePadding(16)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenSize.responsivePadding(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenSize.responsivePadding(12),
                      vertical: screenSize.responsivePadding(6),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEDEDED)),
                      borderRadius: BorderRadius.circular(7),
                      color: kWhite,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('See all', style: kSmallTitleSB),
                        const SizedBox(width: 4),
                        const Icon(Icons.chevron_right, size: 16),
                      ],
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
