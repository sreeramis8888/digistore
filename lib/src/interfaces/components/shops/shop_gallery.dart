import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/constants/color_constants.dart';
import '../../../../src/data/constants/style_constants.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../advanced_network_image.dart';
import '../full_screen_gallery.dart';

class ShopGallery extends ConsumerWidget {
  final List<String> images;

  const ShopGallery({super.key, required this.images});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (images.isEmpty) return const SizedBox();

    final screenSize = ref.watch(screenSizeProvider);
    final displayCount = images.length > 4 ? 4 : images.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Gallery', style: kBodyTitleM),
        SizedBox(height: screenSize.responsivePadding(12)),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: List.generate(displayCount, (index) {
            final isLast = index == 3 && images.length > 4;

            return GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    opaque: false,
                    pageBuilder: (context, animation, secondaryAnimation) {
                      return FullScreenGallery(
                        images: images,
                        initialIndex: index,
                      );
                    },
                    transitionsBuilder: (context, animation, secondaryAnimation, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                );
              },
              child: Padding(
                padding: EdgeInsets.only(
                  right: index != displayCount - 1
                      ? screenSize.responsivePadding(8)
                      : 0,
                ),
                child: Hero(
                  tag: 'gallery_image_${images[index]}_$index',
                  child: SizedBox(
                    width: screenSize.responsivePadding(75),
                    height: screenSize.responsivePadding(75),
                    child: Stack(
                      children: [
                        AdvancedNetworkImage(
                          imageUrl: images[index],
                          fit: BoxFit.cover,
                          borderRadius: BorderRadius.circular(8),
                          width: screenSize.responsivePadding(75),
                          height: screenSize.responsivePadding(75),
                        ),
                        if (isLast)
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: Colors.black.withValues(alpha: 0.5),
                            ),
                            alignment: Alignment.center,
                            child: Material(
                              color: Colors.transparent,
                              child: Text(
                                '+${images.length - 3} more',
                                style: kSmallTitleSB.copyWith(color: kWhite),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}
