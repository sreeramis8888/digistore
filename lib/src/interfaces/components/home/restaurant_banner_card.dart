import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/shops_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/utils/global_variables.dart';
import '../../../data/utils/interactive_feedback_button.dart';

/// Home restaurant promo banner — matches the product design mock
/// (cream→sage gradient, left copy + CTA, cropped plate on the right).
class RestaurantBannerCard extends ConsumerWidget {
  const RestaurantBannerCard({super.key});

  static const _titleColor = Color(0xFF3E1F1A);
  static const _subtitleColor = Color(0xFF757575);
  static const _buttonColor = Color(0xFFCC8E64);
  static const _gradientStart = Color(0xFFF5F2E5);
  static const _gradientEnd = Color(0xFFE7ECCB);

  /// Intrinsic aspect ratio of [assets/png/resturant.png].
  static const _imageAspect = 181 / 110;

  /// In the asset, plate content starts ~12% from the left.
  static const _plateLeftInAsset = 0.12;

  /// In the design mock, the plate's left edge sits at ~57% of banner width.
  static const _plateLeftInBanner = 0.572;

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
            final bannerH = constraints.maxHeight;

            // Plate fills banner height with a slight vertical overflow (design).
            final imageH = bannerH * 1.12;
            final imageW = imageH * _imageAspect;

            // Place so the plate's left edge lands at the design ratio.
            final imageLeft =
                bannerW * _plateLeftInBanner - imageW * _plateLeftInAsset;
            final imageTop = (bannerH - imageH) / 2;

            return Stack(
              children: [
                Positioned(
                  left: imageLeft,
                  top: imageTop,
                  width: imageW,
                  height: imageH,
                  child: Image.asset(
                    'assets/png/resturant.png',
                    fit: BoxFit.fill,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                // Left copy + CTA — keep clear of the plate (~57% mark).
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      vPad,
                      bannerW * 0.42,
                      vPad,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Restaurants',
                          style: GoogleFonts.urbanist(
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
                            style: GoogleFonts.urbanist(
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
                            style: GoogleFonts.urbanist(
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
