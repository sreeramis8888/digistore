import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../data/constants/color_constants.dart';
import '../../../data/providers/screen_size_provider.dart';
import '../../../data/providers/services_provider.dart';
import '../../../data/router/nav_router.dart';
import '../../../data/utils/interactive_feedback_button.dart';

/// Home services promo banner — soft cyan gradient, left copy + CTA,
/// [assets/png/servicescard.png] on the right with floating service icons.
class ServicesBannerCard extends ConsumerWidget {
  const ServicesBannerCard({super.key});

  static const _titleColor = Color(0xFF2D0C03);
  static const _subtitleColor = Color(0xFF647076);
  static const _buttonColor = Color(0xFF006070);
  static const _gradientStart = Color(0xFFB4EFFD);
  static const _gradientMid = Color(0xFFC8E8F5);
  static const _gradientEnd = Color(0xFFDAE3EC);
  static const _iconRing = Color(0xFF9FD9E8);
  static const _iconColor = Color(0xFF5BA8BC);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenSize = ref.watch(screenSizeProvider);

    void onExplorePressed() {
      ref.read(selectedProductsTabProvider.notifier).state = 1; // Services
      ref.read(selectedIndexProvider.notifier).updateIndex(4);
    }

    final height = screenSize.responsivePadding(152);
    final hPad = screenSize.responsivePadding(18);
    final vPad = screenSize.responsivePadding(16);

    return InteractiveFeedbackButton(
      onPressed: onExplorePressed,
      scaleFactor: 0.98,
      child: Container(
        width: double.infinity,
        height: height,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [_gradientStart, _gradientMid, _gradientEnd],
            stops: [0.0, 0.4, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(24),
        ),
        clipBehavior: Clip.antiAlias,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final bannerW = constraints.maxWidth;
            final bannerH = constraints.maxHeight;
            // Design: photo starts ~55% from left, flush right/bottom,
            // with cyan washing over the top-left of the image.
            final imageW = bannerW * 0.55;
            final imageH = bannerH * 0.88;
            final iconSize = screenSize.responsivePadding(28);

            return Stack(
              children: [
                // Scene photo — pushed left, feathered into the cyan field.
                Positioned(
                  right: 0,
                  bottom: 0,
                  width: imageW,
                  height: imageH,
                  child: ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        screenSize.responsivePadding(36),
                      ),
                      bottomLeft: Radius.circular(
                        screenSize.responsivePadding(8),
                      ),
                    ),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.asset(
                          'assets/png/servicescard.png',
                          fit: BoxFit.cover,
                          alignment: const Alignment(0.15, 0.55),
                          filterQuality: FilterQuality.high,
                        ),
                        // Soft left fade — cyan washes into the photo.
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [
                                _gradientStart,
                                Color(0x99B4EFFD),
                                Color(0x00B4EFFD),
                              ],
                              stops: [0.0, 0.18, 0.42],
                            ),
                          ),
                        ),
                        // Soft top fade — sky cyan covers the upper photo edge.
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                _gradientStart,
                                Color(0xCCB4EFFD),
                                Color(0x00C8E8F5),
                              ],
                              stops: [0.0, 0.22, 0.55],
                            ),
                          ),
                        ),
                        // Diagonal wash (top-left) matching the card gradient.
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color(0xE6B4EFFD),
                                Color(0x66C8E8F5),
                                Color(0x00DAE3EC),
                              ],
                              stops: [0.0, 0.35, 0.7],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Floating service icons above the photo (design mock).
                Positioned(
                  right: screenSize.responsivePadding(22),
                  top: screenSize.responsivePadding(12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _FloatingServiceIcon(
                        icon: Icons.inventory_2_outlined,
                        size: iconSize,
                      ),
                      SizedBox(width: screenSize.responsivePadding(8)),
                      _FloatingServiceIcon(
                        icon: Icons.auto_awesome_rounded,
                        size: iconSize,
                      ),
                      SizedBox(width: screenSize.responsivePadding(8)),
                      _FloatingServiceIcon(
                        icon: Icons.work_outline_rounded,
                        size: iconSize,
                      ),
                    ],
                  ),
                ),

                // Left copy + CTA
                Positioned.fill(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      hPad,
                      vPad,
                      bannerW * 0.40,
                      vPad,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Book trusted\nservices fast',
                          style: GoogleFonts.urbanist(
                            fontSize: screenSize.responsivePadding(20),
                            fontWeight: FontWeight.w800,
                            color: _titleColor,
                            height: 1.15,
                          ),
                        ),
                        SizedBox(height: screenSize.responsivePadding(6)),
                        Text(
                          'Home cleaning, beauty, errands, and more - all in one place.',
                          style: GoogleFonts.urbanist(
                            fontSize: screenSize.responsivePadding(11),
                            fontWeight: FontWeight.w500,
                            color: _subtitleColor,
                            height: 1.35,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const Spacer(),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: screenSize.responsivePadding(14),
                            vertical: screenSize.responsivePadding(8),
                          ),
                          decoration: BoxDecoration(
                            color: _buttonColor,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            'Explore services',
                            style: GoogleFonts.urbanist(
                              fontSize: screenSize.responsivePadding(12),
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

class _FloatingServiceIcon extends StatelessWidget {
  const _FloatingServiceIcon({
    required this.icon,
    required this.size,
  });

  final IconData icon;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withValues(alpha: 0.55),
        border: Border.all(
          color: ServicesBannerCard._iconRing.withValues(alpha: 0.9),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: ServicesBannerCard._iconRing.withValues(alpha: 0.35),
            blurRadius: 8,
            spreadRadius: 0.5,
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Icon(
        icon,
        size: size * 0.48,
        color: ServicesBannerCard._iconColor,
      ),
    );
  }
}
