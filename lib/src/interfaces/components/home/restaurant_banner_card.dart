import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/constants/style_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/utils/interactive_feedback_button.dart';

class RestaurantBannerCard extends ConsumerWidget {
  const RestaurantBannerCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final countAsync = ref.watch(restaurantShopsCountProvider);

    final restaurantShopsCount = countAsync.when(
      data: (count) => count == 1 ? '1 shop' : '$count shops',
      loading: () => '',
      error: (_, _) => '',
    );

    void onExplorePressed() {
      const targetCategory = 'Restaurants';
      ref.read(selectedShopsCategoryProvider.notifier).state = targetCategory;

      if (!GlobalVariables.isGuest) {
        ref.read(shopsProvider.notifier).updateCategory(targetCategory);
      }
      ref.read(allShopsProvider.notifier).updateCategory(targetCategory);

      // Navigate to Shops tab (Index 2 in Navbar)
      ref.read(selectedIndexProvider.notifier).updateIndex(2);
    }

    return Container(
      width: double.infinity,
      height: screenSize.responsivePadding(130),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF5F2E5), Color(0xFFE7ECCB)],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // Food Dish Illustration Image aligned to right side
          Positioned(
            right: 0,
            top: 0,
            bottom: 0,
            width: screenSize.responsivePadding(180),
            child: Image.asset(
              'assets/png/restaurantcard.png',
              fit: BoxFit.cover,
              alignment: Alignment.centerRight,
            ),
          ),
          // Left Content Overlay (Text and Button)
          Positioned.fill(
            child: Padding(
              padding: EdgeInsets.all(screenSize.responsivePadding(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Restaurants',
                        style: kHeadTitleEB.copyWith(
                          color: const Color(0xFF2C1810),
                          fontSize: 20,
                        ),
                      ),
                      if (restaurantShopsCount.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          restaurantShopsCount,
                          style: GoogleFonts.montserrat(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ],
                  ),
                  InteractiveFeedbackButton(
                    onPressed: onExplorePressed,
                    scaleFactor: 0.95,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenSize.responsivePadding(18),
                        vertical: screenSize.responsivePadding(8),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFFD68A57,
                        ), // Terracotta brown/amber color from design
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(
                              0xFFD68A57,
                            ).withValues(alpha: 0.3),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        'Explore shops',
                        style: GoogleFonts.montserrat(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: kWhite,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
