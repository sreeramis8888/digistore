import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/utils/interactive_feedback_button.dart';

/// Home restaurant promo banner — matches the product design mock
/// (cream→sage gradient, left copy + CTA, plate image on the right).
class RestaurantBannerCard extends ConsumerWidget {
  const RestaurantBannerCard({super.key});

  static const _titleColor = Color(0xFF3E1F1A);
  static const _subtitleColor = Color(0xFF757575);
  static const _buttonColor = Color(0xFFCC8E64);
  static const _gradientStart = Color(0xFFF5F2E5);
  static const _gradientEnd = Color(0xFFE7ECCB);

  /// Intrinsic aspect ratio of [assets/png/resturant.png] (181×110).
  static const _imageAspect = 181 / 110;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);
    final countAsync = ref.watch(restaurantShopsCountProvider);

    final shopCountLabel = countAsync.when(
      data: (count) => count <= 0 ? '' : '$count+ shops',
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
      ref.read(selectedIndexProvider.notifier).updateIndex(2);
    }

    final height = screenSize.responsivePadding(130);
    final hPad = screenSize.responsivePadding(20);
    final vPad = screenSize.responsivePadding(16);

    return InteractiveFeedbackButton(
      onPressed: onExplorePressed,
      scaleFactor: 0.98,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_gradientStart, _gradientEnd],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bannerW = constraints.maxWidth;

            // Small plate — close to native 181×110 so it stays sharp.
            final imageH = screenSize.responsivePadding(88);
            final imageW = imageH * _imageAspect;

            return Stack(
              children: [
                Positioned(
                  right: screenSize.responsivePadding(12),
                  bottom: 0,
                  width: imageW,
                  height: imageH,
                  child: Image.asset(
                    'assets/png/resturant.png',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    isAntiAlias: true,
                    gaplessPlayback: true,
                  ),
                ),
                // Left copy + CTA
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      vPad,
                      bannerW * 0.38,
                      vPad,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restaurants',
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: screenSize.responsivePadding(22),
                            fontWeight: FontWeight.w800,
                            color: _titleColor,
                            height: 1.15,
                          ),
                        ),
                        if (shopCountLabel.isNotEmpty) ...[
                          SizedBox(height: screenSize.responsivePadding(4)),
                          Text(
                            shopCountLabel,
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenSize.responsivePadding(14),
                              fontWeight: FontWeight.w500,
                              color: _subtitleColor,
                              height: 1.2,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.responsivePadding(16),
                            vertical: screenSize.responsivePadding(8),
                          ),
                          decoration: BoxDecoration(
                            color: _buttonColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Explore shops',
                            style: TextStyle(
                              fontFamily: 'Poppins',
                              fontSize: screenSize.responsivePadding(13),
                              fontWeight: FontWeight.w700,
                              color: kWhite,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
