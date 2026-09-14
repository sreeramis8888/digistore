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
        const Text(
          'Gallery',
          style: TextStyle(
            fontFamily: 'Montserrat',
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF111827),
          ),
        ),
        SizedBox(height: screenSize.responsivePadding(12)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
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
                child: Container(
                  margin: EdgeInsets.only(
                    right: index != displayCount - 1
                        ? screenSize.responsivePadding(10)
                        : 0,
                  ),
                  child: Hero(
                    tag: 'gallery_image_${images[index]}_$index',
                    child: SizedBox(
                      width: screenSize.responsivePadding(92),
                      height: screenSize.responsivePadding(82),
                      child: Stack(
                        children: [
                          AdvancedNetworkImage(
                            imageUrl: images[index],
                            fit: BoxFit.cover,
                            borderRadius: BorderRadius.circular(12),
                            width: screenSize.responsivePadding(92),
                            height: screenSize.responsivePadding(82),
                          ),
                          if (isLast)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black.withValues(alpha: 0.55),
                              ),
                              alignment: Alignment.center,
                              child: Material(
                                color: Colors.transparent,
                                child: Text(
                                  '+${images.length - 3} more',
                                  style: const TextStyle(
                                    fontFamily: 'Montserrat',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
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
        ),
      ],
    );
  }
}
