import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/reward_model.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/utils/interactive_feedback_button.dart';
import '../advanced_network_image.dart';
import 'section_title.dart';

/// Home revamp Rewards For You — vertical list (Figma).
class HomeRewardsSection extends ConsumerWidget {
  final List<RewardModel> rewards;
  final int maxItems;

  const HomeRewardsSection({
    super.key,
    required this.rewards,
    this.maxItems = 3,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rewards.isEmpty) return const SizedBox.shrink();

    final screenSize = ref.watch(screenSizeProvider);
    final hPad = screenSize.responsivePadding(16);
    final visible = rewards.take(maxItems).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(
          title: 'Rewards For You',
          revampStyle: true,
        ),
        SizedBox(height: screenSize.responsivePadding(8)),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: hPad),
          child: Column(
            children: [
              for (var i = 0; i < visible.length; i++) ...[
                if (i > 0) SizedBox(height: screenSize.responsivePadding(10)),
                _HomeRewardTile(reward: visible[i]),
              ],
              SizedBox(height: screenSize.responsivePadding(12)),
              InteractiveFeedbackButton(
                onPressed: () =>
                    ref.read(selectedIndexProvider.notifier).updateIndex(3),
                scaleFactor: 0.97,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'See all rewards',
                      style: kSmallTitleM.copyWith(
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward,
                      size: 14,
                      color: Color(0xFF6B7280),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HomeRewardTile extends StatelessWidget {
  final RewardModel reward;

  const _HomeRewardTile({required this.reward});

  Map<String, dynamic> get _detailArgs => {
        'id': reward.id,
        'title': reward.title,
        'subtitle': reward.description,
        'description': reward.description,
        'points': reward.pointsCost?.toString() ?? '0',
        'imageUrl': reward.image,
        'shopName': '',
        'isClaimed': false,
        'value': reward.value,
        'valueType': reward.valueType,
        'category': reward.category,
        'requiredTier': reward.requiredTier,
        'terms': reward.terms,
        'images': reward.images,
        'gallery': reward.images,
        'expiresAt': reward.expiresAt,
      };

  @override
  Widget build(BuildContext context) {
    final title = reward.title ?? '';
    final subtitle = reward.description ?? '';
    final points = reward.pointsCost?.toString() ?? '0';
    final imageUrl = reward.image ??
        (reward.images != null && reward.images!.isNotEmpty
            ? reward.images!.first
            : '');

    return InteractiveFeedbackButton(
      onPressed: () {
        Navigator.of(context).pushNamed('rewardDetail', arguments: _detailArgs);
      },
      scaleFactor: 0.98,
      child: Container(
        height: 84,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: SizedBox(
                width: 60,
                height: 60,
                child: AdvancedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  disableFade: true,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: kSmallTitleB.copyWith(
                      color: const Color(0xFF111827),
                      fontSize: 14,
                      height: 1.2,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (subtitle.isNotEmpty &&
                      subtitle != 'null' &&
                      subtitle != 'nil') ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: kSmallerTitleL.copyWith(
                        color: const Color(0xFF6B7280),
                        fontSize: 11,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: 8),
            InteractiveFeedbackButton(
              onPressed: () {
                Navigator.of(context).pushNamed(
                  'rewardDetail',
                  arguments: _detailArgs,
                );
              },
              scaleFactor: 0.95,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6D0BB2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Get for $points',
                      style: kSmallerTitleEB.copyWith(
                        color: kWhite,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(width: 4),
                    SvgPicture.asset('assets/svg/coin.svg', height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
