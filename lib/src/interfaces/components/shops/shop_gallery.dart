import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../src/data/models/business_info.dart';
import '../../../../src/data/providers/screen_size_provider.dart';
import '../advanced_network_image.dart';
import '../full_screen_gallery.dart';

class ShopGallery extends ConsumerWidget {
  final List<BusinessMediaItem> media;

  const ShopGallery({super.key, required this.media});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (media.isEmpty) return const SizedBox();

    final screenSize = ref.watch(screenSizeProvider);
    final displayCount = media.length > 4 ? 4 : media.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gallery',
          style: TextStyle(
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
              final item = media[index];
              final isLast = index == 3 && media.length > 4;
              final thumb = item.isVideo
                  ? (item.thumbnailUrl?.isNotEmpty == true
                        ? item.thumbnailUrl!
                        : item.url)
                  : item.url;

              return GestureDetector(
                onTap: () {
                  Navigator.of(context).push(
                    PageRouteBuilder(
                      opaque: false,
                      pageBuilder: (context, animation, secondaryAnimation) {
                        return FullScreenGallery.media(
                          media: media,
                          initialIndex: index,
                        );
                      },
                      transitionsBuilder:
                          (context, animation, secondaryAnimation, child) {
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
                    tag: 'gallery_image_${item.url}_$index',
                    child: SizedBox(
                      width: screenSize.responsivePadding(92),
                      height: screenSize.responsivePadding(82),
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          if (item.isVideo &&
                              (item.thumbnailUrl == null ||
                                  item.thumbnailUrl!.isEmpty))
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF111827),
                                borderRadius: BorderRadius.circular(12),
                              ),
                            )
                          else
                            AdvancedNetworkImage(
                              imageUrl: thumb,
                              fit: BoxFit.cover,
                              borderRadius: BorderRadius.circular(12),
                              width: screenSize.responsivePadding(92),
                              height: screenSize.responsivePadding(82),
                            ),
                          if (item.isVideo)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                color: Colors.black.withValues(alpha: 0.28),
                              ),
                              alignment: Alignment.center,
                              child: const Icon(
                                Icons.play_circle_fill_rounded,
                                color: Colors.white,
                                size: 28,
                              ),
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
                                  '+${media.length - 3} more',
                                  style: const TextStyle(
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
