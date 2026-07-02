import 'package:setgo/src/interfaces/animations/index.dart';
import 'package:setgo/src/interfaces/components/loading_indicator.dart';
import 'package:setgo/src/interfaces/components/shimmers/card_shimmers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/constants/color_constants.dart';
import '../../data/constants/style_constants.dart';
import '../../data/providers/screen_size_provider.dart';
import '../../data/providers/rewards_provider.dart';
import '../components/rewards/reward_card.dart';
import '../components/empty_state.dart';
import '../../data/providers/banners_provider.dart';
import '../components/common/paginated_banner_grid.dart';

class RewardsPage extends ConsumerStatefulWidget {
  const RewardsPage({super.key});

  @override
  ConsumerState<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends ConsumerState<RewardsPage> {
  String? selectedCategory = 'All';
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(rewardsListProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(rewardsListProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = ref.watch(screenSizeProvider);
    final itemWidth = (screenSize.width - screenSize.responsivePadding(48)) / 2;
    final itemHeight = screenSize.responsivePadding(200);
    final aspectRatio = itemWidth / itemHeight;

    final state = ref.watch(rewardsListProvider);
    final bannerFilter = (selectedCategory != null && selectedCategory != 'All')
        ? BannerFilter(category: selectedCategory, page: 'reward')
        : const BannerFilter(page: 'reward');
    final bannersAsync = ref.watch(bannersProvider(bannerFilter));
    final banners = bannersAsync.value ?? [];

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
        child: RefreshIndicator(
          color: kPrimaryColor,
          onRefresh: _onRefresh,
          child: Builder(
            builder: (context) {
              if (state.isLoading && state.rewards.isEmpty) {
                return GridView.builder(
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
                );
              }

              if (state.error != null && state.rewards.isEmpty) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: EmptyState(
                        imagePath: 'assets/png/empty_rewards.png',
                        title: 'Oops!',
                        subtitle: state.error ?? 'Failed to load rewards',
                      ),
                    ),
                  ],
                );
              }

              if (state.rewards.isEmpty) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: const EmptyState(
                        imagePath: 'assets/png/empty_rewards.png',
                        title: 'No rewards available',
                        subtitle:
                            'New rewards are added regularly. Keep earning points to redeem them for exciting gift cards and vouchers!',
                      ),
                    ),
                  ],
                );
              }

              return CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: SizedBox(height: screenSize.responsivePadding(16.0))),
                  ...buildPaginatedGridSliversWithBanners(
                    items: state.rewards,
                    itemBuilder: (context, index, reward) => RewardCard.fromReward(
                      reward,
                    ).fadeScaleUp(delayMilliseconds: (index % 10) * 50),
                    banners: banners,
                    hasMore: state.page < state.pages,
                    screenSize: screenSize,
                    childAspectRatio: aspectRatio,
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.only(
                        top: screenSize.responsivePadding(16),
                        bottom: screenSize.responsivePadding(32),
                      ),
                      child: Center(
                        child: state.isLoadingMore
                            ? const LoadingAnimation()
                            : (state.pages > 1 &&
                                  state.page >= state.pages &&
                                  state.rewards.isNotEmpty)
                            ? Text(
                                'No more rewards',
                                style: kSmallerTitleL.copyWith(
                                  color: kSecondaryTextColor,
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
