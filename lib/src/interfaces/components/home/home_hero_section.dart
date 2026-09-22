import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/models/loyalty_card.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../rewards/loyalty_reward_card.dart';
import 'home_app_bar.dart';

/// Purple gradient hero: profile header, search, and loyalty card.
class HomeHeroSection extends ConsumerWidget {
  final LoyaltyCard? loyaltyCard;
  final TextEditingController searchController;
  final FocusNode searchFocusNode;
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onSearchTap;

  const HomeHeroSection({
    super.key,
    required this.searchController,
    required this.searchFocusNode,
    this.loyaltyCard,
    this.onSearchChanged,
    this.onSearchTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final hPad = screenSize.responsivePadding(16);
    final gap = screenSize.responsivePadding(20);

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [kHeroPurpleStart, kHeroPurpleEnd],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(hPad, 8, hPad, screenSize.responsivePadding(24)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const HomeAppBar(variant: HomeAppBarVariant.hero),
              SizedBox(height: gap),
              _HeroSearchField(
                controller: searchController,
                focusNode: searchFocusNode,
                onChanged: onSearchChanged,
                onTap: onSearchTap,
              ),
              SizedBox(height: gap),
              LoyaltyRewardCard(
                loyaltyCard: loyaltyCard,
                variant: LoyaltyCardVariant.hero,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroSearchField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onTap;

  const _HeroSearchField({
    required this.controller,
    required this.focusNode,
    this.onChanged,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: kWhite,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: kHeroSearchHint, size: 24),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                focusNode: focusNode,
                readOnly: onTap != null,
                enableInteractiveSelection: onTap == null,
                onTap: onTap,
                onTapOutside: (_) => focusNode.unfocus(),
                onChanged: onChanged,
                onSubmitted: onTap == null
                    ? null
                    : (_) => onTap?.call(),
                style: kSmallTitleL.copyWith(color: kBlack),
                decoration: InputDecoration(
                  hintText: 'Search anything',
                  hintStyle: kSmallTitleL.copyWith(color: kHeroSearchHint),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
